import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'ocr_screen.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> with TickerProviderStateMixin {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF093030);
  static const kAccentPurple = Color(0xFF5E5F92);

  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Voice Animation Logic
  bool isListening = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startVoiceEntry() {
    HapticFeedback.heavyImpact();
    setState(() => isListening = true);

    // Simulate listening for 3 seconds then stopping
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => isListening = false);
        // You would insert your Speech-to-Text result processing here
      }
    });
  }

  // --- Date Logic ---
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kAccentPurple,
              onPrimary: Colors.white,
              onSurface: kTextDark,
            ),
            dialogBackgroundColor: kFormBg,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 3,
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

          // 2. BACKGROUND BUBBLES
          _buildAnimatedBubble(left: -329, top: -446, size: 700, colors: [kDeepBlue, const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, colors: [const Color(0xFF9599D3), const Color(0xFF444993)]),

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
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ENTRY METHODS ROW
                          _fadeIn(
                            delay: 100,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildActionBtn(
                                    label: "Scan Receipt",
                                    icon: Icons.document_scanner_outlined,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OcrScreen())),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildActionBtn(
                                    label: "Voice Entry",
                                    icon: Icons.mic_none_rounded,
                                    onTap: _startVoiceEntry,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 35),
                          _buildInputField("Date", "Select date", suffixIcon: Icons.calendar_month, controller: _dateController, readOnly: true, onTap: _selectDate),
                          const SizedBox(height: 25),
                          _buildInputField("Category", "Select the category"),
                          const SizedBox(height: 25),
                          _buildInputField("Amount", "\$0.00"),
                          const SizedBox(height: 25),
                          _buildInputField("Expense Title", "Dinner"),
                          const SizedBox(height: 25),
                          _buildInputField("Enter Message", "", isTextArea: true),
                          const SizedBox(height: 40),
                          
                          Center(
                            child: ElevatedButton(
                              onPressed: () => HapticFeedback.mediumImpact(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, foregroundColor: kTextDark,
                                minimumSize: const Size(200, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                elevation: 2,
                              ),
                              child: Text("Save", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. LISTENING OVERLAY
          if (isListening) _buildListeningOverlay(),
        ],
      ),
    );
  }

  // --- CUSTOM WIDGETS ---

  Widget _buildActionBtn({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: kAccentPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kAccentPurple.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: kAccentPurple, size: 24),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.poppins(color: kAccentPurple, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningOverlay() {
    return Container(
      color: kDeepBlue.withOpacity(0.85),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseController,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: kTealGreen.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: kTealGreen, width: 2),
              ),
              child: const Icon(Icons.mic, color: kTealGreen, size: 60),
            ),
          ),
          const SizedBox(height: 30),
          Text("Listening...", style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Try saying: 'Dinner 45 dollars'", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 50),
          TextButton(
            onPressed: () => setState(() => isListening = false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String placeholder, {IconData? suffixIcon, bool isTextArea = false, TextEditingController? controller, bool readOnly = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark.withOpacity(0.8))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: controller,
            maxLines: isTextArea ? 5 : 1,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: kAccentPurple, size: 20) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
          Text("Add Expenses", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const Icon(Icons.notifications_none, color: Colors.white, size: 22),
        ],
      ),
    );
  }

  Widget _fadeIn({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child)),
      child: child,
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size, required List<Color> colors}) {
    return Positioned(
      left: left, top: top,
      child: Opacity(opacity: 0.4, child: Container(width: size, height: size, decoration: const ShapeDecoration(gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]), shape: OvalBorder()))),
    );
  }
}