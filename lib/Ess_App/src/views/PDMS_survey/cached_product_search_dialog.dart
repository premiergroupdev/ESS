import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:async/async.dart'; // ADD THIS IMPORT
import 'package:ess/Ess_App/src/services/remote/api_service.dart';
import 'survey_form_view.dart';

class CachedProductSearchDialog extends StatefulWidget {
  final ApiService apiService;
  final List<SurveyDropdownItem>? initialProducts;

  // ============ PERSISTENT STATIC VARIABLES ============
  static List<SurveyDropdownItem>? _persistedProducts;
  static bool _persistedCacheLoaded = false;
  static String _persistedCacheStatus = '';
  static int _persistedProductCount = 0;
  static DateTime? _lastLoadTime;
  // =====================================================

  const CachedProductSearchDialog({
    Key? key,
    required this.apiService,
    this.initialProducts,
  }) : super(key: key);

  List<SurveyDropdownItem>? getLoadedProducts() => _persistedProducts;

  @override
  State<CachedProductSearchDialog> createState() => _CachedProductSearchDialogState();
}

class _CachedProductSearchDialogState extends State<CachedProductSearchDialog> {
  // Data management
  List<SurveyDropdownItem> _loadedProducts = [];
  List<SurveyDropdownItem> _filteredProducts = [];

  // Cache status
  bool _usingCache = true;
  bool _cacheLoaded = false;
  int _cachedProductCount = 0;
  String _cacheStatus = 'Checking cache...';

  // Pagination controls
  int _currentChunk = 0;
  final int _chunkSize = 200;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreProducts = true;
  bool _initialLoadComplete = false;

  // ============ FIXED SEARCH CONTROLS ============
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounceTimer;
  String _currentSearchQuery = '';

  // Add these variables for search management
  CancelableOperation<List<SurveyDropdownItem>>? _currentSearchOperation;
  String _lastCompletedSearchQuery = '';
  bool _isSearching = false;
  int _searchId = 0; // For tracking current search
  // ===============================================

  // UI controls
  final ScrollController _scrollController = ScrollController();

  // Background loading
  Timer? _backgroundLoadTimer;
  bool _backgroundLoading = false;
  int _backgroundChunksLoaded = 0;
  final int _maxBackgroundChunks = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeData();
  }

  void _initializeData() {
    if (widget.initialProducts != null && widget.initialProducts!.isNotEmpty) {
      print('📦 Using initial products from parent');
      _initializeWithProducts(widget.initialProducts!, 'From previous session');
      return;
    }

    final now = DateTime.now();
    final tenMinutesAgo = now.subtract(Duration(minutes: 10));

    if (CachedProductSearchDialog._persistedProducts != null &&
        CachedProductSearchDialog._persistedCacheLoaded &&
        CachedProductSearchDialog._lastLoadTime != null &&
        CachedProductSearchDialog._lastLoadTime!.isAfter(tenMinutesAgo)) {
      print('♻️ Using persisted data from static cache');
      _initializeWithProducts(
          CachedProductSearchDialog._persistedProducts!,
          CachedProductSearchDialog._persistedCacheStatus
      );
      return;
    }

    print('🔄 Loading fresh data');
    _initializeFromCache();
  }

  void _initializeWithProducts(List<SurveyDropdownItem> products, String status) {
    setState(() {
      _loadedProducts = products;
      _filteredProducts = _getLimitedProducts(_loadedProducts);
      _currentChunk = 1;
      _cacheLoaded = true;
      _usingCache = true;
      _cachedProductCount = products.length;
      _cacheStatus = status;
      _isLoading = false;
      _initialLoadComplete = true;
      _hasMoreProducts = products.length >= _chunkSize;
    });

    _startBackgroundLoading();
    _checkCacheFreshness();
  }

  Future<void> _initializeFromCache() async {
    setState(() {
      _cacheStatus = 'Loading from cache...';
      _isLoading = true;
    });

    try {
      final cachedProducts = await widget.apiService.getProductChunkWithCache(0, _chunkSize);

      if (cachedProducts.isNotEmpty) {
        setState(() {
          _loadedProducts = cachedProducts;
          _filteredProducts = _getLimitedProducts(_loadedProducts);
          _currentChunk = 1;
          _cacheLoaded = true;
          _usingCache = true;
          _cachedProductCount = cachedProducts.length;
          _cacheStatus = 'Loaded from cache';
          _isLoading = false;
          _initialLoadComplete = true;
          _hasMoreProducts = true;
        });

        CachedProductSearchDialog._persistedProducts = cachedProducts;
        CachedProductSearchDialog._persistedCacheLoaded = true;
        CachedProductSearchDialog._persistedCacheStatus = 'Loaded from cache';
        CachedProductSearchDialog._persistedProductCount = cachedProducts.length;
        CachedProductSearchDialog._lastLoadTime = DateTime.now();
        print('💾 Persisted ${cachedProducts.length} products');

        _startBackgroundLoading();
        _checkCacheFreshness();
      } else {
        setState(() {
          _cacheStatus = 'Cache empty, loading from API...';
          _usingCache = false;
        });
        await _loadInitialChunkFromApi();
      }
    } catch (e) {
      print('Cache initialization error: $e');
      setState(() {
        _cacheStatus = 'Cache error, using API';
        _usingCache = false;
      });
      await _loadInitialChunkFromApi();
    }
  }

  Future<void> _loadInitialChunkFromApi() async {
    try {
      final firstChunk = await widget.apiService.getProductChunk(0, _chunkSize);

      setState(() {
        _loadedProducts = firstChunk;
        _filteredProducts = _getLimitedProducts(_loadedProducts);
        _currentChunk = 1;
        _cacheLoaded = true;
        _usingCache = false;
        _cachedProductCount = firstChunk.length;
        _cacheStatus = 'Loaded from API';
        _isLoading = false;
        _initialLoadComplete = true;
        _hasMoreProducts = firstChunk.length >= _chunkSize;
      });

      CachedProductSearchDialog._persistedProducts = firstChunk;
      CachedProductSearchDialog._persistedCacheLoaded = true;
      CachedProductSearchDialog._persistedCacheStatus = 'Loaded from API';
      CachedProductSearchDialog._persistedProductCount = firstChunk.length;
      CachedProductSearchDialog._lastLoadTime = DateTime.now();
      print('💾 Persisted ${firstChunk.length} API products');

      _startBackgroundLoading();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _initialLoadComplete = true;
        _cacheStatus = 'Failed to load';
      });
    }
  }

  // ============ FIXED SEARCH METHODS ============
  void _onSearchChanged(String query) {
    _currentSearchQuery = query;

    // Cancel any previous debounce timer
    _searchDebounceTimer?.cancel();

    // Cancel any ongoing search operation
    _currentSearchOperation?.cancel();
    _currentSearchOperation = null;

    // Clear search immediately if query is empty
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _getLimitedProducts(_loadedProducts);
        _isSearching = false;
        _lastCompletedSearchQuery = '';
      });
      return;
    }

    // Only search if query has at least 2 characters
    if (query.length < 2) {
      setState(() {
        _filteredProducts = _getLimitedProducts(_loadedProducts);
        _isSearching = false;
      });
      return;
    }

    // Debounce search - wait for user to stop typing
    _searchDebounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted && query == _currentSearchQuery) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    // Don't search if we're already searching the same query
    if (query == _lastCompletedSearchQuery && _isSearching) {
      return;
    }

    // Generate a unique ID for this search
    final currentSearchId = ++_searchId;

    // Update UI to show loading state
    setState(() {
      _isSearching = true;
      _lastCompletedSearchQuery = ''; // Clear last completed query
    });

    try {
      // Cancel any previous search operation
      _currentSearchOperation?.cancel();

      // Create a new cancelable operation
      _currentSearchOperation = CancelableOperation.fromFuture(
        widget.apiService.searchProductsWithCache(query, limit: 100),
      );

      final searchResults = await _currentSearchOperation!.value;

      // Check if this search is still valid (user hasn't typed more)
      if (!mounted || currentSearchId != _searchId) {
        return; // Search was cancelled
      }

      // Update UI with search results
      setState(() {
        _filteredProducts = searchResults;
        _isSearching = false;
        _lastCompletedSearchQuery = query;
      });

      // If few results and more available, load more in background
      if (searchResults.length < 10 && _hasMoreProducts && !_backgroundLoading) {
        _loadMoreForSearch(query);
      }

    } catch (e) {
      // Handle cancellation gracefully
      // Check if the operation was cancelled by checking the operation's state
      if (_currentSearchOperation != null && _currentSearchOperation!.isCanceled) {
        print('Search cancelled for query: $query');
        return;
      }

      print('Search error: $e');

      if (mounted && currentSearchId == _searchId) {
        setState(() {
          _isSearching = false;
        });
      }
    }  }

  void _clearSearch() {
    _searchController.clear();
    _currentSearchQuery = '';
    _lastCompletedSearchQuery = '';

    // Cancel any ongoing operations
    _searchDebounceTimer?.cancel();
    _currentSearchOperation?.cancel();
    _currentSearchOperation = null;

    setState(() {
      _filteredProducts = _getLimitedProducts(_loadedProducts);
      _isSearching = false;
    });
  }
  // ==============================================

  Future<void> _loadMoreForSearch(String query) async {
    if (_backgroundLoading || _isSearching) return;

    await _loadNextChunkInBackground();

    // Re-perform search with updated data
    final searchId = ++_searchId;
    try {
      final searchResults = await widget.apiService.searchProductsWithCache(query, limit: 100);

      if (mounted && searchId == _searchId) {
        setState(() {
          _filteredProducts = searchResults;
        });
      }
    } catch (e) {
      print('Load more search error: $e');
    }
  }

  void _startBackgroundLoading() {
    if (!_hasMoreProducts || _backgroundChunksLoaded >= _maxBackgroundChunks) return;

    _backgroundLoadTimer?.cancel();
    _backgroundLoadTimer = Timer(const Duration(milliseconds: 500), () {
      _loadBackgroundChunks();
    });
  }

  Future<void> _loadBackgroundChunks() async {
    if (_backgroundLoading || !_hasMoreProducts || _backgroundChunksLoaded >= _maxBackgroundChunks) return;

    _backgroundLoading = true;

    try {
      for (int i = 0; i < 2; i++) {
        if (!_hasMoreProducts || _backgroundChunksLoaded >= _maxBackgroundChunks) break;

        await _loadNextChunkInBackground();
        _backgroundChunksLoaded++;

        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (_hasMoreProducts && _backgroundChunksLoaded < _maxBackgroundChunks) {
        _scheduleNextBackgroundLoad();
      }
    } catch (e) {
      print("Background loading error: $e");
    } finally {
      _backgroundLoading = false;
    }
  }

  Future<void> _loadNextChunkInBackground() async {
    final startIndex = _currentChunk * _chunkSize;

    try {
      final nextChunk = await widget.apiService.getProductChunkWithCache(startIndex, _chunkSize);

      if (nextChunk.isEmpty) {
        setState(() => _hasMoreProducts = false);
        return;
      }

      final currentIds = _loadedProducts.map((p) => p.id).toSet();
      final newItems = nextChunk.where((p) => !currentIds.contains(p.id)).toList();

      if (mounted && newItems.isNotEmpty) {
        setState(() {
          _loadedProducts.addAll(newItems);
          _currentChunk++;
          _hasMoreProducts = nextChunk.length >= _chunkSize;
        });

        if (CachedProductSearchDialog._persistedProducts != null) {
          CachedProductSearchDialog._persistedProducts = _loadedProducts;
          CachedProductSearchDialog._persistedProductCount = _loadedProducts.length;
        }

        // Only update search if we're currently searching
        if (_isSearching && _currentSearchQuery.isNotEmpty) {
          _performSearch(_currentSearchQuery);
        }
      }
    } catch (e) {
      print("Background chunk error: $e");
    }
  }

  void _scheduleNextBackgroundLoad() {
    final randomDelay = Random().nextInt(2000) + 1000;

    _backgroundLoadTimer?.cancel();
    _backgroundLoadTimer = Timer(Duration(milliseconds: randomDelay), () {
      if (mounted && _hasMoreProducts && _backgroundChunksLoaded < _maxBackgroundChunks) {
        _loadBackgroundChunks();
      }
    });
  }

  void _onScroll() {
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
      final nextChunk = await widget.apiService.getProductChunkWithCache(startIndex, _chunkSize);

      if (nextChunk.isEmpty) {
        setState(() {
          _isLoadingMore = false;
          _hasMoreProducts = false;
        });
        return;
      }

      final currentIds = _loadedProducts.map((p) => p.id).toSet();
      final newItems = nextChunk.where((p) => !currentIds.contains(p.id)).toList();

      setState(() {
        _loadedProducts.addAll(newItems);
        _filteredProducts = _getLimitedProducts(_loadedProducts);
        _currentChunk++;
        _isLoadingMore = false;
        _hasMoreProducts = nextChunk.length >= _chunkSize;
      });

      CachedProductSearchDialog._persistedProducts = _loadedProducts;
      CachedProductSearchDialog._persistedProductCount = _loadedProducts.length;
    } catch (e) {
      setState(() => _isLoadingMore = false);
      print("Chunk loading error: $e");
    }
  }

  List<SurveyDropdownItem> _getLimitedProducts(List<SurveyDropdownItem> products) {
    if (_currentSearchQuery.isEmpty) {
      return products.take(50).toList();
    }
    return products;
  }

  void _checkCacheFreshness() async {
    try {
      final needsRefresh = await widget.apiService.isProductCacheStale();

      if (needsRefresh && mounted) {
        setState(() {
          _cacheStatus = 'Cache outdated, refreshing...';
        });
        _refreshCacheInBackground();
      }
    } catch (e) {
      print('Cache freshness check error: $e');
    }
  }

  Future<void> _refreshCacheInBackground() async {
    try {
      await widget.apiService.refreshProductCache();

      if (mounted) {
        setState(() {
          _cacheStatus = 'Cache refreshed';
        });
      }
    } catch (e) {
      print('Cache refresh error: $e');
    }
  }

  void _forceRefreshCache() async {
    setState(() {
      _cacheStatus = 'Refreshing cache...';
      _isLoading = true;
    });

    try {
      await widget.apiService.getProductsWithCache(forceRefresh: true);

      final refreshedChunk = await widget.apiService.getProductChunkWithCache(0, _chunkSize);

      setState(() {
        _loadedProducts = refreshedChunk;
        _filteredProducts = _getLimitedProducts(_loadedProducts);
        _cacheStatus = 'Cache refreshed successfully';
        _usingCache = true;
        _isLoading = false;
      });

      CachedProductSearchDialog._persistedProducts = refreshedChunk;
      CachedProductSearchDialog._persistedCacheLoaded = true;
      CachedProductSearchDialog._persistedCacheStatus = 'Cache refreshed successfully';
      CachedProductSearchDialog._persistedProductCount = refreshedChunk.length;
      CachedProductSearchDialog._lastLoadTime = DateTime.now();
      print('🔄 Updated persisted cache with ${refreshedChunk.length} products');
    } catch (e) {
      setState(() {
        _cacheStatus = 'Refresh failed';
        _isLoading = false;
      });
    }
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
          children: [
            // Header - fixed height
            _buildHeader(),

            // Cache Status Banner - fixed height
            _buildCacheStatus(),

            // Search Field - fixed height
            _buildSearchField(),

            // Main content area - flexible
            Expanded(
              child: Column(
                children: [
                  // Loading indicator
                  if (_isLoading && !_initialLoadComplete)
                    const Expanded(child: Center(child: CircularProgressIndicator())),

                  // Results List
                  if (_initialLoadComplete)
                    Expanded(child: _buildResultsList()),
                ],
              ),
            ),

            // Footer - fixed height
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
          Icon(
            _usingCache ? Icons.storage : Icons.cloud,
            color: Colors.white,
            size: 24,
          ),
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

          // if (_backgroundLoading || _isSearching)
          //   Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withOpacity(0.2),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: Row(
          //       children: [
          //         SizedBox(
          //           width: 12,
          //           height: 12,
          //           child: CircularProgressIndicator(
          //             strokeWidth: 2,
          //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //           ),
          //         ),
          //         const SizedBox(width: 4),
          //         Text(
          //           '${_loadedProducts.length}',
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontSize: 12,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),

          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheStatus() {
    Color statusColor = _usingCache ? Colors.green : Colors.orange;
    IconData statusIcon = _usingCache ? Icons.check_circle : Icons.cloud;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: statusColor.withOpacity(0.1),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _cacheStatus,
                style: TextStyle(color: statusColor, fontSize: 11),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (_usingCache) ...[
              const SizedBox(width: 6),
              TextButton(
                onPressed: _forceRefreshCache,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Refresh',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
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
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
                ),
              if (_searchController.text.isNotEmpty && !_isSearching)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
            ],
          ),
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
    // Show loading indicator during search
    if (_isSearching && _currentSearchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Searching for "$_currentSearchQuery"...',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty && _currentSearchQuery.isNotEmpty) {
      return Center(
        child: _buildNoResults(),
      );
    }

    return Column(
      children: [
        // Results count - only show when not searching
        if (_currentSearchQuery.isNotEmpty && !_isSearching)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(
                  _usingCache ? Icons.storage : Icons.cloud,
                  color: Colors.blue,
                  size: 16,
                ),
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

        // Products List - takes remaining space
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
        Icon(
          _usingCache ? Icons.storage : Icons.search_off,
          size: 48,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          'No products found for "${_currentSearchQuery}"',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _usingCache
              ? 'Searching in ${_loadedProducts.length} cached products'
              : 'Searching in ${_loadedProducts.length} products',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
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
              Icon(
                _usingCache ? Icons.storage : Icons.cloud,
                size: 20,
                color: Colors.grey,
              ),
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
            Text(
              _usingCache ? 'All cached products loaded' : 'All products loaded',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
          Text(
            _usingCache ? 'Loading more from cache...' : 'Loading more products...',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Row(
          //           children: [
          //             Icon(
          //               _usingCache ? Icons.storage : Icons.cloud,
          //               size: 14,
          //               color: _usingCache ? Colors.green : Colors.orange,
          //             ),
          //             const SizedBox(width: 4),
          //             Text(
          //               _usingCache ? 'Using Cache' : 'Using API',
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 color: _usingCache ? Colors.green[700] : Colors.orange[700],
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //           ],
          //         ),
          //         Text(
          //           'Loaded: ${_loadedProducts.length}',
          //           style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          //         ),
          //       ],
          //     ),
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.end,
          //       children: [
          //         if (_currentSearchQuery.isEmpty)
          //           Text(
          //             'Chunks: ${_currentChunk}',
          //             style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          //           ),
          //         if (_backgroundLoading)
          //           Text(
          //             'Background loading...',
          //             style: TextStyle(fontSize: 11, color: Colors.blue[700]),
          //           ),
          //       ],
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _forceRefreshCache,
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Refresh Cache'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
              side: BorderSide(color: _usingCache ? Colors.green : Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _backgroundLoadTimer?.cancel();
    _currentSearchOperation?.cancel();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}