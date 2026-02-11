import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class TransactionEntry {
  final String id;
  final String title;
  final String category;
  final String? savingsGoal;
  final double amount;
  final DateTime dateTime;
  final String? description;

  TransactionEntry({
    required this.id,
    required this.title,
    required this.category,
    this.savingsGoal,
    required this.amount,
    required this.dateTime,
    this.description,
  });

  TransactionEntry copyWith({
    String? title,
    String? category,
    String? savingsGoal,
    double? amount,
    DateTime? dateTime,
    String? description,
  }) {
    return TransactionEntry(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'savingsGoal': savingsGoal,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'description': description,
    };
  }

  static TransactionEntry fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      savingsGoal: json['savingsGoal'] as String?,
      amount: (json['amount'] as num).toDouble(),
      dateTime: DateTime.parse(json['dateTime'] as String),
      description: json['description'] as String?,
    );
  }
}

class TransactionService {
  TransactionService._();

  static final TransactionService instance = TransactionService._();

  static const List<String> categories = [
    'Food',
    'Transport',
    'Medicine',
    'Groceries',
    'Rent',
    'Gifts',
    'Savings',
    'Entertainment',
  ];

  static const Map<String, String> categoryIconNames = {
    'Food': 'restaurant',
    'Transport': 'directions_bus',
    'Medicine': 'medical_services',
    'Groceries': 'shopping_bag',
    'Rent': 'vpn_key',
    'Gifts': 'card_giftcard',
    'Savings': 'savings',
    'Entertainment': 'confirmation_number',
  };

  late ApiService _apiService;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _apiService = ApiService();
  }

  /// Load transactions for user
  /// Uses local storage as fallback if backend is unavailable
  Future<List<TransactionEntry>> loadForUser(String email) async {
    await init();
    try {
      // TODO: Replace with backend call when available
      // const url = '/api/transactions/list/';
      // final response = await _apiService.get(url);
      // final data = jsonDecode(response.body);
      // final transactions = (data['transactions'] as List)
      //     .map((item) => TransactionEntry.fromJson(item as Map<String, dynamic>))
      //     .toList();
      // 
      // // Cache locally
      // await _cacheTransactionsLocally(email, transactions);
      // return transactions;

      // Fallback to local storage
      return _loadFromLocalStorage(email);
    } catch (e) {
      return _loadFromLocalStorage(email);
    }
  }

  /// Add a new transaction
  Future<void> addForUser(String email, TransactionEntry entry) async {
    // TODO: Replace with backend call when available
    // const url = '/api/transactions/add/';
    // final response = await _apiService.post(url, {
    //   'title': entry.title,
    //   'category': entry.category,
    //   'savingsGoal': entry.savingsGoal,
    //   'amount': entry.amount,
    //   'dateTime': entry.dateTime.toIso8601String(),
    //   'description': entry.description,
    // });
    // 
    // final data = jsonDecode(response.body);
    // // Update local cache with server response
    // _saveToLocalStorage(email, [...await _loadFromLocalStorage(email), entry]);

    // Fallback: save to local storage
    final list = await _loadFromLocalStorage(email);
    list.add(entry);
    await _saveToLocalStorage(email, list);
  }

  /// Update an existing transaction
  Future<void> updateForUser(String email, TransactionEntry entry) async {
    // TODO: Replace with backend call when available
    // final url = '/api/transactions/${entry.id}/';
    // final response = await _apiService.put(url, {
    //   'title': entry.title,
    //   'category': entry.category,
    //   'savingsGoal': entry.savingsGoal,
    //   'amount': entry.amount,
    //   'dateTime': entry.dateTime.toIso8601String(),
    //   'description': entry.description,
    // });

    // Fallback: update local storage
    final list = await _loadFromLocalStorage(email);
    final index = list.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      return;
    }
    list[index] = entry;
    await _saveToLocalStorage(email, list);
  }

  /// Delete a transaction
  Future<void> deleteForUser(String email, String id) async {
    // TODO: Replace with backend call when available
    // final url = '/api/transactions/$id/';
    // await _apiService.delete(url);

    // Fallback: delete from local storage
    final list = await _loadFromLocalStorage(email);
    list.removeWhere((item) => item.id == id);
    await _saveToLocalStorage(email, list);
  }

  /// Load transactions from local storage
  Future<List<TransactionEntry>> _loadFromLocalStorage(String email) async {
    final raw = _prefs?.getString(_storageKey(email));
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => TransactionEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Save transactions to local storage
  Future<void> _saveToLocalStorage(String email, List<TransactionEntry> list) async {
    final encoded = jsonEncode(list.map((item) => item.toJson()).toList());
    await _prefs?.setString(_storageKey(email), encoded);
  }

  /// Cache transactions locally for offline access
  Future<void> _cacheTransactionsLocally(String email, List<TransactionEntry> transactions) async {
    await _saveToLocalStorage(email, transactions);
  }

  String _storageKey(String email) => 'transactions.$email';
}

String formatTransactionAmount(double amount) {
  final sign = amount < 0 ? '-' : '';
  final value = amount.abs().toStringAsFixed(2);
  return '$sign Rs $value';
}

String formatTransactionDateTime(DateTime dateTime) {
  final hours = dateTime.hour.toString().padLeft(2, '0');
  final minutes = dateTime.minute.toString().padLeft(2, '0');
  final month = _monthName(dateTime.month);
  return '$hours:$minutes - $month ${dateTime.day}';
}

String _monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}
