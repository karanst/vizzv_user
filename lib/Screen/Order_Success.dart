import 'dart:async';
import 'dart:convert';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Model/Order_Model.dart';
import 'package:eshop_multivendor/Screen/OrderDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';

import '../Helper/String.dart';

class OrderSuccess extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateSuccess();
  }
}

class StateSuccess extends State<OrderSuccess> {
  List<OrderModel> orderList = [];
  bool _isNetworkAvail = true;
  Future<Null> getOrder() async {
   await Future.delayed(Duration(seconds: 3));
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (CUR_USERID != null) {
          var parameter = {
            USER_ID: CUR_USERID,
            OFFSET: "0",
            LIMIT: perPage.toString(),
            SEARCH: "",
          };
          print(getOrderApi);
          print(parameter);
          Response response =
          await post(getOrderApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          print(getdata);
          bool error = getdata["error"];

          if (!error) {
            // setState((){
            //   bottomcart = false;
            // });
            // total = int.parse(getdata["total"]);

            //  if ((offset) < total) {
            var data = getdata["data"];
            if (data.length != 0) {
              List<OrderModel> items = [];
              List<OrderModel> allitems = [];

              items.addAll((data as List)
                  .map((data) => OrderModel.fromJson(data))
                  .toList());

              allitems.addAll(items);

              for (OrderModel item in items) {
                orderList.where((i) => i.id == item.id).map((obj) {
                  allitems.remove(item);
                  return obj;
                }).toList();
              }
              orderList.addAll(allitems);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderDetail(
                      model: orderList[0],
                      sellerId: orderList[0].itemList![0].seller_id,
                      orderId: orderList[0].itemList![0].varientId,
                    )),
              );
            }
          }
        } else {}
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }

    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrder();
  }
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.symmetric(vertical: 40),
              child: Image.asset(
                imagePath + "place.gif",
             //   color: colors.primary,
              ),
              /*  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.white,
                      borderRadius: BorderRadius.all(Radius.circular(20))),*/
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated(context, 'ORDER_PLACED')!,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Text(
              getTranslated(context, 'ORD_PLC_SUCC')!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.fontColor,),
            ),
           /* Padding(
              padding: const EdgeInsetsDirectional.only(top: 28.0),
              child: CupertinoButton(
                child: Container(
                    width: deviceWidth! * 0.7,
                    height: 45,
                    alignment: FractionalOffset.center,
                    decoration: new BoxDecoration(
                      color: colors.primary,
                      // gradient: LinearGradient(
                      //     begin: Alignment.topLeft,
                      //     end: Alignment.bottomRight,
                      //     colors: [colors.grad1Color, colors.grad2Color],
                      //     stops: [0, 1]),
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(10.0)),
                    ),
                    child: Text(getTranslated(context, 'CONTINUE_SHOPPING')!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Theme.of(context).colorScheme.white,
                            fontWeight: FontWeight.normal))),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home', (Route<dynamic> route) => false);
                },
              ),
            )*/
          ],
        )),
      ),
    );
  }
}
