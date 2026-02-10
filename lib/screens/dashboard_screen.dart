import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'profile_home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF093030);
  static const kAccentPurple = Color(0xFF5E5F92);
  static const kDarkCard = Color(0xFF16194F);

  String selectedPeriod = 'Monthly'; // State for the toggle bar

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
              MaterialPageRoute(builder: (context) => ProfileHomeScreen()),
            );
          }
        },
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

          // 2. BACKGROUND BUBBLES (Elastic scale animation)
          _buildAnimatedBubble(left: -329, top: -446, size: 700, colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]),

          // 3. MAIN CONTENT
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
                            // VERTICALLY SCROLLABLE TRANSACTIONS
                            _buildTransactionItem(Icons.payments, "Salary", "18:27 - April 30", "Monthly", "\$4.000,00", Colors.tealAccent.shade400, isPositive: true),
                            _buildTransactionItem(Icons.shopping_bag, "Groceries", "17:00 - April 24", "Pantry", "-\$100,00", Colors.tealAccent.shade400),
                            _buildTransactionItem(Icons.vpn_key, "Rent", "8:30 - April 15", "Rent", "-\$674,40", Colors.blueAccent),
                            const SizedBox(height: 100), // Space for nav bar
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceText("Total Balance", "\$7,783.00"),
              _buildBalanceText("Total Expense", "-\$1.187.40", isExpense: true),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kDarkCard, borderRadius: BorderRadius.circular(35)),
      child: Row(
        children: [
          _buildGoalCircle(),
          const VerticalDivider(color: Colors.white24, thickness: 1, indent: 10, endIndent: 10),
          Expanded(
            child: Column(
              children: [
                _buildSmallStat("Revenue Last Week", "\$4.000.00"),
                const Divider(color: Colors.white24),
                _buildSmallStat("Food Last Week", "-\$100.00", isNegative: true),
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
      decoration: BoxDecoration(color: const Color(0xFFD1D1EB), borderRadius: BorderRadius.circular(30)),
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
                  color: isSelected ? kDarkCard : Colors.transparent,
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

  Widget _buildTransactionItem(IconData icon, String title, String time, String category, String amount, Color color, {bool isPositive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTextDark)),
              Text(time, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ]),
          ),
          Text(category, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 20),
          Text(amount, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isPositive ? Colors.teal : kTextDark)),
        ],
      ),
    );
  }

  // Consistent UI helper components...
  Widget _buildGoalCircle() { return Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent, width: 3)), child: const Center(child: Icon(Icons.directions_car, color: Colors.white, size: 35))); }
  Widget _buildSmallStat(String label, String val, {bool isNegative = false}) { return Column(children: [Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)), Text(val, style: GoogleFonts.poppins(color: isNegative ? Colors.cyanAccent : Colors.white, fontWeight: FontWeight.bold))]); }
  
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