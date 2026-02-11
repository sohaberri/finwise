import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'profile_home_screen.dart';
import 'add_expenses_Screen.dart';
import 'edit_expense_screen.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kAccentPurple = Color(0xFF5E5F92);
  static const kDarkCard = Color(0xFF191A4C);

  String selectedPeriod = 'Monthly'; 
  List<TransactionEntry> _transactions = [];
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
        onTap: (index) {
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileHomeScreen()),
            );
          }
        },
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

          _buildAnimatedBubble(left: -329, top: -446, size: 700, colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildBalanceSection(),
                const SizedBox(height: 15),
                
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
                          children: [
                            const SizedBox(height: 30),
                            _buildSummaryCard(),
                            const SizedBox(height: 25),
                            _buildPeriodToggle(),
                            const SizedBox(height: 20),
                            if (_isLoading)
                              const SizedBox(height: 80)
                            else if (_transactions.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  "No transactions to show",
                                  style: GoogleFonts.poppins(color: Colors.grey),
                                ),
                              )
                            else
                              ..._transactions.map((entry) => _buildTransactionItem(
                                    _iconForCategory(entry.category),
                                    entry.title,
                                    formatTransactionDateTime(entry.dateTime),
                                    entry.category,
                                    formatTransactionAmount(entry.amount),
                                    _colorForCategory(entry.category),
                                    entry: entry,
                                    isPositive: entry.amount >= 0,
                                  )),
                            const SizedBox(height: 100), 
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, Welcome Back", style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Good Morning", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const CircleAvatar(backgroundColor: kAccentPurple, child: Icon(Icons.notifications_none, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    final totalIncome = _totalIncome;
    final totalExpense = _totalExpenses;
    final balance = _balance;
    final usagePercent = _monthlyIncome > 0 ? (totalExpense / _monthlyIncome).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceText("Total Balance", _formatCurrency(balance, signed: true)),
              _buildBalanceText("Total Expense", _formatCurrency(totalExpense, signed: true), isExpense: true),
            ],
          ),
          const SizedBox(height: 20),

          // --- ADDED PROGRESS BAR ---
          Container(
            height: 25,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: usagePercent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${(usagePercent * 100).round()}%",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 4,
                  child: Text(
                    _formatCurrency(_monthlyIncome),
                    style: GoogleFonts.poppins(color: kDeepBlue, fontSize: 12, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- ADDED INSIGHT TEXT ---
          Row(
            children: [
              const Icon(Icons.check_box_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                _monthlyIncome > 0
                    ? "${(usagePercent * 100).round()}% Of Your Income has been used!"
                    : "Set a monthly income to track spending.",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ElevatedButton(
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
              backgroundColor: kAccentPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(200, 45),
            ),
            child: Text("Add Expenses", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceText(String label, String amount, {bool isExpense = false}) {
    return Column(
      crossAxisAlignment: isExpense ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward, size: 14, color: Colors.white70),
            Text(" $label", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
          ],
        ),
        Text(amount, style: GoogleFonts.poppins(color: isExpense ? Colors.cyanAccent : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final revenueLastWeek = _revenueLastWeek;
    final foodLastWeek = _foodLastWeek;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kDarkCard, borderRadius: BorderRadius.circular(35)),
      child: Row(
        children: [
          _buildGoalCircle(),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              children: [
                _buildSmallStat("Revenue Last Week", _formatCurrency(revenueLastWeek)),
                const Divider(color: Colors.white24),
                _buildSmallStat("Food Last Week", _formatCurrency(foodLastWeek, signed: true), isNegative: true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      height: 60,
      decoration: BoxDecoration(color: const Color(0xFF53558A), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: ['Daily', 'Weekly', 'Monthly'].map((period) {
          bool isSelected = selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                HapticFeedback.selectionClick();
                selectedPeriod = period;
              }),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2F206C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  period,
                  style: GoogleFonts.poppins(color: isSelected ? Colors.white : kTextDark, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(IconData icon, String title, String time, String category, String amount, Color color, {TransactionEntry? entry, bool isPositive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key('$title$time'),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            if (entry == null) {
              await _showDeleteDialog(title);
              return false;
            }
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
            if (entry == null) {
              return false;
            }
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
                decoration: BoxDecoration(color: color.withOpacity(0.6), shape: BoxShape.circle),
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

  Widget _buildGoalCircle() { return Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent, width: 3)), child: const Center(child: Icon(Icons.directions_car, color: Colors.white, size: 35))); }
  Widget _buildSmallStat(String label, String val, {bool isNegative = false}) { return Column(children: [Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)), Text(val, style: GoogleFonts.poppins(color: isNegative ? Colors.cyanAccent : Colors.white, fontWeight: FontWeight.bold))]); }

  double get _totalIncome => _transactions.where((entry) => entry.amount >= 0).fold(0.0, (sum, entry) => sum + entry.amount);

  double get _totalExpenses => _transactions.where((entry) => entry.amount < 0).fold(0.0, (sum, entry) => sum + entry.amount.abs());

  double get _balance => _transactions.fold(0.0, (sum, entry) => sum + entry.amount);

  double get _revenueLastWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _transactions
        .where((entry) => entry.amount > 0 && entry.dateTime.isAfter(cutoff))
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  double get _foodLastWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _transactions
        .where((entry) => entry.amount < 0 && entry.category == 'Food' && entry.dateTime.isAfter(cutoff))
        .fold(0.0, (sum, entry) => sum + entry.amount.abs());
  }

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

  Widget _buildAnimatedBubble({required double left, required double top, required double size, required List<Color> colors}) {
    return Positioned(
      left: left, top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(scale: value, alignment: Alignment.center, child: child),
        child: Opacity(opacity: 0.50, child: Container(width: size, height: size, decoration: const ShapeDecoration(gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]), shape: OvalBorder()))),
      ),
    );
  }
}