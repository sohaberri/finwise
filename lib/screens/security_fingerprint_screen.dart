import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_screen.dart';
import 'security_face_id_screen.dart';

class SecurityFingerprintScreen extends StatefulWidget {
  const SecurityFingerprintScreen({super.key});

  @override
  State<SecurityFingerprintScreen> createState() => _SecurityFingerprintScreenState();
}

class _SecurityFingerprintScreenState extends State<SecurityFingerprintScreen> with TickerProviderStateMixin {
  
  // Consistency Palette
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kInputBg = Color(0xFF53558A);
  static const kLabelColor = Color(0xFF093030);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT
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
                    'Security Fingerprint',
                    style: GoogleFonts.poppins(
                      fontSize: 28, // Slightly smaller to fit long title
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.1,
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
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 60),
                      child: Column(
                        children: [
                            // Large Fingerprint Illustration Circle
                            _buildFingerprintHero(),
                            
                            const SizedBox(height: 40),
                            
                            Text(
                              "Use Fingerprint To Access",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kInputBg,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Hold fingerprint in different directions",
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 14,
                                color: kLabelColor.withOpacity(0.6),
                              ),
                            ),
                            
                            const SizedBox(height: 60),
                            
                            // "Use Touch Id" Button
                            _buildMainButton(
                              text: "Use Touch Id",
                              color: kInputBg,
                              textColor: Colors.white,
                              onPressed: () {
                                // Logic for fingerprint scanner
                                HapticFeedback.heavyImpact();
                              },
                            ),
                            
                            const SizedBox(height: 40),

                            // BIOMETRIC ALTERNATIVES (As requested)
                            _biometricLink(
                              text: "Or use pincode?", 
                              icon: Icons.dialpad_rounded,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                              }
                            ),
                            const SizedBox(height: 15),
                            _biometricLink(
                              text: "Or use face id?", 
                              icon: Icons.face_retouching_natural,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityFaceIDScreen()));
                              }
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

  // --- UNIQUE WIDGETS FOR THIS SCREEN ---

  Widget _buildFingerprintHero() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Center(
        child: Icon(
          Icons.fingerprint_rounded,
          size: 100,
          color: kLabelColor.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _biometricLink({required String text, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kLabelColor.withOpacity(0.5), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.leagueSpartan(
              color: kLabelColor.withOpacity(0.7),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- CORE REUSABLE WIDGETS ---

  Widget _buildMainButton({required String text, required Color color, required Color textColor, required VoidCallback onPressed}) {
    return Container(
      height: 55,
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
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
