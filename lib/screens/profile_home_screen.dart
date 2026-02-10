import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'settings_screen.dart';

class ProfileHomeScreen extends StatefulWidget {
  const ProfileHomeScreen({super.key});

  @override
  State<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen> {
  // Brand Palette
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF093030);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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

          // 2. ANIMATED BUBBLES
          _buildAnimatedBubble(left: -329, top: -446, size: 700, 
              colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, 
              colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]),

          // 3. MAIN CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // White Panel
                      Container(
                        margin: const EdgeInsets.only(top: 60),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: kFormBg,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60),
                          ),
                        ),
                        child: _fadeIn(
                          delay: 200,
                          child: Column(
                            children: [
                              SizedBox(height: screenHeight * 0.1),
                              Text("John Smith", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kTextDark)),
                              Text("ID: 25030024", style: GoogleFonts.poppins(fontSize: 14, color: kTextDark.withOpacity(0.7))),
                              const SizedBox(height: 35), // Slightly more gap after ID
                              
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 30),
                                  child: Column(
                                    children: [
                                      _buildMenuTile(Icons.person_outline, "Edit Profile", const Color(0xFF81C9CC), onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                                      }),
                                      _buildMenuTile(Icons.shield_outlined, "Security", const Color(0xFF3EC5BE), onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen()));
                                      }),
                                      _buildMenuTile(Icons.settings_outlined, "Setting", const Color(0xFF0F78A2), onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                                      }),
                                      _buildMenuTile(Icons.headset_mic_outlined, "Help", const Color(0xFF81C9CC)),
                                      _buildMenuTile(Icons.logout_rounded, "Logout", const Color(0xFF3EC5BE)),
                                      const SizedBox(height: 120), // Dynamic space for Hot Bar
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Floating Avatar
                      _fadeIn(
                        delay: 100,
                        slideOffset: -20,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: const CircleAvatar(
                            radius: 60,
                            backgroundColor: Color(0xFFE0E0E0),
                            child: Icon(Icons.person, size: 80, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
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
          Text("Profile", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, Color color, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24), // Increased gap between buttons
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap?.call();
          },
          splashColor: color.withOpacity(0.1),
          child: Row(
            children: [
              Container(
                height: 55, // Increased from 55
                width: 55,  // Increased from 55
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: kTextDark)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: kTextDark.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fadeIn({required Widget child, int delay = 0, double slideOffset = 30}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, slideOffset * (1 - value)),
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