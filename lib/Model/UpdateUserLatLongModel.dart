import 'dart:convert';
/// error : false
/// message : "Update Successfully"

UpdateUserLatLongModel updateUserLatLongModelFromJson(String str) => UpdateUserLatLongModel.fromJson(json.decode(str));
String updateUserLatLongModelToJson(UpdateUserLatLongModel data) => json.encode(data.toJson());
class UpdateUserLatLongModel {
  UpdateUserLatLongModel({
      bool? error, 
      String? message,}){
    _error = error;
    _message = message;
}

  UpdateUserLatLongModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
  }
  bool? _error;
  String? _message;
UpdateUserLatLongModel copyWith({  bool? error,
  String? message,
}) => UpdateUserLatLongModel(  error: error ?? _error,
  message: message ?? _message,
);
  bool? get error => _error;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    return map;
  }

}