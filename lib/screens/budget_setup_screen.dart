import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/budget_service.dart';
import '../services/transaction_service.dart';

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kAccentPurple = Color(0xFF5E5F92);

  double totalIncome = 0.0;
  final TextEditingController _incomeController = TextEditingController();
  
  // Storing controllers in a map to track category allocations
  final Map<String, TextEditingController> _controllers = {};
  
  final List<Map<String, dynamic>> categories = [
    {"name": "Food", "icon": Icons.restaurant},
    {"name": "Transport", "icon": Icons.directions_bus},
    {"name": "Medicine", "icon": Icons.medical_services},
    {"name": "Groceries", "icon": Icons.shopping_basket},
    {"name": "Rent", "icon": Icons.vpn_key},
    {"name": "Gifts", "icon": Icons.card_giftcard},
    {"name": "Savings", "icon": Icons.savings},
    {"name": "Entertainment", "icon": Icons.confirmation_number},
  ];

  @override
  void initState() {
    super.initState();
    for (var cat in categories) {
      _controllers[cat['name']] = TextEditingController(text: '0');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBudget();
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadBudget() async {
    final auth = AuthScope.of(context);
    final email = auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      return;
    }

    final saved = await BudgetService.instance.loadForUser(email);
    if (saved == null) {
      return;
    }

    setState(() {
      totalIncome = saved.monthlyIncome;
      _incomeController.text = saved.monthlyIncome.toStringAsFixed(2);
      saved.allocations.forEach((key, value) {
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = value.toStringAsFixed(0);
        }
      });
    });
  }

  Future<void> _saveBudget() async {
    final auth = AuthScope.of(context);
    final email = auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      return;
    }

    final allocations = <String, double>{};
    _controllers.forEach((key, controller) {
      allocations[key] = double.tryParse(controller.text) ?? 0.0;
    });

    final budget = BudgetData(
      monthlyIncome: totalIncome,
      allocations: allocations,
    );

    final shouldAddIncome = await BudgetService.instance.saveForUser(email, budget);

    if (shouldAddIncome) {
      // TODO: Replace with backend transaction creation for income.
      final entry = TransactionEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Monthly Income',
        category: 'Income',
        amount: totalIncome,
        dateTime: DateTime.now(),
      );
      await TransactionService.instance.addForUser(email, entry);
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  double get _totalAllocated {
    double total = 0;
    _controllers.forEach((key, controller) {
      total += double.tryParse(controller.text) ?? 0;
    });
    return total;
  }

  double get _remaining {
    return totalIncome - _totalAllocated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND
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

          // 2. CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                _buildIncomeHeader(),
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
                    child: Column(
                      children: [
                        _buildRemainingIndicator(),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(25, 10, 25, 100),
                            physics: const BouncingScrollPhysics(),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              return _buildCategoryRow(categories[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Monthly Income", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _incomeController,
                    onChanged: (val) => setState(() => totalIncome = double.tryParse(val) ?? 0),
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      prefixText: "Rs ",
                      prefixStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      hintText: "0.00",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingIndicator() {
    bool isOver = _remaining < 0;
    return Container(
      margin: const EdgeInsets.only(top: 30, left: 25, right: 25, bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: isOver ? Colors.red.withOpacity(0.1) : kTealGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOver ? Colors.red : kTealGreen, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isOver ? "Over Allocated" : "Remaining to Allocate",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isOver ? Colors.red : kDeepBlue),
          ),
          Text(
            "Rs ${_remaining.toStringAsFixed(0)}",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: isOver ? Colors.red : kDeepBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> category) {
    String name = category['name'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: kFormBg, borderRadius: BorderRadius.circular(15)),
              child: Icon(category['icon'], color: kDeepBlue, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kTextDark)),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controllers[name],
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kDeepBlue),
                decoration: const InputDecoration(
                  prefixText: "Rs ",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      color: kFormBg,
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 40),
      child: ElevatedButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          await _saveBudget();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kDeepBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text("Save Budget Plan", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          Text("Budget Setup", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size}) {
    return Positioned(
      left: left, top: top,
      child: Opacity(
        opacity: 0.4,
        child: Container(
          width: size, height: size,
          decoration: const ShapeDecoration(
            gradient: LinearGradient(colors: [kDeepBlue, Color(0xFF3A3CB2)]),
            shape: OvalBorder(),
          ),
        ),
      ),
    );
  }
}