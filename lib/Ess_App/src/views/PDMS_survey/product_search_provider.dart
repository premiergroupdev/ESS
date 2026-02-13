// product_search_provider.dart
import 'package:ess/Ess_App/src/views/PDMS_survey/survey_form_view.dart';
import 'package:flutter/material.dart';

import '../../services/remote/api_service.dart';

class ProductSearchProvider extends ChangeNotifier {
  final ApiService apiService;

  List<SurveyDropdownItem> _loadedProducts = [];
  bool _isCacheLoaded = false;
  String _cacheStatus = '';
  bool _isLoading = false;

  ProductSearchProvider(this.apiService);

  List<SurveyDropdownItem> get loadedProducts => _loadedProducts;
  bool get isCacheLoaded => _isCacheLoaded;
  String get cacheStatus => _cacheStatus;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    if (_isCacheLoaded && _loadedProducts.isNotEmpty) {
      return; // Already loaded
    }

    _isLoading = true;
    notifyListeners();

    try {
      final cachedProducts = await apiService.getProductChunkWithCache(0, 200);

      if (cachedProducts.isNotEmpty) {
        _loadedProducts = cachedProducts;
        _isCacheLoaded = true;
        _cacheStatus = 'Loaded from cache';
      }
    } catch (e) {
      _cacheStatus = 'Error loading cache: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearCache() {
    _loadedProducts.clear();
    _isCacheLoaded = false;
    _cacheStatus = '';
    notifyListeners();
  }
}