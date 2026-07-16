class vendorDetailModel {
  bool? status;
  String? message;
  List<Data>? data;

  vendorDetailModel({this.status, this.message, this.data});

  vendorDetailModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      status = json['status'];
      message = json['message'];

      if (json['data'] != null) {
        data = [];
        for (var item in json['data']) {
          data!.add(Data.fromJson(item));
        }
      }
    } else if (json is List) {
      status = true;
      message = "Success";
      data = json.map<Data>((e) => Data.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
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
  dynamic latitude;
  dynamic longitude;
  double? servicePrice;
  int? durationValue;
  String? durationType;
  String? status;
  int? quantity;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  double? averageRating;
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
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.averageRating,
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

    latitude = json['latitude'];
    longitude = json['longitude'];

    servicePrice = parseDouble(json['service_price']);
    durationValue = parseInt(json['duration_value']);

    durationType = json['duration_type']?.toString();
    status = json['status']?.toString();

    quantity = parseInt(json['quantity']);

    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();

    deletedAt = json['deleted_at'];

    averageRating = parseDouble(json['average_rating']);

    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;

    subcategory = json['subcategory'] != null
        ? Category.fromJson(json['subcategory'])
        : null;

    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'service_name': serviceName,
      'service_image': serviceImage,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'service_price': servicePrice,
      'duration_value': durationValue,
      'duration_type': durationType,
      'status': status,
      'quantity': quantity,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'average_rating': averageRating,
      'category': category?.toJson(),
      'subcategory': subcategory?.toJson(),
      'vendor': vendor?.toJson(),
    };
  }
}

class Category {
  int? id;
  String? categoryName;
  String? parentName;

  Category({this.id, this.categoryName, this.parentName});

  Category.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      id = parseInt(json['id']);
      categoryName = json['category_name']?.toString();
      parentName = json['parent_name']?.toString();
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'category_name': categoryName, 'parent_name': parentName};
  }
}

class Vendor {
  int? id;
  String? firstName;
  String? lastName;
  String? proImg;
  double? receivedReviewsAvgRating;
  int? receivedReviewsCount;

  Vendor({
    this.id,
    this.firstName,
    this.lastName,
    this.proImg,
    this.receivedReviewsAvgRating,
    this.receivedReviewsCount,
  });

  Vendor.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      id = parseInt(json['id']);

      firstName = json['first_name']?.toString();
      lastName = json['last_name']?.toString();
      proImg = json['pro_img']?.toString();

      receivedReviewsAvgRating = parseDouble(
        json['received_reviews_avg_rating'],
      );

      receivedReviewsCount = parseInt(json['received_reviews_count']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'pro_img': proImg,
      'received_reviews_avg_rating': receivedReviewsAvgRating,
      'received_reviews_count': receivedReviewsCount,
    };
  }
}
