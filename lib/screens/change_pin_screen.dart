import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart'; // Your imported hotbar

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF093030);
  static const kButtonDark = Color(0xFF1D1E50); // Darker button from screenshot

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 4,
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

          // 2. BACKGROUND BUBBLES (Elastic animation scoped only here)
          _buildAnimatedBubble(
            left: -329, 
            top: -446, 
            size: 700, 
            colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]
          ),
          _buildAnimatedBubble(
            left: -225, 
            top: -342, 
            size: 492, 
            colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]
          ),

          // 3. MAIN CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: kFormBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: _fadeIn(
                      delay: 200, // Smooth slide up for form elements
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50),
                            
                            _buildPinField("Current Pin"),
                            _buildPinField("New Pin"),
                            _buildPinField("Confirm Pin"),
                            
                            const SizedBox(height: 40),
                            
                            // Change Pin Button
                            Center(
                              child: ElevatedButton(
                                onPressed: () => HapticFeedback.mediumImpact(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kButtonDark,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(220, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  "Change Pin", 
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)
                                ),
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
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Text("Change Pin", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildPinField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: kTextDark)),
          const SizedBox(height: 12),
          TextFormField(
            obscureText: true,
            obscuringCharacter: '●',
            keyboardType: TextInputType.number,
            style: const TextStyle(letterSpacing: 8, color: Color(0xFF81A2A2)),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Icon(Icons.visibility_off_outlined, color: kTextDark.withOpacity(0.6), size: 22),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fadeIn({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size, required List<Color> colors}) {
    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.elasticOut, // Animation scoped to bubbles only
        builder: (context, value, child) => Transform.scale(
          scale: value, 
          alignment: Alignment.center,
          child: child
        ),
        child: Opacity(
          opacity: 0.50,
          child: Container(
            width: size, 
            height: size,
            decoration: ShapeDecoration(
              gradient: LinearGradient(colors: colors),
              shape: const OvalBorder(),
            ),
          ),
        ),
      ),
    );
  }
}