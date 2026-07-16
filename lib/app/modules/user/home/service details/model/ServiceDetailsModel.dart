class ServiceDetailsModel {
  bool? status;
  String? message;
  List<ServiceData>? data;
  Pagination? pagination;

  ServiceDetailsModel({this.status, this.message, this.data, this.pagination});

  ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ServiceData>[];
      if (json['data'] is List) {
        json['data'].forEach((v) {
          data!.add(ServiceData.fromJson(v));
        });
      } else if (json['data'] is Map<String, dynamic>) {
        data!.add(ServiceData.fromJson(json['data']));
      }
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class ServiceData {
  int? id;
  int? vendorId;
  String? serviceName;
  String? serviceImage;
  int? categoryId;
  int? subcategoryId;
  String? description;
  dynamic latitude;
  dynamic longitude;
  dynamic servicePrice;
  dynamic durationValue;
  String? durationType;
  String? status;
  dynamic quantity;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  dynamic reviewsCount;
  dynamic ratings;
  Category? category;
  Category? subcategory;
  Vendor? vendor;

  ServiceData({
    this.id,
    this.vendorId,
    this.serviceName,
    this.serviceImage,
    this.categoryId,
    this.subcategoryId,
    this.description,
    this.latitude,
    this.longitude,
    this.servicePrice,
    this.durationValue,
    this.durationType,
    this.status,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.reviewsCount,
    this.ratings,
    this.category,
    this.subcategory,
    this.vendor,
  });

  ServiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    vendorId = json['vendor_id'] != null ? int.tryParse(json['vendor_id'].toString()) : null;
    serviceName = json['service_name'];
    serviceImage = json['service_image'];
    categoryId = json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null;
    subcategoryId = json['subcategory_id'] != null ? int.tryParse(json['subcategory_id'].toString()) : null;
    description = json['description'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    servicePrice = json['service_price'] != null ? num.tryParse(json['service_price'].toString())?.toDouble() : null;
    durationValue = json['duration_value'] != null ? num.tryParse(json['duration_value'].toString())?.toInt() : null;
    durationType = json['duration_type'];
    status = json['status'];
    quantity = json['quantity'] != null ? num.tryParse(json['quantity'].toString())?.toInt() : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    reviewsCount = json['reviews_count'] != null ? num.tryParse(json['reviews_count'].toString())?.toInt() : null;
    ratings = json['average_rating'] != null 
        ? num.tryParse(json['average_rating'].toString())?.toDouble() 
        : (json['ratings'] != null ? num.tryParse(json['ratings'].toString())?.toDouble() : null);
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
    subcategory = json['subcategory'] != null
        ? Category.fromJson(json['subcategory'])
        : null;
    vendor = json['vendor'] != null
        ? Vendor.fromJson(json['vendor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vendor_id'] = vendorId;
    data['service_name'] = serviceName;
    data['service_image'] = serviceImage;
    data['category_id'] = categoryId;
    data['subcategory_id'] = subcategoryId;
    data['description'] = description;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['service_price'] = servicePrice;
    data['duration_value'] = durationValue;
    data['duration_type'] = durationType;
    data['status'] = status;
    data['quantity'] = quantity;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (subcategory != null) {
      data['subcategory'] = subcategory!.toJson();
    }
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    return data;
  }
}

class Category {
  int? id;
  String? categoryName;
  String? parentName;

  Category({this.id, this.categoryName, this.parentName});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    categoryName = json['category_name'];
    parentName = json['parent_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_name'] = categoryName;
    data['parent_name'] = parentName;
    return data;
  }
}

class Vendor {
  int? id;
  String? firstName;
  String? lastName;
  String? profileImage;
  Vendor({this.id, this.firstName, this.lastName, this.profileImage});

  Vendor.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    firstName = json['first_name'];
    lastName = json['last_name'];
    profileImage = json['pro_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['pro_img'] = profileImage;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;
  bool? hasMore;

  Pagination({
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
    this.hasMore,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'] != null ? int.tryParse(json['current_page'].toString()) : null;
    perPage = json['per_page'] != null ? int.tryParse(json['per_page'].toString()) : null;
    total = json['total'] != null ? int.tryParse(json['total'].toString()) : null;
    lastPage = json['last_page'] != null ? int.tryParse(json['last_page'].toString()) : null;
    hasMore = json['has_more'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['per_page'] = perPage;
    data['total'] = total;
    data['last_page'] = lastPage;
    data['has_more'] = hasMore;
    return data;
  }
}
