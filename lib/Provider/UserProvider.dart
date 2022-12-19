import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '',
      _cartCount = '',
      _curBal = '',
      _mob = '',
      _profilePic = '',
      _email = '';
    String _totalAmount = '';
    String _storeName = "";
  String _sellerId = "";
  String _sellerProfile = "";
  String?  _userId = '';

  String? _curPincode = '';
  String? _lat = '';
  String? _lng = '';


  late SettingProvider settingsProvider;

  String get curUserName => _userName;

  String get curPincode => _curPincode ?? '';
  String get lat => _lat ?? '';
  String get lng => _lng ?? '';

  String get curCartCount => _cartCount;

  String get curBalance => _curBal;

  String get totalAmount => _totalAmount;

  String get storeName => _storeName;

  String get curSellerId => _sellerId;

  String get sellerProfile => _sellerProfile;

  String get mob => _mob;

  String get profilePic => _profilePic;

  String? get userId => _userId;

  String get email => _email;

  void setPincode(String pin) {
    _curPincode = pin;
    notifyListeners();
  }

  void setCartCount(String count) {
    _cartCount = count;
    notifyListeners();
  }

  void setBalance(String bal) {
    _curBal = bal;
    notifyListeners();
  }
  void setAmount(String bal) {
    _totalAmount = bal;
    notifyListeners();
  }
  void setStoreName(String bal) {
    _storeName = bal;
    notifyListeners();
  }
  void setSellerId(String bal) {
    _sellerId = bal;
    notifyListeners();
  }
  void setSellerProfile(String bal) {
    _sellerProfile = bal;
    notifyListeners();
  }

  void setName(String count) {
    //settingsProvider.userName=count;
    _userName = count;
    notifyListeners();
  }

  void setMobile(String count) {
    _mob = count;
    notifyListeners();
  }

  void setProfilePic(String count) {
    _profilePic = count;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setUserId(String? count) {
    _userId = count;
  }
  void setLat(String? count) {
    _lat = count;
  }
  void setLng(String? count) {
    _lng = count;
  }
}



class LocationProvider extends ChangeNotifier{
  var lat;
  var lng;
  void onChange(value){
    lat = value;
    lng = value;
    notifyListeners();
  }
}