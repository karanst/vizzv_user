import 'dart:convert';
/// error : false
/// message : "Place Free Order Successfully"

FreeFoodOrderModel freeFoodOrderModelFromJson(String str) => FreeFoodOrderModel.fromJson(json.decode(str));
String freeFoodOrderModelToJson(FreeFoodOrderModel data) => json.encode(data.toJson());
class FreeFoodOrderModel {
  FreeFoodOrderModel({
      bool? error, 
      String? message,}){
    _error = error;
    _message = message;
}

  FreeFoodOrderModel.fromJson(dynamic json) {
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