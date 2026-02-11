import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';

class SavingsCategoryScreen extends StatefulWidget {
  const SavingsCategoryScreen({super.key});

  @override
  State<SavingsCategoryScreen> createState() => _SavingsCategoryScreenState();
}

class _SavingsCategoryScreenState extends State<SavingsCategoryScreen> {
  // Established color palette
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kCategoryColor = Color(0xFF81C9CC);
  static const kPurpleButton = Color(0xFF393078);
  static const kDeleteRed = Color(0xFFFF8585);
  static const kEditCyan = Color(0xFF44DDFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 3, onTap: (index) {}),
      body: Stack(
        children: [
          // 1. Consistent Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kDeepBlue, kTealGreen],
              ),
            ),
          ),

          // 2. Animated Background Bubbles
          _buildAnimatedBubble(left: -329, top: -446, size: 700),
          _buildAnimatedBubble(left: -225, top: -342, size: 492),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                
                // 3. Curved White Body
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
                          _buildTopGoalCard(),
                          const SizedBox(height: 30),
                          _buildProgressBar(),
                          const SizedBox(height: 15),
                          _buildStatusNotice(),
                          const SizedBox(height: 40),
                          _buildTransactionList(),
                          const SizedBox(height: 30),
                          _buildAddSavingsButton(),
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

  // --- TOP GOAL SECTION ---
  Widget _buildTopGoalCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatLabel(Icons.ads_click, "Goal"),
            Text("\$1,962.93", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kDeepBlue)),
            const SizedBox(height: 20),
            _buildStatLabel(Icons.outbox_rounded, "Amount Saved"),
            Text("\$653.31", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kTealGreen)),
          ],
        ),
        _buildCircularProgressIcon(),
      ],
    );
  }

  Widget _buildCircularProgressIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130, height: 130,
          decoration: BoxDecoration(color: kCategoryColor, borderRadius: BorderRadius.circular(35)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 45),
              const SizedBox(height: 5),
              Text("Travel", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
        SizedBox(
          width: 105, height: 105,
          child: CircularProgressIndicator(
            value: 0.4,
            strokeWidth: 8,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(kDeepBlue),
          ),
        ),
      ],
    );
  }

  // --- TRANSACTION LIST WITH DISMISSIBLE SWIPE ACTIONS ---
  Widget _buildTransactionList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("April", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: kDeepBlue)),
            const Icon(Icons.calendar_month, color: kDeepBlue),
          ],
        ),
        const SizedBox(height: 20),
        _buildSwipeableTransaction("Travel Deposit", "19:56 - April 30", "\$217.77"),
        _buildSwipeableTransaction("Travel Deposit", "17:42 - April 14", "\$217.77"),
        _buildSwipeableTransaction("Travel Deposit", "12:30 - April 02", "\$217.77"),
      ],
    );
  }

  Widget _buildSwipeableTransaction(String title, String date, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Dismissible(
        key: Key(date),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Swipe Right -> Trigger Delete
            _showDeleteDialog(title);
            return false; // Return false so the item doesn't disappear immediately
          } else {
            // Swipe Left -> Trigger Edit
            // Navigator.push(context, MaterialPageRoute(builder: (context) => const EditScreen()));
            return false;
          }
        },
        // Swipe Right Background (Delete)
        background: _buildSwipeBackground(
          color: kDeleteRed,
          icon: Icons.delete_outline_rounded,
          alignment: Alignment.centerLeft,
        ),
        // Swipe Left Background (Edit)
        secondaryBackground: _buildSwipeBackground(
          color: kEditCyan,
          icon: Icons.edit_note_rounded,
          alignment: Alignment.centerRight,
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: kCategoryColor.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.flight_takeoff_rounded, color: kCategoryColor),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: kTextDark)),
                  Text(date, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              Text(amount, style: GoogleFonts.poppins(color: kTealGreen, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE UI ELEMENTS ---

  Widget _buildSwipeBackground({required Color color, required IconData icon, required Alignment alignment}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(25)
      ),
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.poppins(color: kPurpleButton))),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
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
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
          Text("Travel", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      children: [
        Container(height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
        Container(
          height: 30, width: 140, // 40% width approx
          decoration: BoxDecoration(color: kTextDark, borderRadius: BorderRadius.circular(15)),
          alignment: Alignment.center,
          child: Text("40%", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Positioned(
          right: 15, top: 5,
          child: Text("\$1,962.93", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
        ),
      ],
    );
  }

  Widget _buildStatusNotice() {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 18, color: kDeepBlue),
        const SizedBox(width: 8),
        Text("40% Of Your Income has been used!", style: GoogleFonts.poppins(fontSize: 13, color: kDeepBlue.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildAddSavingsButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity, height: 60,
        decoration: BoxDecoration(
          color: kPurpleButton,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: kPurpleButton.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: Text("Add Savings", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildStatLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kDeepBlue.withOpacity(0.5)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: kDeepBlue.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size}) {
    return Positioned(
      left: left, top: top,
      child: Opacity(
        opacity: 0.15,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}