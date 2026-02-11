import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_nav_bar.dart';
import 'ocr_screen.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({super.key, required this.entry});

  final TransactionEntry entry;

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> with TickerProviderStateMixin {
  static const kDeepBlue = Color(0xFF191A4C);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF093030);
  static const kAccentPurple = Color(0xFF5E5F92);

  final TextEditingController _dateController = TextEditingController();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  
  DateTime _selectedDate = DateTime.now();
  late String _selectedCategory;

  // Voice Animation Logic
  bool isListening = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.entry.dateTime;
    _dateController.text = _formatDate(_selectedDate);
    _titleController = TextEditingController(text: widget.entry.title);
    _amountController = TextEditingController(text: widget.entry.amount.abs().toStringAsFixed(2));
    _notesController = TextEditingController(text: widget.entry.description ?? '');
    _selectedCategory = widget.entry.category;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startVoiceEntry() {
    HapticFeedback.heavyImpact();
    setState(() => isListening = true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => isListening = false);
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
        selectedIndex: 0, // Keep focus on Home/Transactions
        onTap: (index) {},
      ),
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

          _buildAnimatedBubble(left: -329, top: -446, size: 700, colors: [kDeepBlue, const Color(0xFF3A3CB2)]),
          _buildAnimatedBubble(left: -225, top: -342, size: 492, colors: [const Color(0xFF9599D3), const Color(0xFF444993)]),

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
                          _fadeIn(
                            delay: 100,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildActionBtn(
                                    label: "Rescan",
                                    icon: Icons.refresh_rounded,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OcrScreen())),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildActionBtn(
                                    label: "Voice Update",
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
                          _buildCategoryDropdown(),
                          const SizedBox(height: 25),
                          _buildInputField("Amount", "Rs 0.00", controller: _amountController),
                          const SizedBox(height: 25),
                          _buildInputField("Expense Title", "Dinner", controller: _titleController),
                          const SizedBox(height: 25),
                          _buildInputField("Notes", "Enter message here...", isTextArea: true, controller: _notesController),
                          const SizedBox(height: 40),
                          
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await _deleteEntry();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.redAccent),
                                    minimumSize: const Size(0, 50),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  ),
                                  child: Text("Delete", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    HapticFeedback.mediumImpact();
                                    await _updateEntry();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kDeepBlue, 
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 50),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    elevation: 2,
                                  ),
                                  child: Text("Update Changes", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
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
          Text("Update the amount or title by voice", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
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
            maxLines: isTextArea ? 4 : 1,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.poppins(color: kTextDark, fontSize: 15),
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

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark.withOpacity(0.8))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kAccentPurple),
              style: GoogleFonts.poppins(color: kTextDark, fontSize: 15),
              items: TransactionService.categories
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateEntry() async {
    final auth = AuthScope.of(context);
    final email = auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      return;
    }

    final title = _titleController.text.trim();
    final rawAmount = _amountController.text.trim().replaceAll(',', '');
    final notes = _notesController.text.trim();

    if (title.isEmpty || rawAmount.isEmpty) {
      return;
    }

    final cleanedAmount = rawAmount.replaceAll(RegExp(r'(?i)rs'), '').replaceAll('\$', '').trim();
    final parsed = double.tryParse(cleanedAmount);
    if (parsed == null) {
      return;
    }

    final now = DateTime.now();
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
    );

    final updated = widget.entry.copyWith(
      title: title,
      category: _selectedCategory,
      amount: -parsed.abs(),
      dateTime: dateTime,
      description: notes.isEmpty ? null : notes,
    );

    await TransactionService.instance.updateForUser(email, updated);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  Future<void> _deleteEntry() async {
    final auth = AuthScope.of(context);
    final email = auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      return;
    }

    await TransactionService.instance.deleteForUser(email, widget.entry.id);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.white)),
          Text("Edit Expense", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const Icon(Icons.check, color: Colors.white, size: 22),
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
      child: Opacity(
        opacity: 0.4, 
        child: Container(
          width: size, 
          height: size, 
          decoration: ShapeDecoration(
            gradient: LinearGradient(colors: colors), // Fixed: Now uses the passed colors
            shape: const OvalBorder(),
          ),
        ),
      ),
    );
  }
}