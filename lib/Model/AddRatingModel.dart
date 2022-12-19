import 'dart:convert';
/// error : false
/// message : "Added Rating Successfully"

AddRatingModel addRatingModelFromJson(String str) => AddRatingModel.fromJson(json.decode(str));
String addRatingModelToJson(AddRatingModel data) => json.encode(data.toJson());
class AddRatingModel {
  AddRatingModel({
      bool? error, 
      String? message,}){
    _error = error;
    _message = message;
}

  AddRatingModel.fromJson(dynamic json) {
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