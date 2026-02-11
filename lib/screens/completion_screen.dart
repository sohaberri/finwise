import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // Ensure this matches your login file name

class SuccessScreen extends StatefulWidget {
  final bool autoClose;
  
  const SuccessScreen({super.key, this.autoClose = true});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with TickerProviderStateMixin {
  
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);

  @override
  void initState() {
    super.initState();
    if (widget.autoClose) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (widget.autoClose) {
            Navigator.pop(context);
          } else {
            // Navigates back to login and clears the navigation stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: Stack(
          clipBehavior: Clip.none, // Allows bubbles to hang off the edge
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

            // 2. THE BUBBLES (With original offsets and animations)
            _buildAnimatedBubble(right: -329, top: -446, size: 700, 
                colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]),
            _buildAnimatedBubble(right: -225, top: -342, size: 492, 
                colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]),
            _buildAnimatedBubble(left: -150, bottom: -150, size: 400, 
                colors: [kTealGreen.withOpacity(0.5), kDeepBlue.withOpacity(0.3)]),

            // 3. MAIN CONTENT
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedTick(),
                  const SizedBox(height: 40),
                  _fadeIn(
                    delay: 500,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Completed",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ANIMATED TICK WIDGET (With Safety Clamp) ---
  Widget _buildAnimatedTick() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        // .clamp(0.0, 1.0) prevents the opacity from crashing the app during the "bounce"
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(value.clamp(0.0, 1.0)),
              width: 4,
            ),
          ),
          child: Transform.scale(
            scale: value,
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 80),
          ),
        );
      },
    );
  }

  // --- REUSABLE UTILS ---

  Widget _fadeIn({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeIn,
      builder: (context, value, child) {
        return Opacity(opacity: value.clamp(0.0, 1.0), child: child);
      },
      child: child,
    );
  }

  Widget _buildAnimatedBubble({
    double? left, 
    double? right, 
    double? top, 
    double? bottom, 
    required double size, 
    required List<Color> colors
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1.0),
        duration: const Duration(seconds: 3),
        curve: Curves.easeInOutSine,
        builder: (context, value, child) => Transform.scale(scale: value, child: child),
        child: Opacity(
          opacity: 0.6,
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