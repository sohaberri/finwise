import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'budget_setup_screen.dart';
import 'edit_expense_screen.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';

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
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (!mounted) {
      return;
    }
    setState(() {
      _transactions = list;
      _isLoading = false;
    });
  }

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
                            if (_isLoading)
                              const SizedBox(height: 80)
                            else if (_filteredTransactions().isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  "No transactions to show",
                                  style: GoogleFonts.poppins(color: Colors.grey),
                                ),
                              )
                            else
                              ..._buildGroupedTransactions(),
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

  Widget _buildTransactionItem(IconData icon, String title, String time, String category, String amount, Color iconBg, {required TransactionEntry entry, bool isPositive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key(entry.id),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            final confirmed = await _showDeleteDialog(title);
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
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isPositive ? kTealGreen : const Color(0xFF3EC5BE),
                ),
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

  Future<bool?> _showDeleteDialog(String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text("Delete Transaction", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: kDeepBlue, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text("Are you sure you want to delete '$title'?", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: kTextDark.withOpacity(0.7), fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: GoogleFonts.poppins(color: kAccentPurple))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  List<TransactionEntry> _filteredTransactions() {
    if (selectedType == TransactionType.all) {
      return _transactions;
    }
    if (selectedType == TransactionType.income) {
      return _transactions.where((entry) => entry.amount >= 0).toList();
    }
    return _transactions.where((entry) => entry.amount < 0).toList();
  }

  List<Widget> _buildGroupedTransactions() {
    final filtered = _filteredTransactions();
    if (filtered.isEmpty) {
      return [];
    }

    final Map<String, List<TransactionEntry>> grouped = {};
    for (final entry in filtered) {
      final label = _monthLabel(entry.dateTime);
      grouped.putIfAbsent(label, () => []).add(entry);
    }

    final keys = grouped.keys.toList();
    keys.sort((a, b) => _monthIndex(b).compareTo(_monthIndex(a)));

    final List<Widget> widgets = [];
    for (final key in keys) {
      widgets.add(_buildSectionHeader(key));
      for (final entry in grouped[key]!) {
        widgets.add(
          _buildTransactionItem(
            _iconForCategory(entry.category),
            entry.title,
            formatTransactionDateTime(entry.dateTime),
            entry.category,
            formatTransactionAmount(entry.amount),
            _colorForCategory(entry.category),
            entry: entry,
            isPositive: entry.amount >= 0,
          ),
        );
      }
      widgets.add(const SizedBox(height: 25));
    }
    return widgets;
  }

  String _monthLabel(DateTime dateTime) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[dateTime.month - 1];
  }

  int _monthIndex(String month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months.indexOf(month);
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
              _buildFilterCard("Income", _formatCurrency(_totalIncome), Icons.outbox, Colors.black, TransactionType.income),
              const SizedBox(width: 15),
              _buildFilterCard("Expense", _formatCurrency(_totalExpenses), Icons.move_to_inbox, const Color(0xFF0077B6), TransactionType.expense),
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
            Text(_formatCurrency(_balance, signed: true), style: GoogleFonts.poppins(color: kDeepBlue, fontSize: 28, fontWeight: FontWeight.bold)),
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
    final isSelected = selectedType == type;
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

  double get _totalIncome => _transactions.where((entry) => entry.amount >= 0).fold(0.0, (sum, entry) => sum + entry.amount);

  double get _totalExpenses => _transactions.where((entry) => entry.amount < 0).fold(0.0, (sum, entry) => sum + entry.amount.abs());

  double get _balance => _transactions.fold(0.0, (sum, entry) => sum + entry.amount);

  String _formatCurrency(double amount, {bool signed = false}) {
    final value = amount.abs().toStringAsFixed(2);
    if (signed) {
      final sign = amount < 0 ? '-' : '';
      return '$sign Rs $value';
    }
    return 'Rs $value';
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
      left: left,
      top: top,
      child: Opacity(
        opacity: 0.50,
        child: Container(
          width: size,
          height: size,
          decoration: const ShapeDecoration(
            gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]),
            shape: OvalBorder(),
          ),
        ),
      ),
    );
  }
}
