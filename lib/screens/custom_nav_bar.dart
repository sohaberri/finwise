import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'analysis_screen.dart' show AnalysisScreen;
import 'categories_screen.dart' show CategoriesScreen;
import 'dashboard_screen.dart' show DashboardScreen;
import 'profile_home_screen.dart' show ProfileHomeScreen;
import 'transaction_screen.dart' show TransactionScreen;

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Exact panel color from screenshot
    const kNavPanelColor = Color(0xFF9EA6D9); 

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF9599D4),
        // Matches the "pill" shape of the panel
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, Icons.home_outlined, 0),
            _buildNavItem(context, Icons.analytics_outlined, 1),
            _buildNavItem(context, Icons.compare_arrows_rounded, 2),
            _buildNavItem(context, Icons.layers_outlined, 3),
            _buildNavItem(context, Icons.person_outline, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Smooth clicking animation
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap(index);
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            }
            if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AnalysisScreen()),
              );
            }
            if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TransactionScreen()),
              );
            }
            if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CategoriesScreen()),
              );
            }
            if (index == 4) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileHomeScreen()),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}