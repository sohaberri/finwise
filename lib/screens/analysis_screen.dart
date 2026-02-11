import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'add_expenses_screen.dart'; 

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kAccentPurple = Color(0xFF5E5F92);
  static const kGraphTeal = Color(0xFF0077B6);

  String selectedPeriod = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1, 
        onTap: (index) {},
      ),
      body: Stack(
        children: [
          // 1. BASE GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kDeepBlue, kTealGreen],
              ),
            ),
          ),

          // 2. BACKGROUND BUBBLES
          _buildAnimatedBubble(left: -329, top: -446, size: 700),
          _buildAnimatedBubble(left: -225, top: -342, size: 492),

          // 3. MAIN CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                _buildTopStats(),
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
                            const SizedBox(height: 30),
                            _buildPeriodToggle(),
                            const SizedBox(height: 30),
                            _buildGraphCard(),
                            const SizedBox(height: 30),
                            _buildIncomeExpenseRow(),
                            const SizedBox(height: 30),
                            Text(
                              "My Targets",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kTextDark,
                              ),
                            ),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context), 
            child: const Icon(Icons.arrow_back, color: Colors.white)
          ),
          Text(
            "Analysis", 
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        children: [
          // Row for Balance and Expense
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat("Total Balance", "\$7,783.00", Icons.outbox),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildMiniStat("Total Expense", "-\$1.187.40", Icons.move_to_inbox, isExpense: true),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress Bar (Restored)
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
                  widthFactor: 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: const Text("30%", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 4,
                  child: Text("\$20,000.00", style: GoogleFonts.poppins(color: kDeepBlue, fontSize: 12, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Insight text (Restored)
          Row(
            children: [
              const Icon(Icons.check_box_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text("30% Of Your Income has been used!", style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),

          // Add Expense Button (Positioned over the button)
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpensesScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(200, 45),
              elevation: 0,
            ),
            child: Text(
              "Add Expenses", 
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)
            ),
          ),
        ],
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
            Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
          ],
        ),
        Text(amount, style: GoogleFonts.poppins(color: isExpense ? Colors.cyanAccent : Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: const Color(0xFF5E5F92), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: ['Daily', 'Weekly', 'Monthly', 'Year'].map((period) {
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
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  period,
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGraphCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 5)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Income & Expenses", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kDeepBlue)),
              Row(
                children: [
                  _buildIconBtn(Icons.search),
                  const SizedBox(width: 8),
                  _buildIconBtn(Icons.calendar_month),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey.shade50, 
            child: const Center(child: Text("Bar Chart View", style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFF9599D3).withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: kDeepBlue, size: 20),
    );
  }

  Widget _buildIncomeExpenseRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBottomMiniStat("Income", "\$4,120.00", Icons.outbox, kDeepBlue),
        _buildBottomMiniStat("Expense", "\$1.187.40", Icons.move_to_inbox, kGraphTeal),
      ],
    );
  }

  Widget _buildBottomMiniStat(String label, String amount, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
        Text(amount, style: GoogleFonts.poppins(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
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
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(scale: value, child: child),
        child: Opacity(opacity: 0.50, child: Container(width: size, height: size, decoration: const ShapeDecoration(gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]), shape: OvalBorder()))),
      ),
    );
  }
}