// lib/features/store/model/store_response_model.dart
import 'package:starter_codes/features/store/model/store_model.dart';

class StoreResponse {
  final List<Store> stores;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  StoreResponse({
    required this.stores,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  // fromJson
  factory StoreResponse.fromJson(Map<String, dynamic> json) {
    return StoreResponse(
      stores: (json['data'] as List<dynamic>?)
              ?.map((e) => Store.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [], // Provide an empty list if 'data' is null or not a List
      totalCount: json['totalCount'] as int? ?? 0, // Default to 0 if null
      currentPage: json['currentPage'] as int? ?? 0, // Default to 0 if null
      totalPages: json['totalPages'] as int? ?? 0, // Default to 0 if null
    );
  }

  // toJson (Optional, as this is usually for receiving data)
  Map<String, dynamic> toJson() {
    return {
      'data': stores.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
  }

  // copyWith
  StoreResponse copyWith({
    List<Store>? stores,
    int? totalCount,
    int? currentPage,
    int? totalPages,
  }) {
    return StoreResponse(
      stores: stores ?? this.stores,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

// DEFINING SingleStoreResponse AND SingleStoreData HERE
class SingleStoreResponse {
  final bool success;
  final String message;
  final SingleStoreData data; // A new class to hold the nested 'store' and 'storeProducts'

  SingleStoreResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SingleStoreResponse.fromJson(Map<String, dynamic> json) {
    // Safely cast and provide defaults
    final bool success = json['success'] as bool? ?? false;
    final String message = json['message'] as String? ?? 'Unknown message';
    final Map<String, dynamic>? dataJson = json['data'] as Map<String, dynamic>?;

    return SingleStoreResponse(
      success: success,
      message: message,
      // If dataJson is null, we need to provide a default SingleStoreData instance
      data: dataJson != null ? SingleStoreData.fromJson(dataJson) : SingleStoreData(
        store: Store( // Provide a default empty or invalid Store
          id: '', name: 'N/A', email: 'N/A', isEmailVerified: false, role: '', createdAt: DateTime.now().toString(), updatedAt: DateTime.now().toString(),
          address: '', avatar: null, bio: '', lat: 0.0, lga: '', lng: 0.0, phone: '', state: '',
        ),
        storeProducts: [], // Default to an empty list of products
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }

  SingleStoreResponse copyWith({
    bool? success,
    String? message,
    SingleStoreData? data,
  }) {
    return SingleStoreResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

// New class to represent the 'data' object within the Single Store API response
class SingleStoreData {
  final Store store;
  final List<StoreProduct> storeProducts;

  SingleStoreData({
    required this.store,
    required this.storeProducts,
  });

  factory SingleStoreData.fromJson(Map<String, dynamic> json) {
    // Safely cast and provide defaults for nested objects/lists
    final Map<String, dynamic>? storeJson = json['store'] as Map<String, dynamic>?;
    final List<dynamic>? storeProductsList = json['storeProducts'] as List<dynamic>?;

    return SingleStoreData(
      store: storeJson != null ? Store.fromJson(storeJson) : Store(
        id: '', name: 'N/A', email: 'N/A', isEmailVerified: false, role: '', createdAt: DateTime.now().toString(), updatedAt: DateTime.now().toString(),
        address: '', avatar: null, bio: '', lat: 0.0, lga: '', lng: 0.0, phone: '', state: '',
      ), // Provide a default Store if 'store' is null
      storeProducts: storeProductsList
              ?.map((e) => StoreProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [], // Provide an empty list if 'storeProducts' is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store': store.toJson(),
      'storeProducts': storeProducts.map((e) => e.toJson()).toList(),
    };
  }

  SingleStoreData copyWith({
    Store? store,
    List<StoreProduct>? storeProducts,
  }) {
    return SingleStoreData(
      store: store ?? this.store,
      storeProducts: storeProducts ?? this.storeProducts,
    );
  }
}

// Your existing PaginatedStoreProductsResponseData
class PaginatedStoreProductsResponseData {
  final List<StoreProduct> fetchedData;
  final int noOfPages;
  final int total;
  final int pageNo;
  final int pageSize;

  PaginatedStoreProductsResponseData({
    required this.fetchedData,
    required this.noOfPages,
    required this.total,
    required this.pageNo,
    required this.pageSize,
  });

  // fromJson
  factory PaginatedStoreProductsResponseData.fromJson(
      Map<String, dynamic> json) {
    return PaginatedStoreProductsResponseData(
      fetchedData: (json['fetchedData'] as List<dynamic>?)
              ?.map((e) => StoreProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [], // Provide an empty list if 'fetchedData' is null
      noOfPages: json['noOfPages'] as int? ?? 0, // Default to 0 if null
      total: json['total'] as int? ?? 0, // Default to 0 if null
      pageNo: json['pageNo'] as int? ?? 0, // Default to 0 if null
      pageSize: json['pageSize'] as int? ?? 0, // Default to 0 if null
    );
  }

  // toJson (Optional)
  Map<String, dynamic> toJson() {
    return {
      'fetchedData': fetchedData.map((e) => e.toJson()).toList(),
      'noOfPages': noOfPages,
      'total': total,
      'pageNo': pageNo,
      'pageSize': pageSize,
    };
  }

  // copyWith
  PaginatedStoreProductsResponseData copyWith({
    List<StoreProduct>? fetchedData,
    int? noOfPages,
    int? total,
    int? pageNo,
    int? pageSize,
  }) {
    return PaginatedStoreProductsResponseData(
      fetchedData: fetchedData ?? this.fetchedData,
      noOfPages: noOfPages ?? this.noOfPages,
      total: total ?? this.total,
      pageNo: pageNo ?? this.pageNo,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}