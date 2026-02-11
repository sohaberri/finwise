import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTealAccent = Color(0xFF3EC4BE);
  static const kLabelColor = Color(0xFF093030);

  bool isActivated = false;
  int _resendTimer = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _resendTimer--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kTealGreen, // Prevents white flicker at the very bottom
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

          // 2. BACKGROUND BUBBLES
          _buildAnimatedBubble(left: -329, top: -446, size: 700, 
              colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, 
              colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]),

          // 3. MAIN CONTENT
          SafeArea(
            bottom: false, // Allows the panel to sit flush against the bottom
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 40),
                
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 50),
                      child: Column(
                        children: [
                          _fadeIn(
                            delay: 100,
                            child: Text(
                              "Awaiting Activation",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: kDeepBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _fadeIn(
                            delay: 200,
                            child: Text(
                              "We sent a verification link to your email.\nPlease check your inbox and spam folder.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                          
                          const Spacer(),

                          _fadeIn(
                            delay: 300,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() => isActivated = !isActivated);
                              },
                              child: _buildLoadingSection(),
                            ),
                          ),

                          const Spacer(),

                          _fadeIn(
                            delay: 400,
                            child: _buildMainButton(
                              text: "Next",
                              color: isActivated ? kDeepBlue : Colors.grey[400]!,
                              textColor: Colors.white,
                              onPressed: isActivated
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      );
                                    }
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          _fadeIn(
                            delay: 500,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: _canResend ? "Resend Email" : "Wait ${_resendTimer}s",
                                    icon: Icons.refresh,
                                    onPressed: _canResend ? _startTimer : null,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: "Refresh",
                                    icon: Icons.sync,
                                    onPressed: () => HapticFeedback.lightImpact(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
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

  Widget _buildLoadingSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: isActivated ? 1.0 : null,
                strokeWidth: 8,
                color: isActivated ? kTealGreen : kDeepBlue,
                backgroundColor: Colors.grey[300],
              ),
            ),
            Icon(
              isActivated ? Icons.check_circle : Icons.mark_email_read_outlined,
              size: 50,
              color: isActivated ? kTealGreen : kDeepBlue,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          isActivated ? "Account Activated!" : "Waiting for verification...",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isActivated ? kTealGreen : kDeepBlue,
          ),
        ),
        if (!isActivated)
          Text("(Tap circle to simulate)", 
            style: TextStyle(fontSize: 10, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Verification",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton({required String text, required Color color, required Color textColor, VoidCallback? onPressed}) {
    return SizedBox(
      height: 55,
      width: double.infinity,
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

  Widget _buildSecondaryButton({required String text, required IconData icon, VoidCallback? onPressed}) {
    bool isDisabled = onPressed == null;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        foregroundColor: isDisabled ? Colors.grey : kDeepBlue,
        side: BorderSide(color: isDisabled ? Colors.grey[300]! : kDeepBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _fadeIn({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
      ),
      child: child,
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size, required List<Color> colors}) {
    return Positioned(
      left: left, top: top,
      child: Opacity(
        opacity: 0.50,
        child: Container(
          width: size, height: size,
          decoration: ShapeDecoration(gradient: LinearGradient(colors: colors), shape: const OvalBorder()),
        ),
      ),
    );
  }
}