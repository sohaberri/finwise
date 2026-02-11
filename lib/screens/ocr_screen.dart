import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_nav_bar.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  // Original Color Palette
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF093030);
  static const kAccentPurple = Color(0xFF5E5F92);

  final ImagePicker _imagePicker = ImagePicker();
  File? _receiptImage;

  Future<void> _pickReceiptImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _receiptImage = File(picked.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 3, // Layers icon active as per screenshot
        onTap: (index) {},
      ),
      body: Stack(
        children: [
          // 1. BASE GRADIENT (Consistent with old pages)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kDeepBlue, kTealGreen],
              ),
            ),
          ),

          // 2. BACKGROUND BUBBLES (Elastic scale animation)
          _buildAnimatedBubble(left: -329, top: -446, size: 700),
          _buildAnimatedBubble(left: -225, top: -342, size: 492),

          // 3. MAIN CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // RECEIPT / SCAN AREA
                          _buildScanPlaceholder(),
                          
                          const SizedBox(height: 40),

                          // SAVE BUTTON
                          ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              // Save logic here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: kTextDark,
                              minimumSize: const Size(220, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                              shadowColor: kAccentPurple.withOpacity(0.3),
                            ),
                            child: Text(
                              "Save",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Spacer to push content slightly up from the nav bar
                          const SizedBox(height: 100),
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

  Widget _buildScanPlaceholder() {
    final hasImage = _receiptImage != null;
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: Colors.grey.shade400, // Grey placeholder for image
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kAccentPurple.withOpacity(0.5), width: 4),
        boxShadow: [
          BoxShadow(
            color: kAccentPurple.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            HapticFeedback.heavyImpact();
            _pickReceiptImage();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: hasImage
                ? Image.file(
                    _receiptImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Tap to Scan Receipt",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
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
          Text(
            "Add Expenses",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ANIMATION METHODS (Kept identical for consistency)
  Widget _fadeIn({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size}) {
    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.elasticOut,
        builder: (context, value, child) => Transform.scale(
          scale: value,
          alignment: Alignment.center,
          child: child,
        ),
        child: Opacity(
          opacity: 0.50,
          child: Container(
            width: size,
            height: size,
            decoration: const ShapeDecoration(
              gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]),
              shape: OvalBorder(),
            ),
          ),
        ),
      ),
    );
  }
}