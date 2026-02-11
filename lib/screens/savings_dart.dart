import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'food_category_screen.dart';
import 'add_category_screen.dart';
import 'edit_category_screen.dart';
import 'savings_category_screen.dart';
import '../services/auth_service.dart';
import '../services/budget_service.dart';
import '../services/transaction_service.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kCategoryColor = Color(0xFF81C9CC);

  List<TransactionEntry> _transactions = [];
  bool _isLoading = true;
  double _monthlyIncome = 0.0;

  // Updated categories to match the screenshots provided
  final List<Map<String, dynamic>> categories = [
    {"name": "Travel", "icon": Icons.flight_takeoff_rounded},
    {"name": "New House", "icon": Icons.vpn_key_outlined},
    {"name": "Car", "icon": Icons.directions_car_filled_rounded},
    {"name": "Wedding", "icon": Icons.favorite_border_rounded},
    {"name": "Salary", "icon": Icons.payments_outlined},
    {"name": "Others", "icon": Icons.account_balance_wallet_outlined},
    {"name": "More", "icon": Icons.add},
  ];

  // --- SHOW BOTTOM SHEET FOR EDIT/DELETE ---
  void _showCategoryOptions(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 25),
            Text(
              "Manage ${category['name']}",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: kTextDark),
            ),
            const SizedBox(height: 25),
            _buildOptionTile(
              icon: Icons.edit_rounded,
              color: const Color.fromARGB(255, 68, 221, 255),
              label: "Edit Category",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCategoryScreen(category: category)),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildOptionTile(
              icon: Icons.delete_outline_rounded,
              color: const Color.fromARGB(255, 239, 140, 140),
              label: "Delete Category",
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(category['name']);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Text(label, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 3, onTap: (index) {}),
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
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
                    ),
                    child: _fadeIn(
                      delay: 200,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                        child: Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 25,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) => _buildCategoryItem(categories[index]),
                            ),
                            const SizedBox(height: 30),
                            _buildAddButton(),
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

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Column(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              if (category['name'] != 'More') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SavingsCategoryScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCategoryScreen()));
              }
            },
            onLongPress: () {
              if (category['name'] != 'More') {
                _showCategoryOptions(category);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kCategoryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Icon(category['icon'], color: Colors.white, size: 35),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(category['name'], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: kTextDark)),
      ],
    );
  }

  void _showDeleteConfirmation(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete $name?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text("This category and its history will be permanently removed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: const StadiumBorder()),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCategoryScreen())),
      child: Container(
        width: double.infinity, height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF393078),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF5345C1).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text("Add New Category", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
          Text("Savings", style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(width: 48), 
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
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search Categories...",
            hintStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat("Total Balance", _formatCurrency(totalBalance, signed: true), Icons.outbox),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildMiniStat("Total Expense", _formatCurrency(totalExpense, signed: true), Icons.move_to_inbox, isExpense: true),
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

  Widget _buildMiniStat(String label, String amount, IconData icon, {bool isExpense = false}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
          ],
        ),
        Text(amount, style: GoogleFonts.poppins(color: isExpense ? Colors.cyanAccent : Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _fadeIn({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
      ),
      child: child,
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size}) {
    return Positioned(
      left: left, top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(scale: value, child: child),
        child: Opacity(
          opacity: 0.50,
          child: Container(
            width: size, height: size,
            decoration: const ShapeDecoration(
              gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]),
              shape: OvalBorder(),
            ),
          ),
        ),
      ),
    );
  }
}