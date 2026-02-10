import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  // Matching Your Exact Color Palette
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kInputBg = Color(0xFF53558A);
  static const kPrimaryPurple = Color(0xFF5345C0);
  static const kTealAccent = Color(0xFF3EC4BE);
  static const kLabelColor = Color(0xFF093030);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BASE GRADIENT (Identical to Login)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kDeepBlue, kTealGreen],
              ),
            ),
          ),

          // 2. THE BUBBLES (Identical to Login)
          _buildAnimatedBubble(left: -329, top: -446, size: 700, 
              colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, 
              colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]),

          // 3. MAIN CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _fadeIn(
                  delay: 0,
                  child: Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
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
                        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Full Name"),
                            _buildGlassTextField(hint: "John Doe"),
                            const SizedBox(height: 20),

                            _buildLabel("Email"),
                            _buildGlassTextField(hint: "example@example.com"),
                            const SizedBox(height: 20),

                            _buildLabel("Mobile Number"),
                            _buildGlassTextField(hint: "+ 123 456 789"),
                            const SizedBox(height: 20),

                            _buildLabel("Date Of Birth"),
                            _buildGlassTextField(hint: "DD / MM / YYYY"),
                            const SizedBox(height: 20),

                            _buildLabel("Password"),
                            _buildGlassTextField(
                              hint: "••••••••",
                              isPassword: true,
                              obscureText: _isObscured,
                              toggleVisibility: () {
                                HapticFeedback.selectionClick();
                                setState(() => _isObscured = !_isObscured);
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildLabel("Confirm Password"),
                            _buildGlassTextField(
                              hint: "••••••••",
                              isPassword: true,
                              obscureText: _isConfirmObscured,
                              toggleVisibility: () {
                                HapticFeedback.selectionClick();
                                setState(() => _isConfirmObscured = !_isConfirmObscured);
                              },
                            ),
                            const SizedBox(height: 30),

                            // Terms and Privacy Text
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "By continuing, you agree to\nTerms of Use and Privacy Policy.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: kTealAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            _buildMainButton(
                              text: "Sign Up",
                              color: Colors.white,
                              textColor: kDeepBlue,
                              onPressed: () {},
                            ),

                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.leagueSpartan(
                                      color: kLabelColor,
                                      fontSize: 14,
                                    ),
                                    children: const [
                                      TextSpan(text: "Already have an account? "),
                                      TextSpan(
                                        text: "Log In",
                                        style: TextStyle(
                                          color: kTealAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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

  // --- REUSABLE WIDGETS (Slightly adjusted for spacing) ---

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

  Widget _buildGlassTextField({required String hint, bool isPassword = false, bool obscureText = false, VoidCallback? toggleVisibility}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: kInputBg.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            obscureText: obscureText,
            cursorColor: kTealAccent,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              suffixIcon: isPassword ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                onPressed: toggleVisibility,
              ) : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({required String text, required Color color, required Color textColor, required VoidCallback onPressed}) {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(text, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 8),
      child: Text(text, style: GoogleFonts.poppins(color: kLabelColor, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}