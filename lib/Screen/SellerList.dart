import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../Provider/CartProvider.dart';
import 'All_Category.dart';
import 'Cart.dart';
import 'HomePage.dart';
import 'Seller_Details.dart';

class SellerList extends StatefulWidget {
  final catId;
  final subId;
  final catName;
  final getByLocation;
  final userLocation;

  const SellerList(
      {Key? key, this.catId, this.subId, this.catName, this.getByLocation, this.userLocation})
      : super(key: key);

  @override
  _SellerListState createState() => _SellerListState();
}

List<Product> sellerLists = [];
List<Product> sellerList = [];
class _SellerListState extends State<SellerList> {

  bool showLoading = true;
  dynamic subCatData = [];
  String subCatID = "";
  var imageBase = "";
  bool mount = false;
  String sellerID = "";
  int ind = 0 ;
  bool sub = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

      getSeller();
    getSubCategory(sellerID, widget.catId);

  }
  _seller() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
            width: double.infinity,
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.simmerBase,
                highlightColor: Theme.of(context).colorScheme.simmerHigh,
                child: Text("")
                //catLoading()
            ))
            : Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    !showLoading ? sellerLists.isNotEmpty
                        ? ListView.builder(
                      itemCount: sellerLists.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        double km = double.parse(sellerLists[index].km!);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: GestureDetector(
                            onTap: () {
                              if (sellerLists[index]
                                  .open_close_status ==
                                  "1") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SellerProfile(
                                          title: sellerLists[index].store_name.toString(),
                                          sellerID: sellerLists[index].seller_id.toString(),
                                          sellerId: sellerLists[index].seller_id.toString(),
                                          sellerData: sellerLists[index],
                                          userLocation: currentAddress.text,
                                          // catId: widget.catId,
                                          shop: false,
                                        )));
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             SubCategory(
                                //               title:
                                //               sellerLists[index]
                                //                   .store_name
                                //                   .toString(),
                                //               sellerId:
                                //               sellerLists[index]
                                //                   .seller_id
                                //                   .toString(),
                                //               sellerData:
                                //               sellerLists[
                                //               index],
                                //               shop: false,
                                //               userCurrentLocation: currentAddress.text,
                                //             )));
                              } else {
                                showToast("Shop Closed");
                              }
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => SellerProfile(
                              //               sellerStoreName: sellerList[index]
                              //                       .store_name ??
                              //                   "",
                              //               sellerRating: sellerList[index]
                              //                       .seller_rating ??
                              //                   "",
                              //               sellerImage: sellerList[index]
                              //                       .seller_profile ??
                              //                   "",
                              //               sellerName: sellerList[index]
                              //                       .seller_name ??
                              //                   "",
                              //               sellerID:
                              //                   sellerList[index].seller_id,
                              //               storeDesc: sellerList[index]
                              //                   .store_description,
                              //             )));
                            },
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          10)),
                                  child: Container(
                                    // decoration: BoxDecoration(
                                    //     borderRadius:
                                    //         BorderRadius.circular(10),
                                    //     image: DecorationImage(
                                    //         fit: BoxFit.cover,
                                    //         // opacity: .05,
                                    //         image: NetworkImage(
                                    //             sellerList[index]
                                    //                 .seller_profile!))),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 135,
                                          padding: EdgeInsets.only(
                                              left: 10),
                                          child: Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(10),
                                              child: Stack(
                                                children: [
                                                  SizedBox(
                                                    height: 120,
                                                    width: 135,
                                                    child: commonImage(
                                                        sellerLists[index]
                                                            .seller_profile
                                                            .toString(),
                                                        "",
                                                        context,
                                                        "assets/images/placeholder.png"),
                                                  ),

                                                  Positioned.fill(
                                                    child: sellerLists[index].open_close_status == "0"
                                                        ? Container(
                                                      height: 55,
                                                      color: Colors.white70,
                                                      // width: double.maxFinite,
                                                      padding: EdgeInsets.all(2),
                                                      child: Center(
                                                        child: Text("Closed",
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .caption!
                                                              .copyWith(
                                                              color: Colors.red,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              fontSize: 18
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    )
                                                        : Container(),
                                                  )
                                                ],

                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              ListTile(
                                                dense: true,
                                                title: Text(
                                                  "${sellerLists[index].store_name!}",
                                                  style: TextStyle(fontSize: 16
                                                      ,fontWeight: FontWeight.w600),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.stars_rounded,color: Colors.green,size: 18,),
                                                        Text(""),
                                                        Text(
                                                          "${sellerLists[index].seller_rating!}",
                                                          style: Theme.of(context).textTheme.caption!.copyWith(
                                                              color:
                                                              Theme.of(context).colorScheme.fontColor,
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 14),
                                                        ),
                                                        Text(" . ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),),
                                                        Text(
                                                          "${sellerLists[index].estimated_time} mins",
                                                          style: Theme.of(context).textTheme.caption!.copyWith(
                                                            color:
                                                            Theme.of(context).colorScheme.fontColor,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 14,
                                                          ),
                                                        ),


                                                      ],
                                                    ),
                                                    sellerLists[index].store_description == null || sellerLists[index].store_description == "" ? SizedBox.shrink() :  Text(
                                                      "${sellerLists[index].store_description!}",
                                                      maxLines: 1,
                                                      style: TextStyle(fontSize: 12
                                                          ,fontWeight: FontWeight.w400),

                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width:MediaQuery.of(context).size.width/2.3,
                                                          child: Text(
                                                            "${sellerLists[index].address!}",
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(fontSize: 12
                                                                ,fontWeight: FontWeight.w400),
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                    Text(
                                                      "${km.toStringAsFixed(2)} km",
                                                      style: TextStyle(fontSize: 12
                                                          ,fontWeight: FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                                // subtitle: Text(
                                                //   "${sellerLists[index].store_description!}",
                                                //   maxLines: 2,
                                                //   style: TextStyle(fontSize: 16
                                                //       ,fontWeight: FontWeight.w600),
                                                // ),
                                                // trailing: Text(
                                                //   sellerLists[index]
                                                //       .open_close_status ==
                                                //       "1"
                                                //       ? ""
                                                //       : "Closed",
                                                //   style: TextStyle(
                                                //       color: sellerLists[index]
                                                //           .open_close_status ==
                                                //           "1"
                                                //           ? Colors
                                                //           .green
                                                //           : Colors
                                                //           .red),
                                                // ),
                                              ),
                                              // Padding(
                                              //   padding: const EdgeInsets.symmetric(horizontal:16.0),
                                              //   child: Text(
                                              //     "${sellerLists[index].km!.toStringAsFixed(2)} km",
                                              //     style: Theme.of(context).textTheme.caption!.copyWith(
                                              //         color: Theme.of(context)
                                              //             .colorScheme
                                              //             .fontColor,
                                              //         fontWeight:
                                              //         FontWeight
                                              //             .w500,
                                              //         fontSize:
                                              //         10),
                                              //   ),
                                              // ),

                                              // Padding(
                                              //   padding:
                                              //   const EdgeInsets
                                              //       .all(8.0),
                                              //   child: Row(
                                              //     mainAxisAlignment:
                                              //     MainAxisAlignment
                                              //         .spaceEvenly,
                                              //     children: [
                                              //       FittedBox(
                                              //         child: Row(
                                              //           children: [
                                              //             Icon(
                                              //               Icons
                                              //                   .star_rounded,
                                              //               color: Colors
                                              //                   .amber,
                                              //               size:
                                              //               15,
                                              //             ),
                                              //             Text(
                                              //               "${sellerLists[index].seller_rating!}",
                                              //               style: Theme.of(context).textTheme.caption!.copyWith(
                                              //                   color:
                                              //                   Theme.of(context).colorScheme.fontColor,
                                              //                   fontWeight: FontWeight.w600,
                                              //                   fontSize: 14),
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       ),
                                              //       sellerLists[index]
                                              //           .estimated_time !=
                                              //           ""
                                              //           ? FittedBox(
                                              //         child: Container(
                                              //             child: Center(
                                              //               child:
                                              //               Padding(
                                              //                 padding:
                                              //                 const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              //                 child:
                                              //                 Text(
                                              //                   "${sellerLists[index].estimated_time}",
                                              //                   style: TextStyle(fontSize: 14),
                                              //                 ),
                                              //               ),
                                              //             )),
                                              //       )
                                              //           : Container(),
                                              //       sellerLists[index]
                                              //           .food_person !=
                                              //           ""
                                              //           ? FittedBox(
                                              //         child: Container(
                                              //             child: Padding(
                                              //               padding: const EdgeInsets.symmetric(
                                              //                   horizontal: 1,
                                              //                   vertical: 1),
                                              //               child:
                                              //               Text(
                                              //                 "${sellerLists[index].food_person}",
                                              //                 style:
                                              //                 TextStyle(fontSize: 14),
                                              //               ),
                                              //             )),
                                              //       )
                                              //           : Container(),
                                              //       Row(
                                              //         children: [
                                              //           sellerLists[index].veg_nonveg ==
                                              //               "3" ||
                                              //               sellerLists[index].veg_nonveg ==
                                              //                   "1"
                                              //               ? Image
                                              //               .asset(
                                              //             "assets/images/veg.png",
                                              //             height:
                                              //             20,
                                              //             width:
                                              //             20,
                                              //           )
                                              //               : SizedBox(),
                                              //           SizedBox(
                                              //             width: 5,
                                              //           ),
                                              //           sellerLists[index].veg_nonveg ==
                                              //               "3" ||
                                              //               sellerLists[index].veg_nonveg ==
                                              //                   "2"
                                              //               ? Image
                                              //               .asset(
                                              //             "assets/images/veg.png",
                                              //             height:
                                              //             20,
                                              //             width:
                                              //             20,
                                              //             color:
                                              //             Colors.red,
                                              //           )
                                              //               : SizedBox(),
                                              //         ],
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),
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
                        : Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      height: MediaQuery.of(context).size.height*0.5,
                      child: Center(
                        child:Text("$NO_SELLER_FOUND",
                          maxLines: 3,
                          textAlign: TextAlign.center,),
                      ),
                    )
                        : Container(
                      height: MediaQuery.of(context).size.height*0.5,
                      child: Center(
                        child: LoadingAnimationWidget.threeRotatingDots(
                          color: colors.primary,
                          size: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      selector: (_, homeProvider) => homeProvider.sellerLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    var checkOut = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getAppBar(getTranslated(context, 'SHOP_BY_SELLER')!, context),
        bottomSheet: checkOut.curCartCount != "" &&
            checkOut.curCartCount != null &&
            int.parse(checkOut.curCartCount) > 0
            ? Container(
              margin: const EdgeInsets.only(left: 15.0, right: 15,  bottom: 8),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  //colors.primary,
                  borderRadius: BorderRadius.circular(10)
              ),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  sub == true ?
                  CircularProgressIndicator(color: colors.primary,)
                      :
                  InkWell(
                    onTap: (){
                      getCartSeller(checkOut.curSellerId);
                      print(checkOut.storeName);

                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SellerProfile(
                                        title: checkOut.storeName,
                                        sellerID: checkOut.curSellerId,
                                        sellerId: checkOut.curSellerId,
                                        sellerData: sellerList[0],
                                        userLocation: widget.userLocation,
                                        // catId: widget.catId,
                                        shop: false,
                                      )));
                      });
                        // Future.delayed(Duration(seconds: 2), (){
                        //   getSeller(checkOut.curSellerId);
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => SellerProfile(
                        //             // title: checkOut.storeName,
                        //             sellerID: checkOut.curSellerId,
                        //             sellerId: checkOut.curSellerId,
                        //             sellerData: sellerLists[0],
                        //             // userCurrentLocation: widget.userLocation,
                        //             // catId: widget.catId,
                        //             shop: false,
                        //           )));
                        // });

                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(checkOut.sellerProfile),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            width: 150,
                            child: Text("${checkOut.storeName}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(color: colors.primary,
                              fontWeight: FontWeight.w600),),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Cart(fromBottom: false)));
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Text("${checkOut.curCartCount} Items | $CUR_CURRENCY${checkOut.totalAmount}",
                            style: TextStyle(color: Colors.white),),
                          Text(
                            "View Cart",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
            : SizedBox(
          width: 0,
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: _seller(),
        ),
      )



//       Padding(
//         padding: const EdgeInsets.only(top: 15.0),
//         child: ListView.builder(
//           itemCount: sellerLists.length,
//           scrollDirection: Axis.vertical,
//           shrinkWrap: true,
//           physics: ClampingScrollPhysics(),
//           itemBuilder: (context, index) {
//             sellerLists[index] = sellerLists[index];
//             double km = double.parse(sellerLists[index].km!);
//             return Padding(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 10, vertical: 5),
//               child: GestureDetector(
//                 onTap: () {
//
//                   if (sellerLists[index]
//                       .open_close_status ==
//                       "1") {
//                     print("This is subCatID $subCatID");
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => SellerProfile(
//                               title: sellerLists[index].store_name.toString(),
//                               sellerID: sellerLists[index].seller_id.toString(),
//                               sellerId: sellerLists[index].seller_id.toString(),
//                               sellerData: sellerLists[index],
//                               userLocation: widget.userLocation,
//                               catId: widget.catId,
//                               shop: false,
//                             )));
//                     // Navigator.push(
//                     //     context,
//                     //     MaterialPageRoute(
//                     //         builder: (context) =>
//                     //             SellerProfile(
//                     //               title:
//                     //               sellerLists[index]
//                     //                   .store_name
//                     //                   .toString(),
//                     //               sellerId:
//                     //               sellerLists[index]
//                     //                   .seller_id
//                     //                   .toString(),
//                     //               sellerData:
//                     //               sellerLists[
//                     //               index],
//                     //               shop: false,
//                     //               userCurrentLocation: currentAddress.text,
//                     //             )));
//                   } else {
//                     showToast("Shop Closed");
//                   }
// // Navigator.push(
// //     context,
// //     MaterialPageRoute(
// //         builder: (context) => SellerProfile(
// //               sellerStoreName: sellerList[index]
// //                       .store_name ??
// //                   "",
// //               sellerRating: sellerList[index]
// //                       .seller_rating ??
// //                   "",
// //               sellerImage: sellerList[index]
// //                       .seller_profile ??
// //                   "",
// //               sellerName: sellerList[index]
// //                       .seller_name ??
// //                   "",
// //               sellerID:
// //                   sellerList[index].seller_id,
// //               storeDesc: sellerList[index]
// //                   .store_description,
// //             )));
//                 },
//                 child: Column(
//                   mainAxisAlignment:
//                   MainAxisAlignment.spaceAround,
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment:
//                   CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Container(
//                       child: Row(
//                         children: [
//                           Container(
//                             height: 120,
//                             width: 135,
//                             padding: EdgeInsets.only(
//                                 left: 10),
//                             child: Card(
//                               elevation: 2,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10)
//                               ),
//                               child: ClipRRect(
//                                 borderRadius:
//                                 BorderRadius
//                                     .circular(10),
//                                 child: Stack(
//                                   children: [
//                                     SizedBox(
//                                       height: 120,
//                                       width: 135,
//                                       child: commonImage(
//                                           sellerLists[index]
//                                               .seller_profile
//                                               .toString(),
//                                           "",
//                                           context,
//                                           "assets/images/placeholder.png"),
//                                     ),
//                                     Positioned.fill(
//                                       child: sellerLists[index]
//                                           .open_close_status == "0"
//                                           ? Container(
//                                         height: 55,
//                                         color: Colors.white70,
// // width: double.maxFinite,
//                                         padding: EdgeInsets.all(2),
//                                         child: Center(
//                                           child: Text("Closed",
//                                             style: Theme
//                                                 .of(context)
//                                                 .textTheme
//                                                 .caption!
//                                                 .copyWith(
//                                                 color: Colors.red,
//                                                 fontWeight:
//                                                 FontWeight.bold,
//                                                 fontSize: 18
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       )
//                                           : Container(),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment
//                                   .center,
//                               children: [
//                                 ListTile(
//                                   dense: true,
//                                   title: Text(
//                                     "${sellerLists[index].store_name!}",
//                                     style: TextStyle(fontSize: 16
//                                         , fontWeight: FontWeight.w600),
//                                   ),
//                                   subtitle: Column(
//                                     crossAxisAlignment: CrossAxisAlignment
//                                         .start,
//                                     children: [
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment
//                                             .center,
//                                         children: [
//                                           Icon(Icons.stars_rounded,
//                                             color: Colors.green,
//                                             size: 18,),
//                                           Text(" "),
//                                           Text(
//                                             "${sellerLists[index]
//                                                 .seller_rating!}",
//                                             style: Theme
//                                                 .of(context)
//                                                 .textTheme
//                                                 .caption!
//                                                 .copyWith(
//                                                 color:
//                                                 Theme
//                                                     .of(context)
//                                                     .colorScheme
//                                                     .fontColor,
//                                                 fontWeight: FontWeight
//                                                     .w600,
//                                                 fontSize: 14),
//                                           ),
//                                           Text(" . ", style: TextStyle(
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.black),),
//                                           Text(
//                                             "${sellerLists[index]
//                                                 .estimated_time} mins",
//                                             style: Theme
//                                                 .of(context)
//                                                 .textTheme
//                                                 .caption!
//                                                 .copyWith(
//                                               color:
//                                               Theme
//                                                   .of(context)
//                                                   .colorScheme
//                                                   .fontColor,
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 14,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       sellerLists[index]
//                                           .store_description == null ||
//                                           sellerLists[index]
//                                               .store_description == ""
//                                           ? SizedBox.shrink()
//                                           : Text(
//                                         "${sellerLists[index]
//                                             .store_description!}",
//                                         maxLines: 1,
//                                         style: TextStyle(fontSize: 12
//                                             ,
//                                             fontWeight: FontWeight.w400),
//
//                                       ),
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment
//                                             .start,
//                                         children: [
//                                           Container(
//                                             width: MediaQuery
//                                                 .of(context)
//                                                 .size
//                                                 .width / 2.3,
//                                             child: Text(
//                                               "${sellerLists[index]
//                                                   .address!}",
//                                               maxLines: 1,
//                                               overflow: TextOverflow
//                                                   .ellipsis,
//                                               style: TextStyle(
//                                                   fontSize: 12
//                                                   ,
//                                                   fontWeight: FontWeight
//                                                       .w400),
//                                             ),
//                                           ),
//
//                                         ],
//                                       ),
//                                       Text(
//                                         "${km.toStringAsFixed(2)
//                                             .toString()} km",
//                                         style: TextStyle(fontSize: 12
//                                             ,
//                                             fontWeight: FontWeight.w400),
//                                       ),
//                                     ],
//                                   ),
// // subtitle: Text(
// //   "${sellerLists[index].store_description!}",
// //   maxLines: 2,
// //   style: TextStyle(fontSize: 16
// //       ,fontWeight: FontWeight.w600),
// // ),
// // trailing: Text(
// //   sellerLists[index]
// //       .open_close_status ==
// //       "1"
// //       ? "Open"
// //       : "Closed",
// //   style: TextStyle(
// //       color: sellerLists[index]
// //           .open_close_status ==
// //           "1"
// //           ? Colors
// //           .green
// //           : Colors
// //           .red),
// // ),
//                                 ),
// // Padding(
// //   padding: const EdgeInsets.symmetric(horizontal:16.0),
// //   child: Text(
// //     "${sellerLists[index].km!.toStringAsFixed(2)} km",
// //     style: Theme.of(context).textTheme.caption!.copyWith(
// //         color: Theme.of(context)
// //             .colorScheme
// //             .fontColor,
// //         fontWeight:
// //         FontWeight
// //             .w500,
// //         fontSize:
// //         10),
// //   ),
// // ),
//
// // Padding(
// //   padding:
// //   const EdgeInsets
// //       .all(8.0),
// //   child: Row(
// //     mainAxisAlignment:
// //     MainAxisAlignment
// //         .spaceEvenly,
// //     children: [
// //       FittedBox(
// //         child: Row(
// //           children: [
// //             Icon(
// //               Icons
// //                   .star_rounded,
// //               color: Colors
// //                   .amber,
// //               size:
// //               15,
// //             ),
// //             Text(
// //               "${sellerLists[index].seller_rating!}",
// //               style: Theme.of(context).textTheme.caption!.copyWith(
// //                   color:
// //                   Theme.of(context).colorScheme.fontColor,
// //                   fontWeight: FontWeight.w600,
// //                   fontSize: 14),
// //             ),
// //           ],
// //         ),
// //       ),
// //       sellerLists[index]
// //           .estimated_time !=
// //           ""
// //           ? FittedBox(
// //         child: Container(
// //             child: Center(
// //               child:
// //               Padding(
// //                 padding:
// //                 const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
// //                 child:
// //                 Text(
// //                   "${sellerLists[index].estimated_time}",
// //                   style: TextStyle(fontSize: 14),
// //                 ),
// //               ),
// //             )),
// //       )
// //           : Container(),
// //       sellerLists[index]
// //           .food_person !=
// //           ""
// //           ? FittedBox(
// //         child: Container(
// //             child: Padding(
// //               padding: const EdgeInsets.symmetric(
// //                   horizontal: 1,
// //                   vertical: 1),
// //               child:
// //               Text(
// //                 "${sellerLists[index].food_person}",
// //                 style:
// //                 TextStyle(fontSize: 14),
// //               ),
// //             )),
// //       )
// //           : Container(),
// //       Row(
// //         children: [
// //           sellerLists[index].veg_nonveg ==
// //               "3" ||
// //               sellerLists[index].veg_nonveg ==
// //                   "1"
// //               ? Image
// //               .asset(
// //             "assets/images/veg.png",
// //             height:
// //             20,
// //             width:
// //             20,
// //           )
// //               : SizedBox(),
// //           SizedBox(
// //             width: 5,
// //           ),
// //           sellerLists[index].veg_nonveg ==
// //               "3" ||
// //               sellerLists[index].veg_nonveg ==
// //                   "2"
// //               ? Image
// //               .asset(
// //             "assets/images/veg.png",
// //             height:
// //             20,
// //             width:
// //             20,
// //             color:
// //             Colors.red,
// //           )
// //               : SizedBox(),
// //         ],
// //       ),
// //     ],
// //   ),
// // ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
// // return Padding(
// //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
// //   child: GestureDetector(
// //     onTap: () async {
// //       if (sellerLists[index].open_close_status == "1") {
// //
// //           Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                   builder: (context) => SellerProfile(
// //                    // search: false,
// //                     title: sellerLists[index].store_name.toString(),
// //                     sellerID: sellerLists[index].seller_id.toString(),
// //                     sellerId: sellerLists[index].seller_id.toString(),
// //                     sellerData: sellerLists[index],
// //                     userCurrentLocation: widget.userLocation,
// //                     catId: widget.catId,
// //                     //title: sellerLists[index].store_name.toString(),
// //                    // sellerID: sellerLists[index].seller_id.toString(),
// //                     //subCatId: subCatData[index]['id'],
// //                     // sellerLists[index].subList![index].id,
// //                    // catId: widget.catId,
// //                    // sellerData: sellerLists[index],
// //                     shop: false,
// //                    // userLocation: widget.userLocation,
// //                   )));
// //         // Navigator.push(
// //         //     context,
// //         //     MaterialPageRoute(
// //         //         builder: (context) => SubCategory(
// //         //               title: sellerLists[index].store_name.toString(),
// //         //               sellerId: sellerLists[index].seller_id.toString(),
// //         //               sellerData: sellerLists[index],
// //         //               userCurrentLocation: widget.userLocation,
// //         //               catId: widget.catId,
// //         //           shop: false,
// //         //             )));
// //       } else {
// //         showToast("Shop Closed");
// //       }
// //     },
// //     child: Column(
// //       mainAxisAlignment: MainAxisAlignment.spaceAround,
// //       mainAxisSize: MainAxisSize.min,
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: <Widget>[
// //         Card(
// //           elevation: 2,
// //           shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10)),
// //           child: Container(
// //             child: Row(
// //               children: [
// //                 SizedBox(
// //                   width: 5,
// //                 ),
// //                 Container(
// //                   height: 75,
// //                   width: 80,
// //                   child: ClipRRect(
// //                     borderRadius: BorderRadius.circular(10),
// //                     child: FadeInImage(
// //                       fadeInDuration: Duration(milliseconds: 150),
// //                       image: CachedNetworkImageProvider(
// //                         sellerLists[index].seller_profile!,
// //                       ),
// //                       fit: BoxFit.cover,
// //                       imageErrorBuilder:
// //                           (context, error, stackTrace) =>
// //                               erroWidget(50),
// //                       placeholder: placeHolder(50),
// //                     ),
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: Column(
// //                     children: [
// //                       ListTile(
// //                         dense: true,
// //                         title:
// //                             Text("${sellerLists[index].store_name!}"),
// //                         subtitle: Text(
// //                           "${sellerLists[index].store_description!}",
// //                           maxLines: 2,
// //                         ),
// //                         trailing: sellerLists[index]
// //                                     .open_close_status ==
// //                                 "1"
// //                             ? Text(
// //                                 "Open",
// //                                 style: TextStyle(color: Colors.green),
// //                               )
// //                             : Text(
// //                                 "Closed",
// //                                 style: TextStyle(color: Colors.red),
// //                               ),
// //                       ),
// //                       Divider(
// //                         height: 0,
// //                       ),
// //                       Padding(
// //                         padding: const EdgeInsets.all(8.0),
// //                         child: Row(
// //                           mainAxisAlignment:
// //                               MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             FittedBox(
// //                               child: Row(
// //                                 children: [
// //                                   Icon(
// //                                     Icons.star_rounded,
// //                                     color: Colors.amber,
// //                                     size: 15,
// //                                   ),
// //                                   Text(
// //                                     "${sellerLists[index].seller_rating!}",
// //                                     style: Theme.of(context)
// //                                         .textTheme
// //                                         .caption!
// //                                         .copyWith(
// //                                             color: Theme.of(context)
// //                                                 .colorScheme
// //                                                 .fontColor,
// //                                             fontWeight:
// //                                                 FontWeight.w600,
// //                                             fontSize: 14),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             sellerLists[index].estimated_time != ""
// //                                 ? FittedBox(
// //                                     child: Container(
// //                                         child: Center(
// //                                       child: Padding(
// //                                         padding: const EdgeInsets
// //                                                 .symmetric(
// //                                             horizontal: 5,
// //                                             vertical: 2),
// //                                         child: Text(
// //                                           "${sellerLists[index].estimated_time}",
// //                                           style:
// //                                               TextStyle(fontSize: 14),
// //                                         ),
// //                                       ),
// //                                     )),
// //                                   )
// //                                 : Container(),
// //                             sellerLists[index].food_person != ""
// //                                 ? FittedBox(
// //                                     child: Container(
// //                                         child: Padding(
// //                                       padding:
// //                                           const EdgeInsets.symmetric(
// //                                               horizontal: 5,
// //                                               vertical: 1),
// //                                       child: Text(
// //                                         "${sellerLists[index].food_person}",
// //                                         style:
// //                                             TextStyle(fontSize: 14),
// //                                       ),
// //                                     )),
// //                                   )
// //                                 : Container(),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   ),
// // );
//           },
//         ),
//       )

    );
  }

  Future<void> getSeller() async{

    String pin = context.read<UserProvider>().curPincode;
    var loc = Provider.of<LocationProvider>(context, listen: false);
    Map parameter = {};

    if (widget.getByLocation) {
      parameter = {"lat": "${loc.lat}", "lang": "${loc.lng}"};
    }
    else {
      parameter = {
        "lat": "${loc.lat}",
        "lang": "${loc.lng}",
        "cat_id": "${widget.catId}"
      };
    }

    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      print(parameter);
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        sellerLists =
            (data as List).map((data) => new Product.fromSeller(data)).toList();

        setState(() {
          showLoading = false;
          sellerID = data[0]['seller_id'];
              //sellerLists[0].seller_id ;
        });
        print("S---- $sellerID");
      } else {
        setSnackbar(msg!);
      }

      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString());
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }
  void getCartSeller(curSellerId) {
    setState((){
      sub = true;
    });

    // context.read<UserProvider>().setProgress(true);
    String pin = context.read<UserProvider>().curPincode;
    var loc = Provider.of<LocationProvider>(context, listen: false);
    Map param = {
      "seller_id" : curSellerId
    };
    // setState(() {
    //   //showLoading = true;
    // });
    // Map parameter = {
    //   "lat": "${loc.lat}",
    //   "lang": "${loc.lng}",
    //   "shop_type": "1",
    //   // "veg_nonveg": foodType ? "2" : "1",
    // };
    // print(parameter);
    // if (pin != '') {
    //   parameter = {
    //     "lat":"$latitude",
    //     "lang":"$longitude"
    //   };
    //   print(latitude);
    //   print(longitude);
    // }

    apiBaseHelper.postAPICall(getSellerApi, param).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        dynamic data = getdata["data"];
        print(data);
        setState(() {
          sub = false;
          sellerList =
              (data as List).map((data) {
                //data['km']=calculateDistance(data['latitude'], data['longitude'], latitude, longitude);
                return new Product.fromSeller(data);}).toList();
        });

      } else {

        // setSnackbar(msg!, context);
      }
    }, onError: (error) {
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

  Widget catItem(int index, BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: FadeInImage(
                    image: CachedNetworkImageProvider(
                        sellerLists[index].seller_profile!),
                    fadeInDuration: Duration(milliseconds: 150),
                    fit: BoxFit.fill,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        erroWidget(50),
                    placeholder: placeHolder(50),
                  )),
            ),
          ),
          Text(
            sellerLists[index].seller_name! + "\n",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
          )
        ],
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SellerProfile(
                      sellerStoreName: sellerLists[index].store_name ?? "",
                      sellerRating: sellerLists[index].seller_rating ?? "",
                      sellerImage: sellerLists[index].seller_profile ?? "",
                      sellerName: sellerLists[index].seller_name ?? "",
                      sellerID: sellerLists[index].seller_id,
                      storeDesc: sellerLists[index].store_description,
                  userLocation: widget.userLocation,
                  shop: false,
                    )));
      },
    );
  }
  getSubCategory(sellerId, catId) async {
    var parm = {};
    if (catId != null) {
      parm = {"seller_id": "$sellerId", "cat_id": "$catId"};
    } else {
      parm = {"seller_id": "$sellerId"};
    }

    print("SUB CAT PARAM ---->" + parm.toString());
    print(getSubCatBySellerId);
    apiBaseHelper.postAPICall(getSubCatBySellerId, parm).then((value) {
      setState(() {
        subCatData = value["recommend_products"];
        subCatID = value["recommend_products"][0]["id"];
        imageBase = value["image_path"];
        mount = true;
      });
      print("SUB CAT DATA === $subCatData");
    });
  }
}
