import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activation_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  // Controllers for validation
  final TextEditingController _passController = TextEditingController();

  // Validation States
  bool hasUppercase = false;
  bool hasDigits = false;
  bool hasSpecialCharacters = false;
  bool hasMinLength = false;

  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kInputBg = Color(0xFF53558A);
  static const kTealAccent = Color(0xFF3EC4BE);
  static const kLabelColor = Color(0xFF093030);

  @override
  void initState() {
    super.initState();
    // Listen to password changes
    _passController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _passController.text;
    setState(() {
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasDigits = password.contains(RegExp(r'[0-9]'));
      hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasMinLength = password.length >= 8;
    });
  }

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kDeepBlue, kTealGreen],
              ),
            ),
          ),
          _buildAnimatedBubble(left: -329, top: -446, size: 700, 
              colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, 
              colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _fadeIn(
                  delay: 0,
                  child: Text('Create Account',
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: kFormBg,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(70), topRight: Radius.circular(70)),
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

                            _buildLabel("Password"),
                            _buildGlassTextField(
                              hint: "••••••••",
                              isPassword: true,
                              controller: _passController, // Attached controller
                              obscureText: _isObscured,
                              toggleVisibility: () {
                                HapticFeedback.selectionClick();
                                setState(() => _isObscured = !_isObscured);
                              },
                            ),
                            
                            // --- PASSWORD VALIDATION RULES ---
                            const SizedBox(height: 12),
                            _buildValidationRow("Minimum 8 characters", hasMinLength),
                            _buildValidationRow("At least 1 uppercase letter", hasUppercase),
                            _buildValidationRow("At least 1 number", hasDigits),
                            _buildValidationRow("At least 1 special symbol", hasSpecialCharacters),
                            
                            const SizedBox(height: 25),

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

                            _buildMainButton(
                              text: "Sign Up",
                              color: Colors.white,
                              textColor: kDeepBlue,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ActivationScreen()),
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.leagueSpartan(color: kLabelColor, fontSize: 14),
                                    children: const [
                                      TextSpan(text: "Already have an account? "),
                                      TextSpan(text: "Log In", style: TextStyle(color: kTealAccent, fontWeight: FontWeight.bold)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for validation indicators
  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 15),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle,
            size: 14,
            color: isValid ? kTealGreen : Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isValid ? kTealGreen : Colors.grey,
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required String hint, 
    bool isPassword = false, 
    bool obscureText = false, 
    VoidCallback? toggleVisibility,
    TextEditingController? controller,
  }) {
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
            controller: controller,
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

  // --- REST OF YOUR UI WIDGETS ---
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 15, bottom: 8),
    child: Text(text, style: GoogleFonts.poppins(color: kLabelColor, fontSize: 14, fontWeight: FontWeight.w500)),
  );

  Widget _buildMainButton({required String text, required Color color, required Color textColor, required VoidCallback onPressed}) {
    return SizedBox(
      height: 55, width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: textColor,
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
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, slideOffset * (1 - value)), child: child)),
      child: child,
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size, required List<Color> colors}) {
    return Positioned(left: left, top: top, child: Opacity(opacity: 0.50, child: Container(width: size, height: size, decoration: ShapeDecoration(gradient: LinearGradient(colors: colors), shape: const OvalBorder()))));
  }
}