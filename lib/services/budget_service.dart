import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

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

  late ApiService _apiService;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _apiService = ApiService();
  }

  /// Load budget data for user
  /// Uses local storage as fallback if backend is unavailable
  Future<BudgetData?> loadForUser(String email) async {
    await init();
    try {
      // TODO: Replace with backend call when available
      // const url = '/api/budgets/list/';
      // final response = await _apiService.get(url);
      // final data = jsonDecode(response.body);
      // final budget = BudgetData.fromJson(data['budget'] as Map<String, dynamic>);
      // 
      // // Cache locally
      // await _prefs?.setString(_storageKey(email), jsonEncode(budget.toJson()));
      // return budget;

      // Fallback to local storage
      final raw = _prefs?.getString(_storageKey(email));
      if (raw == null || raw.isEmpty) {
        return null;
      }
      return BudgetData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      // Fallback to local storage on error
      final raw = _prefs?.getString(_storageKey(email));
      if (raw == null || raw.isEmpty) {
        return null;
      }
      return BudgetData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  /// Save budget data for user
  /// Uses local storage as fallback if backend is unavailable
  Future<bool> saveForUser(String email, BudgetData budget) async {
    await init();
    final monthKey = _currentMonthKey();
    final shouldAddIncome = budget.monthlyIncome > 0 && budget.lastIncomeMonth != monthKey;
    final updated = shouldAddIncome ? budget.copyWith(lastIncomeMonth: monthKey) : budget;

    try {
      // TODO: Replace with backend call when available
      // const url = '/api/budgets/set/';
      // final response = await _apiService.post(url, updated.toJson());

      // Save to local storage as well for offline access
      await _prefs?.setString(_storageKey(email), jsonEncode(updated.toJson()));
      return shouldAddIncome;
    } catch (e) {
      // Fallback: save to local storage only
      await _prefs?.setString(_storageKey(email), jsonEncode(updated.toJson()));
      return shouldAddIncome;
    }
  }

  String _storageKey(String email) => 'budget.$email';

  String _currentMonthKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    return '${now.year}-$month';
  }
}
