class CategoryModel {
  bool? status;
  String? message;
  List<Data>? data;

  CategoryModel({this.status, this.message, this.data});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? categoryName;
  String? icon;
  int? parentId;
  String? slug;
  String? status;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;
  List<Subcategories>? subcategories;

  Data(
      {this.id,
        this.categoryName,
        this.icon,
        this.parentId,
        this.slug,
        this.status,
        this.deletedAt,
        this.createdAt,
        this.updatedAt,
        this.subcategories});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    categoryName = json['category_name'];
    icon = json['icon'];
    parentId = json['parent_id'] != null ? int.tryParse(json['parent_id'].toString()) : null;
    slug = json['slug'];
    status = json['status'];
    deletedAt = json['deleted_at']?.toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['subcategories'] != null) {
      subcategories = <Subcategories>[];
      json['subcategories'].forEach((v) {
        subcategories!.add(Subcategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_name'] = categoryName;
    data['icon'] = icon;
    data['parent_id'] = parentId;
    data['slug'] = slug;
    data['status'] = status;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (subcategories != null) {
      data['subcategories'] =
          subcategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subcategories {
  int? id;
  String? categoryName;
  String? icon;
  int? parentId;
  String? slug;
  String? status;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  Subcategories(
      {this.id,
        this.categoryName,
        this.icon,
        this.parentId,
        this.slug,
        this.status,
        this.deletedAt,
        this.createdAt,
        this.updatedAt});

  Subcategories.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    categoryName = json['category_name'];
    icon = json['icon'];
    parentId = json['parent_id'] != null ? int.tryParse(json['parent_id'].toString()) : null;
    slug = json['slug'];
    status = json['status'];
    deletedAt = json['deleted_at']?.toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_name'] = categoryName;
    data['icon'] = icon;
    data['parent_id'] = parentId;
    data['slug'] = slug;
    data['status'] = status;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
