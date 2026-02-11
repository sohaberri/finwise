import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'edit_expense_screen.dart';
import 'add_expenses_screen.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key, required this.categoryName});

  final String categoryName;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
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
    final filtered = list.where((entry) => entry.category == widget.categoryName).toList();
    filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (!mounted) {
      return;
    }
    setState(() {
      _transactions = filtered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0, onTap: (index) {}),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kDeepBlue, kTealGreen],
              ),
            ),
          ),

          // Animated Background Bubbles
          _buildAnimatedBubble(left: -329, top: -446, size: 700),
          _buildAnimatedBubble(left: -225, top: -342, size: 492),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                
                // Curved White Body
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
                          _buildTopStats(),
                          const SizedBox(height: 30),
                          _buildTransactionList(),
                          const SizedBox(height: 30),
                          _buildAddTransactionButton(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Navigator.pop(context, true), icon: const Icon(Icons.arrow_back, color: Colors.white)),
          Text(widget.categoryName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    final totalExpense = _totalExpenses;
    final totalIncome = _totalIncome;
    final usagePercent = totalIncome > 0 ? (totalExpense / totalIncome).clamp(0.0, 1.0) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat("Total Balance", _formatCurrency(totalIncome - totalExpense, signed: true), Icons.outbox),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildMiniStat("Total Expense", _formatCurrency(totalExpense, signed: true), Icons.move_to_inbox, isExpense: true),
        ],
      ),
    );
  }

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
            Text("Transactions", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: kDeepBlue)),
            const Icon(Icons.calendar_month, color: kDeepBlue),
          ],
        ),
        const SizedBox(height: 20),
        ..._transactions.map((entry) => _buildTransactionItem(entry)),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key('${entry.id}'),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
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
          return false;
        },
        background: _buildSwipeBackground(
          color: const Color(0xFFFF8585),
          icon: Icons.delete_outline_rounded,
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: _buildSwipeBackground(
          color: const Color(0xFF5E5F92),
          icon: Icons.edit_note_rounded,
          alignment: Alignment.centerRight,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _colorForCategory(entry.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconForCategory(entry.category), color: _colorForCategory(entry.category), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: kTextDark)),
                    Text(formatTransactionDateTime(entry.dateTime), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text(
                formatTransactionAmount(entry.amount),
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: entry.amount < 0 ? Colors.red : kTealGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required Color color, required IconData icon, required Alignment alignment}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      alignment: alignment,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _buildAddTransactionButton() {
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
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: kPurpleButton.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: kPurpleButton),
            const SizedBox(width: 8),
            Text("Add Transaction", style: GoogleFonts.poppins(color: kPurpleButton, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String amount, IconData icon, {bool isExpense = false}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.poppins(color: Colors.black, fontSize: 12)),
          ],
        ),
        Text(amount, style: GoogleFonts.poppins(color: isExpense ? Colors.cyanAccent : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
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

  double get _totalIncome => _transactions.where((entry) => entry.amount >= 0).fold(0.0, (sum, entry) => sum + entry.amount);

  double get _totalExpenses => _transactions.where((entry) => entry.amount < 0).fold(0.0, (sum, entry) => sum + entry.amount.abs());

  String _formatCurrency(double amount, {bool signed = false}) {
    final value = amount.abs().toStringAsFixed(2);
    if (signed) {
      final sign = amount < 0 ? '-' : '';
      return '$sign Rs $value';
    }
    return 'Rs $value';
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Income':
        return Icons.payments;
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_bus;
      case 'Medicine':
        return Icons.medical_services;
      case 'Groceries':
        return Icons.shopping_bag;
      case 'Rent':
        return Icons.vpn_key;
      case 'Gifts':
        return Icons.card_giftcard;
      case 'Savings':
        return Icons.savings;
      case 'Entertainment':
        return Icons.confirmation_number;
      default:
        return Icons.receipt_long;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'Income':
        return const Color(0xFF81C9CC);
      case 'Food':
        return const Color(0xFF81C9CC);
      case 'Transport':
        return const Color(0xFF3EC5BE);
      case 'Medicine':
        return const Color(0xFF0F78A2);
      case 'Groceries':
        return const Color(0xFF3EC5BE);
      case 'Rent':
        return const Color(0xFF0F78A2);
      case 'Gifts':
        return const Color(0xFF81C9CC);
      case 'Savings':
        return const Color(0xFF81C9CC);
      case 'Entertainment':
        return const Color(0xFF5E5F92);
      default:
        return const Color(0xFF5E5F92);
    }
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size}) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(opacity: 0.4, child: Container(width: size, height: size, decoration: const ShapeDecoration(gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]), shape: OvalBorder()))),
    );
  }
}
