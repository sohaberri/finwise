import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'add_expenses_screen.dart';
import 'edit_expense_screen.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';

class FoodCategoryScreen extends StatefulWidget {
  const FoodCategoryScreen({super.key});

  @override
  State<FoodCategoryScreen> createState() => _FoodCategoryScreenState();
}

class _FoodCategoryScreenState extends State<FoodCategoryScreen> {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kCategoryIconBg = Color(0xFF81C9CC);

  // 1. Controller for the search bar
  final TextEditingController _searchController = TextEditingController();

  List<TransactionEntry> _allTransactions = [];
  List<TransactionEntry> _filteredTransactions = [];
  bool _isLoading = true;
  double _monthlyIncome = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
      _loadBudget();
    });
  }

  Future<void> _loadTransactions() async {
    final auth = AuthScope.of(context);
    final email = auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      setState(() {
        _allTransactions = [];
        _filteredTransactions = [];
        _isLoading = false;
      });
      return;
    }

    final list = await TransactionService.instance.loadForUser(email);
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final foodOnly = list.where((entry) => entry.category == 'Food').toList();
    if (!mounted) {
      return;
    }
    setState(() {
      _allTransactions = list;
      _filteredTransactions = foodOnly;
      _isLoading = false;
    });
  }

  Future<void> _loadBudget() async {
    final auth = AuthScope.of(context);
    final email = auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      return;
    }
    final saved = await BudgetService.instance.loadForUser(email);
    if (!mounted) {
      return;
    }
    setState(() {
      _monthlyIncome = saved?.monthlyIncome ?? 0.0;
    });
  }

  // 4. Filtering logic
  void _runFilter(String enteredKeyword) {
    List<TransactionEntry> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allTransactions.where((entry) => entry.category == 'Food').toList();
    } else {
      results = _allTransactions
          .where((entry) => entry.category == 'Food')
          .where((entry) => entry.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredTransactions = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 3,
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
                _buildTopStats(),
                const SizedBox(height: 15),
                _buildSearchBar(),
                const SizedBox(height: 25),
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
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.fromLTRB(
                          25,
                          40,
                          25,
                          20 + MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Text(
                              "Results",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: kTextDark,
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (_isLoading)
                              const SizedBox(height: 80)
                            else if (_filteredTransactions.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  return _buildTransactionItem(
                                    _filteredTransactions[index],
                                  );
                                },
                              )
                            else
                              Center(
                                child: Text(
                                  "No transactions to show",
                                  style: GoogleFonts.poppins(color: Colors.grey),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final added = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddExpensesScreen()),
                                  );
                                  if (added == true) {
                                    await _loadTransactions();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5E5F92),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  "Add Expenses",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white)),
          Text("Food",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _runFilter(value), // Triggers filter on type
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search in Food...",
            hintStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            // Added clear button for better UX
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      _runFilter('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTopStats() {
    final totalExpense = _totalExpenses;
    final totalBalance = _balance;
    final usagePercent = _monthlyIncome > 0 ? (totalExpense / _monthlyIncome).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat("Total Balance", _formatCurrency(totalBalance, signed: true), Icons.outbox),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildMiniStat("Total Expense", _formatCurrency(totalExpense, signed: true),
                  Icons.move_to_inbox, isExpense: true),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 25,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: usagePercent,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15)),
                    alignment: Alignment.center,
                    child: Text("${(usagePercent * 100).round()}%",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                    right: 15,
                    top: 4,
                    child: Text(_formatCurrency(_monthlyIncome),
                        style: GoogleFonts.poppins(
                            color: kDeepBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_box_outlined,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                  _monthlyIncome > 0
                      ? "${(usagePercent * 100).round()}% Of Your Income has been used!"
                      : "Set a monthly income to track spending.",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String amount, IconData icon,
      {bool isExpense = false}) {
    return Column(
      children: [
        Row(children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12))
        ]),
        Text(amount,
            style: GoogleFonts.poppins(
                color: isExpense ? Colors.cyanAccent : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  double get _totalIncome => _allTransactions.where((entry) => entry.amount >= 0).fold(0.0, (sum, entry) => sum + entry.amount);

  double get _totalExpenses => _allTransactions.where((entry) => entry.amount < 0).fold(0.0, (sum, entry) => sum + entry.amount.abs());

  double get _balance => _allTransactions.fold(0.0, (sum, entry) => sum + entry.amount);

  String _formatCurrency(double amount, {bool signed = false}) {
    final value = amount.abs().toStringAsFixed(2);
    if (signed) {
      final sign = amount < 0 ? '-' : '';
      return '$sign Rs $value';
    }
    return 'Rs $value';
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
                decoration: BoxDecoration(color: _colorForCategory(entry.category).withOpacity(0.6), shape: BoxShape.circle),
                child: Icon(_iconForCategory(entry.category), color: Colors.white, size: 24),
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
                  entry.category,
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: GoogleFonts.poppins(color: const Color(0xFF5E5F92)))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
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

  Widget _fadeIn({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) => Opacity(
          opacity: value,
          child:
              Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child)),
      child: child,
    );
  }

  Widget _buildAnimatedBubble(
      {required double left, required double top, required double size}) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
          opacity: 0.50,
          child: Container(
              width: size,
              height: size,
              decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]),
                  shape: OvalBorder()))),
    );
  }
}