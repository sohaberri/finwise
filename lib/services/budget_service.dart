import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BudgetData {
  final double monthlyIncome;
  final Map<String, double> allocations;
  final String? lastIncomeMonth;

  BudgetData({
    required this.monthlyIncome,
    required this.allocations,
    this.lastIncomeMonth,
  });

  BudgetData copyWith({
    double? monthlyIncome,
    Map<String, double>? allocations,
    String? lastIncomeMonth,
  }) {
    return BudgetData(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      allocations: allocations ?? this.allocations,
      lastIncomeMonth: lastIncomeMonth ?? this.lastIncomeMonth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyIncome': monthlyIncome,
      'allocations': allocations,
      'lastIncomeMonth': lastIncomeMonth,
    };
  }

  static BudgetData fromJson(Map<String, dynamic> json) {
    final rawAllocations = json['allocations'] as Map<String, dynamic>? ?? {};
    final allocations = rawAllocations.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    return BudgetData(
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      allocations: allocations,
      lastIncomeMonth: json['lastIncomeMonth'] as String?,
    );
  }
}

class BudgetService {
  BudgetService._();

  static final BudgetService instance = BudgetService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<BudgetData?> loadForUser(String email) async {
    await init();
    final raw = _prefs?.getString(_storageKey(email));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return BudgetData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> saveForUser(String email, BudgetData budget) async {
    await init();
    final monthKey = _currentMonthKey();
    final shouldAddIncome = budget.monthlyIncome > 0 && budget.lastIncomeMonth != monthKey;
    final updated = shouldAddIncome ? budget.copyWith(lastIncomeMonth: monthKey) : budget;

    // TODO: Replace with backend write for budget configuration.
    await _prefs?.setString(_storageKey(email), jsonEncode(updated.toJson()));
    return shouldAddIncome;
  }

  String _storageKey(String email) => 'budget.$email';

  String _currentMonthKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    return '${now.year}-$month';
  }
}
