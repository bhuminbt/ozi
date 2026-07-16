import 'dart:developer' as dev;
import 'package:ozi/app/data/response/api_response.dart';
import 'package:ozi/app/modules/user/cart/view/model/cart_items_model.dart';
import 'package:ozi/app/modules/user/home/service%20details/model/vendordetaiulmodel.dart';
import 'package:ozi/app/shared/widgets/cutom_nodata_widget.dart';
import '../../../../../core/appExports/app_export.dart';
import '../../../../../core/constants/app_urls.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../data/storage/user_preference.dart';
import '../../model/category_model.dart' hide Data;
import '../model/ServiceDetailsModel.dart';
import '../model/add_to_cart.dart';

class ServiceDetailProvider extends ChangeNotifier {
  final Subcategories service;
  final int categoryId;
  final Repository _repository = Repository();

  ApiResponse<vendorDetailModel> _vendorDetailData = ApiResponse.loading();
  ApiResponse<vendorDetailModel> get vendorDetailData => _vendorDetailData;

  void setVendorDetailModel(ApiResponse<vendorDetailModel> value) {
    _vendorDetailData = value;
    notifyListeners();
  }

  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    dev.log('Search query updated: "$_searchQuery"');
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    searchController.clear();
    dev.log('Search cleared');
    notifyListeners();
  }

  List<Data> get filteredVendorServices {
    final allServices = _vendorDetailData.data?.data ?? [];
    dev.log(
      'Filtering ${allServices.length} services with query: "$_searchQuery"',
    );

    if (_searchQuery.trim().isEmpty) {
      return allServices;
    }

    final query = _searchQuery.trim().toLowerCase();
    return allServices.where((service) {
      final name = service.serviceName?.toLowerCase() ?? '';
      final description = service.description?.toLowerCase() ?? '';
      final match = name.contains(query) || description.contains(query);
      if (match) {
        dev.log('Match found: ${service.serviceName}');
      }
      return match;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  final String? latitude;
  final String? longitude;

  ServiceDetailProvider(this.service, this.categoryId, {this.latitude, this.longitude}) {
    _fetchServiceDetails();
    fetchCartItems();
  }

  Future<void> vendorDetailsApi(String vendorId) async {
    try {
      setVendorDetailModel(ApiResponse.loading());
      final response = await _repository.vendorDetailsApi(vendorId);
      setVendorDetailModel(ApiResponse.completed(response));
      // Sync quantities from response
      if (response.data != null) {
        for (var item in response.data!) {
          if (item.quantity != null && item.quantity! > 0) {
            _cartItems[item.id!] = item.quantity!;
          }
        }
      }
      Get.showToast(response.message ?? '', type: ToastType.success);
      await fetchCartItems();
    } catch (e) {
      dev.log('Error in vendorDetailsApi: $e');
      setVendorDetailModel(ApiResponse.error(e.toString()));
      Get.showToast(e.toString(), type: ToastType.error);
    }
  }

  List<ServiceData> _serviceProviders = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAddingToCart = false;

  List<ServiceData> get serviceProviders => _serviceProviders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAddingToCart => _isAddingToCart;

  // Cart summary fields
  List<CartItem> _items = [];
  double _subtotal = 0;
  double _serviceFee = 0;
  double _discount = 0;
  double _total = 0;

  List<CartItem> get items => _items;
  double get subtotal => _subtotal;
  double get serviceFee => _serviceFee;
  double get discount => _discount;
  double get total => _total;
  int get cartCount =>
      _items.fold(0, (sum, item) => sum + (item.quantity ?? 0));

  Future<void> fetchCartItems() async {
    // 🔐 STEP 1: Check token first
    final token = await UserPreference.returnAccessToken();
    if (token == null || token.isEmpty) {
      // Guest user → do nothing
      return;
    }

    try {
      final CartItemsModel response = await _repository.getCartItemsApi();

      if (response.status == true && response.data != null) {
        _items = response.data!.items ?? [];
        final summary = response.data!.summary;
        _subtotal = summary?.subtotal ?? 0.0;
        _serviceFee = summary?.serviceFee ?? 0.0;
        _discount = summary?.discount ?? 0.0;
        _total = summary?.total ?? 0.0;

        // Sync _cartItems (Map) with fetched items
        _cartItems.clear();
        for (var item in _items) {
          if (item.serviceId != null && item.quantity != null) {
            final svcId = int.tryParse(item.serviceId!);
            if (svcId != null) {
              _cartItems[svcId] = item.quantity!;
            }
          }
        }
      }
      notifyListeners();
    } catch (e) {
      dev.log('Error fetching cart items in ServiceDetailProvider: $e');
    }
  }

  final Map<int, int> _cartItems = {};

  Future<void> _fetchServiceDetails() async {
    if (service.id == null) {
      _errorMessage = 'Invalid subcategory ID';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      dev.log(
        'Fetching services - Category ID: $categoryId, Subcategory ID: ${service.id}',
      );

      final response = await _repository.serviceDetailsApi(
        categoryId,
        service.id!,
        latitude: latitude,
        longitude: longitude,
      );

      dev.log('API Response - Status: ${response.status}');
      dev.log('API Response - Message: ${response.message}');
      dev.log('API Response - Data Count: ${response.data?.length ?? 0}');

      if (response.status == true) {
        _serviceProviders = response.data ?? [];
        // Sync quantities from response
        for (var item in _serviceProviders) {
          if (item.quantity != null && item.quantity! > 0) {
            _cartItems[item.id!] = item.quantity!;
          }
        }
        if (_serviceProviders.isEmpty) {
          NoDataFoundWidget();
        }
        // Fetch cart items to populate _items and correct totals
        await fetchCartItems();
      } else {
        _errorMessage = response.message ?? 'Failed to load services';
      }
    } catch (e) {
      _errorMessage = 'Error loading services';
      dev.log('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _fetchServiceDetails();
    await fetchCartItems();
  }

  bool isInCart(int serviceId) {
    return _cartItems.containsKey(serviceId) && _cartItems[serviceId]! > 0;
  }

  int getQuantity(int serviceId) {
    return _cartItems[serviceId] ?? 0;
  }

  Future<bool> addToCart(int serviceId) async {
    try {
      _isAddingToCart = true;
      notifyListeners();

      Map<String, dynamic> requestData = {
        'service_id': serviceId,
        'quantity': 1,
      };

      dev.log('Adding to cart - Request Data: $requestData');
      dev.log('API URL: ${AppUrls.addToCartApi}');

      // API CALL
      final response = await _repository.addToCartApi(requestData);

      dev.log('Add to Cart API Raw Response: $response');
      dev.log('Response Type: ${response.runtimeType}');

      // Parse correctly
      AddToCartModel addToCartResponse = response;

      if (addToCartResponse.status == true) {
        _cartItems[serviceId] = addToCartResponse.data?.quantity ?? 1;

        dev.log('Successfully added to cart: Service ID $serviceId');

        _isAddingToCart = false;
        notifyListeners();
        Get.showToast(addToCartResponse.message ?? '', type: ToastType.success);
        await fetchCartItems();
        return true;
      } else {
        throw Exception(addToCartResponse.message ?? 'Failed to add to cart');
      }
    } catch (e) {
      dev.log('Error adding to cart: $e');
      _isAddingToCart = false;
      notifyListeners();
      // Rethrow to let the UI handle the error (e.g., showing a popup)
      rethrow;
    }
  }

  Future<void> incrementQuantity(int serviceId) async {
    // Try to find the item in our fetched items list to get the cartId
    var item = _items.firstWhere(
      (element) =>
          element.serviceId?.toString().trim() == serviceId.toString().trim(),
      orElse: () => CartItem(),
    );

    // If we don't have the cartId yet, try to refresh once
    if (item.cartId == null) {
      await fetchCartItems();
      item = _items.firstWhere(
        (element) =>
            element.serviceId?.toString().trim() == serviceId.toString().trim(),
        orElse: () => CartItem(),
      );
    }

    if (item.cartId != null) {
      await updateQuantity(item.cartId!, 1);
    } else {
      // Fallback: if we still don't have a cartId but the UI thinks it's in cart,
      // try adding to cart again (often acts as an increment on the backend)
      await addToCart(serviceId);
    }
  }

  Future<void> decrementQuantity(int serviceId) async {
    var item = _items.firstWhere(
      (element) =>
          element.serviceId?.toString().trim() == serviceId.toString().trim(),
      orElse: () => CartItem(),
    );

    // If we don't have the cartId yet, try to refresh once
    if (item.cartId == null) {
      await fetchCartItems();
      item = _items.firstWhere(
        (element) =>
            element.serviceId?.toString().trim() == serviceId.toString().trim(),
        orElse: () => CartItem(),
      );
    }

    if (item.cartId != null) {
      if ((item.quantity ?? 0) > 1) {
        await updateQuantity(item.cartId!, -1);
      } else {
        await removeItem(item.cartId!);
      }
    } else {
      dev.log('Cannot decrement: cartId not found for service $serviceId');
      // If quantity is 1 according to _cartItems, we might need a different way to remove it
      // but without cartId, removeItem is impossible.
    }
  }

  double get totalAmount {
    // If we have a calculated _total from summary, use it
    if (_total > 0) return _total;

    if (_items.isNotEmpty) {
      double total = 0;
      for (var item in _items) {
        total += (item.serviceItemTotal ?? 0);
      }
      return total;
    }

    // Fallback if _items is empty: Calculate based on _cartItems and _serviceProviders/vendorServices
    double estimatedTotal = 0;
    _cartItems.forEach((svcId, qty) {
      // Look for the price in our fetched service providers
      final svc = _serviceProviders.firstWhere(
        (s) => s.id == svcId,
        orElse: () => ServiceData(),
      );
      if (svc.id != null) {
        estimatedTotal += (svc.servicePrice ?? 0).toDouble() * qty;
      } else {
        // Also check filteredVendorServices (used in VendorDetailScreen)
        final vendorSvc = filteredVendorServices.firstWhere(
          (s) => s.id == svcId,
          orElse: () => Data(),
        );
        if (vendorSvc.id != null) {
          estimatedTotal += (vendorSvc.servicePrice ?? 0).toDouble() * qty;
        }
      }
    });
    return estimatedTotal;
  }

  int get cartItemCount {
    // Prefer the map for immediate UI feedback as it's populated during initial fetch
    return _cartItems.values.fold(0, (sum, qty) => sum + qty);
  }

  Map<int, int> get cartItems => Map.from(_cartItems);

  Future<void> removeItem(int cartId) async {
    final index = _items.indexWhere((item) => item.cartId == cartId);
    if (index == -1) return;

    // Store item for potential rollback
    final removedItem = _items[index];
    int? removedSvcId;
    int? removedQty;

    if (removedItem.serviceId != null) {
      removedSvcId = int.tryParse(removedItem.serviceId!);
      if (removedSvcId != null) {
        removedQty = _cartItems[removedSvcId];
      }
    }

    // Optimistically remove from UI
    _items.removeAt(index);
    if (removedSvcId != null) {
      _cartItems.remove(removedSvcId);
    }

    // Recalculate totals optimistically
    _subtotal = _items.fold(
      0.0,
      (sum, item) => sum + (item.serviceItemTotal ?? 0.0),
    );
    _total = _subtotal + _serviceFee;

    notifyListeners();

    try {
      final response = await _repository.removeCartItemApi(cartId);

      if (kDebugMode) {
        print('Remove Item Response: $response');
      }

      // Check if API call was successful
      if (response != null && response['status'] == true) {
        // Item successfully removed, UI already updated
        if (kDebugMode) {
          print('Item removed successfully');
        }
      } else {
        throw Exception(response?['message'] ?? 'Failed to remove item');
      }
    } catch (e) {
      // Revert on error
      _items.insert(index, removedItem);
      if (removedSvcId != null && removedQty != null) {
        _cartItems[removedSvcId] = removedQty;
      }

      // Recalculate totals after reverting
      _subtotal = _items.fold(
        0,
        (sum, item) => sum + (item.serviceItemTotal ?? 0),
      );
      _total = _subtotal + _serviceFee;

      _errorMessage = 'Failed to remove item: ${e.toString()}';
      notifyListeners();
      Get.showToast(e.toString(), type: ToastType.error);
      if (kDebugMode) {
        print('Error removing item: $e');
      }
    }
  }

  Future<void> updateQuantity(int cartId, int delta) async {
    final index = _items.indexWhere((item) => item.cartId == cartId);
    if (index == -1) return;

    // Store state for potential rollback
    final originalQty = _items[index].quantity ?? 0;
    final double price = _items[index].servicePrice ?? 0.0;
    final originalItemTotal = _items[index].serviceItemTotal ?? 0.0;
    final originalSubtotal = _subtotal;
    final originalTotal = _total;

    final newQty = originalQty + delta;
    if (newQty < 1) return; // Should have called removeItem instead

    // Optimistically update
    _items[index].quantity = newQty;
    _items[index].serviceItemTotal = price * newQty;

    // Sync _cartItems
    int? svcId;
    if (_items[index].serviceId != null) {
      svcId = int.tryParse(_items[index].serviceId!);
      if (svcId != null) {
        _cartItems[svcId] = newQty;
      }
    }

    // Recalculate totals
    _subtotal = _items.fold(
      0.0,
      (sum, item) => sum + (item.serviceItemTotal ?? 0.0),
    );
    _total = _subtotal + _serviceFee - _discount;

    notifyListeners();

    try {
      dynamic response;
      if (delta > 0) {
        response = await _repository.increaseCartItemApi(cartId);
      } else {
        response = await _repository.decreaseCartItemApi(cartId);
      }

      if (kDebugMode) {
        print("Update Quantity Response: $response");
      }

      if (response.status == true && response.data != null) {
        final int confirmedQty = (response.data!.quantity ?? 1).toInt();
        // Sync with server response if slightly different (though usually matches delta)
        if (confirmedQty != newQty) {
          _items[index].quantity = confirmedQty;
          _items[index].serviceItemTotal = price * confirmedQty;
          if (svcId != null) {
            _cartItems[svcId] = confirmedQty;
          }
          _subtotal = _items.fold(
            0.0,
            (sum, item) => sum + (item.serviceItemTotal ?? 0.0),
          );
          _total = _subtotal + _serviceFee - _discount;
          notifyListeners();
        }
      } else {
        throw Exception(response.message ?? "Failed to update quantity");
      }
    } catch (e) {
      // Revert on error
      _items[index].quantity = originalQty;
      _items[index].serviceItemTotal = originalItemTotal;
      if (svcId != null) {
        _cartItems[svcId] = originalQty;
      }
      _subtotal = originalSubtotal;
      _total = originalTotal;

      Get.showToast(e.toString(), type: ToastType.error);
      _errorMessage = "Failed to update quantity: $e";
      notifyListeners();
    }
  }
}
