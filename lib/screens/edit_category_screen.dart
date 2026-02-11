import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCategoryScreen extends StatefulWidget {
  final Map<String, dynamic> category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  static const kDeepBlue = Color(0xFF393078);
  static const kTealGreen = Color(0xFF00D09E);
  static const kFormBg = Color(0xFFF3F2FF);
  static const kTextDark = Color(0xFF052224);
  static const kCategoryColor = Color(0xFF81C9CC);

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late IconData selectedIcon;
  late String previewName;

  final List<IconData> availableIcons = [
    Icons.auto_awesome, Icons.favorite, Icons.pets, 
    Icons.shopping_bag, Icons.fastfood, Icons.fitness_center,
    Icons.movie, Icons.brush, Icons.icecream, Icons.celebration
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill data from the existing category
    _nameController = TextEditingController(text: widget.category['name']);
    _descriptionController = TextEditingController(text: widget.category['description'] ?? "");
    selectedIcon = widget.category['icon'] ?? Icons.auto_awesome;
    previewName = widget.category['name'];

    _nameController.addListener(() {
      setState(() {
        previewName = _nameController.text.isEmpty ? "Category Name" : _nameController.text;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND
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
                          _buildLabel("Update Name:"),
                          _buildTextField(_nameController, "e.g. Dream Trip"),
                          
                          const SizedBox(height: 25),
                          
                          _buildLabel("Update Description: "),
                          _buildTextField(_descriptionController, "Optional detail...", maxLines: 2),
                          
                          const SizedBox(height: 25),
                          
                          _buildLabel("Change Icon: "),
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
            "Edit Category",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          IconButton(
            onPressed: () {
              // Quick delete logic
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
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
            "Current Look",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
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
                  child: Icon(selectedIcon, color: Colors.white, size: 40),
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
          BoxShadow(color: kDeepBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Add your Save logic here!
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(
          "Save Changes ✅",
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
          bool isSelected = selectedIcon == availableIcons[index];
          return GestureDetector(
            onTap: () => setState(() => selectedIcon = availableIcons[index]),
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
                availableIcons[index],
                color: isSelected ? Colors.white : kDeepBlue.withOpacity(0.5),
                size: isSelected ? 30 : 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: kTextDark.withOpacity(0.8))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF191A4C), Color(0xFF3A3CB2)])),
        ),
      ),
    );
  }
}