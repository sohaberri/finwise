import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

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

  late ApiService _apiService;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _apiService = ApiService();
  }

  /// Load categories for user
  /// Uses local storage as fallback if backend is unavailable
  Future<List<CategoryEntry>> loadForUser(String email) async {
    await init();
    try {
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
        await _saveToLocalStorage(email, defaults);
        return defaults;
      }

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => CategoryEntry.fromJson(item as Map<String, dynamic>))
          .toList();

      // TODO: Replace with backend call when available
      // const url = '/api/categories/list/';
      // final response = await _apiService.get(url);
      // final data = jsonDecode(response.body);
      // final categories = (data['categories'] as List)
      //     .map((item) => CategoryEntry.fromJson(item as Map<String, dynamic>))
      //     .toList();
      // 
      // // Cache locally
      // await _saveToLocalStorage(email, categories);
      // return categories;
    } catch (e) {
      // Fallback to local storage
      final raw = _prefs?.getString(_storageKey(email));
      if (raw == null || raw.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => CategoryEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  /// Add a new category
  Future<void> addForUser(String email, CategoryEntry entry) async {
    // TODO: Replace with backend call when available
    // const url = '/api/categories/add/';
    // final response = await _apiService.post(url, entry.toJson());

    // Fallback: save to local storage
    final list = await _loadFromLocalStorage(email);
    list.add(entry);
    await _saveToLocalStorage(email, list);
  }

  /// Update an existing category
  Future<void> updateForUser(String email, CategoryEntry entry) async {
    // TODO: Replace with backend call when available
    // final url = '/api/categories/${entry.id}/';
    // final response = await _apiService.put(url, entry.toJson());

    // Fallback: update local storage
    final list = await _loadFromLocalStorage(email);
    final index = list.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      return;
    }
    list[index] = entry;
    await _saveToLocalStorage(email, list);
  }

  /// Delete a category
  Future<void> deleteForUser(String email, String id) async {
    // TODO: Replace with backend call when available
    // final url = '/api/categories/$id/';
    // await _apiService.delete(url);

    // Fallback: delete from local storage
    final list = await _loadFromLocalStorage(email);
    list.removeWhere((item) => item.id == id);
    await _saveToLocalStorage(email, list);
  }

  /// Load categories from local storage
  Future<List<CategoryEntry>> _loadFromLocalStorage(String email) async {
    final raw = _prefs?.getString(_storageKey(email));
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => CategoryEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Save categories to local storage
  Future<void> _saveToLocalStorage(String email, List<CategoryEntry> list) async {
    final encoded = jsonEncode(list.map((item) => item.toJson()).toList());
    await _prefs?.setString(_storageKey(email), encoded);
  }

  String _storageKey(String email) => 'categories.$email';
}
