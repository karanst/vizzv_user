import 'dart:convert';
/// error : false
/// message : "Data Retrieved Successfully"
/// data : [{"id":"16","ip_address":"49.36.18.108","username":"Rohti","password":"$2y$10$skeuNJaIZfJ3KtNCtLy4TuOd49A0CrfYmYCJDkZ9cu.CYJSJaNbb2","email":"rohitj1.alphawizz@gmail.com","mobile":"08770669964","alternate_number":"","image":null,"balance":"0","activation_selector":"c2b1350baeb56a9bf563","activation_code":"$2y$10$THcOQ.Dh2zswlxXjv89EQeXqDi.ZutiGiwetQab6dOaKaceAjc3Bu","forgotten_password_selector":null,"forgotten_password_code":null,"forgotten_password_time":null,"remember_selector":null,"remember_code":null,"created_on":"1646057546","last_login":"1646155873","active":"1","company":null,"address":"Kalyan - Ahmednagar Highway, Annabhau Sathe Nagar, Khadakpada, Kalyan, Maharashtra 421301, India","bonus":null,"cash_received":"0.00","dob":null,"country_code":null,"city":null,"area":null,"street":null,"pincode":null,"serviceable_zipcodes":null,"apikey":null,"referral_code":null,"friends_code":null,"fcm_id":"d7fZYqz9SteD29gK2C67Z6:APA91bELpwuoOugLBVFOlHuu3RXlFA8LNSVEj7X5xyecGu2alrPUUE3t8lS1jW0HFLhIl5kuRVMAapz72Y5GbjKFX6rKnc7fg6HDdC2zNrkvLVyfybXnYALzmCxdQ5HdpOG-nP3xdHX9","otp":"9786","verify_otp":"0","latitude":"19.2506635","longitude":"73.1224058","first_order":"","created_at":"2022-02-28 19:42:26","online_status":"","user_id":"154","slug":"rohti-1","category_ids":"1,4,9,11,15,2,3,5,6,7,8,20,10,12,13,14,16,17,18,19","store_name":"Rohti","store_description":"test","logo":"uploads/seller/blog_details_two_img1.jpg","cover_image":"","store_url":"https://msfresh.co.in/","no_of_ratings":"0","rating":"0.00","bank_name":"ICICI","bank_code":"54454","account_name":"alphawizz@gmail.com","account_number":"50564624598","national_identity_card":"uploads/seller/blog-list22.jpg","address_proof":"uploads/seller/blog-list23.jpg","pan_number":"454545","tax_name":"test","tax_number":"tes12345","permissions":"{\"require_products_approval\":\"1\",\"customer_privacy\":\"1\",\"open_close_status\":\"0\",\"view_order_otp\":\"1\",\"assign_delivery_boy\":\"1\",\"free_food_delivery\":\"1\"}","commission":"0.00","estimated_time":"1.00","delivery_fee":"","food_person":"test","free_food_delivery":"0","open_close_status":"1","status":"1","date_added":"2022-02-28 19:42:26","seller_id":"154"}]

FavouriteSellerModels favouriteSellerModelsFromJson(String str) => FavouriteSellerModels.fromJson(json.decode(str));
String favouriteSellerModelsToJson(FavouriteSellerModels data) => json.encode(data.toJson());
class FavouriteSellerModels {
  FavouriteSellerModels({
      bool? error, 
      String? message, 
      List<Data>? data,}){
    _error = error;
    _message = message;
    _data = data;
}

  FavouriteSellerModels.fromJson(dynamic json) {
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

/// id : "16"
/// ip_address : "49.36.18.108"
/// username : "Rohti"
/// password : "$2y$10$skeuNJaIZfJ3KtNCtLy4TuOd49A0CrfYmYCJDkZ9cu.CYJSJaNbb2"
/// email : "rohitj1.alphawizz@gmail.com"
/// mobile : "08770669964"
/// alternate_number : ""
/// image : null
/// balance : "0"
/// activation_selector : "c2b1350baeb56a9bf563"
/// activation_code : "$2y$10$THcOQ.Dh2zswlxXjv89EQeXqDi.ZutiGiwetQab6dOaKaceAjc3Bu"
/// forgotten_password_selector : null
/// forgotten_password_code : null
/// forgotten_password_time : null
/// remember_selector : null
/// remember_code : null
/// created_on : "1646057546"
/// last_login : "1646155873"
/// active : "1"
/// company : null
/// address : "Kalyan - Ahmednagar Highway, Annabhau Sathe Nagar, Khadakpada, Kalyan, Maharashtra 421301, India"
/// bonus : null
/// cash_received : "0.00"
/// dob : null
/// country_code : null
/// city : null
/// area : null
/// street : null
/// pincode : null
/// serviceable_zipcodes : null
/// apikey : null
/// referral_code : null
/// friends_code : null
/// fcm_id : "d7fZYqz9SteD29gK2C67Z6:APA91bELpwuoOugLBVFOlHuu3RXlFA8LNSVEj7X5xyecGu2alrPUUE3t8lS1jW0HFLhIl5kuRVMAapz72Y5GbjKFX6rKnc7fg6HDdC2zNrkvLVyfybXnYALzmCxdQ5HdpOG-nP3xdHX9"
/// otp : "9786"
/// verify_otp : "0"
/// latitude : "19.2506635"
/// longitude : "73.1224058"
/// first_order : ""
/// created_at : "2022-02-28 19:42:26"
/// online_status : ""
/// user_id : "154"
/// slug : "rohti-1"
/// category_ids : "1,4,9,11,15,2,3,5,6,7,8,20,10,12,13,14,16,17,18,19"
/// store_name : "Rohti"
/// store_description : "test"
/// logo : "uploads/seller/blog_details_two_img1.jpg"
/// cover_image : ""
/// store_url : "https://msfresh.co.in/"
/// no_of_ratings : "0"
/// rating : "0.00"
/// bank_name : "ICICI"
/// bank_code : "54454"
/// account_name : "alphawizz@gmail.com"
/// account_number : "50564624598"
/// national_identity_card : "uploads/seller/blog-list22.jpg"
/// address_proof : "uploads/seller/blog-list23.jpg"
/// pan_number : "454545"
/// tax_name : "test"
/// tax_number : "tes12345"
/// permissions : "{\"require_products_approval\":\"1\",\"customer_privacy\":\"1\",\"open_close_status\":\"0\",\"view_order_otp\":\"1\",\"assign_delivery_boy\":\"1\",\"free_food_delivery\":\"1\"}"
/// commission : "0.00"
/// estimated_time : "1.00"
/// delivery_fee : ""
/// food_person : "test"
/// free_food_delivery : "0"
/// open_close_status : "1"
/// status : "1"
/// date_added : "2022-02-28 19:42:26"
/// seller_id : "154"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      String? id, 
      String? ipAddress, 
      String? username, 
      String? password, 
      String? email, 
      String? mobile, 
      String? alternateNumber, 
      dynamic image, 
      String? balance, 
      String? activationSelector, 
      String? activationCode, 
      dynamic forgottenPasswordSelector, 
      dynamic forgottenPasswordCode, 
      dynamic forgottenPasswordTime, 
      dynamic rememberSelector, 
      dynamic rememberCode, 
      String? createdOn, 
      String? lastLogin, 
      String? active, 
      dynamic company, 
      String? address, 
      dynamic bonus, 
      String? cashReceived, 
      dynamic dob, 
      dynamic countryCode, 
      dynamic city, 
      dynamic area, 
      dynamic street, 
      dynamic pincode, 
      dynamic serviceableZipcodes, 
      dynamic apikey, 
      dynamic referralCode, 
      dynamic friendsCode, 
      String? fcmId, 
      String? otp, 
      String? verifyOtp, 
      String? latitude, 
      String? longitude, 
      String? firstOrder, 
      String? createdAt, 
      String? onlineStatus, 
      String? userId, 
      String? slug, 
      String? categoryIds, 
      String? storeName, 
      String? storeDescription, 
      String? logo, 
      String? coverImage, 
      String? storeUrl, 
      String? noOfRatings, 
      String? rating, 
      String? bankName, 
      String? bankCode, 
      String? accountName, 
      String? accountNumber, 
      String? nationalIdentityCard, 
      String? addressProof, 
      String? panNumber, 
      String? taxName, 
      String? taxNumber, 
      String? permissions, 
      String? commission, 
      String? estimatedTime, 
      String? deliveryFee, 
      String? foodPerson, 
      String? freeFoodDelivery, 
      String? openCloseStatus, 
      String? status, 
      String? dateAdded, 
      String? sellerId,}){
    _id = id;
    _ipAddress = ipAddress;
    _username = username;
    _password = password;
    _email = email;
    _mobile = mobile;
    _alternateNumber = alternateNumber;
    _image = image;
    _balance = balance;
    _activationSelector = activationSelector;
    _activationCode = activationCode;
    _forgottenPasswordSelector = forgottenPasswordSelector;
    _forgottenPasswordCode = forgottenPasswordCode;
    _forgottenPasswordTime = forgottenPasswordTime;
    _rememberSelector = rememberSelector;
    _rememberCode = rememberCode;
    _createdOn = createdOn;
    _lastLogin = lastLogin;
    _active = active;
    _company = company;
    _address = address;
    _bonus = bonus;
    _cashReceived = cashReceived;
    _dob = dob;
    _countryCode = countryCode;
    _city = city;
    _area = area;
    _street = street;
    _pincode = pincode;
    _serviceableZipcodes = serviceableZipcodes;
    _apikey = apikey;
    _referralCode = referralCode;
    _friendsCode = friendsCode;
    _fcmId = fcmId;
    _otp = otp;
    _verifyOtp = verifyOtp;
    _latitude = latitude;
    _longitude = longitude;
    _firstOrder = firstOrder;
    _createdAt = createdAt;
    _onlineStatus = onlineStatus;
    _userId = userId;
    _slug = slug;
    _categoryIds = categoryIds;
    _storeName = storeName;
    _storeDescription = storeDescription;
    _logo = logo;
    _coverImage = coverImage;
    _storeUrl = storeUrl;
    _noOfRatings = noOfRatings;
    _rating = rating;
    _bankName = bankName;
    _bankCode = bankCode;
    _accountName = accountName;
    _accountNumber = accountNumber;
    _nationalIdentityCard = nationalIdentityCard;
    _addressProof = addressProof;
    _panNumber = panNumber;
    _taxName = taxName;
    _taxNumber = taxNumber;
    _permissions = permissions;
    _commission = commission;
    _estimatedTime = estimatedTime;
    _deliveryFee = deliveryFee;
    _foodPerson = foodPerson;
    _freeFoodDelivery = freeFoodDelivery;
    _openCloseStatus = openCloseStatus;
    _status = status;
    _dateAdded = dateAdded;
    _sellerId = sellerId;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _ipAddress = json['ip_address'];
    _username = json['username'];
    _password = json['password'];
    _email = json['email'];
    _mobile = json['mobile'];
    _alternateNumber = json['alternate_number'];
    _image = json['image'];
    _balance = json['balance'];
    _activationSelector = json['activation_selector'];
    _activationCode = json['activation_code'];
    _forgottenPasswordSelector = json['forgotten_password_selector'];
    _forgottenPasswordCode = json['forgotten_password_code'];
    _forgottenPasswordTime = json['forgotten_password_time'];
    _rememberSelector = json['remember_selector'];
    _rememberCode = json['remember_code'];
    _createdOn = json['created_on'];
    _lastLogin = json['last_login'];
    _active = json['active'];
    _company = json['company'];
    _address = json['address'];
    _bonus = json['bonus'];
    _cashReceived = json['cash_received'];
    _dob = json['dob'];
    _countryCode = json['country_code'];
    _city = json['city'];
    _area = json['area'];
    _street = json['street'];
    _pincode = json['pincode'];
    _serviceableZipcodes = json['serviceable_zipcodes'];
    _apikey = json['apikey'];
    _referralCode = json['referral_code'];
    _friendsCode = json['friends_code'];
    _fcmId = json['fcm_id'];
    _otp = json['otp'];
    _verifyOtp = json['verify_otp'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _firstOrder = json['first_order'];
    _createdAt = json['created_at'];
    _onlineStatus = json['online_status'];
    _userId = json['user_id'];
    _slug = json['slug'];
    _categoryIds = json['category_ids'];
    _storeName = json['store_name'];
    _storeDescription = json['store_description'];
    _logo = json['logo'];
    _coverImage = json['cover_image'];
    _storeUrl = json['store_url'];
    _noOfRatings = json['no_of_ratings'];
    _rating = json['rating'];
    _bankName = json['bank_name'];
    _bankCode = json['bank_code'];
    _accountName = json['account_name'];
    _accountNumber = json['account_number'];
    _nationalIdentityCard = json['national_identity_card'];
    _addressProof = json['address_proof'];
    _panNumber = json['pan_number'];
    _taxName = json['tax_name'];
    _taxNumber = json['tax_number'];
    _permissions = json['permissions'];
    _commission = json['commission'];
    _estimatedTime = json['estimated_time'];
    _deliveryFee = json['delivery_fee'];
    _foodPerson = json['food_person'];
    _freeFoodDelivery = json['free_food_delivery'];
    _openCloseStatus = json['open_close_status'];
    _status = json['status'];
    _dateAdded = json['date_added'];
    _sellerId = json['seller_id'];
  }
  String? _id;
  String? _ipAddress;
  String? _username;
  String? _password;
  String? _email;
  String? _mobile;
  String? _alternateNumber;
  dynamic _image;
  String? _balance;
  String? _activationSelector;
  String? _activationCode;
  dynamic _forgottenPasswordSelector;
  dynamic _forgottenPasswordCode;
  dynamic _forgottenPasswordTime;
  dynamic _rememberSelector;
  dynamic _rememberCode;
  String? _createdOn;
  String? _lastLogin;
  String? _active;
  dynamic _company;
  String? _address;
  dynamic _bonus;
  String? _cashReceived;
  dynamic _dob;
  dynamic _countryCode;
  dynamic _city;
  dynamic _area;
  dynamic _street;
  dynamic _pincode;
  dynamic _serviceableZipcodes;
  dynamic _apikey;
  dynamic _referralCode;
  dynamic _friendsCode;
  String? _fcmId;
  String? _otp;
  String? _verifyOtp;
  String? _latitude;
  String? _longitude;
  String? _firstOrder;
  String? _createdAt;
  String? _onlineStatus;
  String? _userId;
  String? _slug;
  String? _categoryIds;
  String? _storeName;
  String? _storeDescription;
  String? _logo;
  String? _coverImage;
  String? _storeUrl;
  String? _noOfRatings;
  String? _rating;
  String? _bankName;
  String? _bankCode;
  String? _accountName;
  String? _accountNumber;
  String? _nationalIdentityCard;
  String? _addressProof;
  String? _panNumber;
  String? _taxName;
  String? _taxNumber;
  String? _permissions;
  String? _commission;
  String? _estimatedTime;
  String? _deliveryFee;
  String? _foodPerson;
  String? _freeFoodDelivery;
  String? _openCloseStatus;
  String? _status;
  String? _dateAdded;
  String? _sellerId;

  String? get id => _id;
  String? get ipAddress => _ipAddress;
  String? get username => _username;
  String? get password => _password;
  String? get email => _email;
  String? get mobile => _mobile;
  String? get alternateNumber => _alternateNumber;
  dynamic get image => _image;
  String? get balance => _balance;
  String? get activationSelector => _activationSelector;
  String? get activationCode => _activationCode;
  dynamic get forgottenPasswordSelector => _forgottenPasswordSelector;
  dynamic get forgottenPasswordCode => _forgottenPasswordCode;
  dynamic get forgottenPasswordTime => _forgottenPasswordTime;
  dynamic get rememberSelector => _rememberSelector;
  dynamic get rememberCode => _rememberCode;
  String? get createdOn => _createdOn;
  String? get lastLogin => _lastLogin;
  String? get active => _active;
  dynamic get company => _company;
  String? get address => _address;
  dynamic get bonus => _bonus;
  String? get cashReceived => _cashReceived;
  dynamic get dob => _dob;
  dynamic get countryCode => _countryCode;
  dynamic get city => _city;
  dynamic get area => _area;
  dynamic get street => _street;
  dynamic get pincode => _pincode;
  dynamic get serviceableZipcodes => _serviceableZipcodes;
  dynamic get apikey => _apikey;
  dynamic get referralCode => _referralCode;
  dynamic get friendsCode => _friendsCode;
  String? get fcmId => _fcmId;
  String? get otp => _otp;
  String? get verifyOtp => _verifyOtp;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  String? get firstOrder => _firstOrder;
  String? get createdAt => _createdAt;
  String? get onlineStatus => _onlineStatus;
  String? get userId => _userId;
  String? get slug => _slug;
  String? get categoryIds => _categoryIds;
  String? get storeName => _storeName;
  String? get storeDescription => _storeDescription;
  String? get logo => _logo;
  String? get coverImage => _coverImage;
  String? get storeUrl => _storeUrl;
  String? get noOfRatings => _noOfRatings;
  String? get rating => _rating;
  String? get bankName => _bankName;
  String? get bankCode => _bankCode;
  String? get accountName => _accountName;
  String? get accountNumber => _accountNumber;
  String? get nationalIdentityCard => _nationalIdentityCard;
  String? get addressProof => _addressProof;
  String? get panNumber => _panNumber;
  String? get taxName => _taxName;
  String? get taxNumber => _taxNumber;
  String? get permissions => _permissions;
  String? get commission => _commission;
  String? get estimatedTime => _estimatedTime;
  String? get deliveryFee => _deliveryFee;
  String? get foodPerson => _foodPerson;
  String? get freeFoodDelivery => _freeFoodDelivery;
  String? get openCloseStatus => _openCloseStatus;
  String? get status => _status;
  String? get dateAdded => _dateAdded;
  String? get sellerId => _sellerId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['ip_address'] = _ipAddress;
    map['username'] = _username;
    map['password'] = _password;
    map['email'] = _email;
    map['mobile'] = _mobile;
    map['alternate_number'] = _alternateNumber;
    map['image'] = _image;
    map['balance'] = _balance;
    map['activation_selector'] = _activationSelector;
    map['activation_code'] = _activationCode;
    map['forgotten_password_selector'] = _forgottenPasswordSelector;
    map['forgotten_password_code'] = _forgottenPasswordCode;
    map['forgotten_password_time'] = _forgottenPasswordTime;
    map['remember_selector'] = _rememberSelector;
    map['remember_code'] = _rememberCode;
    map['created_on'] = _createdOn;
    map['last_login'] = _lastLogin;
    map['active'] = _active;
    map['company'] = _company;
    map['address'] = _address;
    map['bonus'] = _bonus;
    map['cash_received'] = _cashReceived;
    map['dob'] = _dob;
    map['country_code'] = _countryCode;
    map['city'] = _city;
    map['area'] = _area;
    map['street'] = _street;
    map['pincode'] = _pincode;
    map['serviceable_zipcodes'] = _serviceableZipcodes;
    map['apikey'] = _apikey;
    map['referral_code'] = _referralCode;
    map['friends_code'] = _friendsCode;
    map['fcm_id'] = _fcmId;
    map['otp'] = _otp;
    map['verify_otp'] = _verifyOtp;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['first_order'] = _firstOrder;
    map['created_at'] = _createdAt;
    map['online_status'] = _onlineStatus;
    map['user_id'] = _userId;
    map['slug'] = _slug;
    map['category_ids'] = _categoryIds;
    map['store_name'] = _storeName;
    map['store_description'] = _storeDescription;
    map['logo'] = _logo;
    map['cover_image'] = _coverImage;
    map['store_url'] = _storeUrl;
    map['no_of_ratings'] = _noOfRatings;
    map['rating'] = _rating;
    map['bank_name'] = _bankName;
    map['bank_code'] = _bankCode;
    map['account_name'] = _accountName;
    map['account_number'] = _accountNumber;
    map['national_identity_card'] = _nationalIdentityCard;
    map['address_proof'] = _addressProof;
    map['pan_number'] = _panNumber;
    map['tax_name'] = _taxName;
    map['tax_number'] = _taxNumber;
    map['permissions'] = _permissions;
    map['commission'] = _commission;
    map['estimated_time'] = _estimatedTime;
    map['delivery_fee'] = _deliveryFee;
    map['food_person'] = _foodPerson;
    map['free_food_delivery'] = _freeFoodDelivery;
    map['open_close_status'] = _openCloseStatus;
    map['status'] = _status;
    map['date_added'] = _dateAdded;
    map['seller_id'] = _sellerId;
    return map;
  }

}