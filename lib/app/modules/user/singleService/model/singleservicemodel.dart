class singleServiceModel {
  bool? status;
  Data? data;

  singleServiceModel({this.status, this.data});

  singleServiceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

class Data {
  int? id;
  int? vendorId;
  String? serviceName;
  String? serviceImage;
  int? categoryId;
  int? subcategoryId;
  String? description;
  String? latitude;
  String? longitude;
  int? servicePrice;
  int? durationValue;
  String? durationType;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? reviewCount;
  String? avgRating;
  Category? category;
  Category? subcategory;
  Vendor? vendor;

  Data({
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
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.reviewCount,
    this.avgRating,
    this.category,
    this.subcategory,
    this.vendor,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = parseInt(json['id']);
    vendorId = parseInt(json['vendor_id']);
    categoryId = parseInt(json['category_id']);
    subcategoryId = parseInt(json['subcategory_id']);

    serviceName = json['service_name']?.toString();
    serviceImage = json['service_image']?.toString();
    description = json['description']?.toString();

    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();

    servicePrice = parseInt(json['service_price']);
    durationValue = parseInt(json['duration_value']);

    durationType = json['duration_type']?.toString();
    status = json['status']?.toString();

    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    deletedAt = json['deleted_at']?.toString();

    reviewCount = json['reviews_count']?.toString();
    avgRating = json['average_rating']?.toString();

    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;

    subcategory = json['subcategory'] != null
        ? Category.fromJson(json['subcategory'])
        : null;

    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
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
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['reviews_count'] = reviewCount;
    data['average_rating'] = avgRating;

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
    id = parseInt(json['id']);
    categoryName = json['category_name']?.toString();
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
  String? proImg;

  Vendor({this.id, this.firstName, this.lastName, this.proImg});

  Vendor.fromJson(Map<String, dynamic> json) {
    id = parseInt(json['id']);
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    proImg = json['pro_img']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['pro_img'] = proImg;

    return data;
  }
}
