import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Same Brand Palette for consistency
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF093030);
  static const kFieldBg = Color(0xFF5E5F92);

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  bool _initialized = false;

  // Password validation states
  bool hasUppercase = false;
  bool hasDigits = false;
  bool hasSpecialCharacters = false;
  bool hasMinLength = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers without values - they'll be populated in didChangeDependencies
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // Listen to password changes for validation
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasDigits = password.contains(RegExp(r'[0-9]'));
      hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasMinLength = password.length >= 8;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize data after inherited widgets are available
    if (!_initialized) {
      final auth = AuthScope.of(context);
      _fullNameController.text = auth.currentUser?.fullName ?? '';
      _emailController.text = auth.currentUser?.email ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    // Check password requirements
    if (!hasMinLength || !hasUppercase || !hasDigits || !hasSpecialCharacters) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please meet all password requirements')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with backend update call.
      // Backend should:
      // 1. Validate email format and uniqueness
      // 2. Hash and store password securely
      // 3. Update user's fullName, email, and password
      // 4. Return success/error response
      // 5. Handle token refresh if needed

      final auth = AuthScope.of(context);
      await auth.updateProfile(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final currentUserName = auth.currentUser?.fullName ?? "User";

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

          // 2. ANIMATED BUBBLES (Exact same as Home Screen)
          _buildAnimatedBubble(left: -329, top: -446, size: 700, 
              colors: [const Color(0xFF191A4C), const Color(0xFF2A2B7F), const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, 
              colors: [const Color(0xFF9599D3), const Color(0xFF6C71B3), const Color(0xFF444993)]),

          // 3. MAIN CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(), // Now identical to Home Screen
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
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: Column(
                                    children: [
                                      Text(currentUserName, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: kTextDark)),
                                      Text("ID: --------", style: GoogleFonts.poppins(fontSize: 13, color: kTextDark.withOpacity(0.7))),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text("Account Settings", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
                                const SizedBox(height: 20),
                                
                                _buildInputField("Full Name", _fullNameController),
                                _buildInputField("Email Address", _emailController),
                                _buildInputField("Password", _passwordController, isPassword: true),
                                
                                // --- PASSWORD VALIDATION RULES ---
                                const SizedBox(height: 12),
                                _buildValidationRow("Minimum 8 characters", hasMinLength),
                                _buildValidationRow("At least 1 uppercase letter", hasUppercase),
                                _buildValidationRow("At least 1 number", hasDigits),
                                _buildValidationRow("At least 1 special symbol", hasSpecialCharacters),
                                
                                const SizedBox(height: 30),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _updateProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      minimumSize: const Size(200, 50),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      elevation: 0,
                                      disabledBackgroundColor: Colors.grey[300],
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text("Update Profile", style: GoogleFonts.poppins(color: kTextDark, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(height: 120),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Floating Avatar with Camera Overlay
                      _fadeIn(
                        delay: 100,
                        slideOffset: -20,
                        child: Stack(
                          children: [
                            Container(
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
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Icon(Icons.camera_alt_outlined, size: 18, color: kTextDark.withOpacity(0.5)),
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
          ),
        ],
      ),
    );
  }

  // UPDATED: Matches Home Screen AppBar exactly
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
          Text("Edit My Profile", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: kFieldBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 15),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle,
            size: 14,
            color: isValid ? const Color(0xFF00D09E) : Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isValid ? const Color(0xFF00D09E) : Colors.grey,
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
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

  // FIXED: Opacity wrap added to avoid "opacity parameter" build error
  Widget _buildAnimatedBubble({required double left, required double top, required double size, required List<Color> colors}) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          width: size, height: size,
          decoration: ShapeDecoration(
            gradient: LinearGradient(colors: colors),
            shape: const OvalBorder(),
          ),
        ),
      ),
    );
  }
}