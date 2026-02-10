import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'completion_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> with TickerProviderStateMixin {
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  // Matching Your Brand Palette
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kInputBg = Color(0xFF53558A);
  static const kTealAccent = Color(0xFF3EC4BE);
  static const kLabelColor = Color(0xFF093030);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // 2. THE BUBBLES
          _buildAnimatedBubble(left: -329, top: -446, size: 700, 
              colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, 
              colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]),

          // 3. MAIN CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 40),
                _fadeIn(
                  delay: 0,
                  child: Text(
                    'New Password',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                
                Expanded(
                  child: _fadeIn(
                    delay: 200,
                    slideOffset: 100,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: kFormBg,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(70),
                          topRight: Radius.circular(70),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildLabel("New Password"),
                            _buildWhitePasswordField(
                              hint: "••••••••",
                              obscureText: _isObscured,
                              toggleVisibility: () {
                                HapticFeedback.selectionClick();
                                setState(() => _isObscured = !_isObscured);
                              },
                            ),
                            
                            const SizedBox(height: 30),
                            
                            _buildLabel("Confirm New Password"),
                            _buildWhitePasswordField(
                              hint: "••••••••",
                              obscureText: _isConfirmObscured,
                              toggleVisibility: () {
                                HapticFeedback.selectionClick();
                                setState(() => _isConfirmObscured = !_isConfirmObscured);
                              },
                            ),
                            
                            const SizedBox(height: 120),
                            
                            // Change Password Button
                            _buildMainButton(
                              text: "Change Password",
                              color: Colors.white,
                              textColor: kLabelColor,
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
                              },
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

  // --- CUSTOM WIDGETS ---

  Widget _buildWhitePasswordField({
    required String hint, 
    required bool obscureText, 
    required VoidCallback toggleVisibility
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        obscureText: obscureText,
        cursorColor: kTealAccent,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
              color: kDeepBlue.withOpacity(0.5),
            ),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({required String text, required Color color, required Color textColor, required VoidCallback onPressed}) {
    return Center(
      child: Container(
        height: 60,
        width: double.infinity, // Using full width for this final primary action
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(text, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(text, style: GoogleFonts.poppins(color: kDeepBlue, fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  // Common smoothing/bubble utils
  Widget _fadeIn({required Widget child, int delay = 0, double slideOffset = 30}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size, required List<Color> colors}) {
    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(seconds: 2),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(scale: value, child: child),
        child: Opacity(
          opacity: 0.50,
          child: Container(
            width: size, height: size,
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
