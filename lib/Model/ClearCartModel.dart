import 'dart:convert';
/// error : false
/// message : "Cart empty Successfully"

ClearCartModel clearCartModelFromJson(String str) => ClearCartModel.fromJson(json.decode(str));
String clearCartModelToJson(ClearCartModel data) => json.encode(data.toJson());
class ClearCartModel {
  ClearCartModel({
      bool? error, 
      String? message,}){
    _error = error;
    _message = message;
}

  ClearCartModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
  }
  bool? _error;
  String? _message;

  bool? get error => _error;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    return map;
  }

}