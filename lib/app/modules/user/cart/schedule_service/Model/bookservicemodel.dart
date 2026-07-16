class BookServiceModel {
  bool? status;
  int? vendorId;
  VendorAvailability? vendorAvailability;
  DefaultAddress? defaultAddress;

  BookServiceModel({
    this.status,
    this.vendorId,
    this.vendorAvailability,
    this.defaultAddress,
  });
  BookServiceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    vendorId = json['vendor_id'];

    vendorAvailability =
        (json['vendor_availability'] != null &&
            json['vendor_availability'] is Map)
        ? VendorAvailability.fromJson(
            json['vendor_availability'] as Map<String, dynamic>,
          )
        : null;

    defaultAddress =
        (json['default_address'] != null && json['default_address'] is Map)
        ? DefaultAddress.fromJson(
            json['default_address'] as Map<String, dynamic>,
          )
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['vendor_id'] = vendorId;
    if (vendorAvailability != null) {
      data['vendor_availability'] = vendorAvailability!.toJson();
    }
    data['default_address'] = defaultAddress?.toJson();
    return data;
  }
}

class VendorAvailability {
  Map<String, List<DaySlot>>? days;

  VendorAvailability({this.days});

  VendorAvailability.fromJson(dynamic json) {
    days = {};

    if (json is Map) {
      json.forEach((key, value) {
        if (value is List) {
          days![key.toString()] = value
              .map<DaySlot>(
                (e) => DaySlot.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    days?.forEach((key, value) {
      data[key] = value.map((e) => e.toJson()).toList();
    });

    return data;
  }
}
// class VendorAvailability {
//   // Map key = day of week, value = list of slots
//   Map<String, List<DaySlot>>? days;

//   VendorAvailability({this.days});

//   VendorAvailability.fromJson(dynamic json) {
//     days = {};
//     if (json is Map) {
//       json.forEach((key, value) {
//         if (value is List) {
//           days![key] = value.map((e) => DaySlot.fromJson(e)).toList();
//         }
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     days?.forEach((key, value) {
//       data[key] = value.map((e) => e.toJson()).toList();
//     });
//     return data;
//   }
// }

class DaySlot {
  String? from;
  String? to;

  DaySlot({this.from, this.to});

  DaySlot.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() => {'from': from, 'to': to};
}

class DefaultAddress {
  int? id;
  int? userId;
  String? addressType;
  bool? isDefault;
  String? streetAddress;
  String? apartment;
  String? city;
  String? zipCode;
  String? createdAt;
  String? updatedAt;
  String? fullAddress;

  DefaultAddress({
    this.id,
    this.userId,
    this.addressType,
    this.isDefault,
    this.streetAddress,
    this.apartment,
    this.city,
    this.zipCode,
    this.createdAt,
    this.updatedAt,
    this.fullAddress,
  });

  DefaultAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    addressType = json['address_type'];
    isDefault = json['is_default'];
    streetAddress = json['street_address'];
    apartment = json['apartment'];
    city = json['city'];
    zipCode = json['zip_code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fullAddress = json['full_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['address_type'] = addressType;
    data['is_default'] = isDefault;
    data['street_address'] = streetAddress;
    data['apartment'] = apartment;
    data['city'] = city;
    data['zip_code'] = zipCode;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['full_address'] = fullAddress;
    return data;
  }
}
