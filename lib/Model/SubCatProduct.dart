import 'Data.dart';

class SubCatProduct {
  SubCatProduct({
      this.error, 
      this.message, 
      this.minPrice, 
      this.maxPrice, 
      this.search, 
      this.filters, 
      this.tags, 
      this.total, 
      this.offset, 
      this.data,});

  SubCatProduct.fromJson(dynamic json) {
    error = json['error'];
    message = json['message'];
    minPrice = json['min_price'];
    maxPrice = json['max_price'];
    search = json['search'];
    if (json['filters'] != null) {
      filters = [];
      json['filters'].forEach((v) {
        filters!.add((v));
      });
    }
    if (json['tags'] != null) {
      tags = [];
      json['tags'].forEach((v) {
        tags!.add((v));
      });
    }
    total = json['total'];
    offset = json['offset'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }
  bool? error;
  String? message;
  String? minPrice;
  String? maxPrice;
  dynamic search;
  List<dynamic>? filters;
  List<dynamic>? tags;
  String? total;
  String? offset;
  List<Data>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = error;
    map['message'] = message;
    map['min_price'] = minPrice;
    map['max_price'] = maxPrice;
    map['search'] = search;
    if (filters != null) {
      map['filters'] = filters!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      map['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    map['total'] = total;
    map['offset'] = offset;
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}