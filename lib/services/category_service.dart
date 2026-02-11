import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryEntry {
  final String id;
  final String name;
  final String icon; // icon name as string for serialization

  CategoryEntry({
    required this.id,
    required this.name,
    required this.icon,
  });

  CategoryEntry copyWith({
    String? name,
    String? icon,
  }) {
    return CategoryEntry(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  static CategoryEntry fromJson(Map<String, dynamic> json) {
    return CategoryEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }
}

class CategoryService {
  CategoryService._();

  static final CategoryService instance = CategoryService._();

  // Default categories initialized for new users
  static const List<Map<String, String>> defaultCategories = [
    {'name': 'Food', 'icon': 'restaurant'},
    {'name': 'Transport', 'icon': 'directions_bus'},
    {'name': 'Medicine', 'icon': 'medical_services'},
    {'name': 'Groceries', 'icon': 'shopping_bag'},
    {'name': 'Rent', 'icon': 'vpn_key'},
    {'name': 'Gifts', 'icon': 'card_giftcard'},
    {'name': 'Savings', 'icon': 'savings'},
    {'name': 'Entertainment', 'icon': 'confirmation_number'},
  ];

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<CategoryEntry>> loadForUser(String email) async {
    await init();
    final raw = _prefs?.getString(_storageKey(email));

    // If no categories exist, initialize with defaults
    if (raw == null || raw.isEmpty) {
      final defaults = <CategoryEntry>[];
      for (final cat in defaultCategories) {
        defaults.add(CategoryEntry(
          id: '${cat['name']}_${DateTime.now().millisecondsSinceEpoch}',
          name: cat['name']!,
          icon: cat['icon']!,
        ));
      }
      await _saveForUser(email, defaults);
      return defaults;
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => CategoryEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addForUser(String email, CategoryEntry entry) async {
    // TODO: Replace with backend write for creating a category.
    final list = await loadForUser(email);
    list.add(entry);
    await _saveForUser(email, list);
  }

  Future<void> updateForUser(String email, CategoryEntry entry) async {
    // TODO: Replace with backend write for updating a category.
    final list = await loadForUser(email);
    final index = list.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      return;
    }
    list[index] = entry;
    await _saveForUser(email, list);
  }

  Future<void> deleteForUser(String email, String id) async {
    // TODO: Replace with backend write for deleting a category.
    final list = await loadForUser(email);
    list.removeWhere((item) => item.id == id);
    await _saveForUser(email, list);
  }

  Future<void> _saveForUser(String email, List<CategoryEntry> list) async {
    await init();
    final encoded = jsonEncode(list.map((item) => item.toJson()).toList());
    await _prefs?.setString(_storageKey(email), encoded);
  }

  String _storageKey(String email) => 'categories.$email';
}
