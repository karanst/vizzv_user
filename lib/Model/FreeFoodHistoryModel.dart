import 'dart:convert';
/// error : false
/// message : " Free Order Successfully"
/// data : [{"id":"1","product_identity":null,"category_id":"11","sub_category_id":"12","seller_id":"174","tax":"1","row_order":"0","type":"simple_product","stock_type":null,"name":"Daal-Makhani","short_description":"Daal-Makhani","slug":"daal-makhani","indicator":null,"cod_allowed":"0","minimum_order_quantity":"1","quantity_step_size":"1","total_allowed_quantity":"500","is_prices_inclusive_tax":"0","is_returnable":"0","is_cancelable":"0","cancelable_till":"","image":"","other_images":"[]","video_type":"","video":"","tags":"","warranty_period":"","guarantee_period":"","made_in":"","sku":null,"recommend_products":"0","free_food_delivery":"0","stock":null,"availability":null,"rating":"0","no_of_ratings":"0","description":"<p>Daal-Makhani<br></p>","deliverable_type":"1","deliverable_zipcodes":null,"status":"0","date_added":"2022-03-03 12:37:33","user_id":"173","product_id":"7","donate_person_name":"rahul bana","address":"","pickup_type":"self pickup","create_date":"2022-03-11 16:45:31"}]

FreeFoodHistoryModel freeFoodHistoryModelFromJson(String str) => FreeFoodHistoryModel.fromJson(json.decode(str));
String freeFoodHistoryModelToJson(FreeFoodHistoryModel data) => json.encode(data.toJson());
class FreeFoodHistoryModel {
  FreeFoodHistoryModel({
      bool? error, 
      String? message, 
      List<Data>? data,}){
    _error = error;
    _message = message;
    _data = data;
}

  FreeFoodHistoryModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  String? _message;
  List<Data>? _data;

  bool? get error => _error;
  String? get message => _message;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "1"
/// product_identity : null
/// category_id : "11"
/// sub_category_id : "12"
/// seller_id : "174"
/// tax : "1"
/// row_order : "0"
/// type : "simple_product"
/// stock_type : null
/// name : "Daal-Makhani"
/// short_description : "Daal-Makhani"
/// slug : "daal-makhani"
/// indicator : null
/// cod_allowed : "0"
/// minimum_order_quantity : "1"
/// quantity_step_size : "1"
/// total_allowed_quantity : "500"
/// is_prices_inclusive_tax : "0"
/// is_returnable : "0"
/// is_cancelable : "0"
/// cancelable_till : ""
/// image : ""
/// other_images : "[]"
/// video_type : ""
/// video : ""
/// tags : ""
/// warranty_period : ""
/// guarantee_period : ""
/// made_in : ""
/// sku : null
/// recommend_products : "0"
/// free_food_delivery : "0"
/// stock : null
/// availability : null
/// rating : "0"
/// no_of_ratings : "0"
/// description : "<p>Daal-Makhani<br></p>"
/// deliverable_type : "1"
/// deliverable_zipcodes : null
/// status : "0"
/// date_added : "2022-03-03 12:37:33"
/// user_id : "173"
/// product_id : "7"
/// donate_person_name : "rahul bana"
/// address : ""
/// pickup_type : "self pickup"
/// create_date : "2022-03-11 16:45:31"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      String? id, 
      dynamic productIdentity, 
      String? categoryId, 
      String? subCategoryId, 
      String? sellerId, 
      String? tax, 
      String? rowOrder, 
      String? type, 
      dynamic stockType, 
      String? name, 
      String? shortDescription, 
      String? slug, 
      dynamic indicator, 
      String? codAllowed, 
      String? minimumOrderQuantity, 
      String? quantityStepSize, 
      String? totalAllowedQuantity, 
      String? isPricesInclusiveTax, 
      String? isReturnable, 
      String? isCancelable, 
      String? cancelableTill, 
      String? image, 
      String? otherImages, 
      String? videoType, 
      String? video, 
      String? tags, 
      String? warrantyPeriod, 
      String? guaranteePeriod, 
      String? madeIn, 
      dynamic sku, 
      String? recommendProducts, 
      String? freeFoodDelivery, 
      dynamic stock, 
      dynamic availability, 
      String? rating, 
      String? noOfRatings, 
      String? description, 
      String? deliverableType, 
      dynamic deliverableZipcodes, 
      String? status, 
      String? dateAdded, 
      String? userId, 
      String? productId, 
      String? donatePersonName, 
      String? address, 
      String? pickupType, 
      String? createDate,}){
    _id = id;
    _productIdentity = productIdentity;
    _categoryId = categoryId;
    _subCategoryId = subCategoryId;
    _sellerId = sellerId;
    _tax = tax;
    _rowOrder = rowOrder;
    _type = type;
    _stockType = stockType;
    _name = name;
    _shortDescription = shortDescription;
    _slug = slug;
    _indicator = indicator;
    _codAllowed = codAllowed;
    _minimumOrderQuantity = minimumOrderQuantity;
    _quantityStepSize = quantityStepSize;
    _totalAllowedQuantity = totalAllowedQuantity;
    _isPricesInclusiveTax = isPricesInclusiveTax;
    _isReturnable = isReturnable;
    _isCancelable = isCancelable;
    _cancelableTill = cancelableTill;
    _image = image;
    _otherImages = otherImages;
    _videoType = videoType;
    _video = video;
    _tags = tags;
    _warrantyPeriod = warrantyPeriod;
    _guaranteePeriod = guaranteePeriod;
    _madeIn = madeIn;
    _sku = sku;
    _recommendProducts = recommendProducts;
    _freeFoodDelivery = freeFoodDelivery;
    _stock = stock;
    _availability = availability;
    _rating = rating;
    _noOfRatings = noOfRatings;
    _description = description;
    _deliverableType = deliverableType;
    _deliverableZipcodes = deliverableZipcodes;
    _status = status;
    _dateAdded = dateAdded;
    _userId = userId;
    _productId = productId;
    _donatePersonName = donatePersonName;
    _address = address;
    _pickupType = pickupType;
    _createDate = createDate;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _productIdentity = json['product_identity'];
    _categoryId = json['category_id'];
    _subCategoryId = json['sub_category_id'];
    _sellerId = json['seller_id'];
    _tax = json['tax'];
    _rowOrder = json['row_order'];
    _type = json['type'];
    _stockType = json['stock_type'];
    _name = json['name'];
    _shortDescription = json['short_description'];
    _slug = json['slug'];
    _indicator = json['indicator'];
    _codAllowed = json['cod_allowed'];
    _minimumOrderQuantity = json['minimum_order_quantity'];
    _quantityStepSize = json['quantity_step_size'];
    _totalAllowedQuantity = json['total_allowed_quantity'];
    _isPricesInclusiveTax = json['is_prices_inclusive_tax'];
    _isReturnable = json['is_returnable'];
    _isCancelable = json['is_cancelable'];
    _cancelableTill = json['cancelable_till'];
    _image = json['image'];
    _otherImages = json['other_images'];
    _videoType = json['video_type'];
    _video = json['video'];
    _tags = json['tags'];
    _warrantyPeriod = json['warranty_period'];
    _guaranteePeriod = json['guarantee_period'];
    _madeIn = json['made_in'];
    _sku = json['sku'];
    _recommendProducts = json['recommend_products'];
    _freeFoodDelivery = json['free_food_delivery'];
    _stock = json['stock'];
    _availability = json['availability'];
    _rating = json['rating'];
    _noOfRatings = json['no_of_ratings'];
    _description = json['description'];
    _deliverableType = json['deliverable_type'];
    _deliverableZipcodes = json['deliverable_zipcodes'];
    _status = json['status'];
    _dateAdded = json['date_added'];
    _userId = json['user_id'];
    _productId = json['product_id'];
    _donatePersonName = json['donate_person_name'];
    _address = json['address'];
    _pickupType = json['pickup_type'];
    _createDate = json['create_date'];
  }
  String? _id;
  dynamic _productIdentity;
  String? _categoryId;
  String? _subCategoryId;
  String? _sellerId;
  String? _tax;
  String? _rowOrder;
  String? _type;
  dynamic _stockType;
  String? _name;
  String? _shortDescription;
  String? _slug;
  dynamic _indicator;
  String? _codAllowed;
  String? _minimumOrderQuantity;
  String? _quantityStepSize;
  String? _totalAllowedQuantity;
  String? _isPricesInclusiveTax;
  String? _isReturnable;
  String? _isCancelable;
  String? _cancelableTill;
  String? _image;
  String? _otherImages;
  String? _videoType;
  String? _video;
  String? _tags;
  String? _warrantyPeriod;
  String? _guaranteePeriod;
  String? _madeIn;
  dynamic _sku;
  String? _recommendProducts;
  String? _freeFoodDelivery;
  dynamic _stock;
  dynamic _availability;
  String? _rating;
  String? _noOfRatings;
  String? _description;
  String? _deliverableType;
  dynamic _deliverableZipcodes;
  String? _status;
  String? _dateAdded;
  String? _userId;
  String? _productId;
  String? _donatePersonName;
  String? _address;
  String? _pickupType;
  String? _createDate;

  String? get id => _id;
  dynamic get productIdentity => _productIdentity;
  String? get categoryId => _categoryId;
  String? get subCategoryId => _subCategoryId;
  String? get sellerId => _sellerId;
  String? get tax => _tax;
  String? get rowOrder => _rowOrder;
  String? get type => _type;
  dynamic get stockType => _stockType;
  String? get name => _name;
  String? get shortDescription => _shortDescription;
  String? get slug => _slug;
  dynamic get indicator => _indicator;
  String? get codAllowed => _codAllowed;
  String? get minimumOrderQuantity => _minimumOrderQuantity;
  String? get quantityStepSize => _quantityStepSize;
  String? get totalAllowedQuantity => _totalAllowedQuantity;
  String? get isPricesInclusiveTax => _isPricesInclusiveTax;
  String? get isReturnable => _isReturnable;
  String? get isCancelable => _isCancelable;
  String? get cancelableTill => _cancelableTill;
  String? get image => _image;
  String? get otherImages => _otherImages;
  String? get videoType => _videoType;
  String? get video => _video;
  String? get tags => _tags;
  String? get warrantyPeriod => _warrantyPeriod;
  String? get guaranteePeriod => _guaranteePeriod;
  String? get madeIn => _madeIn;
  dynamic get sku => _sku;
  String? get recommendProducts => _recommendProducts;
  String? get freeFoodDelivery => _freeFoodDelivery;
  dynamic get stock => _stock;
  dynamic get availability => _availability;
  String? get rating => _rating;
  String? get noOfRatings => _noOfRatings;
  String? get description => _description;
  String? get deliverableType => _deliverableType;
  dynamic get deliverableZipcodes => _deliverableZipcodes;
  String? get status => _status;
  String? get dateAdded => _dateAdded;
  String? get userId => _userId;
  String? get productId => _productId;
  String? get donatePersonName => _donatePersonName;
  String? get address => _address;
  String? get pickupType => _pickupType;
  String? get createDate => _createDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['product_identity'] = _productIdentity;
    map['category_id'] = _categoryId;
    map['sub_category_id'] = _subCategoryId;
    map['seller_id'] = _sellerId;
    map['tax'] = _tax;
    map['row_order'] = _rowOrder;
    map['type'] = _type;
    map['stock_type'] = _stockType;
    map['name'] = _name;
    map['short_description'] = _shortDescription;
    map['slug'] = _slug;
    map['indicator'] = _indicator;
    map['cod_allowed'] = _codAllowed;
    map['minimum_order_quantity'] = _minimumOrderQuantity;
    map['quantity_step_size'] = _quantityStepSize;
    map['total_allowed_quantity'] = _totalAllowedQuantity;
    map['is_prices_inclusive_tax'] = _isPricesInclusiveTax;
    map['is_returnable'] = _isReturnable;
    map['is_cancelable'] = _isCancelable;
    map['cancelable_till'] = _cancelableTill;
    map['image'] = _image;
    map['other_images'] = _otherImages;
    map['video_type'] = _videoType;
    map['video'] = _video;
    map['tags'] = _tags;
    map['warranty_period'] = _warrantyPeriod;
    map['guarantee_period'] = _guaranteePeriod;
    map['made_in'] = _madeIn;
    map['sku'] = _sku;
    map['recommend_products'] = _recommendProducts;
    map['free_food_delivery'] = _freeFoodDelivery;
    map['stock'] = _stock;
    map['availability'] = _availability;
    map['rating'] = _rating;
    map['no_of_ratings'] = _noOfRatings;
    map['description'] = _description;
    map['deliverable_type'] = _deliverableType;
    map['deliverable_zipcodes'] = _deliverableZipcodes;
    map['status'] = _status;
    map['date_added'] = _dateAdded;
    map['user_id'] = _userId;
    map['product_id'] = _productId;
    map['donate_person_name'] = _donatePersonName;
    map['address'] = _address;
    map['pickup_type'] = _pickupType;
    map['create_date'] = _createDate;
    return map;
  }

}