import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new_password_screen.dart';

class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> with TickerProviderStateMixin {
  
  // Exact Color Palette for Brand Consistency
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kInputBg = Color(0xFF53558A);
  static const kTealAccent = Color(0xFF3EC4BE);
  static const kLabelColor = Color(0xFF093030);
  static const kSocialIconColor = Color(0xFF0E3E3E);

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

          // 2. THE BUBBLES (Same as Login/Signup/Forgot)
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
                    'Security Pin',
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
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
                      child: Column(
                        children: [
                            Text(
                              "Enter Security Pin",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: kLabelColor,
                              ),
                            ),
                            const SizedBox(height: 50),
                            
                            // 6-Digit Pin Input Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(6, (index) => _buildPinBox()),
                            ),
                            
                            const SizedBox(height: 80),
                            
                            // Accept Button (White)
                            _buildMainButton(
                              text: "Accept",
                              color: Colors.white,
                              textColor: kLabelColor,
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const NewPasswordScreen()));
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Send Again Button (Dark/Purplish)
                            _buildMainButton(
                              text: "Send Again",
                              color: kInputBg,
                              textColor: Colors.white,
                              onPressed: () {},
                            ),
                            
                            const SizedBox(height: 120),

                            Center(
                              child: Text(
                                "or sign up with",
                                style: GoogleFonts.leagueSpartan(
                                  color: kLabelColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _socialIcon(Icons.facebook),
                                const SizedBox(width: 25),
                                _socialIcon(Icons.g_mobiledata, isGoogle: true),
                              ],
                            ),
                            const SizedBox(height: 30),
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
                                      TextSpan(text: "Don't have an account? "),
                                      TextSpan(
                                        text: "Sign Up",
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

  // --- PIN BOX WIDGET ---
  Widget _buildPinBox() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: kTealAccent.withOpacity(0.3), width: 1),
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kDeepBlue,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.length == 1) FocusScope.of(context).nextFocus();
          },
        ),
      ),
    );
  }

  // --- REUSABLE UTILS ---

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

  Widget _buildMainButton({required String text, required Color color, required Color textColor, required VoidCallback onPressed}) {
    return Container(
      height: 55,
      width: 240, // Consistent with your reference images
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

  Widget _socialIcon(IconData icon, {bool isGoogle = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kSocialIconColor.withOpacity(0.2)),
      ),
      child: Icon(icon, size: isGoogle ? 35 : 25, color: kSocialIconColor),
    );
  }
}
