import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<TransactionEntry>> loadForUser(String email) async {
    await init();
    final raw = _prefs?.getString(_storageKey(email));
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => TransactionEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addForUser(String email, TransactionEntry entry) async {
    // TODO: Replace with backend write for creating a transaction.
    final list = await loadForUser(email);
    list.add(entry);
    await _saveForUser(email, list);
  }

  Future<void> updateForUser(String email, TransactionEntry entry) async {
    // TODO: Replace with backend write for updating a transaction.
    final list = await loadForUser(email);
    final index = list.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      return;
    }
    list[index] = entry;
    await _saveForUser(email, list);
  }

  Future<void> deleteForUser(String email, String id) async {
    // TODO: Replace with backend write for deleting a transaction.
    final list = await loadForUser(email);
    list.removeWhere((item) => item.id == id);
    await _saveForUser(email, list);
  }

  Future<void> _saveForUser(String email, List<TransactionEntry> list) async {
    await init();
    final encoded = jsonEncode(list.map((item) => item.toJson()).toList());
    await _prefs?.setString(_storageKey(email), encoded);
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
