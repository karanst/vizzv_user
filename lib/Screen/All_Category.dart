import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/location_details.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/MyOrder.dart';
import 'package:eshop_multivendor/Screen/NotificationLIst.dart';
import 'package:eshop_multivendor/Screen/Search.dart';
import 'package:eshop_multivendor/Screen/SellerList.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:eshop_multivendor/Screen/new_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../Helper/Session.dart';
import '../Model/Section_Model.dart';
import 'Cart.dart';
import 'ProductList.dart';
import 'package:eshop_multivendor/Screen/Map.dart' as newMap;

import 'Seller_Details.dart';
import 'my_favorite_seller/category.dart';

class AllCategory extends StatefulWidget {
  @override
  State<AllCategory> createState() => _AllCategoryState();
}
var latitude;
var longitude;
var foodType = false;
bool cartSeller = false;
bool showLoading = true;
List<Product> sellerLists = [];
List<Product> sellerTopLists = [];
List<Product> sellerList = [];
class _AllCategoryState extends State<AllCategory> with AutomaticKeepAliveClientMixin{
  var changeLat;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  List<Product> popularLists = [];
  List<Product> catLists = [];
  //var currentAddress = TextEditingController();
  var pinController = TextEditingController();

  bool sub = false;
  Future<void> getCurrentLoc() async {
    GetLocation location = new GetLocation((result) async {
      if (mounted) {
        var loc = Provider.of<LocationProvider>(context, listen: false);
        if (currentAddress.text == "") {
          currentAddress.text = result.first.addressLine;
          latitude = result.first.coordinates.latitude;
          longitude = result.first.coordinates.longitude;
          pinController.text = result.first.postalCode;
          loc.lat = latitude;
          loc.lng = longitude;
          getSeller();
          getTopSeller();
        }

        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString(mylatitude, latitude.toString());
        await preferences.setString(mylongitude, longitude.toString());

      }
    });
    location.getLoc();
    if(currentAddress.text!=""){
      //var loc = Provider.of<LocationProvider>(context, listen: false);

      // changeLat = loc.lat;
      print("lat :" + changeLat.toString());
      getSeller();
      getTopSeller();
    }
  }

  @override
  void initState() {


    super.initState();


    getCurrentLoc();
    //getCat();
  }
  bool shouldKeepAlive = true;
  @override
  bool get wantKeepAlive {
    print("changeLat :" + changeLat.toString());
    print("new lat :" + latitude.toString());
    if(changeLat.toString() == latitude.toString()){
      shouldKeepAlive = true;

    }else{
      if(changeLat!=null){
        shouldKeepAlive = false;
      }
      changeLat = latitude.toString();
    }
    return shouldKeepAlive;
  }
  // Future<void> getCat() async {
  //   await Future.delayed(Duration.zero);
  //   Map parameter = {
  //     CAT_FILTER: "false",
  //   };
  //   apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
  //     bool error = getdata["error"];
  //     String? msg = getdata["message"];
  //     if (!error) {
  //       var data = getdata["data"];
  //
  //       catList =
  //           (data as List).map((data) => new Product.fromCat(data)).toList();
  //
  //       if (getdata.containsKey("popular_categories")) {
  //         var data = getdata["popular_categories"];
  //         popularList =
  //             (data as List).map((data) => new Product.fromCat(data)).toList();
  //
  //         if (popularList.length > 0) {
  //           Product pop =
  //               new Product.popular("Popular", imagePath + "popular.svg");
  //           catList.insert(0, pop);
  //           context.read<CategoryProvider>().setSubList(popularList);
  //         }
  //       }
  //     } else {
  //       setSnackbar(msg!, context);
  //     }
  //
  //     context.read<HomeProvider>().setCatLoading(false);
  //   }, onError: (error) {
  //     setSnackbar(error.toString(), context);
  //     context.read<HomeProvider>().setCatLoading(false);
  //   });
  // }
  _deliverLocation() {
    var loc = Provider.of<LocationProvider>(context, listen: false);
    String curpin = context.read<UserProvider>().curPincode;
    String result  = "";
    if(currentAddress.text != null && currentAddress.text.length > 0){
      result = currentAddress.text.substring(0,
          currentAddress.text.indexOf(','));
    }
    return GestureDetector(
      child: Row(
        children: [
          Icon(
            Icons.location_pin,
            size: 30,
            color: colors.primary,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              result == null || result == ""
                  ? SizedBox.shrink()
                  : Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    // Icon(
                    //   Icons.location_pin,
                    //   size: 25,
                    //   color: colors.primary,
                    // ),
                    Text(
                      result,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                width: 170,
                child: Text(
                  currentAddress.text.isEmpty
                      ? getTranslated(context, 'SELOC')!
                      : getTranslated(context, 'DELIVERTO')! +
                      currentAddress.text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlacePicker(
              apiKey: Platform.isAndroid
                  ? "AIzaSyD6Jt-f1wlCIXV146XMOGtxrTNfzVB-2oY"
                  : "AIzaSyD6Jt-f1wlCIXV146XMOGtxrTNfzVB-2oY",
              onPlacePicked: (result) async{
                print(result.formattedAddress);
                currentAddress.text = result.formattedAddress.toString();
                latitude = result.geometry!.location.lat;
                longitude = result.geometry!.location.lng;
                SharedPreferences preferences = await SharedPreferences.getInstance();
                await preferences.setString(mylatitude, latitude.toString());
                await preferences.setString(mylongitude, longitude.toString());
                // pinController.text = result.first.postalCode;
                loc.lat = latitude;
                loc.lng = longitude;

                Navigator.of(context).pop();
                setState(() {
                  sellerLists.clear();
                  showLoading = true;
                });

                getSeller();
                getTopSeller();
              },
              initialPosition: latitude!=null?LatLng(double.parse(latitude.toString()), double.parse(longitude.toString())):LatLng(20.5937,78.9629),
              //useCurrentLocation: true,
              selectInitialPosition: true,
            ),
          ),
        );
        /*     var result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => newMap.Map(
                      latitude: latitude,
                      longitude: longitude,
                      from: getTranslated(context, 'ADDADDRESS'),
                    )));
        if (result != null) {
          currentAddress.text = result.first.addressLine;
          latitude = result.first.coordinates.latitude;
          longitude = result.first.coordinates.longitude;
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.setString(mylatitude, latitude.toString());
          await preferences.setString(mylongitude, longitude.toString());
          pinController.text = result.first.postalCode;
          loc.lat = latitude;
          loc.lng = longitude;
          sellerLists.clear();
          getSeller();
        }*/
      },
    );
  }

  _catList() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
            color: Colors.white,
            width: double.infinity,
            child: Shimmer.fromColors(
                baseColor: Theme
                    .of(context)
                    .colorScheme
                    .simmerBase,
                highlightColor: Theme
                    .of(context)
                    .colorScheme
                    .simmerHigh,
                child: catLoading()))
            : Container(
          color: Colors.white,
          height: 120,
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: ListView.builder(
            itemCount: catList.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // print(catList[index].home_cat.toString());
              return catList[index].home_cat.toString() == "1" ? Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SellerList(
                                      catId: catList[index].id,
                                      catName: catList[index].name,
                                      subId: catList[index].subList,
                                      userLocation: currentAddress.text,
                                      getByLocation: false,
                                    )));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 5.0),
                              child: new ClipRRect(
                                borderRadius: BorderRadius.circular(35.0),
                                child: commonHWImage(
                                    catList[index].image.toString(), 60.0, 60.0,
                                    "", context, "assets/images/placeholder.png"),
                                /* child: new FadeInImage(
                                        fadeInDuration: Duration(milliseconds: 150),
                                        image: CachedNetworkImageProvider(
                                          catList[index].image!,
                                        ),
                                        height: 70.0,
                                        width: 70.0,
                                        fit: BoxFit.cover,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) =>
                                            erroWidget(50),
                                        placeholder: placeHolder(50),
                                      ),*/
                              ),
                            ),
                            Container(
                              child: Text(
                                catList[index].name!,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .fontColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              // width: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ) :
              Row(
                children: [
                  SizedBox(),
                  index == catList.length - 1
                      ? SizedBox(width: 5,)
                      : SizedBox(),
                  index == catList.length - 1 ? InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Category(catList.toList())));
                      },
                      child: Text("View All",
                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight
                            .w700, color: Theme
                            .of(context)
                            .colorScheme
                            .fontColor),)) : SizedBox(),
                ],
              );
              if (index == 0)
                return Container();
              else
                return catList[index].home_cat.toString() == "1" ? Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SellerList(
                                        catId: catList[index].id,
                                        catName: catList[index].name,
                                        subId: catList[index].subList,
                                        getByLocation: false,
                                      )));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  bottom: 5.0),
                              child: new ClipRRect(
                                borderRadius: BorderRadius.circular(35.0),
                                child: new FadeInImage(
                                  fadeInDuration: Duration(milliseconds: 150),
                                  image: CachedNetworkImageProvider(
                                    catList[index].image!,
                                  ),
                                  height: 70.0,
                                  width: 70.0,
                                  fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                      erroWidget(50),
                                  placeholder: placeHolder(50),
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                catList[index].name!,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .fontColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              // width: 50,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ) :
                Row(
                  children: [
                    SizedBox(),
                    index == catList.length - 1
                        ? SizedBox(width: 5,)
                        : SizedBox(),
                    index == catList.length - 1 ? InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>
                                  Category(catList.toList())));
                        },
                        child: Text("View All", style: TextStyle(fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .fontColor),)) : SizedBox(),
                  ],
                );
            },
          ),
        );
      },
      selector: (_, homeProvider) => homeProvider.catLoading,
    );
  }
  TopList() {
    return Container(
      color: Colors.white,
      width: deviceWidth,
      height: 240,
      padding: const EdgeInsets.only(top: 1, left: 10),
      child: ListView.builder(
        itemCount: sellerTopLists.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            height: 240,
            width: 180,
            child: GestureDetector(
              onTap: () {
                if (sellerTopLists[index]
                    .open_close_status ==
                    "1") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SellerProfile(
                            title: sellerTopLists[index].store_name.toString(),
                            sellerID: sellerTopLists[index].seller_id.toString(),
                            sellerId: sellerTopLists[index].seller_id.toString(),
                            sellerData: sellerTopLists[index],
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
              child: Card(
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
                  child: Column(
                    children: [
                      Container(
                        height: 135,
                        width: 150,
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
                                  height: 135,
                                  width: 150,
                                  child: commonImage(
                                      sellerTopLists[index]
                                          .seller_profile
                                          .toString(),
                                      "",
                                      context,
                                      "assets/images/placeholder.png"),
                                ),
                                Positioned.fill(
                                  child: sellerTopLists[index].open_close_status == "0"
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
                      ListTile(
                        dense: true,
                        title: Text(
                          "${sellerTopLists[index].store_name!}",
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
                                Text(" "),
                                Text(
                                  "${sellerTopLists[index].seller_rating!}",
                                  style: Theme.of(context).textTheme.caption!.copyWith(
                                      color:
                                      Theme.of(context).colorScheme.fontColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                Text(" . ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),),
                                Text(
                                  "${sellerTopLists[index].estimated_time} mins",
                                  style: Theme.of(context).textTheme.caption!.copyWith(
                                    color:
                                    Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),


                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  _searchpage() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewSearch()));
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Card(
          elevation: 0,
          color: Color(0xffF3F3F3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            dense: true,
            minLeadingWidth: 10,
            leading: Icon(
              Icons.search_rounded,
            ),
            title: Text(
              "Search For Products and More",
              style: TextStyle(color: Theme
                  .of(context)
                  .colorScheme
                  .fontColor),
            ),

          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var checkOut = Provider.of<UserProvider>(context);
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
                : InkWell(
              onTap: (){
                setState((){
                  cartSeller = true;
                });
                getCartSeller(checkOut.curSellerId);
                if(checkOut.curSellerId != "") {
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
                                  userLocation: currentAddress.text,
                                  // userCurrentLocation: ,
                                  // catId: widget.catId,
                                  shop: false,
                                )));
                  });
                }
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            // automaticallyImplyLeading: false,
            snap: true,
            pinned: true,
            floating: true,
            // leading: SizedBox(),
            leadingWidth: 30,
            backgroundColor: colors.whiteTemp,
            title: SizedBox(
              child: _deliverLocation(),
            ),
            bottom: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: colors.whiteTemp,
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                child: SizedBox(
                  child: _searchpage(),
                ),
              ),
            ),
            actions: [
              // IconButton(
              //     onPressed: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(builder: (context) => NewSearch()));
              //     },
              //     icon: Icon(
              //       Icons.search,
              //       color: colors.primary,
              //     )),
              IconButton(
                icon: SvgPicture.asset(
                  imagePath + "desel_notification.svg",
                  color: colors.primary,
                ),
                onPressed: () {
                  CUR_USERID != null
                      ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationList(
                          userId: CUR_USERID,
                        ),
                      ))
                      : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ));
                },
              ),
              IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  size: 24,
                  color: colors.primary,
                ),
                onPressed: () {
                  CUR_USERID != null
                      ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyOrder(),
                      ))
                      : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ));
                },
              )
            ],
            //<Widget>[]
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10,top: 10),
                  child: Text("What's on your mind?",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600),),
                ),
                _catList(),

                ListTile(
                  /*trailing: Container(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        foodType
                            ? Text(
                          "Non Veg",
                          style: TextStyle(color: Colors.red),
                        )
                            : Text(
                          "Veg",
                          style: TextStyle(color: Colors.green),
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Switch(
                              value: foodType,
                              onChanged: (val) {
                                setState(() {
                                  foodType = val;
                                });
                                foodType
                                    ? showToast("Non Veg")
                                    : showToast("Veg");
                                sellerLists.clear();
                                getSeller();
                              }),
                        ),
                      ],
                    ),
                  ),*/
                  title: Text("Top 10 restaurants",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold)),

                  // trailing: TextButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => SellerList(
                  //                   getByLocation: true,
                  //                 )));
                  //   },
                  //   child: Text(
                  //     getTranslated(context, 'VIEW_ALL')!,
                  //     style: TextStyle(fontWeight: FontWeight.w600),
                  //   ),
                  // ),
                ),
                sellerTopLists.length>0?TopList():SizedBox(),
                ListTile(
                  /*trailing: Container(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        foodType
                            ? Text(
                          "Non Veg",
                          style: TextStyle(color: Colors.red),
                        )
                            : Text(
                          "Veg",
                          style: TextStyle(color: Colors.green),
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Switch(
                              value: foodType,
                              onChanged: (val) {
                                setState(() {
                                  foodType = val;
                                });
                                foodType
                                    ? showToast("Non Veg")
                                    : showToast("Veg");
                                sellerLists.clear();
                                getSeller();
                              }),
                        ),
                      ],
                    ),
                  ),*/
                  title: Text(getTranslated(context, 'RES_BY_SELLER')!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold)),

                  // trailing: TextButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => SellerList(
                  //                   getByLocation: true,
                  //                 )));
                  //   },
                  //   child: Text(
                  //     getTranslated(context, 'VIEW_ALL')!,
                  //     style: TextStyle(fontWeight: FontWeight.w600),
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
         /* SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: EdgeInsets.only(left: 10,top: 10),
                  child: Text("What's on your mind?",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600),),
                ),
                 _catList(),
                Container(
                    child:_seller()
                ),
                // _seller()
              ]
            ),
          ),*/
          !showLoading ? sellerLists.isNotEmpty
              ?  SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
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
                                                    Text(" "),
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
              childCount: sellerLists.length,
            ),
          ):SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              height: MediaQuery.of(context).size.height*0.5,
              child: Center(
                child:Text("$NO_SELLER_FOUND",
                maxLines: 3,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ):SliverToBoxAdapter(
            child:  Container(
              height: MediaQuery.of(context).size.height*0.5,
              child: Center(
                child: LoadingAnimationWidget.threeRotatingDots(
                  color: colors.primary,
                  size: 100,
                ),
              ),
            ),

          ),
        ],
      ),
        // appBar: AppBar(
        //   leading: SizedBox(),
        //   leadingWidth: 0,
        //   backgroundColor: Colors.white,
        //   title: SizedBox(
        //     child: _deliverLocation(),
        //   ),
        //   actions: [
        //     IconButton(
        //         onPressed: () {
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => NewSearch()));
        //         },
        //         icon: Icon(
        //           Icons.search,
        //           color: colors.primary,
        //         )),
        //     IconButton(
        //       icon: SvgPicture.asset(
        //         imagePath + "desel_notification.svg",
        //         color: colors.primary,
        //       ),
        //       onPressed: () {
        //         CUR_USERID != null
        //             ? Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => NotificationList(),
        //             ))
        //             : Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => Login(),
        //             ));
        //       },
        //     ),
        //     IconButton(
        //       padding: EdgeInsets.all(0),
        //       icon: Icon(
        //         Icons.shopping_bag_outlined,
        //         size: 24,
        //         color: colors.primary,
        //       ),
        //       onPressed: () {
        //         CUR_USERID != null
        //             ? Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => MyOrder(),
        //             ))
        //             : Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => Login(),
        //             ));
        //       },
        //     )
        //   ],
        // ),
        // body: _seller()
      // Consumer<HomeProvider>(
      //   builder: (context, homeProvider, _) {
      //     if (homeProvider.catLoading) {
      //       return Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //
      //     return Row(
      //       children: [
      //        /* Expanded(
      //           flex: 1,
      //           child: Container(
      //             color: Theme.of(context).colorScheme.gray,
      //             child: ListView.builder(
      //               shrinkWrap: true,
      //               scrollDirection: Axis.vertical,
      //               padding: EdgeInsetsDirectional.only(top: 10.0),
      //               itemCount: catList.length,
      //               itemBuilder: (context, index) {
      //                 return catItem(index, context);
      //               },
      //             ),
      //           ),
      //         ),*/
      //         Expanded(
      //           flex: 3,
      //           child: catList.length > 0
      //               ? Column(
      //                   children: [
      //                     Selector<CategoryProvider, int>(
      //                       builder: (context, data, child) {
      //                         return Padding(
      //                           padding: const EdgeInsets.all(8.0),
      //                           child: Column(
      //                             crossAxisAlignment: CrossAxisAlignment.start,
      //                             mainAxisSize: MainAxisSize.min,
      //                             children: [
      //                             /*  Row(
      //                                 children: [
      //                                   Text(catList[data].name! + " "),
      //                                   Expanded(
      //                                     child: Divider(
      //                                       thickness: 2,
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),*/
      //                               Padding(
      //                                 padding: const EdgeInsets.symmetric(
      //                                     vertical: 8.0),
      //                                 child: Text(
      //                                   getTranslated(context, 'All')! +
      //                                       " " +
      //                                       catList[data].name! +
      //                                       " ",
      //                                   style: TextStyle(
      //                                     color: Theme.of(context)
      //                                         .colorScheme
      //                                         .fontColor,
      //                                     fontWeight: FontWeight.bold,
      //                                     fontSize: 16,
      //                                   ),
      //                                 ),
      //                               )
      //                             ],
      //                           ),
      //                         );
      //                       },
      //                       selector: (_, cat) => cat.curCat,
      //                     ),
      //                     Expanded(
      //                       child: Selector<CategoryProvider, List<Product>>(
      //                         builder: (context, data, child) {
      //                           return data.length > 0
      //                               ? GridView.count(
      //                                   padding: EdgeInsets.symmetric(
      //                                       horizontal: 20),
      //                                   crossAxisCount: 3,
      //                                   shrinkWrap: true,
      //                                   childAspectRatio: .75,
      //                                   children: List.generate(
      //                                     data.length,
      //                                     (index) {
      //                                       return subCatItem(
      //                                           data, index, context);
      //                                     },
      //                                   ))
      //                               : Center(
      //                                   child: Text(
      //                                       getTranslated(context, 'noItem')!));
      //                         },
      //                         selector: (_, categoryProvider) =>
      //                             categoryProvider.subList,
      //                       ),
      //                     ),
      //                   ],
      //                 )
      //               : Container(),
      //         ),
      //       ],
      //     );
      //   },
      // ),
    );
  }

  Widget catItem(int index, BuildContext context1) {
    return Selector<CategoryProvider, int>(
      builder: (context, data, child) {
        if (index == 0 && (popularLists.length > 0)) {
          return GestureDetector(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index
                      ? Theme.of(context).colorScheme.white
                      : Colors.transparent,
                  border: data == index
                      ? Border(
                    left: BorderSide(width: 5.0, color: colors.primary),
                  )
                      : null
                // borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: SvgPicture.asset(
                        data == index
                            ? imagePath + "popular_sel.svg"
                            : imagePath + "popular.svg",
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Text(
                    catLists[index].name! + "\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context1).textTheme.caption!.copyWith(
                        color: data == index
                            ? colors.primary
                            : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              context1.read<CategoryProvider>().setCurSelected(index);
              context1.read<CategoryProvider>().setSubList(popularLists);
            },
          );
        } else {
          return GestureDetector(
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index
                      ? Theme.of(context).colorScheme.white
                      : Colors.transparent,
                  border: data == index
                      ? Border(
                    left: BorderSide(width: 5.0, color: colors.primary),
                  )
                      : null),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: FadeInImage(
                            image: CachedNetworkImageProvider(
                                catLists[index].image!),
                            fadeInDuration: Duration(milliseconds: 150),
                            fit: BoxFit.fill,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                erroWidget(50),
                            placeholder: placeHolder(50),
                          )),
                    ),
                  ),
                  Text(
                    catLists[index].name! + "\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context1).textTheme.caption!.copyWith(
                        color: data == index
                            ? colors.primary
                            : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              context1.read<CategoryProvider>().setCurSelected(index);
              if (catLists[index].subList == null ||
                  catLists[index].subList!.length == 0) {
                context1.read<CategoryProvider>().setSubList([]);
                Navigator.push(
                    context1,
                    MaterialPageRoute(
                      builder: (context) => ProductList(
                        name: catLists[index].name,
                        id: catLists[index].id,
                        tag: false,
                        fromSeller: false,
                      ),
                    ));
              } else {
                context1
                    .read<CategoryProvider>()
                    .setSubList(catLists[index].subList);
              }
            },
          );
        }
      },
      selector: (_, cat) => cat.curCat,
    );
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    shape: BoxShape.circle,
                  ),
                  width: 50.0,
                  height: 50.0,
                ))
                    .toList()),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  subCatItem(List<Product> subList, int index, BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: FadeInImage(
                  image: CachedNetworkImageProvider(subList[index].image!),
                  fadeInDuration: Duration(milliseconds: 150),
                  fit: BoxFit.fill,
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.height * 0.12,
                  imageErrorBuilder: (context, error, stackTrace) =>
                      erroWidget(50),
                  placeholder: placeHolder(50),
                )),
          ),
          Text(
            subList[index].name! + "\n",
            textAlign: TextAlign.center,
            maxLines: 1,
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
                builder: (context) => SellerList(
                  getByLocation: false,
                  catId: subList[index].id!,
                  userLocation: currentAddress.text,
                )));
        // if (context.read<CategoryProvider>().curCat == 0 &&
        //     popularList.length > 0) {
        //   if (popularList[index].subList == null ||
        //       popularList[index].subList!.length == 0) {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => ProductList(
        //             name: popularList[index].name,
        //             id: popularList[index].id,
        //             tag: false,
        //             fromSeller: false,
        //           ),
        //         ));
        //   } else {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => SubCategory(
        //             title: popularList[index].name ?? "",
        //           ),
        //         ));
        //   }
        // } else if (subList[index].subList == null ||
        //     subList[index].subList!.length == 0) {
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ProductList(
        //           name: subList[index].name,
        //           id: subList[index].id,
        //           tag: false,
        //           fromSeller: false,
        //         ),
        //       ));
        // } else {
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => SubCategory(
        //           title: subList[index].name ?? "",
        //         ),
        //       ));
        // }
      },
    );
  }

  void getSeller() {
    String pin = context.read<UserProvider>().curPincode;
    var loc = Provider.of<LocationProvider>(context, listen: false);

    Map parameter = {
      "lat": "${loc.lat}",
      "lang": "${loc.lng}",
      "shop_type": "2",
      "veg_nonveg": foodType ? "2" : "1",
    };
    print(parameter);
    // if (pin != '') {
    //   parameter = {
    //     "lat":"$latitude",
    //     "lang":"$longitude"
    //   };
    //   print(latitude);
    //   print(longitude);
    // }

    apiBaseHelper.postAPICall(getSellerApi,  parameter ).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        dynamic data = getdata["data"];
        print(data);
        if (data.isEmpty) {
          // showToast("No Seller Available");
        }
        setState(() {
          showLoading = false;
          sellerLists =
              (data as List).map((data) {
                data['km']=calculateDistance(data['latitude'], data['longitude'], latitude, longitude);
                return new Product.fromSeller(data);}).toList();
          List<Product> temp = [];

          // sellerLists.sort((a,b)=> a.km!.compareTo(b.km!));
          // sellerLists.sort((a,b)=> b.open_close_status!.compareTo(a.open_close_status!));
        });
      } else {
        setState(() {
          showLoading = false;
        });
        // setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      // setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }
  void getTopSeller() {
    String pin = context.read<UserProvider>().curPincode;
    var loc = Provider.of<LocationProvider>(context, listen: false);

    Map parameter = {
      "lat": "${loc.lat}",
      "lang": "${loc.lng}",
      "shop_type": "2",
      "veg_nonveg": foodType ? "2" : "1",
    };
    print(parameter);
    // if (pin != '') {
    //   parameter = {
    //     "lat":"$latitude",
    //     "lang":"$longitude"
    //   };
    //   print(latitude);
    //   print(longitude);
    // }

    apiBaseHelper.postAPICall(getTopSellerApi,  parameter ).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        dynamic data = getdata["data"];
        print(data);
        if (data.isEmpty) {
          // showToast("No Seller Available");
        }
        setState(() {
          showLoading = false;
          sellerTopLists =
              (data as List).map((data) {
                data['km']=calculateDistance(data['latitude'], data['longitude'], latitude, longitude);
                return new Product.fromSeller(data);}).toList();
          List<Product> temp = [];

          // sellerLists.sort((a,b)=> a.km!.compareTo(b.km!));
          // sellerLists.sort((a,b)=> b.open_close_status!.compareTo(a.open_close_status!));
        });
      } else {
        setState(() {
          showLoading = false;
        });
        // setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      // setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }
  void getCartSeller(curSellerId) {
    setState((){
      sub = true;
    });
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
          showLoading = false;
          sellerList =
              (data as List).map((data) {
                data['km']=calculateDistance(data['latitude'], data['longitude'], latitude, longitude);
                return new Product.fromSeller(data);}).toList();
        });
      } else {
        setState(() {
          showLoading = false;
        });
        // setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      // setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
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
                child: catLoading()))
            : Column(
          children: [
            ListTile(
              trailing: Container(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    foodType
                        ? Text(
                      "Non Veg",
                      style: TextStyle(color: Colors.red),
                    )
                        : Text(
                      "Veg",
                      style: TextStyle(color: Colors.green),
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Switch(
                          value: foodType,
                          onChanged: (val) {
                            setState(() {
                              foodType = val;
                            });
                            foodType
                                ? showToast("Non Veg")
                                : showToast("Veg");
                            sellerLists.clear();
                            getSeller();

                          }),
                    ),
                  ],
                ),
              ),
              title: Text(getTranslated(context, 'RES_BY_SELLER')!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold)),

              // trailing: TextButton(
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => SellerList(
              //                   getByLocation: true,
              //                 )));
              //   },
              //   child: Text(
              //     getTranslated(context, 'VIEW_ALL')!,
              //     style: TextStyle(fontWeight: FontWeight.w600),
              //   ),
              // ),
            ),
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
                                                        Text(" "),
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
}