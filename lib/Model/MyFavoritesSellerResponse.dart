class MyFavoritesSellerResponse {
  bool? error;
  String? message;
  List<Data>? data;

  MyFavoritesSellerResponse({this.error, this.message, this.data});

  MyFavoritesSellerResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? ipAddress;
  String? username;
  String? password;
  String? email;
  String? mobile;
  String? alternateNumber;
  Null? image;
  String? balance;
  String? activationSelector;
  String? activationCode;
  Null? forgottenPasswordSelector;
  Null? forgottenPasswordCode;
  Null? forgottenPasswordTime;
  Null? rememberSelector;
  Null? rememberCode;
  String? createdOn;
  String? lastLogin;
  String? active;
  Null? company;
  String? address;
  Null? bonus;
  String? cashReceived;
  Null? dob;
  Null? countryCode;
  Null? city;
  Null? area;
  Null? street;
  Null? pincode;
  Null? serviceableZipcodes;
  Null? apikey;
  Null? referralCode;
  Null? friendsCode;
  String? fcmId;
  String? otp;
  String? verifyOtp;
  String? latitude;
  String? longitude;
  String? firstOrder;
  String? createdAt;
  String? onlineStatus;
  String? userId;
  String? slug;
  String? categoryIds;
  String? storeName;
  String? storeDescription;
  String? logo;
  String? coverImage;
  String? storeUrl;
  String? noOfRatings;
  String? rating;
  String? bankName;
  String? bankCode;
  String? accountName;
  String? accountNumber;
  String? nationalIdentityCard;
  String? addressProof;
  String? panNumber;
  String? taxName;
  String? taxNumber;
  String? permissions;
  String? commission;
  String? estimatedTime;
  String? deliveryFee;
  String? foodPerson;
  String? openCloseStatus;
  String? status;
  String? dateAdded;
  String? sellerId;

  Data(
      {this.id,
      this.ipAddress,
      this.username,
      this.password,
      this.email,
      this.mobile,
      this.alternateNumber,
      this.image,
      this.balance,
      this.activationSelector,
      this.activationCode,
      this.forgottenPasswordSelector,
      this.forgottenPasswordCode,
      this.forgottenPasswordTime,
      this.rememberSelector,
      this.rememberCode,
      this.createdOn,
      this.lastLogin,
      this.active,
      this.company,
      this.address,
      this.bonus,
      this.cashReceived,
      this.dob,
      this.countryCode,
      this.city,
      this.area,
      this.street,
      this.pincode,
      this.serviceableZipcodes,
      this.apikey,
      this.referralCode,
      this.friendsCode,
      this.fcmId,
      this.otp,
      this.verifyOtp,
      this.latitude,
      this.longitude,
      this.firstOrder,
      this.createdAt,
      this.onlineStatus,
      this.userId,
      this.slug,
      this.categoryIds,
      this.storeName,
      this.storeDescription,
      this.logo,
      this.coverImage,
      this.storeUrl,
      this.noOfRatings,
      this.rating,
      this.bankName,
      this.bankCode,
      this.accountName,
      this.accountNumber,
      this.nationalIdentityCard,
      this.addressProof,
      this.panNumber,
      this.taxName,
      this.taxNumber,
      this.permissions,
      this.commission,
      this.estimatedTime,
      this.deliveryFee,
      this.foodPerson,
      this.openCloseStatus,
      this.status,
      this.dateAdded,
      this.sellerId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ipAddress = json['ip_address'];
    username = json['username'];
    password = json['password'];
    email = json['email'];
    mobile = json['mobile'];
    alternateNumber = json['alternate_number'];
    image = json['image'];
    balance = json['balance'];
    activationSelector = json['activation_selector'];
    activationCode = json['activation_code'];
    forgottenPasswordSelector = json['forgotten_password_selector'];
    forgottenPasswordCode = json['forgotten_password_code'];
    forgottenPasswordTime = json['forgotten_password_time'];
    rememberSelector = json['remember_selector'];
    rememberCode = json['remember_code'];
    createdOn = json['created_on'];
    lastLogin = json['last_login'];
    active = json['active'];
    company = json['company'];
    address = json['address'];
    bonus = json['bonus'];
    cashReceived = json['cash_received'];
    dob = json['dob'];
    countryCode = json['country_code'];
    city = json['city'];
    area = json['area'];
    street = json['street'];
    pincode = json['pincode'];
    serviceableZipcodes = json['serviceable_zipcodes'];
    apikey = json['apikey'];
    referralCode = json['referral_code'];
    friendsCode = json['friends_code'];
    fcmId = json['fcm_id'];
    otp = json['otp'];
    verifyOtp = json['verify_otp'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    firstOrder = json['first_order'];
    createdAt = json['created_at'];
    onlineStatus = json['online_status'];
    userId = json['user_id'];
    slug = json['slug'];
    categoryIds = json['category_ids'];
    storeName = json['store_name'];
    storeDescription = json['store_description'];
    logo = json['logo'];
    coverImage = json['cover_image'];
    storeUrl = json['store_url'];
    noOfRatings = json['no_of_ratings'];
    rating = json['rating'];
    bankName = json['bank_name'];
    bankCode = json['bank_code'];
    accountName = json['account_name'];
    accountNumber = json['account_number'];
    nationalIdentityCard = json['national_identity_card'];
    addressProof = json['address_proof'];
    panNumber = json['pan_number'];
    taxName = json['tax_name'];
    taxNumber = json['tax_number'];
    permissions = json['permissions'];
    commission = json['commission'];
    estimatedTime = json['estimated_time'];
    deliveryFee = json['delivery_fee'];
    foodPerson = json['food_person'];
    openCloseStatus = json['open_close_status'];
    status = json['status'];
    dateAdded = json['date_added'];
    sellerId = json['seller_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ip_address'] = this.ipAddress;
    data['username'] = this.username;
    data['password'] = this.password;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['alternate_number'] = this.alternateNumber;
    data['image'] = this.image;
    data['balance'] = this.balance;
    data['activation_selector'] = this.activationSelector;
    data['activation_code'] = this.activationCode;
    data['forgotten_password_selector'] = this.forgottenPasswordSelector;
    data['forgotten_password_code'] = this.forgottenPasswordCode;
    data['forgotten_password_time'] = this.forgottenPasswordTime;
    data['remember_selector'] = this.rememberSelector;
    data['remember_code'] = this.rememberCode;
    data['created_on'] = this.createdOn;
    data['last_login'] = this.lastLogin;
    data['active'] = this.active;
    data['company'] = this.company;
    data['address'] = this.address;
    data['bonus'] = this.bonus;
    data['cash_received'] = this.cashReceived;
    data['dob'] = this.dob;
    data['country_code'] = this.countryCode;
    data['city'] = this.city;
    data['area'] = this.area;
    data['street'] = this.street;
    data['pincode'] = this.pincode;
    data['serviceable_zipcodes'] = this.serviceableZipcodes;
    data['apikey'] = this.apikey;
    data['referral_code'] = this.referralCode;
    data['friends_code'] = this.friendsCode;
    data['fcm_id'] = this.fcmId;
    data['otp'] = this.otp;
    data['verify_otp'] = this.verifyOtp;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['first_order'] = this.firstOrder;
    data['created_at'] = this.createdAt;
    data['online_status'] = this.onlineStatus;
    data['user_id'] = this.userId;
    data['slug'] = this.slug;
    data['category_ids'] = this.categoryIds;
    data['store_name'] = this.storeName;
    data['store_description'] = this.storeDescription;
    data['logo'] = this.logo;
    data['cover_image'] = this.coverImage;
    data['store_url'] = this.storeUrl;
    data['no_of_ratings'] = this.noOfRatings;
    data['rating'] = this.rating;
    data['bank_name'] = this.bankName;
    data['bank_code'] = this.bankCode;
    data['account_name'] = this.accountName;
    data['account_number'] = this.accountNumber;
    data['national_identity_card'] = this.nationalIdentityCard;
    data['address_proof'] = this.addressProof;
    data['pan_number'] = this.panNumber;
    data['tax_name'] = this.taxName;
    data['tax_number'] = this.taxNumber;
    data['permissions'] = this.permissions;
    data['commission'] = this.commission;
    data['estimated_time'] = this.estimatedTime;
    data['delivery_fee'] = this.deliveryFee;
    data['food_person'] = this.foodPerson;
    data['open_close_status'] = this.openCloseStatus;
    data['status'] = this.status;
    data['date_added'] = this.dateAdded;
    data['seller_id'] = this.sellerId;
    return data;
  }
}
