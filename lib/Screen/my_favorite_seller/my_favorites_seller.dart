import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/FavouriteSellerModels.dart';
import 'package:eshop_multivendor/Model/MyFavoritesSellerResponse.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/Seller_Details.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MyFavoritesSeller extends StatefulWidget {
  const MyFavoritesSeller({Key? key}) : super(key: key);

  @override
  State<MyFavoritesSeller> createState() => _MyFavoritesSellerState();
}

class _MyFavoritesSellerState extends State<MyFavoritesSeller> {
  StreamController<MyFavoritesSellerResponse> responseStream =
      StreamController();
  // List<Product> sellerList = [];
  var sellerData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    responseStream.close();
  }

  String convertNA(value) {
    return value ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        appBar: getAppBar("Favorites Seller", context),
        body: FutureBuilder<FavouriteSellerModels?>(
            future: favouriteSeller(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data.data);
                FavouriteSellerModels sellerList = snapshot.data;
                return sellerList.error == false
                    ? ListView.builder(
                  itemCount: snapshot.data!.data!.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 1),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SellerProfile(
                                    search: true,
                                        sellerData: sellerList.data![index],
                                        sellerID: sellerList.data![index].sellerId,
                                        sellerStoreName: sellerList.data![index].storeName,
                                        storeDesc:sellerList.data![index].storeDescription,
                                        sellerImage: "$imageUrl${sellerList.data![index].logo}",
                                        shop: false,
                                        userLocation: currentAddress.text,
                                        // sellerData: sellerList.data![index],
                                        // sellerStoreName: sellerList.data![index].storeName??
                                        //     "",
                                        // // sellerRating: sellerList.data![index]
                                        // //         . ??
                                        // //     "",
                                        // sellerImage: sellerList.data![index]
                                        //         .logo ??
                                        //     "",
                                        // sellerName: sellerList.data![index]
                                        //         .username ??
                                        //     "",
                                        // sellerID:
                                        //     sellerList.data![index].sellerId,
                                        // storeDesc: sellerList.data![index]
                                        //     .storeDescription,
                                      )));
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => SubCategory(
                          //               title: sellerList[index]
                          //                   .store_name
                          //                   .toString(),
                          //               sellerId: sellerList[index]
                          //                   .seller_id
                          //                   .toString(),
                          //               sellerData: sellerList[index],
                          //             )));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        // opacity: .05,
                                        image: NetworkImage(snapshot
                                            .data!.data![index].logo!))),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 80,
                                      padding: EdgeInsets.only(left: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: FadeInImage(
                                          fadeInDuration:
                                              Duration(milliseconds: 150),
                                          image: CachedNetworkImageProvider(
                                            snapshot.data!.data![index].logo!,
                                          ),
                                          fit: BoxFit.cover,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  erroWidget(50),
                                          placeholder: placeHolder(50),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          ListTile(
                                            dense: true,
                                            title: Text(convertNA(snapshot.data!
                                                .data![index].storeName!)),
                                            subtitle: Text(
                                              convertNA(snapshot
                                                  .data!
                                                  .data![index]
                                                  .storeDescription!),
                                              maxLines: 2,
                                            ),
                                            trailing: Text(
                                              snapshot.data!.data![index]
                                                          .openCloseStatus! ==
                                                      "1"
                                                  ? "Open"
                                                  : "Closed",
                                              style: TextStyle(
                                                  color: snapshot
                                                              .data!
                                                              .data![index]
                                                              .openCloseStatus! ==
                                                          "1"
                                                      ? Colors.green
                                                      : Colors.red),
                                            ),
                                          ),
                                          Divider(
                                            height: 0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [

                                                snapshot.data!.data![index]
                                                            .estimatedTime! !=
                                                        ""
                                                    ? FittedBox(
                                                        child: Container(
                                                            child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical:
                                                                        2),
                                                            child: Text(
                                                              convertNA(snapshot
                                                                  .data!
                                                                  .data![index]
                                                                  .estimatedTime!),
                                                              style: TextStyle(
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        )),
                                                      )
                                                    : Container(),
                                                snapshot.data!.data![index]
                                                            .foodPerson! !=
                                                        ""
                                                    ? FittedBox(
                                                        child: Container(
                                                            child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 1),
                                                          child: Text(
                                                            convertNA(snapshot
                                                                .data!
                                                                .data![index]
                                                                .foodPerson!),
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        )),
                                                      )
                                                    : Container(),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: FittedBox(
                                                    child: Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () => removeNow(
                                                              sellerID: snapshot
                                                                  .data!
                                                                  .data![index]
                                                                  .sellerId),
                                                          child: Icon(
                                                            Icons.delete,
                                                            // color: Colors.amber,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        // Text(
                                                        //   convertNA(snapshot.data!
                                                        //       .data![index].rating),
                                                        //   style: Theme.of(context)
                                                        //       .textTheme
                                                        //       .caption!
                                                        //       .copyWith(
                                                        //           color: Theme.of(
                                                        //                   context)
                                                        //               .colorScheme
                                                        //               .fontColor,
                                                        //           fontWeight:
                                                        //               FontWeight.w600,
                                                        //           fontSize: 10),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : Center(child: Container(child: Text("No Favourite Seller"),));
              } else if (snapshot.hasError) {
                return Icon(Icons.error_outline);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  late MyFavoritesSellerResponse myFavoritesSellerres;

  Future<FavouriteSellerModels?> favouriteSeller() async {
    var userid = Provider.of<SettingProvider>(context, listen: false);
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('$getFavouriteSeller'));
    request.fields.addAll({'user_id': '${userid.userId}'});

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      print(str);
      return FavouriteSellerModels.fromJson(json.decode(str));
    } else {
      return null;
    }
  }

  void removeNow({required sellerID}) async {
    String userid = await context.read<SettingProvider>().userId!;
    Map<String, String> toBody = {"user_id": userid, "seller_id": sellerID};
    print(toBody);
    Response response =
        await post(removeFavoritSeller, body: toBody, headers: headers)
            .timeout(Duration(seconds: timeOut));
    var resonseDecode = jsonDecode(response.body);
    print(response.body);

    setSnackbar(resonseDecode["message"], context);
    favouriteSeller();
  }
//  sellerList =
//           (data as List).map((data) => new Product.fromSeller(data)).toList();
}
