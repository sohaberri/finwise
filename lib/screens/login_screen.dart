import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // Added for Haptic Feedback

import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_screen.dart';
import 'profile_home_screen.dart';
import 'dashboard_screen.dart';
import '../services/auth_service.dart';



class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});



  @override

  State<LoginScreen> createState() => _LoginScreenState();

}



class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {

  bool _isObscured = true;
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;



  // Exact Color Palette

  static const kDeepBlue = Color(0xFF191A4C);

  static const kTealGreen = Color(0xFF00D09E);

  static const kFormBg = Color(0xFFF3F2FF);

  static const kInputBg = Color(0xFF53558A);

  static const kPrimaryPurple = Color(0xFF5345C0);

  static const kTealAccent = Color(0xFF3EC4BE);

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



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

                    'Welcome',

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

                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 50),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                            _buildLabel("Email"),

                            _buildGlassTextField(
                              hint: "example@example.com",
                              controller: _identifierController,
                            ),

                            const SizedBox(height: 25),

                            _buildLabel("Password"),

                            _buildGlassTextField(

                              hint: "••••••••",

                              isPassword: true,

                              controller: _passwordController,

                              obscureText: _isObscured,

                              toggleVisibility: () {

                                HapticFeedback.selectionClick();

                                setState(() => _isObscured = !_isObscured);

                              },

                            ),

                            if (_errorText != null) ...[

                              const SizedBox(height: 10),

                              Text(

                                _errorText!,

                                style: GoogleFonts.poppins(

                                  color: Colors.redAccent,

                                  fontSize: 12,

                                  fontWeight: FontWeight.w500,

                                ),

                              ),

                            ],

                            const SizedBox(height: 30),

                            _buildMainButton(

                              text: "Log In",

                              color: Colors.white,

                              textColor: Colors.black,

                              onPressed: () async {

                                final auth = AuthScope.of(context);

                                final email = _identifierController.text.trim();

                                final password = _passwordController.text;



                                if (email.isEmpty || password.isEmpty) {

                                  setState(() {

                                    _errorText = 'Please enter your email and password.';

                                  });

                                  return;

                                }



                                final isValid = await auth.login(

                                  email: email,

                                  password: password,

                                );



                                if (!mounted) {

                                  return;

                                }



                                if (isValid) {

                                  setState(() => _errorText = null);

                                  Navigator.pushAndRemoveUntil(

                                    context,

                                    MaterialPageRoute(builder: (context) => const DashboardScreen()),

                                    (route) => false,

                                  );

                                } else {

                                  setState(() {

                                    _errorText = 'Invalid credentials. Please try again.';

                                  });

                                }

                              },

                            ),

                            Center(

                              child: TextButton(

                                onPressed: () {

                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));

                                },

                                child: Text(

                                  "Forgot Password?",

                                  style: GoogleFonts.leagueSpartan(

                                    color: Colors.black,

                                    fontWeight: FontWeight.w600,

                                    fontSize: 14,

                                  ),

                                ),

                              ),

                            ),

                            _buildMainButton(

                              text: "Sign Up",

                              color: kPrimaryPurple,

                              textColor: Colors.white,

                              onPressed: () {

                                Navigator.pushNamed(context, '/signup');

                              },

                            ),

                            const SizedBox(height: 40),

                            Center(

                              child: Text(

                                "or sign up with",

                                style: GoogleFonts.leagueSpartan(

                                  color: const Color(0xFF093030),

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

                            const SizedBox(height: 40),

                            
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



  // SMOOTHING UTILS



  Widget _fadeIn({required Widget child, int delay = 0, double slideOffset = 30}) {

    return TweenAnimationBuilder<double>(

      tween: Tween(begin: 0.0, end: 1.0),

      duration: Duration(milliseconds: 800),

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



  Widget _buildGlassTextField({
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    TextEditingController? controller,
  }) {

    return AnimatedContainer(

      duration: const Duration(milliseconds: 300),

      child: ClipRRect(

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

      ),

    );

  }



  Widget _buildMainButton({required String text, required Color color, required Color textColor, required VoidCallback onPressed}) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),

      child: Container(

        height: 55,

        width: double.infinity,

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(30),

          boxShadow: [if (color == Colors.white) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],

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

      ),

    );

  }



  Widget _buildLabel(String text) {

    return Padding(

      padding: const EdgeInsets.only(left: 15, bottom: 8),

      child: Text(text, style: GoogleFonts.poppins(color: const Color(0xFF093030), fontSize: 14, fontWeight: FontWeight.w500)),

    );

  }



  Widget _socialIcon(IconData icon, {bool isGoogle = false}) {

    return InkWell(

      onTap: () => HapticFeedback.mediumImpact(),

      borderRadius: BorderRadius.circular(50),

      child: Container(

        width: 50,

        height: 50,

        decoration: BoxDecoration(

          shape: BoxShape.circle,

          border: Border.all(color: const Color(0xFF0E3E3E).withOpacity(0.2)),

        ),

        child: Icon(icon, size: isGoogle ? 35 : 25, color: const Color(0xFF0E3E3E)),

      ),

    );

  }

}