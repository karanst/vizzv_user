import 'dart:convert';
/// error : false
/// message : "Get Rating"
/// data : [{"id":"6","user_id":"154","seller_id":"154","rating":"2","comment":"new","insert_date":"2022-03-02 11:57:40","user_name":"Rohti"},{"id":"7","user_id":"166","seller_id":"154","rating":"5","comment":"dfsgsd","insert_date":"2022-03-02 12:14:58","user_name":""},{"id":"8","user_id":"154","seller_id":"154","rating":"4","comment":"new","insert_date":"2022-03-02 11:57:45","user_name":"Rohti"},{"id":"9","user_id":"154","seller_id":"154","rating":"4","comment":"new","insert_date":"2022-03-02 12:15:20","user_name":"Rohti"},{"id":"10","user_id":"163","seller_id":"154","rating":"5","comment":"new","insert_date":"2022-03-02 12:15:06","user_name":"shaikh"},{"id":"11","user_id":"173","seller_id":"154","rating":"5.0","comment":"wow","insert_date":"2022-03-02 13:47:15","user_name":"Dminj"},{"id":"12","user_id":"173","seller_id":"154","rating":"5.0","comment":"bjvjfhchnm","insert_date":"2022-03-02 14:03:15","user_name":"Dminj"},{"id":"13","user_id":"173","seller_id":"154","rating":"5.0","comment":"chxj","insert_date":"2022-03-02 14:47:33","user_name":"Dminj"},{"id":"14","user_id":"173","seller_id":"154","rating":"4.0","comment":"hwbxjd sjbd","insert_date":"2022-03-02 15:31:09","user_name":"Dminj"},{"id":"15","user_id":"173","seller_id":"154","rating":"3.0","comment":"hwbxjd sjbd","insert_date":"2022-03-02 15:34:00","user_name":"Dminj"}]

GetSellerRatingModel getSellerRatingModelFromJson(String str) => GetSellerRatingModel.fromJson(json.decode(str));
String getSellerRatingModelToJson(GetSellerRatingModel data) => json.encode(data.toJson());
class GetSellerRatingModel {
  GetSellerRatingModel({
      bool? error, 
      String? message, 
      List<Data>? data,}){
    _error = error;
    _message = message;
    _data = data;
}

  GetSellerRatingModel.fromJson(dynamic json) {
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

/// id : "6"
/// user_id : "154"
/// seller_id : "154"
/// rating : "2"
/// comment : "new"
/// insert_date : "2022-03-02 11:57:40"
/// user_name : "Rohti"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      String? id, 
      String? userId, 
      String? sellerId, 
      String? rating, 
      String? comment, 
      String? insertDate, 
      String? userName,}){
    _id = id;
    _userId = userId;
    _sellerId = sellerId;
    _rating = rating;
    _comment = comment;
    _insertDate = insertDate;
    _userName = userName;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _sellerId = json['seller_id'];
    _rating = json['rating'];
    _comment = json['comment'];
    _insertDate = json['insert_date'];
    _userName = json['user_name'];
  }
  String? _id;
  String? _userId;
  String? _sellerId;
  String? _rating;
  String? _comment;
  String? _insertDate;
  String? _userName;

  String? get id => _id;
  String? get userId => _userId;
  String? get sellerId => _sellerId;
  String? get rating => _rating;
  String? get comment => _comment;
  String? get insertDate => _insertDate;
  String? get userName => _userName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['seller_id'] = _sellerId;
    map['rating'] = _rating;
    map['comment'] = _comment;
    map['insert_date'] = _insertDate;
    map['user_name'] = _userName;
    return map;
  }

}