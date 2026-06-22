import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ItemProvider extends ChangeNotifier {
  List<ItemModel> _items = [];
  List<CategoryModel> _categories = [];
  ItemModel? _selectedItem;
  bool _isLoading = false;
  String? _error;
  String? _activeCategory;
  String? _searchQuery;

  List<ItemModel> get items => _items;
  List<CategoryModel> get categories => _categories;
  ItemModel? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final _api = ApiService();

  Future<void> loadItems({String? category, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (category != null && category != 'all') params['category'] = category;
      if (search != null && search.isNotEmpty) params['search'] = search;
      final data = await _api.getItems(params: params);
      _items = (data['results'] as List).map((e) => ItemModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      final data = await _api.getCategories();
      _categories = (data as List).map((e) => CategoryModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadItem(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getItem(id);
      _selectedItem = ItemModel.fromJson(data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String? category) {
    _activeCategory = category;
    loadItems(category: category, search: _searchQuery);
  }

  void search(String query) {
    _searchQuery = query;
    loadItems(category: _activeCategory, search: query);
  }
}
