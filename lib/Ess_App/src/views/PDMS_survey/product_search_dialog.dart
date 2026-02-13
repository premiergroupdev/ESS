import 'package:flutter/material.dart';
import 'package:ess/Ess_App/src/services/remote/api_service.dart';
import 'survey_form_view.dart';

class ProductSearchDialog extends StatefulWidget {
  final ApiService apiService;

  const ProductSearchDialog({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  State<ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<ProductSearchDialog> {
  List<SurveyDropdownItem> _allProducts = [];
  List<SurveyDropdownItem> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    try {
      final response = await widget.apiService.getSurveyData('product');

      response.when(
        success: (data) {
          if (data['status'] == true && data['data'] != null) {
            _allProducts.clear();
            final List<dynamic> apiData = data['data'];

            // Load ALL products but limit display to manageable amount
            int count = 0;
            for (var item in apiData) {
              final id = item['product_code']?.toString() ?? '';
              final value = item['product_name']?.toString() ?? '';
              if (id.isNotEmpty && value.isNotEmpty) {
                _allProducts.add(SurveyDropdownItem(id: id, value: value));
                count++;
                if (count >= 1000) break; // Load only first 1000 for memory
              }
            }

            _filteredProducts = _allProducts;
            setState(() {
              _isLoading = false;
            });
            print("Loaded ${_allProducts.length} products for search");
          }
        },
        failure: (error) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _allProducts.take(50).toList(); // Show only first 50 when empty
      });
      return;
    }

    final searchTerms = query.toLowerCase().split(' ');
    final results = _allProducts.where((product) {
      final productName = product.value.toLowerCase();
      return searchTerms.every((term) => productName.contains(term));
    }).take(100).toList(); // Limit to 100 results

    setState(() {
      _filteredProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Search Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Type product name...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterProducts('');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: _filterProducts,
                autofocus: true,
              ),
            ),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                  ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text('Failed to load products'),
                  ],
                ),
              )
                  : _filteredProducts.isEmpty
                  ? const Center(child: Text('No products found'))
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(
                      product.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pop(context, product);
                    },
                  );
                },
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Text(
                'Showing ${_filteredProducts.length} of ${_allProducts.length} products',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}