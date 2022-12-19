import 'dart:async';
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/SubCatProduct.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Cart.dart';
import 'package:eshop_multivendor/Screen/Item_Search.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/my_favorite_seller/add_remove_favrite_seller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../Helper/AppBtn.dart';
import '../Helper/widget.dart';
import '../Model/Section_Model.dart';
import '../Model/response_recomndet_products.dart';
import 'Product_Detail.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class SellerProfile extends StatefulWidget {
  var sellerID,
      sellerName,
      sellerImage,
      sellerRating,
      storeDesc,
      sellerStoreName,
      subCatId;
  var userLocation;
  final sellerData;
  final search;
  final extraData;
  final coverImage;
  bool shop;
  String? title;
  final sellerId;
  final catId;
  final userCurrentLocation;

  SellerProfile(
      {Key? key,
        this.sellerId,
        this.catId,
        this.userCurrentLocation,
        this.sellerID,
        this.sellerName,
        this.sellerImage,
        this.sellerRating,
        this.storeDesc,
        this.sellerStoreName,
        this.subCatId,
        this.sellerData,
        this.userLocation,
        this.search,
        this.extraData,
        this.coverImage,
        required this.shop,
        this.title})
      : super(key: key);

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  late TabController _tabController;
  bool _isNetworkAvail = true;
  StreamController<dynamic> productStream = StreamController();
  var newData;
  var sData;
  List subData = [];
  bool hasData = true;
  List productList = [];
  bool isDescriptionVisible = false;
  bool favoriteSeller = true;
  bool listVisible = true;
  bool recommendedVisible = true;
  StreamController<dynamic> productStreamController = StreamController();

  String sortBy = 'p.id', orderBy = "DESC";
  final List<String> items = ['Veg', 'Non-Veg', 'Egg', 'All'];
  String? selectedValue;
  String vegPro = "0";
  String vegNonVeg = "";

  bool expand = true;
  int? tapped;
  //double overallAmount = 0;
  List subCatData = [];
  var subCatId;
  var recommendedProductsData = [];
  bool mount = false;
  String top = "";
  late ResponseRecomndetProducts responseProducts;
  var imageBase = "";
  List<TextEditingController> _controller = [];
  //ScrollController scrollController = ScrollController();

  bool _isLoading = true, _isProgress = false;
  final GlobalKey expansionTile = new GlobalKey();

  AutoScrollController _autoScrollController = AutoScrollController();

  final ValueNotifier<bool> showFloatingFilter = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    /*   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, // navigation bar color
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light// status bar color
    ));*/
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // getCart();
      getSubCategory(widget.sellerId, widget.catId);
      getRecommended(widget.sellerID);
    });

    _autoScrollController.addListener(() {
      if (_autoScrollController.position.pixels > 250) {
        if (showFloatingFilter.value == true) return;
        showFloatingFilter.value = true;
      } else {
        if (showFloatingFilter.value == false) return;
        showFloatingFilter.value = false;
      }
      return;
    });
  }

  getRecommended(sellerId) async {
    var parm = {
      SORT: sortBy,
      ORDER: orderBy,
      // SUB_CAT_ID: widget.subCatId ?? "",
      // LIMIT: perPage.toString(),
      // OFFSET: offset.toString(),
      "product_type": top,
      //TOP_RETAED: top,
      "seller_id": sellerId,
      "filter": vegNonVeg,
    };
    print(parm);
    var data = await apiBaseHelper.postAPINew(recommendedProductapi, parm);
    newData = data;
    context.read<CartProvider>().setProgress(false);
    if (newData.isNotEmpty) {
      print(
          "new recommended products data ==== ${newData["data"].length.toString()}");
      productStream.sink.add(newData);
    } else {
      productStream.sink.addError("");
    }
  }

  getSubCategory(sellerId, catId) async {
    var parm = {};
    if (catId != null) {
      parm = {
        SORT: sortBy,
        ORDER: orderBy,
        "product_type": top,
        "cat_id": "$catId",
        "seller_id": "$sellerId",
        "filter": vegNonVeg,
      };
      //  {"seller_id": "$sellerId", "cat_id": "$catId"};
    } else {
      parm = {
        SORT: sortBy,
        ORDER: orderBy,
        "product_type": top,
        "seller_id": "$sellerId",
        "filter": vegNonVeg,
      };
      // parm = {"seller_id": "$sellerId"};
    }

    print("SUB CAT PARAM ---->" + parm.toString());
    print(getSubCatBySellerId);
    apiBaseHelper.postAPICall(getSubCatBySellerId, parm).then((value) {
      context.read<CartProvider>().setProgress(false);

      // await Future.delayed(Duration(seconds: 5));
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      subCatData = value["recommend_products"];
      var i;
      for (i = 0; i < subCatData.length; i++) {
        subCatId = subCatData[i]["id"].toString();
        print(subCatId);
      }
      imageBase = value["image_path"];
      mount = true;
      setState(() {});
      // });
    });
  }

  SubCatProduct? h = SubCatProduct();

  Future<void> addToCart(int index, String qty, response) async {
    // eturn;
    context.read<CartProvider>().setProgress(true);
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        // print(response['minimum_order_quantity'].toString());
        if (int.parse(qty) <
            int.parse(response['minimum_order_quantity'].toString())) {
          qty = response['minimum_order_quantity'].toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_VARIENT_ID: response['variants'][0]['id'],
          QTY: qty,
          "seller_id": "${widget.sellerID}"
        };

        print('Calling the API......');
        print(json.encode(parameter));
        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
                (getdata) async {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                context.read<CartProvider>().setProgress(false);
                var data = getdata["data"];

                String? qty = data['total_quantity'];
                // CUR_CART_COUNT = data['cart_count'];

                context.read<UserProvider>().setCartCount(data['total_items']);

                context
                    .read<UserProvider>()
                    .setAmount(getdata['data']['overall_amount']);



                context.read<UserProvider>().setSellerId(
                    widget.sellerData.seller_id);

                context
                    .read<UserProvider>()
                    .setStoreName(widget.sellerData.store_name);
                context
                    .read<UserProvider>()
                    .setSellerProfile(widget.sellerData.seller_profile);

                response['variants'][0]['cart_count'] = qty.toString();

                // productList[index]
                //     .prVarientList![productList[index].selVarient!]
                //     .cartCount = qty.toString();

                var cart = getdata["cart"];
                // overallAmount = double.parse(getdata["data"]["overall_amount"]);
                // print(overallAmount.toStringAsFixed(2));
                List<SectionModel> cartList = (cart as List)
                    .map((cart) => new SectionModel.fromCart(cart))
                    .toList();
                context.read<CartProvider>().setCartlist(cartList);
                setState(() {});
              } else {
                var data = await clearCart(context, msg);
                if (data) {
                  // if (!mounted) return;
                  // setState(() {
                  context.read<UserProvider>().setCartCount(0.toString());
                  //  context.read<CartProvider>().setProgress(false);
                  // });
                  addToCart(index, qty, response);
                } else {
                  if (!mounted) return;
                  setState(() {
                    _isProgress = false;
                    // context.read<CartProvider>().setProgress(false);
                  });
                }
              }
              // if (mounted)
              //   setState(() {
              //
              //    // context.read<CartProvider>().setProgress(true);
              //   });
            }, onError: (error) {
          setSnackbar(error.toString(), context);
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  removeFromCart(int index, response) async {
    print('------------316----------------');
    context.read<CartProvider>().setProgress(true);
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        int qty;

        qty = (int.parse(_controller[index].text) -
            int.parse(response['minimum_order_quantity'].toString()));

        if (qty < int.parse(response['minimum_order_quantity'].toString())) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: response['variants'][0]['id'],
          // productList[index]
          //     .prVarientList![productList[index].selVarient!]
          //     .id,
          USER_ID: CUR_USERID,
          QTY: qty.toString(),
          "seller_id": "${widget.sellerId}"
        };

        print('Calling the API--------------');

        print(parameter);

        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
                (getdata) async {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                // try {
                var data = getdata["data"];

                print('Got the response............');

                print(data);

                /// Start
                try {
                  print("qerertrterterterttretetretret");
                  if (data['total_quantity'] == 0 ||
                      data['total_quantity'] == '0') {
                    getRecommended(widget.sellerID);
                    getSubCategory(widget.sellerId, widget.catId);
                  }
                } catch (e) {
                  print(e);
                }

                // End

                print("controller.............." + _controller[index].text);

                print("Index ----------------------" + index.toString());

                String? qty = data['total_quantity'];
                // CUR_CART_COUNT = ;

                context.read<UserProvider>().setCartCount(data['total_items']);
                context
                    .read<UserProvider>()
                    .setAmount(getdata['data']['overall_amount']);
                context
                    .read<UserProvider>()
                    .setStoreName(widget.sellerData.store_name);
                context
                    .read<UserProvider>()
                    .setSellerProfile(widget.sellerData.seller_profile);

                // productList[index]
                //     .prVarientList![productList[index].selVarient!]
                //     .cartCount
                response['variants'][0]['cart_count'] = qty.toString();

                var cart = getdata["cart"];
                List<SectionModel> cartList = (cart as List)
                    .map((cart) => new SectionModel.fromCart(cart))
                    .toList();

                print(cartList);

                context.read<CartProvider>().setCartlist(cartList);
                // } catch (e) {
                //   print(e);
                // }
                // if (qty < 1) {}
                context.read<CartProvider>().setProgress(false);
                _isProgress = false;
              } else {
                var data = await clearCart(context, msg);
                if (data) {
                  if (!mounted) return;
                  setState(() {
                    context.read<UserProvider>().setCartCount(0.toString());

                    _isProgress = false;
                  });
                } else {
                  if (mounted)
                    setState(() {
                      _isProgress = false;
                    });
                }
              }
              setState(() {});
            }, onError: (error) {
          setSnackbar(error.toString(), context);
          setState(() {
            _isProgress = false;
          });
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();

  // CART STARTS
  Future<void> getCart() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {USER_ID: CUR_USERID, SAVE_LATER: "0"};

      Response response =
      await post(getCartApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        if (getdata["latitude"] != null && getdata["longitude"] != null) {
          //  cartCount = getdata['total_quantity'];

          List<SectionModel> cartList = (data as List)
              .map((data) => new SectionModel.fromCart(data))
              .toList();
          context.read<CartProvider>().setCartlist(cartList);
          //  context.read<UserProvider>().se(cartList);

        }
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }
  // CART ENDS

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var checkOut = Provider.of<UserProvider>(context);
    //double km = double.parse(widget.sellerData.km.toString());

    /* To set the status bar color. */
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarBrightness:
        Brightness.dark // Dark == white status bar -- for IOS.
    ));

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        // appBar: getAppBar("Store", context),
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          leading: Builder(
            builder: (BuildContext context) {
              return Container(
                margin: EdgeInsets.all(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => Navigator.of(context).pop(),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: colors.primary,
                    ),
                  ),
                ),
              );
            },
          ),
          title: Text(
            "Store",
            style:
            TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
          ),
          actions: <Widget>[
            IconButton(
                icon: SvgPicture.asset(
                  imagePath + "search.svg",
                  height: 20,
                  color: colors.primary,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemSearch(
                            widget.sellerID, widget.sellerData.store_name),
                      ));
                }),
          ],
        ),
        bottomSheet: checkOut.curCartCount != "" &&
            checkOut.curCartCount != null &&
            int.parse(checkOut.curCartCount) > 0
            ? InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Cart(fromBottom: false)));
          },
          child: Padding(
            padding:
            const EdgeInsets.only(left: 15.0, right: 15, bottom: 8),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10)),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${checkOut.curCartCount} Item | $CUR_CURRENCY${checkOut.totalAmount}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "View Cart",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        )
            : SizedBox(
          width: 0,
        ),
        body: _isNetworkAvail
            ? Stack(
          children: <Widget>[
            _showContent(context),
            Selector<CartProvider, bool>(
              builder: (context, data, child) {
                return showCircularProgress(data, colors.primary);
              },
              selector: (_, provider) => provider.isProgress,
            ),

            //Floating Filters
            ValueListenableBuilder<bool>(
              builder: (BuildContext context, bool value, Widget? child) {
                return showFloatingFilter.value == true
                    ? Container(child: filters())
                    : Container();
              },
              valueListenable: showFloatingFilter,
              child: Container(),
            )
          ],
        )
            : noInternet(context),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70.0),
          child: FloatingActionButton(
            onPressed: () async {
              _dialogBuilder(context, subCatData, newData);
            },
            child: Text("Menu"),
          ),
        ),
      ),
    );
  }

  Widget filters() {
    return Container(
      //  margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      height: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.shop == false
              ? Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                isExpanded: true,
                hint: vegPro == "1"
                    ? Row(
                  children: [
                    Image.asset(
                      "assets/images/veg.png",
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Text(
                        'Pure Veg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
                    : Row(
                  children: [
                    Image.asset(
                      "assets/images/veg.png",
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Image.asset(
                      "assets/images/non_veg.jpg",
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Image.asset(
                      "assets/images/egg.png",
                      width: 15,
                      height: 15,
                    ),
                  ],
                ),
                items: items
                    .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
                    .toList(),
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value as String;
                  });
                  if (selectedValue == "Veg") {
                    setState(() {
                      vegNonVeg = "1";
                      getRecommended(widget.sellerId);
                      getSubCategory(widget.sellerId, widget.catId);
                      // getSubCategoryProducts(subCatId);
                    });
                  } else if (selectedValue == "Egg") {
                    setState(() {
                      vegNonVeg = "3";
                      getRecommended(widget.sellerId);
                      getSubCategory(widget.sellerId, widget.catId);
                      // getSubCategoryProducts(subCatId);
                    });
                  } else if (selectedValue == "Non-Veg") {
                    setState(() {
                      vegNonVeg = "2";
                      getRecommended(widget.sellerId);
                      getSubCategory(widget.sellerId, widget.catId);
                      // getSubCategoryProducts(subCatId);
                    });
                  } else {
                    setState(() {
                      vegNonVeg = "";
                      //  getSubCategoryProducts(subCatId);
                    });
                    getRecommended(widget.sellerId);
                    getSubCategory(widget.sellerId, widget.catId);
                  }
                  // getRecommended(widget.sellerId);
                  //getProduct("0");
                },
                icon: const Icon(
                  Icons.arrow_drop_down_outlined,
                ),
                iconEnabledColor: colors.primary,
                iconDisabledColor: Colors.grey,
                buttonHeight: 40,
                buttonWidth: 120,
                buttonPadding: const EdgeInsets.only(left: 12, right: 12),
                buttonDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    width: 0.5,
                    color: Colors.black26,
                  ),
                  color: Colors.white,
                ),
                itemHeight: 40,
                itemPadding: const EdgeInsets.only(left: 12, right: 12),
                dropdownPadding: null,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(14.0),
                      bottomLeft: Radius.circular(14.0)),
                ),
                dropdownElevation: 2,
                scrollbarRadius: const Radius.circular(40),
                scrollbarThickness: 6,
                scrollbarAlwaysShow: true,
              ),
            ),
          )
              : Container(),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  width: 0.6,
                  color: Colors.grey,
                )),
            height: 35,
            child: TextButton.icon(
              onPressed: sortDialog,
              icon: Icon(
                Icons.swap_vert,
                color: colors.primary,
              ),
              label: Text(
                getTranslated(context, 'SORT_BY')!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontSize: 10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget recommendedProducts() {
    return StreamBuilder<dynamic>(
        stream: productStream.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/vizzve_bottom_logo.png',
                      height: 20.0,
                    ),
                  ),
                  Center(child: Text("Vizzve")),
                  // SizedBox(
                  //     height: 50,
                  //     child: Center(child: CircularProgressIndicator())),
                ],
              ),
            );
          }
          return snapshot.data['data'].isNotEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 90),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 60,
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        hasData = false;
                      });

                      setState(() {
                        recommendedVisible = !recommendedVisible;
                        if (recommendedVisible) {
                          productStream.close();
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 40,
                          margin: EdgeInsets.symmetric(
                            horizontal:
                            MediaQuery.of(context).size.width / 40,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Center(
                            child: Text(
                              'Recommended (${newData['data'].length.toString()})',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        InkWell(
                          child: !recommendedVisible
                              ? Icon(Icons.keyboard_arrow_down_outlined)
                              : Icon(Icons.keyboard_arrow_up),
                          onTap: () {
                            // if(subData.isNotEmpty || subData.length != null) {
                            setState(() {
                              recommendedVisible = !recommendedVisible;
                              if (recommendedVisible) {
                                productStream.close();
                              }
                            });
                            //  }
                            //  }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 150,
                  ),
                  snapshot.data["data"] != null
                      ? Visibility(
                    visible: recommendedVisible,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      // AlwaysScrollableScrollPhysics(),
                      itemCount: newData["data"].length,
                      itemBuilder:
                          (BuildContext context, int index) {
                        productList = snapshot.data["data"];
                        return recommendedItem(
                            index,
                            snapshot.data,
                            newData["data"].length);
                      },

                      // }
                      // else if(snapshot.hasError){
                      //   return Text("${snapshot.error}");
                      // }
                      // return CircularProgressIndicator();
                      //     }
                    ),
                  )
                      : Container(
                    child: Text("No Items found.."),
                  )
                  // GridView.builder(
                  //   shrinkWrap: true,
                  //   physics: ScrollPhysics(),
                  //   itemCount: snapshot.data["data"].length,
                  //   gridDelegate:
                  //       SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: 2,
                  //     crossAxisSpacing: 1.0,
                  //     childAspectRatio: 1.0,
                  //     mainAxisSpacing: 4.5,
                  //   ),
                  //   itemBuilder: (BuildContext context, int index) {
                  //     dynamic model = snapshot.data["data"][index];
                  //     return InkWell(
                  //       onTap: () => onTapGoDetails(
                  //           index: index, response: snapshot.data!),
                  //       child: Container(
                  //         margin: EdgeInsets.symmetric(
                  //             horizontal:
                  //                 MediaQuery.of(context).size.width /
                  //                     50),
                  //         child: ClipRRect(
                  //           borderRadius: BorderRadius.only(
                  //             topLeft: Radius.circular(8),
                  //             topRight: Radius.circular(8),
                  //           ),
                  //           child: new Card(
                  //               child: new Column(
                  //             mainAxisAlignment:
                  //                 MainAxisAlignment.start,
                  //             crossAxisAlignment:
                  //                 CrossAxisAlignment.start,
                  //             children: [
                  //               ClipRRect(
                  //                 borderRadius: BorderRadius.only(
                  //                   topLeft: Radius.circular(8),
                  //                   topRight: Radius.circular(8),
                  //                 ),
                  //                 child: commonHWImage(
                  //                     snapshot.data["data"][index]
                  //                             ["image"]
                  //                         .toString(),
                  //                     120.0,
                  //                     MediaQuery.of(context)
                  //                         .size
                  //                         .width,
                  //                     "",
                  //                     context,
                  //                     "assets/images/placeholder.png"),
                  //               ),
                  //               Container(
                  //                 alignment: Alignment.centerLeft,
                  //                 padding: EdgeInsets.only(
                  //                     top: 5, left: 5),
                  //                 child: Text(
                  //                   snapshot.data["data"][index]
                  //                           ["name"]
                  //                       .toString(),
                  //                   style: Theme.of(context)
                  //                       .textTheme
                  //                       .subtitle1!
                  //                       .copyWith(
                  //                           color: Theme.of(context)
                  //                               .colorScheme
                  //                               .lightBlack),
                  //                   maxLines: 1,
                  //                   overflow: TextOverflow.ellipsis,
                  //                 ),
                  //               ),
                  //               Row(
                  //                 children: [
                  //                   SizedBox(
                  //                     width: 5,
                  //                   ),
                  //                   Text(MONEY_TYPE),
                  //                   Text(
                  //                       "${snapshot.data["data"][index]["min_max_price"]["max_special_price"]}"),
                  //                   Text(
                  //                     " ${snapshot.data["data"][index]["min_max_price"]["max_price"]}",
                  //                     style: TextStyle(
                  //                         decoration: TextDecoration
                  //                             .lineThrough,
                  //                         fontSize: 10),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ],
                  //           )),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          )
              : Container();
        });
  }

  Widget subCatProducts() {
    return mount
        ? subCatData.isNotEmpty || subData.length != null
        ? Padding(
      padding:
      const EdgeInsets.only(bottom: 100.0, left: 15, right: 15),
      child: ScrollablePositionedList.builder(
        // physics: NeverScrollableScrollPhysics(),
        itemCount: subCatData.length,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        // ListView.builder(
        //   shrinkWrap: true,
        //   physics: ClampingScrollPhysics(),
        //   itemCount: subCatData.length,
        //   itemBuilder: (BuildContext context, int index) {
        itemBuilder: (BuildContext context, index) {
          return subCatData[index]['data'].isNotEmpty
              ? Container(
            margin: EdgeInsets.only(top: 15),
            // height: 60,
            color: Colors.white,
            child: ExpansionTile(
                initiallyExpanded: expand,
                iconColor: colors.primary,
                textColor:
                Theme.of(context).colorScheme.fontColor,
                collapsedTextColor:
                Theme.of(context).colorScheme.fontColor,
                collapsedIconColor: colors.primary,
                title: Center(
                  child: Container(
                    color: Colors.white,
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.symmetric(
                        horizontal:
                        MediaQuery.of(context).size.width /
                            40,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Center(
                        child: Container(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${subCatData[index]["name"].toString()}',
                                  overflow:
                                  TextOverflow.ellipsis,
                                  // : '${subCatData[index]["name"].toString()}',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight:
                                      FontWeight.w600),
                                ),
                              ),
                              //     hasData == false ?
                              // //|| subCatData[index]["id"] == sData["sub_category_id"]?
                              //     Container(
                              //       height: 20,
                              //       width: 20,
                              //       child: CircularProgressIndicator(),
                              //     )
                              Text(
                                subCatData.length == 0
                                    ? ""
                                    : ' (${subCatData[index]["total"].toString()})',

                                // : '${subCatData[index]["name"].toString()}',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight:
                                    FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // trailing: Icon(Icons.keyboard_arrow_down_outlined),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    //  AlwaysScrollableScrollPhysics(),
                    itemCount:
                    //subData.length,
                    subCatData[index]['data'].length,
                    itemBuilder:
                        (BuildContext context, int ind) {
                      var response = subCatData[index];
                      // dynamic model = snapshot.data["data"][index];
                      //  print("----hello--${subData[index].total}");
                      return
                        //subCatItem(ind, response);
                        recommendedItem(ind, response,
                            subCatData[index]['data'].length);
                    },

                    // }
                    // else if(snapshot.hasError){
                    //   return Text("${snapshot.error}");
                    // }
                    // return CircularProgressIndicator();
                    //     }
                  )
                  //      }).toList(),
                ]),
          )
              : Container();
        },
      ),
    )
        : Center(child: Text("No Sub Category"))
        : Column(
      children: [
        // Container(
        //   height: 40,
        //   width: 40,
        //   child: CircularProgressIndicator(
        //     color: colors.primary,
        //   ),
        // ),
      ],
    );
  }

  final dataKey = new GlobalKey();

  Widget subCatProducts2() {
    // subCatData.length
    return mount
        ? subCatData.isNotEmpty || subData.length != null
        ? Padding(
      padding:
      const EdgeInsets.only(bottom: 100.0, left: 15, right: 15),
      child: Column(
          children: subCatData
              .map<Widget>((e) => e['data'].isNotEmpty
              ? AutoScrollTag(
            index: subCatData.indexOf(e),
            key: ValueKey(subCatData.indexOf(e)),
            controller: _autoScrollController,
            child: Container(
              margin: EdgeInsets.only(top: 15),
              // height: 60,
              color: Colors.white,
              child: ExpansionTile(
                initiallyExpanded: expand,
                iconColor: colors.primary,
                textColor:
                Theme.of(context).colorScheme.fontColor,
                collapsedTextColor:
                Theme.of(context).colorScheme.fontColor,
                collapsedIconColor: colors.primary,
                title: Center(
                  child: Container(
                    color: Colors.white,
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context)
                            .size
                            .width /
                            40,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Center(
                        child: Container(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  // subCatData
                                  //     .indexOf(e)
                                  //     .toString(),
                                  '${e["name"].toString()}',
                                  overflow:
                                  TextOverflow.ellipsis,
                                  // : '${subCatData[index]["name"].toString()}',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight:
                                      FontWeight.w600),
                                ),
                              ),
                              //     hasData == false ?
                              // //|| subCatData[index]["id"] == sData["sub_category_id"]?
                              //     Container(
                              //       height: 20,
                              //       width: 20,
                              //       child: CircularProgressIndicator(),
                              //     )
                              Text(
                                subCatData.length == 0
                                    ? ""
                                    : ' (${e["total"].toString()})',
                                // : '${subCatData[index]["name"].toString()}',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight:
                                    FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // trailing: Icon(Icons.keyboard_arrow_down_outlined),
                // children: e['data']
                //     .map<Widget>((subCat) => AutoScrollTag(
                //         index: e['data'].indexOf(subCat),
                //         key: ValueKey(
                //             e['data'].indexOf(subCat)),
                //         controller: _autoScrollController,
                //         // child: recommendedItem(
                //         //     e['data'].indexOf(subCat), e)
                //         child: SizedBox(
                //           height: 200,
                //           child: Text(e['data'].indexOf(subCat).toString())),

                //             )
                //             )
                //     .toList()

                children: [
                  for (int i = 0; i < e['data'].length; i++)
                    Container(
                        child: recommendedItem(
                            i, e, e['data'].length)),
                ],
                // children: [
                //   ListView.builder(
                //     controller: _autoScrollController,
                //     shrinkWrap: true,
                //     physics: ClampingScrollPhysics(),
                //     //  AlwaysScrollableScrollPhysics(),
                //     itemCount:
                //         //subData.length,
                //         e['data'].length,
                //     itemBuilder:
                //         (BuildContext context, int ind) {
                //       var response = e;
                //       // dynamic model = snapshot.data["data"][index];
                //       //  print("----hello--${subData[index].total}");
                //       return
                //           //subCatItem(ind, response);
                //           AutoScrollTag(
                //               index: ind,
                //               key: ValueKey(ind),
                //               controller:
                //                   _autoScrollController,
                //               child: recommendedItem(
                //                   ind, response));
                //     },

                //     // }
                //     // else if(snapshot.hasError){
                //     //   return Text("${snapshot.error}");
                //     // }
                //     // return CircularProgressIndicator();
                //     //     }
                //   )
                //   //      }).toList(),
                // ]
              ),
            ),
          )
              : Container())
              .toList()),
    )
        : Center(child: Text("No Sub Category"))
        : Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Center(
              //   child: Image.asset(
              //     'assets/images/vizzve_bottom_logo.png',
              //     height: 20.0,
              //   ),
              // ),
              SizedBox(
                height: 60.0,
              ),
              CircularProgressIndicator(
                color: colors.primary,
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(child: Text("Loading Categories")),
              // SizedBox(
              //     height: 50,
              //     child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
        Container(
          height: 50,
          // width: 40,
          // child: CircularProgressIndicator(
          //   color: colors.primary,
          // ),
        ),
      ],
    );
  }

  _showContent(BuildContext context) {
    double km = double.parse(widget.sellerData.km.toString());
    return SingleChildScrollView(
      controller: _autoScrollController,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0), color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 250,
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        // widget.sellerName
                        "${widget.sellerData.store_name!}".toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: AddRemveSeller(sellerID: widget.sellerID),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: colors.primary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "${widget.sellerData.seller_rating}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    widget.sellerData.food_person != ""
                        ? Text(
                      "${widget.sellerData.food_person}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : Container(),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Card(
                  elevation: 0,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            "assets/images/green.png",
                            width: 12,
                          ),
                          Container(
                              height: 25,
                              child: VerticalDivider(color: Colors.grey)),
                          Image.asset("assets/images/red.png", width: 12),
                        ],
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  "Outlet",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Container(
                                  width: 230,
                                  child: Text(
                                    "${widget.sellerData.address}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  "${widget.sellerData.estimated_time}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text("Deliver To"),
                                SizedBox(
                                  width: 3,
                                ),
                                Container(
                                  width: 150,
                                  child: Text(
                                    "${widget.userLocation}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 20,
                ),
                Row(
                  children: [
                    Icon(Icons.delivery_dining_outlined),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      child: Text(
                        "${km.toStringAsFixed(2).toString()} km",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(child: filters()),
          Container(child: recommendedProducts()),
          subCatProducts2(),
          SizedBox(
            height: 100,
          ),
          // Placeholder()
          // Expanded(child: subCatProducts())
          // Expanded(child: subCatProducts())
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     filters(),
          //     recommendedProducts(),
          //     // Placeholder()
          //     Expanded(child: subCatProducts())
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  // if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget recommendedItem(int index, response, int length) {
    if (_controller.length < index + 1)
      _controller.add(new TextEditingController());

    var data = response["data"][index];

    List<SectionModel> cartList = context.read<CartProvider>().cartList ?? [];

    // _controller[index].text =
    //     response["data"][index]["variants"][0]["cart_count"]; // UNCOMMENT

    SectionModel? _cartItem;
    try {
      _cartItem = cartList
          .firstWhere((element) => element.id == response["data"][index]["id"]);
    } catch (e) {
      print(e);
    }

    print(_cartItem);

    if (_cartItem != null) {
      _controller[index].text = _cartItem.qty;
    } else {
      _controller[index].text = "0";
    }

    int qty = 0;

    print('---------------------------------------------' + index.toString());
    print(_controller[index].text);

    String timeData = "";
    String openStatus = "";
    openStatus = response["data"][index]["open_close_status"];

    bool isTime = true;
    DateTime time = DateTime.now();

    return openStatus == "0"
        ? Container()
        : Container(
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        onTapGoDetails(index: index, response: response),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        response["data"][index]["indicator"] == "1"
                            ? Image.asset(
                          "assets/images/veg.png",
                          width: 15,
                          height: 15,
                        )
                            : response["data"][index]["indicator"] == "2"
                            ? Image.asset(
                          "assets/images/non_veg.jpg",
                          width: 15,
                          height: 15,
                        )
                            : response["data"][index]["indicator"] ==
                            "3"
                            ? Image.asset(
                          "assets/images/egg.png",
                          width: 15,
                          height: 15,
                        )
                            : SizedBox(),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: 160,
                          child: Text(
                            "${response["data"][index]["name"]}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (response["data"][index]["rating"] == "0" ||
                                response["data"][index]["rating"] ==
                                    "0.0")
                                ? Container()
                                : Row(
                              children: [
                                RatingBarIndicator(
                                  rating: double.parse(
                                      response["data"][index]
                                      ["rating"]),
                                  itemBuilder: (context, index) =>
                                      Icon(
                                        Icons.star_rate_rounded,
                                        color: Colors.amber,
                                        //color: colors.primary,
                                      ),
                                  unratedColor:
                                  Colors.grey.withOpacity(0.5),
                                  itemCount: 5,
                                  itemSize: 18.0,
                                  direction: Axis.horizontal,
                                ),
                                Text(
                                  " (" +
                                      response["data"][index]
                                      ["no_of_ratings"] +
                                      ")",
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline,
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        response["data"][index]
                                        ["min_max_price"]
                                        ["max_special_price"]
                                            .toString() +
                                        " ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  "${response["data"][index]["min_max_price"]["max_price"]}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                      decoration:
                                      TextDecoration.lineThrough,
                                      letterSpacing: 0),
                                ),
                              ],
                            ),
                            Container(
                              height: 50,
                              width:
                              MediaQuery.of(context).size.width / 2.3,
                              child: Html(
                                data:
                                "${response["data"][index]["short_description"]}",
                                style: {
                                  "body": Style(
                                      fontSize: FontSize(12.0),
                                      fontWeight: FontWeight.w400,
                                      maxLines: 2,
                                      padding: EdgeInsets.zero,
                                      margin: EdgeInsets.zero,
                                      textOverflow:
                                      TextOverflow.ellipsis),
                                },
                              ),
                            ),
                            response["data"][index][
                            "breakfast_start_product_time"] !=
                                null
                                ? Text(
                              openStatus == "0"
                                  ? "${response["data"][index]["next_available_text"].toString()}"
                                  : "",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.red),
                            )
                                : Text("")
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Container(
                        height: 120,
                        width: 140,
                        padding: EdgeInsets.only(left: 10),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: commonHWImage(
                                response["data"][index]["image"]
                                    .toString(),
                                120.0,
                                MediaQuery.of(context).size.width,
                                "",
                                context,
                                "assets/images/placeholder.png"),
                          ),
                        ),
                      ),
                      _controller[index].text == "0"
                          ? Positioned(
                        top: 100,
                        left: 25,
                        width: 100,
                        height: 30,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                elevation: 2),
                            onPressed: () {
                              if (openStatus == "0") {
                                showToast(response["data"][index]
                                ["next_available_text"]
                                    .toString());
                                // "Item Available After ${timeData}");
                              }
                              // if (timeData != "Yes" &&
                              //     timeData != "No" &&
                              //     timeData != "") {
                              //   showToast(
                              //       "Item Available After ${timeData}");
                              // }
                              else {
                                if (context
                                    .read<CartProvider>()
                                    .isProgress ==
                                    false)
                                  print(response["data"][index]
                                  ["quantity_step_size"]);
                                // addToCart(
                                //     index,
                                //     (int.parse(response["data"][index]["variants"][0]["cart_count"])
                                //         + int.parse(
                                //             response["data"][index]["quantity_step_size"]))
                                //         .toString(), response["data"][index]);
                                addToCart(
                                    index,
                                    (int.parse(_controller[index]
                                        .text) +
                                        int.parse(response[
                                        "data"][index][
                                        "quantity_step_size"]))
                                        .toString(),
                                    response["data"][index]);
                              }
                            },
                            child: Text(
                              "ADD",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            )),
                      )
                          : Positioned(
                        top: 100,
                        left: 25,
                        width: 120,
                        // width: 100,
                        child: Padding(
                          padding:
                          const EdgeInsets.only(right: 20.0),
                          child: Card(
                            elevation: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(10.0),
                                color: Colors.white,
                                // border: Border.all(
                                //     color: Colors.black, width: 0.7)
                              ),
                              child: Row(
                                children: <Widget>[
                                  response["data"][index]
                                  ["availability"] ==
                                      "0"
                                      ? Container()
                                      : cartBtnList
                                      ? Container()
                                      : Container(),
                                  // GestureDetector(
                                  //     child:
                                  Container(
                                    height: 35,
                                    width: 30,
                                    child: IconButton(
                                      onPressed: () {
                                        if (context
                                            .read<
                                            CartProvider>()
                                            .isProgress ==
                                            false)
                                          removeFromCart(
                                              index,
                                              response["data"]
                                              [index]);
                                      },
                                      icon: Icon(
                                        Icons.remove,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  // onTap: () {
                                  //     // if (_isProgress == false
                                  //     //     // (int.parse(
                                  //     //     //     _controller[index].text) >
                                  //     //     //     0)
                                  //     // )
                                  //       if (context.read<CartProvider>().isProgress ==
                                  //           false)
                                  //       removeFromCart(index, response["data"][index]);
                                  //   },
                                  // ),
                                  Container(
                                      width: 26,
                                      height: 20,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [
                                          Center(
                                              child: Text(
                                                  _controller[index]
                                                      .text)),
                                        ],
                                      )
                                    // TextField(
                                    //   textAlign: TextAlign.center,
                                    //   readOnly: true,
                                    //   style: TextStyle(
                                    //       fontSize: 12,
                                    //       color: Theme.of(context)
                                    //           .colorScheme
                                    //           .fontColor),
                                    //   controller: _controller[index],
                                    //   decoration: InputDecoration(
                                    //     border: InputBorder.none,
                                    //   ),
                                    // ),
                                  ),
                                  // GestureDetector(
                                  //   child:
                                  Container(
                                    height: 35,
                                    width: 30,
                                    child: IconButton(
                                      onPressed: () {
                                        if (context
                                            .read<
                                            CartProvider>()
                                            .isProgress ==
                                            false)
                                          addToCart(
                                              index,
                                              (int.parse(response["data"]
                                              [index]
                                              ["variants"][0][
                                              "cart_count"])
                                                  // model
                                                  // .prVarientList![model
                                                  // .selVarient!]
                                                  // .cartCount!)
                                                  +
                                                  int.parse(response[
                                                  "data"]
                                                  [
                                                  index]
                                                  [
                                                  "quantity_step_size"]))
                                                  .toString(),
                                              response["data"]
                                              [index]);
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  //   onTap: () {
                                  //     if (context.read<CartProvider>().isProgress ==
                                  //         false)
                                  //     addToCart(
                                  //         index,
                                  //         (int.parse(response["data"][index]["variants"][0]["cart_count"])
                                  //             // model
                                  //             // .prVarientList![model
                                  //             // .selVarient!]
                                  //             // .cartCount!)
                                  //             + int.parse(
                                  //                 response["data"][index]["quantity_step_size"]))
                                  //             .toString(), response["data"][index]);
                                  //   },
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ),
                        /*Row(
                                    children: [
                                      model.availability == "0"
                                          ? Container()
                                          : cartBtnList
                                              ? Container()
                                              : Container(),

                                      Row(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              GestureDetector(
                                                child: Card(
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (_isProgress == false &&
                                                      (int.parse(_controller[
                                                                  index]
                                                              .text) >
                                                          0))
                                                    removeFromCart(index);
                                                },
                                              ),
                                              Container(
                                                width: 26,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5),
                                                ),
                                                child: TextField(
                                                  textAlign: TextAlign.center,
                                                  readOnly: true,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor),
                                                  controller:
                                                      _controller[index],
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                child: Card(
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (_isProgress == false)
                                                    addToCart(
                                                        index,
                                                        (int.parse(model
                                                                    .prVarientList![
                                                                        model
                                                                            .selVarient!]
                                                                    .cartCount!) +
                                                                int.parse(model
                                                                    .qtyStepSize!))
                                                            .toString());
                                                },
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),*/
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          length == index + 1 ? Container() : Divider()
        ],
      ),
    );
  }

  Widget detailsScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: colors.primary,
              backgroundImage: NetworkImage(widget.sellerImage!),
            ),
          ),
          getHeading(widget.sellerStoreName!),
          SizedBox(
            height: 5,
          ),
          Text(
            widget.sellerName!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.lightBlack2, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: colors.primary),
                      child: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      widget.sellerRating!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            color: colors.primary),
                        child: Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.white,
                          size: 30,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isDescriptionVisible = !isDescriptionVisible;
                        });
                      },
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'DESCRIPTION')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: colors.primary),
                          child: Icon(
                            Icons.list_alt,
                            color: Theme.of(context).colorScheme.white,
                            size: 30,
                          ),
                        ),
                        onTap: () => _tabController
                            .animateTo((_tabController.index + 1) % 2)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'PRODUCTS')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Visibility(
              visible: isDescriptionVisible,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 8,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: colors.primary)),
                child: SingleChildScrollView(
                    child: Text(
                      (widget.storeDesc != "" || widget.storeDesc != null)
                          ? "${widget.storeDesc}"
                          : getTranslated(context, "NO_DESC")!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack2),
                    )),
              ))
        ],
      ),
    );
  }

  Widget getHeading(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline6!.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.fontColor,
      ),
    );
  }

  Widget getRatingBarIndicator(var ratingStar, var totalStars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: RatingBarIndicator(
        rating: ratingStar,
        itemBuilder: (context, index) => const Icon(
          Icons.star_outlined,
          color: colors.yellow,
        ),
        itemCount: totalStars,
        itemSize: 20.0,
        direction: Axis.horizontal,
        unratedColor: Colors.transparent,
      ),
    );
  }

  onTapGoDetails({response, index}) {
    Product model = Product.fromJson(response["data"][index]);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetail(
          index: index,
          model: model,
          secPos: 0,
          list: false,
          sellerId: widget.sellerID,
        )));
  }

  _dialogBuilder(BuildContext context, subCatData, newData) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          alignment: Alignment.bottomCenter,
          content: Container(
            /* decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0)
          ),*/
            height: 200.0,
            width: 500.0,
            child: SingleChildScrollView(
              child: Column(children: [
                newData["data"].isNotEmpty
                    ? ListTile(
                  onTap: () {
                    jump(-1);
                    Navigator.pop(context);
                  },
                  title: Text(
                    'Recommended',
                    overflow: TextOverflow.ellipsis,
                    // : '${subCatData[index]["name"].toString()}',
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w600),
                  ),
                )
                    : Container(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: subCatData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        jump(index);
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        title: Text(
                          '${subCatData[index]["name"].toString()}',
                          overflow: TextOverflow.ellipsis,
                          // : '${subCatData[index]["name"].toString()}',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        );

        /* alignment: Alignment.bottomCenter,
        title: const Text('Basic dialog title'),
        content: const Text('A dialog is a type of modal window that\n'
            'appears in front of app content to\n'
            'provide critical information, or prompt\n'
            'for a decision to be made.'),
       */ /* actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Disable'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Enable'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],*/ /*
      );*/
      },
    );
  }

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                            padding:
                            EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                            child: Text(
                              getTranslated(context, 'SORT_BY')!,
                              style: Theme.of(context).textTheme.headline6,
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          sortBy = '';
                          orderBy = 'DESC';
                          if (mounted)
                            setState(() {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              top = "top_rated_products";
                              productList.clear();
                            });
                          getRecommended(widget.sellerId);
                          getSubCategory(widget.sellerId, widget.catId);
                          //getSubCategoryProducts(subCatId);
                          //getProduct("1");
                          Navigator.pop(context, 'option 1');
                        },
                        child: Container(
                          width: deviceWidth,
                          color: sortBy == ''
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Text(getTranslated(context, 'TOP_RATED')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: sortBy == ''
                                      ? Theme.of(context).colorScheme.white
                                      : Theme.of(context)
                                      .colorScheme
                                      .fontColor)),
                        ),
                      ),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'p.date_added' && orderBy == 'DESC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(getTranslated(context, 'F_NEWEST')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                      color: sortBy == 'p.date_added' &&
                                          orderBy == 'DESC'
                                          ? Theme.of(context).colorScheme.white
                                          : Theme.of(context)
                                          .colorScheme
                                          .fontColor))),
                          onTap: () {
                            sortBy = 'p.date_added';
                            orderBy = 'DESC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                productList.clear();
                              });
                            getRecommended(widget.sellerId);
                            getSubCategory(widget.sellerId, widget.catId);
                            // getSubCategoryProducts(subCatId);
                            //getProduct("0");
                            Navigator.pop(context, 'option 1');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'p.date_added' && orderBy == 'ASC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(
                                getTranslated(context, 'F_OLDEST')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'p.date_added' &&
                                        orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'p.date_added';
                            orderBy = 'ASC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                productList.clear();
                              });
                            getRecommended(widget.sellerId);
                            getSubCategory(widget.sellerId, widget.catId);
                            // getSubCategoryProducts(subCatId);

                            // getProduct("0");
                            Navigator.pop(context, 'option 2');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'pv.price' && orderBy == 'ASC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: new Text(
                                getTranslated(context, 'F_LOW')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'pv.price' &&
                                        orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'pv.price';
                            orderBy = 'ASC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                productList.clear();
                              });
                            getRecommended(widget.sellerId);
                            getSubCategory(widget.sellerId, widget.catId);
                            // getSubCategoryProducts(subCatId);

                            //   getProduct("0");
                            Navigator.pop(context, 'option 3');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'pv.price' && orderBy == 'DESC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: new Text(
                                getTranslated(context, 'F_HIGH')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'pv.price' &&
                                        orderBy == 'DESC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'pv.price';
                            orderBy = 'DESC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                productList.clear();
                              });
                            getRecommended(widget.sellerId);
                            getSubCategory(widget.sellerId, widget.catId);
                            // getSubCategoryProducts(subCatId);

                            // getProduct("0");
                            Navigator.pop(context, 'option 4');
                          }),
                    ]),
              );
            });
      },
    );
  }

  void jump(int ind) async {
    if (ind < 0) {
      _autoScrollController.animateTo(
        _autoScrollController.position.minScrollExtent,
        duration: Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
      return;
    }
    await _autoScrollController.scrollToIndex(ind,
        preferPosition: AutoScrollPosition.begin);
    // setState(() {
    //   // itemScrollController.scrollTo(index: ind, duration: (Duration(milliseconds: 500)));
    //   // itemScrollController.scrollTo(
    //   //     index: ind,
    //   //     duration: Duration(milliseconds: 200),
    //   //     curve: Curves.easeInOutCubic);
    //   // itemScrollController.jumpTo(index: ind);
    // });
  }

  @override
  void dispose() {
    super.dispose();
    productStream.close();
    productStreamController.close();
  }

  @override
  bool get wantKeepAlive => true;
}
/*Widget _showMyDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Surendra Singh'),
        content: SingleChildScrollView(
          child: ListView(
            children:[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        */ /*actions: <Widget>[
          TextButton(
            child: Text('Allow'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Back'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],*/
/*
      );
    },
  );
}*/




