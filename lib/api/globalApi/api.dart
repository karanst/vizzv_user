import 'dart:convert';

import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/ClearCartModel.dart';
import 'package:eshop_multivendor/Model/FreeFoodHistoryModel.dart';
import 'package:eshop_multivendor/Model/FreeFoodModel.dart';
import 'package:eshop_multivendor/Model/FreeFoodOrderModel.dart';
import 'package:eshop_multivendor/Model/FreeSellerModel.dart';
import 'package:eshop_multivendor/Model/SingleSellerModel.dart';
import 'package:http/http.dart' as http;

// Future<SingleSellerModel?> openClose(sellerId) async {
//   var header = headers;
//   var request = http.MultipartRequest('POST', singleSeller);
//   request.fields.addAll({'seller_id': '$sellerId'});
//
//   request.headers.addAll(header);
//
//   http.StreamedResponse response = await request.send();
//
//   if (response.statusCode == 200) {
//     final str = await response.stream.bytesToString();
//     return SingleSellerModel.fromJson(json.decode(str));
//   } else {
//     return null;
//   }
// }

Future<FreeSellerModel?> freeSeller() async {
  var header = headers;
  var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '$getFreeFoodDeliverySeller'));

  request.headers.addAll(header);

  http.StreamedResponse response = await request.send();
  print(request);
  if (response.statusCode == 200) {
    final str = await response.stream.bytesToString();
    print(str);
    return FreeSellerModel.fromJson(json.decode(str));
  } else {
    return null;
  }
}

Future<FreeFoodModel?> freeFoodList(sellerId) async {
  var header = headers;
  var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '$getFreeFoodDeliveryProducts'));
  request.fields.addAll({'seller_id': '$sellerId'});

  request.headers.addAll(header);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final str = await response.stream.bytesToString();
    print(str);
    return FreeFoodModel.fromJson(json.decode(str));
  } else {
    return null;
  }
}

Future<ClearCartModel?> clearCartApi(userId) async {
  var header = headers;
  var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '$clear_cart_by_user'));
  request.fields.addAll({'user_id': "$userId"});
  print(request);
  print(request.fields);

  request.headers.addAll(header);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final str = await response.stream.bytesToString();
    print(str);
    return ClearCartModel.fromJson(json.decode(str));
  } else {
    return null;
  }
}

Future<FreeFoodOrderModel?> orderFreeFood(
    userId, name, productId, picType, address, image) async {
  var header = headers;
  var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '$ngo_donate_food'));
  request.fields.addAll({
    'product_id': '$productId',
    'donate_person_name': '$name',
    'user_id': '$userId',
    'pickup_type': '$picType',
    'address': '$address'
  });
  request.files.add(await http.MultipartFile.fromPath('image', '$image'));
  request.headers.addAll(header);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final str = await response.stream.bytesToString();
    return FreeFoodOrderModel.fromJson(json.decode(str));
  } else {
    return null;
  }
}

Future<FreeFoodHistoryModel?> freeFoodHistory(userId) async {
  var header = headers;
  var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '$ngo_donate_food_get'));
  request.fields.addAll({'user_id': '$userId'});

  request.headers.addAll(header);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final str = await response.stream.bytesToString();
    return FreeFoodHistoryModel.fromJson(json.decode(str));
  } else {
    return null;
  }
}
