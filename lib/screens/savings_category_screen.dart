import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'edit_expense_screen.dart';
import 'add_expenses_screen.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';

class SavingsCategoryScreen extends StatefulWidget {
  const SavingsCategoryScreen({super.key});

  @override
  State<SavingsCategoryScreen> createState() => _SavingsCategoryScreenState();
}

class _SavingsCategoryScreenState extends State<SavingsCategoryScreen> {
  // Established color palette
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kCategoryColor = Color(0xFF81C9CC);
  static const kPurpleButton = Color(0xFF393078);
  static const kDeleteRed = Color(0xFFFF8585);
  static const kEditCyan = Color(0xFF44DDFF);

  List<TransactionEntry> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  Future<void> _loadTransactions() async {
    final auth = AuthScope.of(context);
    final email = auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      setState(() {
        _transactions = [];
        _isLoading = false;
      });
      return;
    }

    final list = await TransactionService.instance.loadForUser(email);
    final savingsOnly = list.where((entry) => entry.category == 'Savings').toList();
    savingsOnly.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (!mounted) {
      return;
    }
    setState(() {
      _transactions = savingsOnly;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 3, onTap: (index) {}),
      body: Stack(
        children: [
          // 1. Consistent Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kDeepBlue, kTealGreen],
              ),
            ),
          ),

          // 2. Animated Background Bubbles
          _buildAnimatedBubble(left: -329, top: -446, size: 700),
          _buildAnimatedBubble(left: -225, top: -342, size: 492),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                
                // 3. Curved White Body
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: kFormBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopGoalCard(),
                          const SizedBox(height: 30),
                          _buildProgressBar(),
                          const SizedBox(height: 15),
                          _buildStatusNotice(),
                          const SizedBox(height: 40),
                          _buildTransactionList(),
                          const SizedBox(height: 30),
                          _buildAddSavingsButton(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TOP GOAL SECTION ---
  Widget _buildTopGoalCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatLabel(Icons.ads_click, "Goal"),
            Text("Rs 1,962.93", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kDeepBlue)),
            const SizedBox(height: 20),
            _buildStatLabel(Icons.outbox_rounded, "Amount Saved"),
            Text("Rs 653.31", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kTealGreen)),
          ],
        ),
        _buildCircularProgressIcon(),
      ],
    );
  }

  Widget _buildCircularProgressIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130, height: 130,
          decoration: BoxDecoration(color: kCategoryColor, borderRadius: BorderRadius.circular(35)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 45),
              const SizedBox(height: 5),
              Text("Travel", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
        SizedBox(
          width: 105, height: 105,
          child: CircularProgressIndicator(
            value: 0.4,
            strokeWidth: 8,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(kDeepBlue),
          ),
        ),
      ],
    );
  }

  // --- TRANSACTION LIST WITH DISMISSIBLE SWIPE ACTIONS ---
  Widget _buildTransactionList() {
    if (_isLoading) {
      return const SizedBox(height: 80);
    }
    if (_transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text("No transactions to show", style: GoogleFonts.poppins(color: Colors.grey)),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Savings", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: kDeepBlue)),
            const Icon(Icons.calendar_month, color: kDeepBlue),
          ],
        ),
        const SizedBox(height: 20),
        ..._transactions.map((entry) => _buildSwipeableTransaction(entry)),
      ],
    );
  }

  Widget _buildSwipeableTransaction(TransactionEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key(entry.id),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Swipe Right -> Trigger Delete
            final confirmed = await _showDeleteDialog(entry.title);
            if (confirmed != true) {
              return false;
            }
            final auth = AuthScope.of(context);
            final email = auth.currentUser?.email;
            if (email == null || email.isEmpty) {
              return false;
            }
            await TransactionService.instance.deleteForUser(email, entry.id);
            await _loadTransactions();
            return false;
          } else if (direction == DismissDirection.endToStart) {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditExpenseScreen(entry: entry)),
            );
            if (updated == true) {
              await _loadTransactions();
            }
            return false;
          }
        },
        // Swipe Right Background (Delete)
        background: _buildSwipeBackground(
          color: kDeleteRed,
          icon: Icons.delete_outline_rounded,
          alignment: Alignment.centerLeft,
        ),
        // Swipe Left Background (Edit)
        secondaryBackground: _buildSwipeBackground(
          color: kEditCyan,
          icon: Icons.edit_note_rounded,
          alignment: Alignment.centerRight,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kDeepBlue.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: kCategoryColor.withOpacity(0.6), shape: BoxShape.circle),
                child: const Icon(Icons.savings, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark)),
                    Text(formatTransactionDateTime(entry.dateTime), style: GoogleFonts.poppins(fontSize: 10, color: kDeepBlue.withOpacity(0.6), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  'Savings',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                formatTransactionAmount(entry.amount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: entry.amount >= 0 ? kTealGreen : const Color(0xFF3EC5BE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE UI ELEMENTS ---

  Widget _buildSwipeBackground({required Color color, required IconData icon, required Alignment alignment}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Future<bool?> _showDeleteDialog(String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text("Delete Transaction", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: kDeepBlue, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text("Are you sure you want to delete '$title'?", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: kTextDark.withOpacity(0.7), fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: GoogleFonts.poppins(color: kPurpleButton))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
          Text("Travel", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      children: [
        Container(height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
        Container(
          height: 30, width: 140, // 40% width approx
          decoration: BoxDecoration(color: kTextDark, borderRadius: BorderRadius.circular(15)),
          alignment: Alignment.center,
          child: Text("40%", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Positioned(
          right: 15, top: 5,
          child: Text("Rs 1,962.93", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
        ),
      ],
    );
  }

  Widget _buildStatusNotice() {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 18, color: kDeepBlue),
        const SizedBox(width: 8),
        Text("40% Of Your Income has been used!", style: GoogleFonts.poppins(fontSize: 13, color: kDeepBlue.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildAddSavingsButton() {
    return GestureDetector(
      onTap: () async {
        final added = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddExpensesScreen()),
        );
        if (added == true) {
          await _loadTransactions();
        }
      },
      child: Container(
        width: double.infinity, height: 60,
        decoration: BoxDecoration(
          color: kPurpleButton,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: kPurpleButton.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: Text("Add Savings", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildStatLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kDeepBlue.withOpacity(0.5)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: kDeepBlue.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size}) {
    return Positioned(
      left: left, top: top,
      child: Opacity(
        opacity: 0.15,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}