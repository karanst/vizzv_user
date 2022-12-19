import 'dart:convert';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/src/provider.dart';

class AddRemveSeller extends StatefulWidget {
  String sellerID;
  AddRemveSeller({Key? key, required this.sellerID}) : super(key: key);

  @override
  State<AddRemveSeller> createState() => _AddRemveSellerState();
}

class _AddRemveSellerState extends State<AddRemveSeller> {
  bool favoriteSeller = false;
  bool lodingfavrate = true;
  @override
  void initState() {
    super.initState();
    chakingFavrit();
  }

  @override
  Widget build(BuildContext context) {
    return lodingfavrate
        ? CircularProgressIndicator(
            color: colors.primary,
          )
        : InkWell(
            onTap: () => addRemovefavorit(0),
            child: Container(
                child: Icon(favoriteSeller
                    ? Icons.favorite_border_sharp
                    : Icons.favorite_sharp)),
          );
  }

  chakingFavrit() async {
    var userID = Provider.of<SettingProvider>(context, listen: false);

    Map<String, String> toBody = {
      "user_id": userID.userId.toString(),
      "seller_id": widget.sellerID
    };
    print(toBody);
    Response response =
        await post(removeFavoritSeller, body: toBody, headers: headers)
            .timeout(Duration(seconds: timeOut));
    print(removeFavoritSeller);
    var resonseDecode = jsonDecode(response.body);
    if (!resonseDecode["error"]) {
      favoriteSeller = false;
      print("data in list");
      // print("========");
      String userid = await context.read<SettingProvider>().userId!;
      Map<String, String> toBody = {
        "user_id": userid,
        "seller_id": widget.sellerID
      };
      print(toBody);
      Response response =
          await post(addFavoritSeller, body: toBody, headers: headers)
              .timeout(Duration(seconds: timeOut));
      var resonseDecode = jsonDecode(response.body);
      print(favoriteSeller);
      print(response.body);
      print(favoriteSeller);
    } else {
      print("====2====");
      print("data Not add list");
      print(favoriteSeller);
      favoriteSeller = true;
    }
    lodingfavrate = false;
    setState(() {});
    print(favoriteSeller);
    print("lostr");
    print(response.body);
  }

  addRemovefavorit(from) async {
    favoriteSeller = !favoriteSeller;
    setState(() {});
    var userid = Provider.of<SettingProvider>(context, listen: false);
    Map<String, String> toBody = {
      "user_id": userid.userId.toString(),
      "seller_id": widget.sellerID
    };
    print(toBody);
    Response response = await post(
            favoriteSeller ? removeFavoritSeller : addFavoritSeller,
            body: toBody,
            headers: headers)
        .timeout(Duration(seconds: timeOut));
    var resonseDecode = jsonDecode(response.body);
    print(favoriteSeller);
    print(response.body);
    if (from == 0) {
      setSnackbar(resonseDecode["message"], context);
    } else {}
  }
}
