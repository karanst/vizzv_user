import 'dart:convert';
import 'dart:math';

import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';

String razorPayKey="rzp_test_UUBtmcArqOLqIY";
String razorPaySecret="NTW3MUbXOtcwUrz5a4YCshqk";
class CashFreeHelper{
  String amount;
  String? orderId;
  BuildContext context;
  ValueChanged onResult;
  Razorpay? _razorpay;
  CashFreeHelper(this.amount, this.context, this.onResult);
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String token ="";
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  init(){

    getOrder();
  }
  void getOrder() async {
    String username = razorPayKey;
    String password = razorPaySecret;
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    double newmoney = double.parse(amount.toString());
    int nw=newmoney.toInt();
    orderId = "ORD" + getRandomString(5);
    print(nw);
    Map data = {
      "orderAmount":amount.toString(),
      "orderCurrency": "INR",
      "orderId": orderId
    }; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!
    Map<String,String> headers = {
      "Content-Type": "application/json",
      "x-client-id": cashfreeId.toString(),
      "x-client-secret": cashfreeKey.toString(),
    };
    print(data);
    print(headers);
    var res = await http.post(Uri.parse('https://api.cashfree.com/api/v2/cftoken/order'),
        headers: headers, body: jsonEncode(data));
    print(res.body);
    if (res.statusCode == 200) {
      Map data2 = json.decode(res.body);
      token = data2['cftoken'];

      openCheckout(amount);
    }
    else
    {

      print(res.body);
      print(res.statusCode);
    }
  }
  void openCheckout(String amt) async {
    String orderId1 = orderId.toString();
    String stage = "PROD";
    String orderAmount =amt;
    String tokenData = token;
  //  String customerName = "Customer Name";
    String orderNote = "Vizzve Payment";
    String orderCurrency = "INR";
    String appId = cashfreeId.toString();
    String notifyUrl = "https://vizzvefoods.com/app/v1/api/update_payment_details";
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(this.context, listen: false);

    String contact = settingsProvider.mobile;
    String email = settingsProvider.email;
    if (email == '')

      setSnackbar(getTranslated(context, 'emailWarning')!, context);
    else if (contact == '')
      setSnackbar(getTranslated(context, 'phoneWarning')!, context);
    String name = settingsProvider.userName;
    context.read<CartProvider>().setProgress(true);
    Map<String, dynamic> inputParams = {
      "orderId": orderId1,
      "color1": "#AFCB1F",
      "color2": "#FFFFFF",
      "orderAmount": orderAmount,
      "customerName": name,
      "orderNote": orderNote,
      "orderCurrency": orderCurrency,
      "appId": appId,
      "customerPhone": contact,
      "customerEmail": email,
      "stage": stage,
      "tokenData": tokenData,
      "notifyUrl": notifyUrl
    };
    print(inputParams);
    CashfreePGSDK.doPayment(inputParams)
        .then((value) {
          value?.forEach((key, value) {
      print("$key : $value");

      //Do something with the result
    });
          onResult(value);
        });
  }

}