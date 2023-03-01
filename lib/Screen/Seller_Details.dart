import 'dart:async';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eshop_multivendor/Model/new_model.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  @override
  bool get wantKeepAlive => true;
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

  @override
  void initState() {
    print(
        "---------data is ${widget.sellerID} and ${widget.catId} && ${widget.subCatId}");
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    getRecommended(widget.sellerID);
    getSubCategory(widget.sellerId, widget.catId);
  /*  WidgetsBinding.instance.addPostFrameCallback((_) {

    });*/
    sCon
      ..addListener(() {
        print("offset = ${sCon.offset}");
      });
    // Future.delayed(Duration(seconds: 1), (){
    //   getSubCatProducts();
    // });

    // Future.delayed(Duration(seconds: 1), () async {
    //   getSubCategoryProducts(subCatId);
    // });
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
    /* var data = await apiBaseHelper.postAPINew(recommendedProductapi, parm);
    newData = data;
    context.read<CartProvider>().setProgress(false);
    if (newData.isNotEmpty) {
      print(
          "new recommended products data ==== ${newData["data"].length.toString()}");
      productStream.sink.add(newData);
    } else {
      productStream.sink.addError("");
    }*/
  }

  List<SubCatModel> subProductList = [];
  bool loading = false;
  getSubCategory(sellerId, catId) async {
    var parm = {};
    setState(() {
      loading = true;
    });
    if (catId != null) {
      parm = {
        SORT: sortBy,
        ORDER: orderBy,
        "product_type": top,
        "cat_id": "$catId",
        "seller_id": "$sellerId",
        "user_id": CUR_USERID!=null?CUR_USERID:"",
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
        "user_id": CUR_USERID!=null?CUR_USERID:"",
      };
      // parm = {"seller_id": "$sellerId"};
    }

    print("SUB CAT PARAM ---->" + parm.toString());
    print(getSubCatBySellerId);
    apiBaseHelper.postAPICall(getSubCatBySellerId, parm).then((value) {
      context.read<CartProvider>().setProgress(false);
      List<Product> newList = [];
      setState(() {
        loading = false;
      });
      for (var v in value['products']) {
        newList.add(Product.fromJson(v));
      }
      var v = value['recommend_products1'];
      List<Product> tempList = [];
      for (var p in v['product']) {
        tempList.add(Product.fromJson(p));
      }

      loading = false;
      subProductList.clear();
      subProductList.add(new SubCatModel("0", "Recommended",
          tempList.length.toString(), "", tempList.toList(), 0.0, true));

      for (var v in value['subcategory_products']) {
        List<Product> tempList = [];
        for (var p in v['data']) {
          if (p['open_close_status'] == "1") {
            tempList.add(Product.fromJson(p));
          }
        }
        /* for(var i=0;i<newList.length;i++){
          if(v['id']== newList[i].sub_category_id){
              tempList.add(newList[i]);
              newList.removeAt(i);
          }
        }*/
        if (tempList.length > 0)
          subProductList.add(new SubCatModel(
              v['id'],
              v['name'],
              tempList.length.toString(),
              v['image'],
              tempList.toList(),
              0.0,
              true));
      }

      print("sub Cat Id ---------${subCatId.toString()}");
    });
  }

  SubCatProduct? h = SubCatProduct();

  Future<void> addToCart(int index, String qty, Product response) async {
    print(
        '************************************************************************************');
    context.read<CartProvider>().setProgress(true);
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        // print(response['minimum_order_quantity'].toString());
        if (int.parse(qty) < int.parse(response.minOrderQuntity.toString())) {
          qty = response.minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_VARIENT_ID: response.prVarientList![0].id,
          QTY: qty,
          "seller_id": "${widget.sellerID}"
        };
        int start = 0;
        Timer timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
          start++;
        });
        print('Calling the API......');
        apiBaseHelper.postAPICall(addCartApi, parameter).then((getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            timer.cancel();
            print("timer1" + start.toString());
            context.read<CartProvider>().setProgress(false);
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];
            context.read<UserProvider>().setCartCount(data['total_items']);

            context
                .read<UserProvider>()
                .setStoreName(widget.sellerData.store_name);
            context
                .read<UserProvider>()
                .setSellerId(widget.sellerData.seller_id);
            context
                .read<UserProvider>()
                .setAmount(getdata['data']['overall_amount']);

            context
                .read<UserProvider>()
                .setSellerProfile(widget.sellerData.seller_profile);

            response.prVarientList![0].cartCount = qty.toString();
            subProductList.forEach((SubCatModel model) {
              int subIndex = subProductList.indexWhere((element) => element==model);
              int index = model.productList.indexWhere((element) => element.id==response.id);
              if(index!=-1){
                subProductList[subIndex].productList[index].prVarientList![0].cartCount = qty.toString();
              }
            });
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

  Future removeFromCart(int index, Product response) async {
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
        print(response.prVarientList![0].cartCount);
        print(response.quantity_step_size);
        qty = (int.parse(response.prVarientList![0].cartCount!) -
            int.parse(response.quantity_step_size.toString()));
        print(qty.toString() + response.minOrderQuntity.toString());
        if (qty < int.parse(response.minOrderQuntity.toString())) {
          print("yes");
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: response.prVarientList![0].id,
          // productList[index]
          //     .prVarientList![productList[index].selVarient!]
          //     .id,
          USER_ID: CUR_USERID,
          QTY: qty.toString(),
          "seller_id": "${widget.sellerId}"
        };

        print('Calling the API--------------');

        print(parameter);

        apiBaseHelper.postAPICall(addCartApi, parameter).then((getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            print('Got the response............');

            print(data);

            /*/// Start
                  try {
                    print("qerertrterterterttretetretret");
                    if (data['total_quantity'] == 0 ||
                        data['total_quantity'] == '0') {
                    //  getRecommended(widget.sellerID);
                      getSubCategory(widget.sellerId, widget.catId);
                    }
                  } catch (e) {
                    print(e);
                  }*/

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
            setState(() {
              response.prVarientList![0].cartCount = qty.toString();
              subProductList.forEach((SubCatModel model) {
                int subIndex = subProductList.indexWhere((element) => element==model);
                int index = model.productList.indexWhere((element) => element.id==response.id);
                    if(index!=-1){
                        subProductList[subIndex].productList[index].prVarientList![0].cartCount = qty.toString();
                    }
              });
            });
            print("qty" + qty.toString());
            /*  var cart = getdata["cart"];
                  List<SectionModel> cartList = (cart as List)
                      .map((cart) => new SectionModel.fromCart(cart))
                      .toList();
                  context.read<CartProvider>().setCartlist(cartList);*/
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
  final ValueNotifier<bool> showFloatingFilter = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var checkOut = Provider.of<UserProvider>(context);

    /* To set the status bar color. */
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarBrightness:
            Brightness.dark // Dark == white status bar -- for IOS.
        ));

    //double km = double.parse(widget.sellerData.km.toString());
    super.build(context);
    return SafeArea(
      top: false,
      child: Scaffold(
        // appBar: getAppBar("Store", context),
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          backgroundColor: Theme.of(context).colorScheme.white,
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
            height1 < 200
                ? "${widget.sellerData.store_name!}".toUpperCase()
                : "Store",
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
                onTap: () async {
                  bool result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Cart(fromBottom: false)));
                  if (result == true) {
                    //getRecommended(widget.sellerId);
                    getSubCategory(widget.sellerId, widget.catId);
                  }
                  // .then((_)
                  // {
                  //   getRecommended(widget.sellerId);
                  //   getSubCategory(widget.sellerId, widget.catId);
                  // });
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
                  NewContent(context),
                  Selector<CartProvider, bool>(
                    builder: (context, data, child) {
                      return showCircularProgress(data, colors.primary);
                    },
                    selector: (_, provider) => provider.isProgress,
                  ),
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
            onPressed: () {
              _dialogBuilder(
                context,
                subProductList.toList(),
              );
            },
            child: Text("Menu"),
          ),
        ),
      ),
    );
  }

  Widget filters() {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15, top: 0, bottom: 10),
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
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
                  child: InkWell(
                    onTap: () {
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
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(bottom: 5),
                      margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 90),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
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
                                Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: InkWell(
                                    child: !recommendedVisible
                                        ? Icon(
                                            Icons.keyboard_arrow_down_outlined)
                                        : Icon(Icons.keyboard_arrow_up),
                                    onTap: () {
                                      // if(subData.isNotEmpty || subData.length != null) {
                                      setState(() {
                                        recommendedVisible =
                                            !recommendedVisible;
                                        if (recommendedVisible) {
                                          productStream.close();
                                        }
                                      });
                                      //  }
                                      //  }
                                    },
                                  ),
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
                                          index, snapshot.data);
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
                            //  padding: EdgeInsets.symmetric(horizontal: 10),
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
                                          recommendedItem(ind, response);
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
              Container(
                  // height: 40,
                  // width: 40,
                  // child: CircularProgressIndicator(
                  //   color: colors.primary,
                  // ),
                  ),
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
                                      ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: e['data'].length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                                child:
                                                    recommendedItem(index, e));
                                          }),
                                      /*for (int i = 0; i < e['data'].length; i++)
                    Container(child: recommendedItem(i, e)),*/
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
                  // height: 40,
                  // width: 40,
                  // child: CircularProgressIndicator(
                  //   color: colors.primary,
                  // ),
                  ),
            ],
          );
  }

  ScrollController sCon = new ScrollController();
  NewContent1(BuildContext context) {
    double km = double.parse(widget.sellerData.km.toString());
    return CustomScrollView(
      controller: sCon,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
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
        ),
        SliverToBoxAdapter(
          child: Container(child: filters()),
        ),
        /* SliverList(
              delegate:SliverChildListDelegate([
                ScrollablePositionedList.builder(
            itemCount: subProductList.length,
      physics: ClampingScrollPhysics(),

      shrinkWrap: true,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemBuilder: (context, index) {
        SubCatModel model = subProductList[index];
        return Container(
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
                              '${model.name.toString()}',
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
                            ' (${model.total.toString()})',
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
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: model.productList.length,
                  primary: false,
                  itemBuilder: (context,index){
                    Product model1 = model.productList[index];
                    return  Container(child: recommendedItem(index, model1));
                  }),
              */
        /*for (int i = 0; i < e['data'].length; i++)
                    Container(child: recommendedItem(i, e)),*/
        /*
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
        );
      }
            )])
          ),*/
        !loading
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    SubCatModel model = subProductList[index];
                    return buildRow(subProductList[index]);
                    /*  return Container(
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
                                    '${model.name.toString()}',
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
                                  ' (${model.total.toString()})',
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
                    ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) => Divider(),
                        itemCount: model.productList.length,
                        primary: false,
                        itemBuilder: (context,index){
                          Product model1 = model.productList[index];
                          return  Container(child: recommendedItem(index, model1));
                        }),
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
              );*/
                  },
                  childCount: subProductList.length,
                ),
              )
            : SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
          ),
        ),
      ],
    );
  }

  double height1 = 200;
  bool _visible = true;
  NewContent(BuildContext context) {
    double km = double.parse(widget.sellerData.km.toString());
    return Column(
      children: [
        /*   AnimatedContainer(
          width: MediaQuery.of(context).size.width,
          height: height1,
          duration: Duration (milliseconds: 300),
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white),
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
        ),*/
        //Container(child: filters()),
        !loading
            ? Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    final ScrollDirection direction = notification.direction;

                    print(notification.metrics.pixels);
                    if (notification.metrics.pixels > 200) {
                      showFloatingFilter.value = true;
                    } else {
                      showFloatingFilter.value = false;
                    }
                    return true;
                  },
                  child: ScrollablePositionedList.builder(
                    itemCount: subProductList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => Column(
                      children: [
                        index == 0
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                // duration: Duration (milliseconds: 300),
                                margin: EdgeInsets.all(10.0),
                                padding:
                                    EdgeInsets.only(left: 15.0, right: 15.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: Colors.white),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 250,
                                          padding: EdgeInsets.only(top: 10),
                                          child: Text(
                                            // widget.sellerName
                                            "${widget.sellerData.store_name!}"
                                                .toUpperCase(),
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
                                          child: AddRemveSeller(
                                              sellerID: widget.sellerID),
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
                                                  child: VerticalDivider(
                                                      color: Colors.grey)),
                                              Image.asset(
                                                  "assets/images/red.png",
                                                  width: 12),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Outlet",
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                              )
                            : Container(),
                        index == 0 ? Container(child: filters()) : SizedBox(),
                        buildRow(subProductList[index]),
                        subProductList.length - 1 == index
                            ? SizedBox(
                                height: 100,
                              )
                            : SizedBox(),
                      ],
                    ),
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                  ),
                ),
              )
            : Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Center(
                  child:Image.asset("assets/images/loading_gif.gif"),
                ),
              ),
      ],
    );
  }

  Widget buildRow(SubCatModel model1) {
    return Container(
      margin: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              setState(() {
                model1.show = !model1.show;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                //
                color: Colors.white, //                   <-- BoxDecoration
                border: Border(
                    bottom: BorderSide(
                  color: Colors.white,
                  width: 2,
                )),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      // subCatData
                      //     .indexOf(e)
                      //     .toString(),
                      '${model1.name.toString()} (${model1.total.toString()})',
                      overflow: TextOverflow.ellipsis,
                      // : '${subCatData[index]["name"].toString()}',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                  //     hasData == false ?
                  // //|| subCatData[index]["id"] == sData["sub_category_id"]?
                  //     Container(
                  //       height: 20,
                  //       width: 20,
                  //       child: CircularProgressIndicator(),
                  //     )
                  Icon(
                    model1.show ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.black,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          ),
          model1.show
              ? ListView.builder(
                  key: new Key(Random().nextInt(800).toString()),
                  itemCount: model1.productList.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  //  separatorBuilder: (context, index) => Divider(),
                  primary: false,
                  itemBuilder: (context, index) {
                    Product model = model1.productList[index];
                    return Container(
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.6),
                            width: 0.5,
                          )),
                        ),
                        child: recommendedItem(index, model));
                  },
                )
              : SizedBox(),
        ],
      ),
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
          subCatProducts2()
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

  Widget recommendedItem(int index, Product response) {
    if (_controller.length < index + 1)
      _controller.add(new TextEditingController());

    //  print('cart quantiy..........');

    // print(response.prVarientList![0]);

    _controller[index].text = response.prVarientList![0].cartCount!;
    //  print(response.image.toString());
    //print('---------------------------------------------' + index.toString());
    //  print(_controller[index].text);

    String timeData = "";
    String openStatus = "";
    openStatus = response.open_close_status!;

    bool isTime = true;
    DateTime time = DateTime.now();

    return openStatus == "1"
        ? InkWell(
      onTap: (){
        onTapGoDetails(index: index, response: response);
      },
          child: Container(
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
                                response.indicator == "1"
                                    ? Image.asset(
                                        "assets/images/veg.png",
                                        width: 15,
                                        height: 15,
                                      )
                                    : response.indicator == "2"
                                        ? Image.asset(
                                            "assets/images/non_veg.jpg",
                                            width: 15,
                                            height: 15,
                                          )
                                        : response.indicator == "3"
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
                                    "${response.name}",
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
                                    (response.rating == "0" ||
                                            response.rating == "0.0")
                                        ? Container()
                                        : Row(
                                            children: [
                                              RatingBarIndicator(
                                                rating: double.parse(
                                                    response.rating!),
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
                                                " (" + response.noOfRating! + ")",
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
                                                response.min_max_price![
                                                        "max_special_price"]
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
                                          "${response.min_max_price!["max_price"]}",
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
                                    response.time_left!=null&&response.time_left!=""?Text(
                                        response.time_left!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)):SizedBox(),
                                    Container(
                                      height: 50,
                                      width:
                                          MediaQuery.of(context).size.width / 2.3,
                                      child: Html(
                                        data: "${response.shortDescription!}",
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
                                    response.breakfast_start_product_time != null
                                        ? Text(
                                            openStatus == "0"
                                                ? "${response.next_available_text.toString()}"
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
                                    child: response.image!=null&&response.image!=""&&response.image.toString().contains("jpg")||response.image!=null&&response.image!=""&&response.image.toString().contains("png")?commonHWImage(
                                        response.image.toString(),
                                        120.0,
                                        MediaQuery.of(context).size.width,
                                        "assets/images/placeholder.png",
                                        context,
                                        "assets/images/placeholder.png"):Image.asset("assets/images/placeholder.png"),
                                  ),
                                ),
                              ),
                              response.prVarientList![0].cartCount == "0"
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
                                              showToast(response
                                                  .next_available_text
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
                                                print(
                                                    response.quantity_step_size);
                                              // addToCart(
                                              //     index,
                                              //     (int.parse(response["data"][index]["variants"][0]["cart_count"])
                                              //         + int.parse(
                                              //             response["data"][index]["quantity_step_size"]))
                                              //         .toString(), response["data"][index]);

                                              addToCart(
                                                  index,
                                                  (int.parse(response
                                                              .prVarientList![0]
                                                              .cartCount!) +
                                                          int.parse(response
                                                              .quantity_step_size!))
                                                      .toString(),
                                                  response);
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
                                                response.availability == "0"
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
                                                            index, response);
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
                                                            child: Text(response
                                                                .prVarientList![0]
                                                                .cartCount!)),
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
                                                      print(response.totalAllow);
                                                      if(response.totalAllow!=null&&int.parse(response
                                                          .prVarientList![
                                                      0]
                                                          .cartCount!)==int.parse(response.totalAllow!)){
                                                          setSnackbar("Total Allowed Quantity ${response.totalAllow!}", context);
                                                        return;
                                                      }
                                                      if (context
                                                              .read<
                                                                  CartProvider>()
                                                              .isProgress ==
                                                          false)
                                                        addToCart(
                                                            index,
                                                            (int.parse(response
                                                                        .prVarientList![
                                                                            0]
                                                                        .cartCount!)
                                                                    // model
                                                                    // .prVarientList![model
                                                                    // .selVarient!]
                                                                    // .cartCount!)
                                                                    +
                                                                    int.parse(response
                                                                        .quantity_step_size
                                                                        .toString()))
                                                                .toString(),
                                                            response);
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
                ],
              ),
            ),
        )
        : SizedBox(
            height: 0,
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
    Product model = response;
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => ProductDetail(
    //           index: index,
    //           model: model,
    //           secPos: 0,
    //           list: false,
    //           sellerId: widget.sellerID,
    //         )));
  }

  int selectedIndex = 0;
  _dialogBuilder(BuildContext context, List<SubCatModel> subCatData) {
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
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subCatData.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    selectedIndex = index;
                    //   jump(index);
                    Navigator.pop(context);
                    setState(() {
                      height1 = 0;
                    });
                    itemScrollController.scrollTo(
                        index: selectedIndex,
                        duration: Duration(seconds: 2),
                        curve: Curves.easeInOutCubic);
                    /*  sCon.animateTo(200,   duration: Duration(seconds: 1),
                        curve: Curves.easeInOutCubic);*/
                    /*  setState(() {
                      itemScrollController.scrollTo(
                          index: selectedIndex,
                          duration: Duration(seconds: 2),
                          curve: Curves.easeInOutCubic);
                    });*/
                  },
                  child: ListTile(
                    title: Text(
                      '${subCatData[index].name.toString()}',
                      overflow: TextOverflow.ellipsis,
                      // : '${subCatData[index]["name"].toString()}',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
        );
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
    productStream.close();
    productStreamController.close();
    super.dispose();
  }


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
        */
/*actions: <Widget>[
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
        ],*/ /*
      );
    },
  );
}*/
