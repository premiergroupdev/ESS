import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ess/Ess_App/src/services/remote/api_service.dart';
import 'survey_form_view.dart';

class ChunkedProductSearchDialog extends StatefulWidget {
  final ApiService apiService;

  const ChunkedProductSearchDialog({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  State<ChunkedProductSearchDialog> createState() => _ChunkedProductSearchDialogState();
}

class _ChunkedProductSearchDialogState extends State<ChunkedProductSearchDialog> {
  // Data management
  List<SurveyDropdownItem> _loadedProducts = [];
  List<SurveyDropdownItem> _filteredProducts = [];

  // Pagination controls
  int _currentChunk = 0;
  final int _chunkSize = 200;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreProducts = true;
  bool _initialLoadComplete = false;

  // Search controls
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  String _currentSearchQuery = '';

  // UI controls
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  // Background loading
  Timer? _backgroundLoadTimer;
  bool _backgroundLoading = false;
  int _backgroundChunksLoaded = 0;
  final int _maxBackgroundChunks = 10; // Load max 10 chunks (2000 items) in background

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialChunk();
  }

  Future<void> _loadInitialChunk() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Load first chunk
      final firstChunk = await widget.apiService.getProductChunk(0, _chunkSize);

      setState(() {
        _loadedProducts = firstChunk;
        _filteredProducts = _getLimitedProducts(_loadedProducts);
        _currentChunk = 1;
        _isLoading = false;
        _initialLoadComplete = true;
        _hasMoreProducts = firstChunk.length >= _chunkSize;
      });

      // Start background loading IMMEDIATELY
      _startBackgroundLoading();

    } catch (e) {
      setState(() {
        _isLoading = false;
        _initialLoadComplete = true;
      });
      print("Error loading initial chunk: $e");
    }
  }

  void _startBackgroundLoading() {
    if (!_hasMoreProducts || _backgroundChunksLoaded >= _maxBackgroundChunks) return;

    // Cancel any existing timer
    _backgroundLoadTimer?.cancel();

    // Start background loading after 500ms delay (let UI settle)
    _backgroundLoadTimer = Timer(const Duration(milliseconds: 500), () {
      _loadBackgroundChunks();
    });
  }

  Future<void> _loadBackgroundChunks() async {
    if (_backgroundLoading || !_hasMoreProducts || _backgroundChunksLoaded >= _maxBackgroundChunks) return;

    _backgroundLoading = true;

    try {
      // Load 2 chunks in background (400 products)
      for (int i = 0; i < 2; i++) {
        if (!_hasMoreProducts || _backgroundChunksLoaded >= _maxBackgroundChunks) break;

        await _loadNextChunkInBackground();
        _backgroundChunksLoaded++;

        // Small delay between chunks to prevent overwhelming
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // If still has more products, schedule next background load
      if (_hasMoreProducts && _backgroundChunksLoaded < _maxBackgroundChunks) {
        _scheduleNextBackgroundLoad();
      }

    } catch (e) {
      print("Error in background loading: $e");
    } finally {
      _backgroundLoading = false;
    }
  }

  Future<void> _loadNextChunkInBackground() async {
    final startIndex = _currentChunk * _chunkSize;

    try {
      final nextChunk = await widget.apiService.getProductChunk(startIndex, _chunkSize);

      if (nextChunk.isEmpty) {
        setState(() => _hasMoreProducts = false);
        return;
      }

      // Add new chunk to loaded products
      final currentIds = _loadedProducts.map((p) => p.id).toSet();
      final newItems = nextChunk.where((p) => !currentIds.contains(p.id)).toList();

      // Update state without rebuilding UI (setState without causing full rebuild)
      if (mounted) {
        setState(() {
          _loadedProducts.addAll(newItems);
          _currentChunk++;
          _hasMoreProducts = nextChunk.length >= _chunkSize;
        });

        // If user is searching, update filtered list
        if (_currentSearchQuery.isNotEmpty) {
          _performSearch(_currentSearchQuery, silent: true);
        }
      }

    } catch (e) {
      print("Error loading background chunk: $e");
    }
  }

  void _scheduleNextBackgroundLoad() {
    // Schedule next background load with random delay (1-3 seconds)
    final randomDelay = Random().nextInt(2000) + 1000; // 1-3 seconds

    _backgroundLoadTimer?.cancel();
    _backgroundLoadTimer = Timer(Duration(milliseconds: randomDelay), () {
      if (mounted && _hasMoreProducts && _backgroundChunksLoaded < _maxBackgroundChunks) {
        _loadBackgroundChunks();
      }
    });
  }

  void _onScroll() {
    // Load more when user scrolls near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMoreProducts &&
        _currentSearchQuery.isEmpty) {
      _loadNextChunk();
    }
  }

  Future<void> _loadNextChunk() async {
    if (_isLoadingMore || !_hasMoreProducts) return;

    setState(() => _isLoadingMore = true);

    try {
      final startIndex = _currentChunk * _chunkSize;
      final nextChunk = await widget.apiService.getProductChunk(startIndex, _chunkSize);

      if (nextChunk.isEmpty) {
        setState(() {
          _isLoadingMore = false;
          _hasMoreProducts = false;
        });
        return;
      }

      // Add new chunk to loaded products
      final currentIds = _loadedProducts.map((p) => p.id).toSet();
      final newItems = nextChunk.where((p) => !currentIds.contains(p.id)).toList();

      setState(() {
        _loadedProducts.addAll(newItems);
        _filteredProducts = _getLimitedProducts(_loadedProducts);
        _currentChunk++;
        _isLoadingMore = false;
        _hasMoreProducts = nextChunk.length >= _chunkSize;
      });

    } catch (e) {
      setState(() => _isLoadingMore = false);
      print("Error loading next chunk: $e");
    }
  }

  List<SurveyDropdownItem> _getLimitedProducts(List<SurveyDropdownItem> products) {
    if (_currentSearchQuery.isEmpty) {
      // For browsing, show products from all loaded chunks
      return products;
    }

    // For search, show all matching products
    return products;
  }

  void _onSearchChanged(String query) {
    _currentSearchQuery = query;

    // Debounce search
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query, {bool silent = false}) {
    if (!silent) {
      setState(() {
        _currentSearchQuery = query;
      });
    }

    if (query.isEmpty) {
      if (!silent) {
        setState(() {
          _filteredProducts = _getLimitedProducts(_loadedProducts);
        });
      }
      return;
    }

    final searchTerms = query.toLowerCase().split(' ');

    // Search in loaded products
    final results = _loadedProducts.where((product) {
      final productName = product.value.toLowerCase();
      return searchTerms.every((term) => productName.contains(term));
    }).toList();

    if (!silent) {
      setState(() {
        _filteredProducts = results;
      });
    }

    // If not enough results and we have more products to load
    if (results.length < 10 && _hasMoreProducts && !_backgroundLoading) {
      // Trigger immediate background loading for search
      _loadMoreForSearch(query);
    }
  }

  Future<void> _loadMoreForSearch(String query) async {
    if (_backgroundLoading) return;

    // Load 1 chunk immediately for better search results
    await _loadNextChunkInBackground();

    // Re-search with newly loaded products
    _performSearch(query, silent: false);
  }

  void _clearSearch() {
    _searchController.clear();
    _currentSearchQuery = '';
    _performSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Search Field
            _buildSearchField(),

            // Loading indicator for initial load
            if (_isLoading && !_initialLoadComplete)
              const Expanded(child: Center(child: CircularProgressIndicator())),

            // Results List
            if (_initialLoadComplete)
              Expanded(child: _buildResultsList()),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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

          // Background loading indicator
          if (_backgroundLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_loadedProducts.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Type to search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSearch,
          )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: _onSearchChanged,
        autofocus: true,
      ),
    );
  }

  Widget _buildResultsList() {
    if (_filteredProducts.isEmpty && _currentSearchQuery.isNotEmpty) {
      return _buildNoResults();
    }

    return Column(
      children: [
        // Results count
        if (_currentSearchQuery.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Found ${_filteredProducts.length} products',
                  style: TextStyle(color: Colors.blue[800], fontSize: 12),
                ),
                const Spacer(),
                if (_backgroundLoading)
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Loading more...',
                        style: TextStyle(color: Colors.blue[600], fontSize: 11),
                      ),
                    ],
                  ),
              ],
            ),
          ),

        // Background loading indicator while browsing
        if (_currentSearchQuery.isEmpty && _backgroundLoading && _backgroundChunksLoaded < 3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.green[50],
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading more products in background...',
                  style: TextStyle(color: Colors.green[800], fontSize: 12),
                ),
              ],
            ),
          ),

        // Products List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _filteredProducts.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _filteredProducts.length) {
                return _buildLoadMoreIndicator();
              }

              final product = _filteredProducts[index];
              return _buildProductItem(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, size: 48, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          'No products found for "${_currentSearchQuery}"',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Loaded ${_loadedProducts.length} products so far',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        if (_hasMoreProducts)
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () => _loadMoreForSearch(_currentSearchQuery),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Load more products for search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  foregroundColor: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Or wait for background loading...',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProductItem(SurveyDropdownItem product) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context, product),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.value,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${product.id}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (!_hasMoreProducts) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'All available products loaded',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${_loadedProducts.length} products',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Loading more products...',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loaded: ${_loadedProducts.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                  if (_hasMoreProducts)
                    Text(
                      'More available',
                      style: TextStyle(fontSize: 11, color: Colors.green[700]),
                    ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_currentSearchQuery.isEmpty)
                    Text(
                      'Chunks: ${_currentChunk}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  if (_backgroundLoading)
                    Text(
                      'Background loading...',
                      style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                    ),
                ],
              ),
            ],
          ),

          // Progress bar (optional)
          if (_hasMoreProducts)
            const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _loadedProducts.length / 20000, // Assuming ~20k products
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),

          // Load more button for search
          if (_currentSearchQuery.isNotEmpty && _hasMoreProducts && _filteredProducts.length < 10)
            Column(
              children: [
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _loadMoreForSearch(_currentSearchQuery),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, size: 16),
                      SizedBox(width: 8),
                      Text('Load More Products'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _backgroundLoadTimer?.cancel();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}