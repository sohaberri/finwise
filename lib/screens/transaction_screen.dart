import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'budget_setup_screen.dart';
import 'edit_expense_screen.dart'; 

enum TransactionType { all, income, expense }

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kAccentPurple = Color(0xFF5E5F92);

  TransactionType selectedType = TransactionType.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 0,
        onTap: (index) {},
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kDeepBlue, kTealGreen],
              ),
            ),
          ),
          _buildAnimatedBubble(left: -329, top: -446, size: 700),
          _buildAnimatedBubble(left: -225, top: -342, size: 492),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                _buildTopCards(),
                const SizedBox(height: 20),
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
                    child: _fadeIn(
                      delay: 200,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 35),
                            if (_shouldShowSection("April")) ...[
                              _buildSectionHeader("April"),
                              if (selectedType == TransactionType.all || selectedType == TransactionType.income)
                                _buildTransactionItem(Icons.payments, "Salary", "18:27 - April 30", "Monthly", "\$4.000,00", const Color(0xFF81C9CC), isPositive: true),
                              if (selectedType == TransactionType.all || selectedType == TransactionType.expense) ...[
                                _buildTransactionItem(Icons.shopping_bag, "Groceries", "17:00 - April 24", "Pantry", "-\$100,00", const Color(0xFF3EC5BE)),
                                _buildTransactionItem(Icons.vpn_key, "Rent", "8:30 - April 15", "Rent", "-\$674,40", const Color(0xFF0F78A2)),
                                _buildTransactionItem(Icons.directions_bus, "Transport", "7:30 - April 08", "Fuel", "-\$4,13", const Color(0xFF3EC5BE)),
                              ]
                            ],
                            const SizedBox(height: 25),
                            if (_shouldShowSection("March")) ...[
                              _buildSectionHeader("March"),
                              if (selectedType == TransactionType.all || selectedType == TransactionType.expense)
                                _buildTransactionItem(Icons.restaurant, "Food", "19:30 - March 31", "Dinner", "-\$70,40", const Color(0xFF81C9CC)),
                            ],
                            const SizedBox(height: 120),
                          ],
                        ),
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

  // --- UPDATED TRANSACTION ITEM WITH CATEGORIES ---

  Widget _buildTransactionItem(IconData icon, String title, String time, String category, String amount, Color iconBg, {bool isPositive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key(title + time), 
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _showDeleteDialog(title);
            return false;
          } else if (direction == DismissDirection.endToStart) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditExpenseScreen()));
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
          color: kAccentPurple.withOpacity(0.9),
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
                decoration: BoxDecoration(color: iconBg.withOpacity(0.6), shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark)),
                    Text(time, style: GoogleFonts.poppins(fontSize: 10, color: kDeepBlue.withOpacity(0.6), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              // THE CATEGORY COLUMN
              Container(
                height: 30,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  category,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ),
              // AMOUNT COLUMN
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15,
                  color: isPositive ? kTealGreen : const Color(0xFF3EC5BE)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REMAINDER OF HELPER METHODS ---

  Widget _buildSwipeBackground({required Color color, required IconData icon, required Alignment alignment}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      alignment: alignment,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  void _showDeleteDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text("Delete Transaction", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: kDeepBlue, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text("Are you sure you want to delete '$title'?", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: kTextDark.withOpacity(0.7), fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.poppins(color: kAccentPurple))),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  bool _shouldShowSection(String month) {
    if (selectedType == TransactionType.all) return true;
    if (month == "April") return true; 
    if (month == "March" && selectedType == TransactionType.expense) return true;
    return false;
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
          Text("Transaction", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const Icon(Icons.notifications_none, color: Colors.white, size: 22),
        ],
      ),
    );
  }

  Widget _buildTopCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildTotalBalanceCard(),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildFilterCard("Income", "\$4,120.00", Icons.outbox, Colors.black, TransactionType.income),
              const SizedBox(width: 15),
              _buildFilterCard("Expense", "\$1.187.40", Icons.move_to_inbox, const Color(0xFF0077B6), TransactionType.expense),
            ],
          ),
          const SizedBox(height: 15),
          _buildAllocateBudgetBtn(),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    return GestureDetector(
      onTap: () => setState(() => selectedType = TransactionType.all),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selectedType == TransactionType.all ? Colors.white : Colors.white.withOpacity(0.7), 
          borderRadius: BorderRadius.circular(20),
          border: selectedType == TransactionType.all ? Border.all(color: kTealGreen, width: 2) : null,
        ),
        child: Column(
          children: [
            Text("Total Balance", style: GoogleFonts.poppins(color: kDeepBlue, fontSize: 14)),
            Text("\$7,783.00", style: GoogleFonts.poppins(color: kDeepBlue, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocateBudgetBtn() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetSetupScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Center(child: Text("Allocate Budget", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600))),
      ),
    );
  }

  Widget _buildFilterCard(String label, String amount, IconData icon, Color amountColor, TransactionType type) {
    bool isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E2E5D) : Colors.white, 
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : const Color(0xFF0077B6), size: 28),
              const SizedBox(height: 5),
              Text(label, style: GoogleFonts.poppins(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 13)),
              Text(amount, style: GoogleFonts.poppins(color: isSelected ? Colors.white : amountColor, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String month) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(month, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kTextDark)),
          const Icon(Icons.calendar_month, color: kDeepBlue, size: 20),
        ],
      ),
    );
  }

  Widget _fadeIn({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child)),
      child: child,
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size}) {
    return Positioned(
      left: left, top: top,
      child: Opacity(
        opacity: 0.50, 
        child: Container(
          width: size, 
          height: size, 
          decoration: const ShapeDecoration(
            gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]), 
            shape: OvalBorder()
          )
        )
      ),
    );
  }
}