import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/transaction_service.dart';
import 'services/budget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  await TransactionService.instance.init();
  await BudgetService.instance.init();
  runApp(AuthScope(auth: authService, child: Finwise(authService: authService)));
}

class Finwise extends StatelessWidget {
  const Finwise({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: authService.isLoggedIn ? const DashboardScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}