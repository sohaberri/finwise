import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  static const kDeepBlue = Color(0xFF393078);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kCategoryColor = Color(0xFF81C9CC);

  final _nameController = TextEditingController();
  
  // Map icon names to IconData for selection
  final Map<String, IconData> availableIcons = {
    'restaurant': Icons.restaurant,
    'directions_bus': Icons.directions_bus,
    'medical_services': Icons.medical_services,
    'shopping_bag': Icons.shopping_bag,
    'vpn_key': Icons.vpn_key,
    'card_giftcard': Icons.card_giftcard,
    'savings': Icons.savings,
    'confirmation_number': Icons.confirmation_number,
    'flight_takeoff': Icons.flight_takeoff,
    'favorite': Icons.favorite,
    'auto_awesome': Icons.auto_awesome,
  };

  String selectedIconName = 'auto_awesome';
  String previewName = "Category Name";

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        previewName = _nameController.text.isEmpty ? "Category Name" : _nameController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. VIBRANT GRADIENT BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kDeepBlue, kTealGreen],
              ),
            ),
          ),

          _buildAnimatedBubble(left: -329, top: -446, size: 700),
          _buildAnimatedBubble(left: -225, top: -342, size: 492),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                
                // 2. LIVE PREVIEW TILE (The "Cute" Part)
                _buildLivePreview(),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: kFormBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Name: "),
                          _buildTextField(_nameController, "e.g. Dream Trip"),
                          
                          const SizedBox(height: 25),
                          
                          _buildLabel("Pick an icon"),
                          const SizedBox(height: 10),
                          _buildIconSelector(),
                          
                          const SizedBox(height: 40),
                          
                          _buildSubmitButton(),
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

  Widget _buildLivePreview() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Text(
            "Preview",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          // Animated Preview Tile
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(scale: value, child: child),
            child: Column(
              children: [
                Container(
                  height: 90, width: 90,
                  decoration: BoxDecoration(
                    color: kCategoryColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Icon(availableIcons[selectedIconName] ?? Icons.auto_awesome, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  previewName,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(colors: [kDeepBlue, Color(0xFF3A3CB2)]),
        boxShadow: [
          BoxShadow(
            color: kDeepBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final name = _nameController.text.trim();
          if (name.isEmpty) return;

          final auth = AuthScope.of(context);
          final email = auth.currentUser?.email;
          if (email == null || email.isEmpty) return;

          final entry = CategoryEntry(
            id: '${name}_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            icon: selectedIconName,
          );

          await CategoryService.instance.addForUser(email, entry);
          if (!mounted) return;
          Navigator.pop(context, true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(
          "Create Category",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: availableIcons.length,
        itemBuilder: (context, index) {
          final iconName = availableIcons.keys.toList()[index];
          final icon = availableIcons[iconName]!;
          bool isSelected = selectedIconName == iconName;
          return GestureDetector(
            onTap: () => setState(() => selectedIconName = iconName),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 65,
              margin: const EdgeInsets.only(right: 12, bottom: 10),
              decoration: BoxDecoration(
                color: isSelected ? kDeepBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(color: kDeepBlue.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))
                  else
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                ],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : kDeepBlue.withOpacity(0.5),
                size: isSelected ? 30 : 24,
              ),
            ),
          );
        },
      ),
    );
  }

  // Reuse your existing _buildAppBar, _buildLabel, _buildTextField, and bubble methods here
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          Text(
            "New Category",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: kTextDark.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 15, color: kTextDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: const EdgeInsets.all(22),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAnimatedBubble({required double left, required double top, required double size}) {
    return Positioned(
      left: left, top: top,
      child: Opacity(
        opacity: 0.4,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)]),
          ),
        ),
      ),
    );
  }
}