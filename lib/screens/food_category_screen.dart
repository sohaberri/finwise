import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'add_expenses_screen.dart';

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

  // 2. The master list of transactions
  final List<Map<String, dynamic>> allTransactions = [
    {"name": "Dinner", "time": "18:27 - April 30", "amount": "-\$26.00"},
    {"name": "Delivery Pizza", "time": "15:00 - April 24", "amount": "-\$18.35"},
    {"name": "Lunch", "time": "12:30 - April 15", "amount": "-\$15.40"},
    {"name": "Brunch", "time": "9:30 - April 08", "amount": "-\$12.13"},
  ];

  // 3. The list that actually gets displayed
  List<Map<String, dynamic>> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    // Initialize with all transactions
    filteredTransactions = allTransactions;
  }

  // 4. Filtering logic
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = allTransactions;
    } else {
      results = allTransactions
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredTransactions = results;
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
                            if (filteredTransactions.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  return _buildTransactionItem(
                                    filteredTransactions[index],
                                  );
                                },
                              )
                            else
                              Center(
                                child: Text(
                                  "No transactions found",
                                  style: GoogleFonts.poppins(color: Colors.grey),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddExpensesScreen()),
                                  );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat("Total Balance", "\$7,783.00", Icons.outbox),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildMiniStat("Total Expense", "-\$1.187.40",
                  Icons.move_to_inbox,
                  isExpense: true),
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
                  widthFactor: 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15)),
                    alignment: Alignment.center,
                    child: const Text("30%",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                    right: 15,
                    top: 4,
                    child: Text("\$20,000.00",
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
              Text("30% Of Your Expenses, Looks Good.",
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

  Widget _buildTransactionItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: kCategoryIconBg,
                borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.restaurant, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, color: kTextDark)),
                Text(item['time'],
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(item['amount'],
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: const Color(0xFF00D09E))),
        ],
      ),
    );
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