import 'dart:async';
import 'dart:convert';
import 'package:ess/Ess_App/src/views/PDMS_survey/product_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:ess/Ess_App/src/services/remote/api_service.dart';
import 'package:ess/Ess_App/src/services/local/auth_service.dart';
import 'package:ess/Ess_App/src/shared/loading_indicator.dart';
import 'package:ess/Ess_App/src/base/utils/constants.dart';
import '../../configs/app_setup.locator.dart';
import '../../services/remote/network_exceptions.dart';
import 'cached_product_search_dialog.dart';
import 'chunked_product_search_dialog.dart';
import 'package:dio/dio.dart';

// Add this import if you don't have it
import 'package:flutter/material.dart';

class SurveyDropdownItem {
  final String id;
  final String value;

  SurveyDropdownItem({
    required this.id,
    required this.value,
  });
}

class SurveyFormView extends StatefulWidget {
  const SurveyFormView({Key? key}) : super(key: key);

  @override
  State<SurveyFormView> createState() => _SurveyFormViewState();
}

class _SurveyFormViewState extends State<SurveyFormView> {
  final AuthService _authService = locator<AuthService>();
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Dropdown values from API
  List<SurveyDropdownItem> dosageList = [];
  List<SurveyDropdownItem> genericList = [];
  List<SurveyDropdownItem> packSizeList = [];
  List<SurveyDropdownItem> categoryList = [];
  List<SurveyDropdownItem> classificationList = [];
  List<SurveyDropdownItem> routeList = [];
  List<SurveyDropdownItem> strengthList = [];
  List<SurveyDropdownItem> volumeList = [];

  // ValueNotifiers for dropdowns
  final ValueNotifier<String?> selectedDosage = ValueNotifier(null);
  final ValueNotifier<String?> selectedGeneric = ValueNotifier(null);
  final ValueNotifier<String?> selectedPackSize = ValueNotifier(null);
  final ValueNotifier<String?> selectedCategory = ValueNotifier(null);
  final ValueNotifier<String?> selectedClassification = ValueNotifier(null);
  final ValueNotifier<String?> selectedRoute = ValueNotifier(null);
  final ValueNotifier<String?> selectedStrength = ValueNotifier(null);
  final ValueNotifier<String?> selectedVolume = ValueNotifier(null);

  // Product selection
  String? selectedProductId;
  String? selectedProductName;
  final TextEditingController productSearchController = TextEditingController();

  // Text controllers for manual fields
  final TextEditingController distributorSystemCodeController = TextEditingController();
  final TextEditingController registrationNoController = TextEditingController();
  final TextEditingController priceUnitController = TextEditingController();
  final TextEditingController pricePackController = TextEditingController();
  final TextEditingController storageTempController = TextEditingController();
  final TextEditingController manufacturerController = TextEditingController();
  final TextEditingController manufacturerAddressController = TextEditingController();
  final TextEditingController importerController = TextEditingController();
  final TextEditingController importerAddressController = TextEditingController();
  final TextEditingController distributorNameController = TextEditingController();
  final TextEditingController distributorLicenseController = TextEditingController();
  final TextEditingController shelfLifeController = TextEditingController();
  final TextEditingController cartonSizeController = TextEditingController();

  // Keys for focusing on fields
  final GlobalKey<FormFieldState> importerFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> productCodeFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> genericFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> manufacturerFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> distributorSystemCodeFieldKey = GlobalKey<FormFieldState>();

  static List<SurveyDropdownItem>? _cachedDialogProducts;

  List<SurveyDropdownItem> companyList = [];
  final ValueNotifier<String?> selectedCompany = ValueNotifier(null);
  bool isLoadingCompanies = false;
  bool isLoadingProducts = false;

  // Validation
  Timer? _validationTimer;
  bool isLoading = true;
  bool isSubmitting = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);

    try {
      // First load companies
      await _fetchCompanies();

      // Then load other dropdowns
      await Future.wait([
        _fetchDropdownData('generic', genericList),
        _fetchDropdownData('dosage', dosageList),
        _fetchDropdownData('pack', packSizeList),
        _fetchDropdownData('category', categoryList),
        _fetchDropdownData('classification', classificationList),
        _fetchDropdownData('route', routeList),
        _fetchDropdownData('strength', strengthList),
        _fetchDropdownData('volume', volumeList),
      ]);

      setState(() => isLoading = false);

    } catch (e) {
      Constants.customErrorSnack(context, 'Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchDropdownData(String tab, List<SurveyDropdownItem> list) async {
    try {
      final response = await _apiService.getSurveyData(tab);

      response.when(
        success: (data) {
          if (data['status'] == true && data['data'] != null) {
            list.clear();
            final List<dynamic> apiData = data['data'];

            // Map data based on tab
            final Map<String, String> keyMap = {
              'dosage': 'dosage_id,dosage_value',
              'generic': 'generic_id,generic_value',
              'pack': 'pack_id,pack_value',
              'category': 'prod_category_id,prod_category_value',
              'classification': 'prod_classification_id,prod_classification_value',
              'route': 'route_admin_id,route_admin_value',
              'strength': 'strength_id,strength_value',
              'volume': 'volume_id,volume_value',
            };

            if (keyMap.containsKey(tab)) {
              final keys = keyMap[tab]!.split(',');
              final idKey = keys[0];
              final valueKey = keys[1];

              for (var item in apiData) {
                final id = item[idKey]?.toString() ?? '';
                final value = item[valueKey]?.toString() ?? '';
                if (id.isNotEmpty && value.isNotEmpty) {
                  list.add(SurveyDropdownItem(id: id, value: value));
                }
              }
            }

            print("Loaded ${list.length} items for $tab");

            if (mounted) {
              setState(() {});
            }
          }
        },
        failure: (error) {
          print("Error loading $tab: $error");
        },
      );
    } catch (e) {
      print("Exception in _fetchDropdownData for $tab: $e");
    }
  }

  Future<void> _fetchCompanies() async {
    setState(() => isLoadingCompanies = true);

    try {
      final response = await _apiService.getSurveyData('company');

      response.when(
        success: (data) {
          if (data['status'] == true && data['data'] != null) {
            companyList.clear();
            final List<dynamic> apiData = data['data'];

            for (var item in apiData) {
              final id = item['company_code']?.toString() ?? '';
              final value = item['company_title']?.toString() ?? '';
              if (id.isNotEmpty && value.isNotEmpty) {
                companyList.add(SurveyDropdownItem(id: id, value: value));
              }
            }

            print("Loaded ${companyList.length} companies");

            if (mounted) {
              setState(() {});
            }
          }
        },
        failure: (error) {
          print("Error loading companies: $error");
          Constants.customErrorSnack(context, 'Failed to load companies');
        },
      );
    } catch (e) {
      print("Exception in _fetchCompanies: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingCompanies = false);
      }
    }
  }

  Future<void> _fetchProductsForCompany(String companyCode) async {
    if (companyCode.isEmpty) return;

    setState(() => isLoadingProducts = true);

    // Clear previous product selection
    selectedProductId = null;
    selectedProductName = null;

    try {
      final response = await _apiService.getSurveyDataWithParams('product', companyCode: companyCode);

      response.when(
        success: (data) {
          if (data['status'] == true && data['data'] != null) {
            final List<dynamic> apiData = data['data'];
            final List<SurveyDropdownItem> products = [];

            for (var item in apiData) {
              final id = item['product_code']?.toString() ?? '';
              final value = item['product_name']?.toString() ?? '';
              if (id.isNotEmpty && value.isNotEmpty) {
                products.add(SurveyDropdownItem(id: id, value: value));
              }
            }

            // Store products in cache for the product search dialog
            _cachedDialogProducts = products;

            print("Loaded ${products.length} products for company $companyCode");

            if (mounted) {
              setState(() {});
            }
          }
        },
        failure: (error) {
          print("Error loading products: $error");
          Constants.customErrorSnack(context, 'Failed to load products for selected company');
        },
      );
    } catch (e) {
      print("Exception in _fetchProductsForCompany: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingProducts = false);
      }
    }
  }

  void _validateFormDebounced() {
    _validationTimer?.cancel();
    _validationTimer = Timer(const Duration(milliseconds: 300), _validateForm);
  }

  void _showGenericError(String message) {
    _showErrorDialog(
      title: 'Error',
      message: message,
      isMissingFieldError: false,
      missingField: null,
    );
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final dropdownsValid = selectedGeneric.value != null &&
        selectedCompany.value != null &&
        selectedProductId != null &&
        selectedProductName != null &&
        selectedProductName!.isNotEmpty &&
        selectedDosage.value != null &&
        selectedPackSize.value != null &&
        selectedCategory.value != null &&
        selectedClassification.value != null &&
        selectedRoute.value != null &&
        selectedStrength.value != null &&
        selectedVolume.value != null;

    if (isValid && dropdownsValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid && dropdownsValid;
      });
    }
  }

  Widget _buildProductSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Name*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _openProductSearch,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedCompany.value == null
                    ? Colors.grey[300]!
                    : Theme.of(context).primaryColor.withOpacity(0.5),
                width: selectedCompany.value == null ? 1.5 : 2,
              ),
              color: selectedCompany.value == null
                  ? Colors.grey[100]
                  : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: selectedCompany.value == null
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedProductName ??
                            (selectedCompany.value == null
                                ? 'Select a company first'
                                : 'Tap to search product...'),
                        style: TextStyle(
                          fontSize: 15,
                          color: selectedProductName != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (selectedProductName != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      setState(() {
                        selectedProductId = null;
                        selectedProductName = null;
                      });
                      _validateFormDebounced();
                    },
                  ),
              ],
            ),
          ),
        ),
        if (selectedProductName != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Product:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        selectedProductName!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getSelectedCompanyName() {
    if (selectedCompany.value == null) return '';
    final company = companyList.firstWhere(
          (c) => c.id == selectedCompany.value,
      orElse: () => SurveyDropdownItem(id: '', value: ''),
    );
    return company.value;
  }

  // Helper method to get value from ID
  String _getValueFromId(List<SurveyDropdownItem> list, String? id) {
    if (id == null || id.isEmpty) return '';
    final item = list.firstWhere(
          (item) => item.id == id,
      orElse: () => SurveyDropdownItem(id: '', value: ''),
    );
    return item.value;
  }

  void _openCompanySearchDialog() async {
    final TextEditingController searchController = TextEditingController();
    List<SurveyDropdownItem> filteredList = List.from(companyList);
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                width: 450,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: 450,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Compact Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Select Company',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Compact Search bar
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search company...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey[500],
                                size: 16,
                              ),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  filteredList = List.from(companyList);
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              filteredList = companyList.where((item) {
                                final searchLower = value.toLowerCase();
                                return item.value.toLowerCase().contains(searchLower) ||
                                    item.id.toLowerCase().contains(searchLower);
                              }).toList();
                            });
                          },
                        ),
                      ),
                    ),

                    // Compact Results count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredList.length} companies',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Company list with compact items
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 32,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchController.text.isEmpty
                                  ? 'No companies'
                                  : 'No results found',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                selectedCompany.value = item.id;
                                Navigator.pop(context);
                                _fetchProductsForCompany(item.id);
                                _validateFormDebounced();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedCompany.value == item.id
                                      ? Theme.of(context).primaryColor.withOpacity(0.05)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedCompany.value == item.id
                                        ? Theme.of(context).primaryColor.withOpacity(0.3)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.value.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.value,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Code: ${item.id}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (selectedCompany.value == item.id)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Compact Footer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: const Size(0, 0),
                            ),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openProductSearch() {
    // Check if company is selected
    if (selectedCompany.value == null) {
      Constants.customErrorSnack(context, 'Please select a company first');
      return;
    }

    // Check if products are loaded
    if (_cachedDialogProducts == null || _cachedDialogProducts!.isEmpty) {
      Constants.customErrorSnack(context, 'No products available for this company');
      return;
    }

    final dialog = CachedProductSearchDialog(
      apiService: _apiService,
      initialProducts: _cachedDialogProducts,
    );

    showDialog<SurveyDropdownItem>(
      context: context,
      builder: (context) => dialog,
    ).then((result) {
      if (result != null) {
        setState(() {
          selectedProductId = result.id;
          selectedProductName = result.value;
        });
        _validateFormDebounced();
      }
    });
  }

  // Searchable dropdown for generic list
  Widget _buildSearchableGenericDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Ingredients Generic*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showGenericSearchDialog();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.medication_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<String?>(
                    valueListenable: selectedGeneric,
                    builder: (context, value, child) {
                      final selectedItem = genericList.firstWhere(
                            (item) => item.id == value,
                        orElse: () => SurveyDropdownItem(id: '', value: ''),
                      );
                      return Text(
                        selectedItem.value.isNotEmpty
                            ? selectedItem.value
                            : 'Search active ingredients...',
                        style: TextStyle(
                          fontSize: 15,
                          color: selectedItem.value.isNotEmpty ? Colors.black : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                if (selectedGeneric.value != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      selectedGeneric.value = null;
                      _validateFormDebounced();
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _openCompanySearchDialog,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.business,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<String?>(
                    valueListenable: selectedCompany,
                    builder: (context, value, child) {
                      final selectedItem = companyList.firstWhere(
                            (item) => item.id == value,
                        orElse: () => SurveyDropdownItem(id: '', value: ''),
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (selectedItem.value.isNotEmpty) ...[
                            Text(
                              'Selected Company:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            selectedItem.value.isNotEmpty
                                ? selectedItem.value
                                : (isLoadingCompanies ? 'Loading companies...' : 'Select a company'),
                            style: TextStyle(
                              fontSize: 15,
                              color: selectedItem.value.isNotEmpty ? Colors.black : Colors.grey,
                              fontWeight: selectedItem.value.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (selectedCompany.value != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          selectedCompany.value = null;
                          // Clear products when company is deselected
                          _cachedDialogProducts = null;
                          selectedProductId = null;
                          selectedProductName = null;
                          setState(() {});
                          _validateFormDebounced();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        // Show selected company info
        if (selectedCompany.value != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Company selected. You can now search products.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Method to show search dialog for generic list
  void _showGenericSearchDialog() async {
    final TextEditingController searchController = TextEditingController();
    List<SurveyDropdownItem> filteredList = List.from(genericList);
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: 500,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search Active Ingredients',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search field
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Type ingredient name...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey[500],
                                size: 18,
                              ),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  filteredList = List.from(genericList);
                                });
                              },
                            )
                                : null,
                          ),
                          style: const TextStyle(fontSize: 15),
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              filteredList = genericList.where((item) {
                                return item.value.toLowerCase().contains(value.toLowerCase());
                              }).toList();
                            });
                          },
                        ),
                      ),
                    ),

                    // Results count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredList.length} ingredient${filteredList.length != 1 ? 's' : ''} found',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (filteredList.isNotEmpty)
                            Text(
                              'Tap to select',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Results list
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey[100]!),
                          ),
                          child: filteredList.isEmpty
                              ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_outlined,
                                  color: Colors.grey[400],
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchController.text.isEmpty
                                      ? 'Start typing to search ingredients'
                                      : 'No ingredients found for "${searchController.text}"',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                if (searchController.text.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {
                                        filteredList = List.from(genericList);
                                      });
                                    },
                                    child: Text(
                                      'Clear search',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                              : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredList.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey[100],
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    selectedGeneric.value = item.id;
                                    Navigator.pop(context);
                                    _validateFormDebounced();
                                  },
                                  splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.medication_outlined,
                                            color: Theme.of(context).primaryColor,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.value,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'ID: ${item.id}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Footer with close button
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptimizedDropdown({
    required String label,
    required ValueNotifier<String?> valueNotifier,
    required List<SurveyDropdownItem> items,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: ValueListenableBuilder<String?>(
              valueListenable: valueNotifier,
              builder: (context, value, child) {
                return DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.arrow_drop_down, color: Colors.grey, size: 24),
                  ),
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.grey[500], size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Select $label',
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(icon, color: Theme.of(context).primaryColor, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.value,
                                style: const TextStyle(fontSize: 15, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    valueNotifier.value = newValue;
                    _validateFormDebounced();
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? suffixText,
    bool isRequired = false,
    bool isOptional = false,
    GlobalKey<FormFieldState>? fieldKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            if (isOptional)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  '(Optional)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: fieldKey,
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter ${label.replaceAll('*', '').trim()}',
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 0,
            ),
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          }
              : null,
          style: const TextStyle(fontSize: 15, color: Colors.grey),
          onChanged: (value) => _validateFormDebounced(),
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.check, size: 40, color: Colors.green),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Success!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Survey submitted successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate all required fields including company
    List<String> missingFields = [];

    if (selectedCompany.value == null) missingFields.add('Company');
    if (selectedGeneric.value == null) missingFields.add('Active Ingredients');
    if (selectedProductId == null || selectedProductName == null) missingFields.add('Product');
    if (selectedDosage.value == null) missingFields.add('Dosage Form');
    if (selectedPackSize.value == null) missingFields.add('Pack Size');
    if (selectedCategory.value == null) missingFields.add('Product Category');
    if (selectedClassification.value == null) missingFields.add('Product Classification');
    if (selectedRoute.value == null) missingFields.add('Route of Administration');
    if (selectedStrength.value == null) missingFields.add('Strength');
    if (selectedVolume.value == null) missingFields.add('Volume');

    // Check text fields that are required
    if (distributorSystemCodeController.text.trim().isEmpty) missingFields.add('Distributor System Code');
    if (registrationNoController.text.trim().isEmpty) missingFields.add('Registration No');
    if (priceUnitController.text.trim().isEmpty) missingFields.add('Price (Unit)');
    if (pricePackController.text.trim().isEmpty) missingFields.add('Price (Pack)');
    if (storageTempController.text.trim().isEmpty) missingFields.add('Storage Temperature');
    if (manufacturerController.text.trim().isEmpty) missingFields.add('Manufacturer');
    if (manufacturerAddressController.text.trim().isEmpty) missingFields.add('Manufacturer Address');
    if (distributorNameController.text.trim().isEmpty) missingFields.add('Distributor Name');
    if (distributorLicenseController.text.trim().isEmpty) missingFields.add('Distributor License');
    if (shelfLifeController.text.trim().isEmpty) missingFields.add('Shelf Life');
    if (cartonSizeController.text.trim().isEmpty) missingFields.add('Carton Size');

    if (missingFields.isNotEmpty) {
      _showErrorDialog(
        title: 'Missing Information',
        message: 'Please fill all required fields',
        isMissingFieldError: true,
        missingField: missingFields.first,
      );

      Constants.customErrorSnack(
          context,
          'Required fields missing: ${missingFields.join(', ')}'
      );
      return;
    }

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Survey'),
        content: const Text('Are you sure you want to submit this survey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() => isSubmitting = true);

    try {
      // Debug dropdown values
      print('=== DROPDOWN VALUES DEBUG ===');
      print('Dosage Form - ID: ${selectedDosage.value}, Value: ${_getValueFromId(dosageList, selectedDosage.value)}');
      print('Route Admin - ID: ${selectedRoute.value}, Value: ${_getValueFromId(routeList, selectedRoute.value)}');
      print('Strength - ID: ${selectedStrength.value}, Value: ${_getValueFromId(strengthList, selectedStrength.value)}');
      print('Volume - ID: ${selectedVolume.value}, Value: ${_getValueFromId(volumeList, selectedVolume.value)}');
      print('Category - ID: ${selectedCategory.value}, Value: ${_getValueFromId(categoryList, selectedCategory.value)}');
      print('Classification - ID: ${selectedClassification.value}, Value: ${_getValueFromId(classificationList, selectedClassification.value)}');
      print('Generic - ID: ${selectedGeneric.value}, Value: ${_getValueFromId(genericList, selectedGeneric.value)}');
      print('=== END DROPDOWN DEBUG ===');

      final Map<String, dynamic> formData = {
        // Company Information
        'company_code': selectedCompany.value ?? '',

        // Product Information
        'product_code': selectedProductId ?? '',
        'product_name': selectedProductName ?? '',

        // IMPORTANT: Send the actual values, not the IDs
        'generic': _getValueFromId(genericList, selectedGeneric.value),
        'dosage_form': _getValueFromId(dosageList, selectedDosage.value),
        'pack_size': _getValueFromId(packSizeList, selectedPackSize.value),
        'product_category': _getValueFromId(categoryList, selectedCategory.value),
        'product_clasification': _getValueFromId(classificationList, selectedClassification.value), // Note: API uses 'product_clasification'
        'route_admin': _getValueFromId(routeList, selectedRoute.value),
        'strength': _getValueFromId(strengthList, selectedStrength.value),
        'volume': _getValueFromId(volumeList, selectedVolume.value),

        // Registration & Pricing
        'registration_no': registrationNoController.text.trim(),
        'price_unit': priceUnitController.text.trim(),
        'price_pack': pricePackController.text.trim(),

        // Storage & Shelf Life
        'storage_temp': storageTempController.text.trim(),
        'shelf_life': shelfLifeController.text.trim(),
        'carton_size': cartonSizeController.text.trim(),

        // Manufacturer Information
        'manufacturer': manufacturerController.text.trim(),
        'mfr_address': manufacturerAddressController.text.trim(),

        // Importer Information
        'importer': importerController.text.trim(),
        'importer_address': importerAddressController.text.trim(),

        // Distributor Information
        'system_code': distributorSystemCodeController.text.trim(),
        'distributor_name': distributorNameController.text.trim(),
        'dist_license_no': distributorLicenseController.text.trim(),

        // User Information
        'user_name': _authService.user?.userName?.toString() ?? '',
        'user_id': _authService.user?.userId?.toString() ?? '',
      };

      print('Submitting form data: $formData');

      final response = await _apiService.submitSurveyFormPost(formData);

      response.when(
        success: (data) {
          setState(() => isSubmitting = false);
          if (data['status'] == true) {
            _showSuccessDialog();
          } else {
            _showErrorDialog(
              title: 'Submission Failed',
              message: data['message'] ?? 'Failed to submit survey',
              isMissingFieldError: false,
              missingField: null,
            );
          }
        },
        failure: (error) {
          setState(() => isSubmitting = false);

          print('Error type: ${error.runtimeType}');

          if (error is NetworkExceptions) {
            final errorMessage = NetworkExceptions.getErrorMessage(error);
            print('NetworkExceptions error: $errorMessage');

            error.when(
              conflict: () {
                _showErrorDialog(
                  title: 'Duplicate Entry',
                  message: 'This product code already exists. Duplicate entry not allowed.',
                  isMissingFieldError: false,
                  missingField: null,
                );
              },
              unauthorizedRequest: () {
                _showErrorDialog(
                  title: 'Missing Information',
                  message: 'Please check all required fields are filled correctly.',
                  isMissingFieldError: true,
                  missingField: null,
                );
              },
              badRequest: () {
                _showErrorDialog(
                  title: 'Missing Information',
                  message: 'Required field is missing. Please fill all required fields.',
                  isMissingFieldError: true,
                  missingField: null,
                );
              },
              defaultError: (String defaultError) {
                if (defaultError.contains('Missing field:')) {
                  final missingField = _extractMissingField(defaultError);
                  _showErrorDialog(
                    title: 'Missing Information',
                    message: defaultError,
                    isMissingFieldError: true,
                    missingField: missingField,
                  );
                } else {
                  _showErrorDialog(
                    title: 'Error',
                    message: defaultError,
                    isMissingFieldError: false,
                    missingField: null,
                  );
                }
              },
              requestCancelled: () => _showGenericError('Request Cancelled'),
              notFound: (reason) => _showGenericError(reason),
              methodNotAllowed: () => _showGenericError('Method Not Allowed'),
              notAcceptable: () => _showGenericError('Not Acceptable'),
              requestTimeout: () => _showGenericError('Request Timeout'),
              sendTimeout: () => _showGenericError('Send Timeout'),
              internalServerError: () => _showGenericError('Internal Server Error'),
              notImplemented: () => _showGenericError('Not Implemented'),
              serviceUnavailable: () => _showGenericError('Service Unavailable'),
              noInternetConnection: () => _showGenericError('No Internet Connection'),
              formatException: () => _showGenericError('Format Exception'),
              unableToProcess: () => _showGenericError('Unable to Process Data'),
              unexpectedError: () => _showGenericError('Unexpected Error'),
            );
          } else {
            _showErrorDialog(
              title: 'Error',
              message: error.toString(),
              isMissingFieldError: false,
              missingField: null,
            );
          }
        },
      );
    } catch (e) {
      setState(() => isSubmitting = false);
      _showErrorDialog(
        title: 'Error',
        message: e.toString(),
        isMissingFieldError: false,
        missingField: null,
      );
    }
  }

  // Helper method to extract error message from response
  String? _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData is String) {
        final parsed = jsonDecode(responseData);
        if (parsed is Map && parsed.containsKey('message')) {
          return parsed['message'].toString();
        }
        return responseData;
      } else if (responseData is Map) {
        return responseData['message']?.toString();
      }
      return null;
    } catch (e) {
      return responseData?.toString();
    }
  }

  // Helper method to extract missing field from error message
  String? _extractMissingField(String? errorMessage) {
    if (errorMessage == null) return null;

    final missingFieldMatch = RegExp(r'Missing field:\s*(\w+)').firstMatch(errorMessage);
    if (missingFieldMatch != null) {
      return missingFieldMatch.group(1);
    }

    final requiredFieldMatch = RegExp(r'(\w+)\s+is required').firstMatch(errorMessage);
    if (requiredFieldMatch != null) {
      return requiredFieldMatch.group(1);
    }

    return null;
  }

  // Custom error dialog method
  void _showErrorDialog({
    required String title,
    required String message,
    required bool isMissingFieldError,
    String? missingField,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: Icon(
                    isMissingFieldError ? Icons.warning_amber : Icons.error_outline,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                if (isMissingFieldError && missingField != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[800],
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Please fill the "$missingField" field',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (title.contains('Duplicate')) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[800],
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This product is already registered. Please check the product list.',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (isMissingFieldError)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (missingField != null) {
                              _focusOnMissingField(missingField);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          child: Text(
                            'Go to Field',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (isMissingFieldError) const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMissingFieldError ? Colors.grey[300] : Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isMissingFieldError ? 'Cancel' : 'OK',
                          style: TextStyle(
                            color: isMissingFieldError ? Colors.grey[700] : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to focus on the missing field
  void _focusOnMissingField(String fieldName) {
    final fieldMap = {
      'importer': () {
        if (importerFieldKey.currentState != null) {
          FocusScope.of(context).requestFocus(FocusNode());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Scrollable.ensureVisible(
              importerFieldKey.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        }
      },
      'product_code': () {
        _openProductSearch();
      },
      'generic': () {
        _showGenericSearchDialog();
      },
      'manufacturer': () {
        if (manufacturerFieldKey.currentState != null) {
          FocusScope.of(context).requestFocus(FocusNode());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Scrollable.ensureVisible(
              manufacturerFieldKey.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        }
      },
      'system_code': () {
        if (distributorSystemCodeFieldKey.currentState != null) {
          FocusScope.of(context).requestFocus(FocusNode());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Scrollable.ensureVisible(
              distributorSystemCodeFieldKey.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        }
      },
    };

    if (fieldMap.containsKey(fieldName.toLowerCase())) {
      fieldMap[fieldName.toLowerCase()]!();
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();

    // Reset ValueNotifiers
    selectedCompany.value = null;
    selectedDosage.value = null;
    selectedGeneric.value = null;
    selectedPackSize.value = null;
    selectedCategory.value = null;
    selectedClassification.value = null;
    selectedRoute.value = null;
    selectedStrength.value = null;
    selectedVolume.value = null;

    // Reset product selection
    selectedProductId = null;
    selectedProductName = null;
    _cachedDialogProducts = null;

    // Clear text controllers
    distributorSystemCodeController.clear();
    registrationNoController.clear();
    priceUnitController.clear();
    pricePackController.clear();
    storageTempController.clear();
    manufacturerController.clear();
    manufacturerAddressController.clear();
    importerController.clear();
    importerAddressController.clear();
    distributorNameController.clear();
    distributorLicenseController.clear();
    shelfLifeController.clear();
    cartonSizeController.clear();

    setState(() {
      _isFormValid = false;
    });
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    _scrollController.dispose();

    // Dispose ValueNotifiers
    selectedCompany.dispose();
    selectedDosage.dispose();
    selectedGeneric.dispose();
    selectedPackSize.dispose();
    selectedCategory.dispose();
    selectedClassification.dispose();
    selectedRoute.dispose();
    selectedStrength.dispose();
    selectedVolume.dispose();

    // Dispose text controllers
    distributorSystemCodeController.dispose();
    registrationNoController.dispose();
    priceUnitController.dispose();
    pricePackController.dispose();
    storageTempController.dispose();
    manufacturerController.dispose();
    manufacturerAddressController.dispose();
    importerController.dispose();
    importerAddressController.dispose();
    distributorNameController.dispose();
    distributorLicenseController.dispose();
    shelfLifeController.dispose();
    cartonSizeController.dispose();
    productSearchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'PDMS Survey Form',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: LoadingIndicator())
          : Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'Product Information',
                      subtitle: 'Select product details from dropdowns',
                      icon: Icons.medical_services_outlined,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    ..._buildProductInfoFields(),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      title: 'Additional Information',
                      subtitle: 'Enter product specifications and details',
                      icon: Icons.description_outlined,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),
                    ..._buildAdditionalInfoFields(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    icon: Icon(Icons.refresh, size: 14, color: Colors.grey[600]),
                    label: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isFormValid && !isSubmitting ? _submitForm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: primaryColor.withOpacity(0.3),
                      disabledBackgroundColor: primaryColor.withOpacity(0.3),
                    ),
                    icon: isSubmitting
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.cloud_upload_outlined, size: 22),
                    label: isSubmitting
                        ? const Text('Submitting...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                        : const Text('Submit Survey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProductInfoFields() {
    return [
      _buildCompanyDropdown(),
      const SizedBox(height: 16),
      if (isLoadingProducts)
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading Products',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fetching products for ${_getSelectedCompanyName()}...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      _buildProductSearchField(),
      const SizedBox(height: 12),
      _buildSearchableGenericDropdown(),
      const SizedBox(height: 12),
      _buildOptimizedDropdown(
        label: 'Dosage Form*',
        valueNotifier: selectedDosage,
        items: dosageList,
        icon: Icons.format_shapes_outlined,
      ),
      const SizedBox(height: 12),
      _buildOptimizedDropdown(
        label: 'Pack Size*',
        valueNotifier: selectedPackSize,
        items: packSizeList,
        icon: Icons.backpack_outlined,
      ),
      const SizedBox(height: 12),
      _buildOptimizedDropdown(
        label: 'Product Category*',
        valueNotifier: selectedCategory,
        items: categoryList,
        icon: Icons.category_outlined,
      ),
      const SizedBox(height: 12),
      _buildOptimizedDropdown(
        label: 'Product Classification*',
        valueNotifier: selectedClassification,
        items: classificationList,
        icon: Icons.class_outlined,
      ),
      const SizedBox(height: 12),
      _buildOptimizedDropdown(
        label: 'Route of Administration*',
        valueNotifier: selectedRoute,
        items: routeList,
        icon: Icons.alt_route_outlined,
      ),
      const SizedBox(height: 12),
      _buildOptimizedDropdown(
        label: 'Strength*',
        valueNotifier: selectedStrength,
        items: strengthList,
        icon: Icons.fitness_center_outlined,
      ),
      const SizedBox(height: 12),
      _buildOptimizedDropdown(
        label: 'Volume*',
        valueNotifier: selectedVolume,
        items: volumeList,
        icon: Icons.water_drop_outlined,
      ),
    ];
  }

  List<Widget> _buildAdditionalInfoFields() {
    return [
      Row(
        children: [
          Expanded(
            child: _buildOptimizedTextField(
              controller: distributorSystemCodeController,
              label: 'Distributor System Code*',
              icon: Icons.qr_code_outlined,
              isRequired: true,
              fieldKey: distributorSystemCodeFieldKey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildOptimizedTextField(
              controller: registrationNoController,
              label: 'Registration No*',
              icon: Icons.assignment_outlined,
              isRequired: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildOptimizedTextField(
              controller: priceUnitController,
              label: 'Price (PKR/Unit)*',
              icon: Icons.monetization_on_outlined,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              suffixText: 'PKR',
              isRequired: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildOptimizedTextField(
              controller: pricePackController,
              label: 'Price (PKR/Pack)*',
              icon: Icons.attach_money_outlined,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              suffixText: 'PKR',
              isRequired: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _buildOptimizedTextField(
        controller: storageTempController,
        label: 'Storage Temperature*',
        icon: Icons.thermostat_outlined,
        suffixText: '°C',
        isRequired: true,
      ),
      const SizedBox(height: 16),
      _buildOptimizedTextField(
        controller: manufacturerController,
        label: 'Manufacturer*',
        icon: Icons.factory_outlined,
        isRequired: true,
        fieldKey: manufacturerFieldKey,
      ),
      const SizedBox(height: 16),
      _buildOptimizedTextField(
        controller: manufacturerAddressController,
        label: 'Manufacturer Address*',
        icon: Icons.location_on_outlined,
        maxLines: 2,
        isRequired: true,
      ),
      const SizedBox(height: 16),
      _buildOptimizedTextField(
        controller: importerController,
        label: 'Importer (if applicable)',
        icon: Icons.business_outlined,
        isOptional: true,
        fieldKey: importerFieldKey,
      ),
      const SizedBox(height: 16),
      _buildOptimizedTextField(
        controller: importerAddressController,
        label: 'Importer Address',
        icon: Icons.location_city_outlined,
        maxLines: 2,
        isOptional: true,
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildOptimizedTextField(
              controller: distributorNameController,
              label: 'Distributor\'s Name*',
              icon: Icons.person_pin_outlined,
              isRequired: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildOptimizedTextField(
              controller: distributorLicenseController,
              label: 'Distributor\'s License No*',
              icon: Icons.badge_outlined,
              isRequired: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildOptimizedTextField(
              controller: shelfLifeController,
              label: 'Shelf Life*',
              icon: Icons.calendar_month_outlined,
              suffixText: 'months',
              isRequired: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildOptimizedTextField(
              controller: cartonSizeController,
              label: 'Carton Size*',
              icon: Icons.inventory_outlined,
              suffixText: 'units',
              isRequired: true,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}