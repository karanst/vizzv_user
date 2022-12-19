import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Cashfree.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:paytm/paytm.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/SimBtn.dart';
import '../Helper/String.dart';
import '../Helper/Stripe_Service.dart';
import '../Model/Model.dart';
import '../Model/Section_Model.dart';
import '../Model/User.dart';
import 'Add_Address.dart';
import 'Manage_Address.dart';
import 'Order_Success.dart';
import 'Payment.dart';
import 'PaypalWebviewActivity.dart';



class Cart extends StatefulWidget {
  final bool fromBottom;

  const Cart({Key? key, required this.fromBottom}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}
/*String gpayEnv = "TEST",
    gpayCcode = "US",
    gpaycur = "USD",
    gpayMerId = "01234567890123456789",
    gpayMerName = "Example Merchant Name";*/

class _CartState extends State<Cart> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  new GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<ScaffoldMessengerState> _checkscaffoldKey =
  new GlobalKey<ScaffoldMessengerState>();
  List<Model> deliverableList = [];
  bool _isCartLoad = true,
      _placeOrder = true;

  //HomePage? home;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  List<TextEditingController> _controller = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  List<SectionModel> saveLaterList = [];
  String? msg;
  bool _isLoading = true;
  Razorpay? _razorpay;
  TextEditingController promoC = new TextEditingController();
  TextEditingController noteC = new TextEditingController();
  StateSetter? checkoutState;

  //final paystackPlugin = PaystackPlugin();
  bool deliverable = false;
  bool deliverableRadius = false;
  bool saveLater = false,
      addCart = false;

  double itemLat = 0.0;
  double itemLong = 0.0;
  String? cartCount;

  var sellerId;
  bool isExtra = false;
  String showDelCharge = "";

  //List<PaymentItem> _gpaytItems = [];
  //Pay _gpayClient;
  AnimationController? _resizableController;

  static Color? colorVariation(int note) {
    if (note <= 1) {
      return Colors.blue[50];
    } else if (note > 1 && note <= 2) {
      return Colors.blue[100];
    } else if (note > 2 && note <= 3) {
      return Colors.blue[200];
    } else if (note > 3 && note <= 4) {
      return Colors.blue[300];
    } else if (note > 4 && note <= 5) {
      return Colors.blue[400];
    } else if (note > 5 && note <= 6) {
      return Colors.blue;
    } else if (note > 6 && note <= 7) {
      return Colors.blue[600];
    } else if (note > 7 && note <= 8) {
      return Colors.blue[700];
    } else if (note > 8 && note <= 9) {
      return Colors.blue[800];
    } else if (note > 9 && note <= 10) {
      return Colors.blue[900];
    }
  }

  String? sellerName;

  @override
  void initState() {
    super.initState();
    isPromoValid = false;
    promoAmt = 0;
    promocode = null;
    promoC.text = '';
    _resizableController = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 500,
      ),
    );
    _resizableController!.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _resizableController!.reverse();
          break;
        case AnimationStatus.dismissed:
          _resizableController!.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _resizableController!.forward();
    selectedAddress = null;
    //clearAll();
    _checkShop();
    _getAddress();
    //  _getSaveLater("1");

    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 400), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  Future<Null> _refresh() {
    if (mounted)
      setState(() {
        _isCartLoad = true;
      });
    clearAll();

    _getCart("0");
    return _getSaveLater("1");
  }

  clearAll() {
    totalPrice = 0;
    oriPrice = 0;

    taxPer = 0;
    delCharge = 0;
    addressList.clear();
    // cartList.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CartProvider>().setCartlist([]);
      context.read<CartProvider>().setProgress(false);
    });

    promoAmt = 0;
    remWalBal = 0;
    usedBal = 0;
    payMethod = '';
    isPromoValid = false;
    isUseWallet = false;
    isPayLayShow = true;
    selectedMethod = null;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    _resizableController!.dispose();
    for (int i = 0; i < _controller.length; i++)
      _controller[i].dispose();

    if (_razorpay != null) _razorpay!.clear();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
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
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return Future.value();
      },
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
            appBar: widget.fromBottom
                ? null
                : AppBar(
              elevation: 0,
              titleSpacing: 0,
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .white,
              leading: Builder(builder: (BuildContext context) {
                return Container(
                  margin: EdgeInsets.all(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      if (cartCount == "0") {
                        Navigator.pop(context, true);
                      } else {
                        Navigator.pop(context, true);
                      }
                    },
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: colors.primary,
                      ),
                    ),
                  ),
                );
              }),
              title: Text(
                "Cart",
                style: TextStyle(
                    color: colors.primary, fontWeight: FontWeight.normal),
              ),
            ),
            //getSimpleAppBar(getTranslated(context, 'CART')!, context),
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
              ],
            )
                : noInternet(context)),
      ),
    );
  }

  Widget listItem(int index, SectionModel cartModel) {
    int selectedPos = 0;
    for (int i = 0;
    i < cartModel.productList![0].prVarientList!.length;
    i++) {
      if (cartModel.varientId ==
          cartModel.productList![0].prVarientList![i].id) selectedPos = i;
    }
    String? offPer;
    double price = double.parse(cartModel
        .productList![0]
        .
    // totalSpecialPrice.toString());
    prVarientList![selectedPos]
        .disPrice!);
    if (price == 0)
      price = double.parse(
          cartModel.productList![0].totalSpecialPrice.toString()
        //  prVarientList![selectedPos].price!
      );
    else {
      double off = (double.parse(cartModel
          .productList![0]
          .prVarientList![selectedPos]
          .price!)) -
          price;
      offPer = (off *
          100 /
          double.parse(cartModel
              .productList![0]
              .prVarientList![selectedPos]
              .price!))
          .toStringAsFixed(2);
    }
    cartModel.perItemPrice = price.toString();
    print("cartList**avail****${cartModel.productList![0].availability}");

    if (_controller.length < index + 1) {
      _controller.add(new TextEditingController());
    }
    if (cartModel.productList![0].availability != "0") {
      cartModel.perItemTotal =
          (price * double.parse(cartModel.qty!)).toString();
      _controller[index].text = cartModel.qty!;
    }
    List att = [],
        val = [];
    if (cartModel.productList![0].prVarientList![selectedPos].attr_name !=
        null) {
      att = cartModel
          .productList![0]
          .prVarientList![selectedPos]
          .attr_name!
          .split(',');
      val = cartModel
          .productList![0]
          .prVarientList![selectedPos]
          .varient_value!
          .split(',');
    }

    if (cartModel.productList![0].availability == "0") {
      isAvailable = false;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 2,
              ),
              // Hero(
              //     tag: "$index${cartModel.productList![0].id}",
              //     child: Stack(
              //       children: [
              //         ClipRRect(
              //             borderRadius: BorderRadius.circular(7.0),
              //             child: Stack(children: [
              //               // Card(
              //               //   child: Container(
              //               //     width: 120,
              //               //     height: 100,
              //               //     child: FadeInImage(
              //               //       image: CachedNetworkImageProvider(
              //               //           cartModel
              //               //               .productList![0]
              //               //               .image!),
              //               //       height: 125.0,
              //               //       width: 110.0,
              //               //       fit: BoxFit.contain,
              //               //       imageErrorBuilder:
              //               //           (context, error, stackTrace) =>
              //               //               erroWidget(125),
              //               //       placeholder: placeHolder(125),
              //               //     ),
              //               //   ),
              //               // ),
              //               Positioned.fill(
              //                   child: cartModel
              //                               .productList![0]
              //                               .availability ==
              //                           "0"
              //                       ? Container(
              //                           height: 55,
              //                           color: Colors.white70,
              //                           // width: double.maxFinite,
              //                           padding: EdgeInsets.all(2),
              //                           child: Center(
              //                             child: Text(
              //                               getTranslated(context,
              //                                   'OUT_OF_STOCK_LBL')!,
              //                               style: Theme.of(context)
              //                                   .textTheme
              //                                   .caption!
              //                                   .copyWith(
              //                                     color: Colors.red,
              //                                     fontWeight:
              //                                         FontWeight.bold,
              //                                   ),
              //                               textAlign: TextAlign.center,
              //                             ),
              //                           ),
              //                         )
              //                       : Container()),
              //             ])),
              //         offPer != null
              //             ? Container(
              //                 decoration: BoxDecoration(
              //                     color: colors.red,
              //                     borderRadius: BorderRadius.circular(10)),
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(5.0),
              //                   child: Text(
              //                     offPer + "%",
              //                     style: TextStyle(
              //                         color: colors.whiteTemp,
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 9),
              //                   ),
              //                 ),
              //                 margin: EdgeInsets.all(5),
              //               )
              //             : Container()
              //       ],
              //     )),
              Padding(
                padding: const EdgeInsetsDirectional.all(3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        cartModel
                            .productList![0]
                            .indicator
                            .toString() ==
                            "0"
                            ? SizedBox(
                          width: 12,
                        )
                            : cartModel
                            .productList![0]
                            .indicator
                            .toString() ==
                            "1"
                            ? Image.asset(
                          "assets/images/veg.png",
                          height: 15,
                        )
                            : cartModel
                            .productList![0]
                            .indicator
                            .toString() ==
                            "2"
                            ? Image.asset(
                          "assets/images/non_veg.jpg",
                          height: 15,
                        )
                            : Image.asset(
                          "assets/images/egg.png",
                          height: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: 130,
                          child: Text(
                            cartModel.productList![0].name!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .fontColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // GestureDetector(
                        //   child: Padding(
                        //     padding: const EdgeInsetsDirectional.only(
                        //         start: 8.0, end: 8, bottom: 8),
                        //     child: Icon(
                        //       Icons.clear,
                        //       size: 20,
                        //       color:
                        //           Theme.of(context).colorScheme.fontColor,
                        //     ),
                        //   ),
                        //   onTap: () {
                        //     print(index);
                        //     print(cartList);
                        //     print(selectedPos);
                        //     if (context.read<CartProvider>().isProgress ==
                        //         false)
                        //       removeFromCart(index, true, cartList, false,
                        //           selectedPos);
                        //   },
                        // )
                      ],
                    ),
                    cartModel
                        .productList![0]
                        .prVarientList![selectedPos]
                        .attr_name !=
                        null &&
                        cartModel
                            .productList![0]
                            .prVarientList![selectedPos]
                            .attr_name!
                            .isNotEmpty
                        ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: att.length,
                        itemBuilder: (context, index) {
                          return Row(children: [
                            Flexible(
                              child: Text(
                                att[index].trim() + ":",
                                overflow: TextOverflow.ellipsis,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .lightBlack,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsetsDirectional.only(start: 5.0),
                              child: Text(
                                val[index],
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .lightBlack,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ]);
                        })
                        : Container(),
                    /* Row(
                  children: <Widget>[
                    Text(
                      double.parse(cartModel
                                  .productList![0]
                                  .prVarientList![selectedPos]
                                  .disPrice!) !=
                              0
                          ? CUR_CURRENCY! +
                              "" +
                              cartModel
                                  .productList![0]
                                  .prVarientList![selectedPos]
                                  .price!
                          : "",
                      style: Theme.of(context)
                          .textTheme
                          .overline!
                          .copyWith(
                              decoration: TextDecoration.lineThrough,
                              letterSpacing: 0.7),
                    ),
                    Text(
                      " " + CUR_CURRENCY! + " " + price.toString(),
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),*/
                    cartModel
                        .productList![0]
                        .packing_charge
                        .toString() ==
                        "" ||
                        cartModel.productList![0].packing_charge ==
                            null
                        ? Container()
                        : Row(
                      children: [
                        Text(
                          getTranslated(context, 'PACKING_CRG')!,
                          style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .lightBlack2),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          CUR_CURRENCY! +
                              " " +
                              cartModel
                                  .productList![0]
                                  .packing_charge
                                  .toString(),
                          style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .lightBlack2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: colors.grad1Color,
                      )),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                          ),
                        ),
                        onTap: () {
                          if (context
                              .read<CartProvider>()
                              .isProgress ==
                              false) if (cartModel.qty.toString() == "1") {
                            removeFromCart(
                                index,
                                // (int.parse(cartModel.qty!) -
                                //     int.parse(cartModel
                                //         .productList![0]
                                //         .qtyStepSize!)),
                                true,
                                cartList,
                                true,
                                selectedPos);
                          }
                          /* else if (cartModel.qty.toString() == "1") {
                            removeFromCart(
                                index,
                                // (int.parse(cartModel.qty!) -
                                //     int.parse(cartModel
                                //         .productList![0]
                                //         .qtyStepSize!)),
                                true,
                                cartList,
                                true,
                                selectedPos);
                            // Future.delayed(Duration(seconds: 2),(){
                            //   _refresh();
                            // });

                          }*/ else {
                            removeFromCart(
                                index,
                                // (int.parse(cartModel.qty!) -
                                //     int.parse(cartModel
                                //         .productList![0]
                                //         .qtyStepSize!)),
                                false,
                                cartList,
                                true,
                                selectedPos);
                          }
                          // index, false, cartList, false, selectedPos);
                        },
                      ),

                      Container(
                        width: 26,
                        height: 20,
                        child: Text(
                          cartModel.qty!,
                          textAlign: TextAlign.center,
                          //price.toString(),
                          style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .fontColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      /* Container(
                        width: 26,
                        height: 20,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.fontColor),
                          initialValue: cartModel.qty!,
                         // controller: _controller[index],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),*/
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.add,
                            size: 16,
                          ),
                        ),
                        onTap: () {
                          if (cartModel
                              .productList![0].totalAllow != null && int.parse(
                              cartModel.qty!) == int.parse(cartModel
                              .productList![0].totalAllow!)) {
                            setSnackbar("Total Allowed Quantity ${cartModel
                                .productList![0].totalAllow!}", _scaffoldKey);
                            return;
                          }
                          if (context
                              .read<CartProvider>()
                              .isProgress ==
                              false)
                            addToCart(
                                index,
                                (int.parse(cartModel.qty!) +
                                    int.parse(cartModel
                                        .productList![0]
                                        .qtyStepSize!))
                                    .toString(),
                                cartList);
                        },
                      )
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 60,
                  child: Column(
                    children: <Widget>[
                      /*Text(
                        double.parse(cartModel
                                    .productList![0]
                                    .prVarientList![selectedPos]
                                    .disPrice!) !=
                                0
                            ? CUR_CURRENCY! +
                                "" +
                                cartModel
                                    .productList![0].prVarientList![selectedPos]
                                    .price!
                            : "",
                        style: Theme.of(context).textTheme.overline!.copyWith(
                            decoration: TextDecoration.lineThrough,
                            letterSpacing: 0.7),
                      ),*/
                      Text(
                        " " +
                            CUR_CURRENCY! +
                            " " +
                            cartModel
                                .productList![0]
                                .totalSpecialPrice
                                .toString(),
                        //price.toString(),
                        style: TextStyle(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .fontColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget listItem1(int index, List<SectionModel> cartList) {
    int selectedPos = 0;
    for (int i = 0;
    i < cartList[index].productList![0].prVarientList!.length;
    i++) {
      if (cartList[index].varientId ==
          cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
    }
    String? offPer;
    double price = double.parse(cartList[index]
        .productList![0]
        .
    // totalSpecialPrice.toString());
    prVarientList![selectedPos]
        .disPrice!);
    if (price == 0)
      price = double.parse(
          cartList[index].productList![0].totalSpecialPrice.toString()
        //  prVarientList![selectedPos].price!
      );
    else {
      double off = (double.parse(cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .price!)) -
          price;
      offPer = (off *
          100 /
          double.parse(cartList[index]
              .productList![0]
              .prVarientList![selectedPos]
              .price!))
          .toStringAsFixed(2);
    }
    cartList[index].perItemPrice = price.toString();
    print("cartList**avail****${cartList[index].productList![0].availability}");

    if (_controller.length < index + 1) {
      _controller.add(new TextEditingController());
    }
    if (cartList[index].productList![0].availability != "0") {
      cartList[index].perItemTotal =
          (price * double.parse(cartList[index].qty!)).toString();
      _controller[index].text = cartList[index].qty!;
    }
    List att = [],
        val = [];
    if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
        null) {
      att = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .attr_name!
          .split(',');
      val = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .varient_value!
          .split(',');
    }

    if (cartList[index].productList![0].availability == "0") {
      isAvailable = false;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 2,
              ),
              // Hero(
              //     tag: "$index${cartList[index].productList![0].id}",
              //     child: Stack(
              //       children: [
              //         ClipRRect(
              //             borderRadius: BorderRadius.circular(7.0),
              //             child: Stack(children: [
              //               // Card(
              //               //   child: Container(
              //               //     width: 120,
              //               //     height: 100,
              //               //     child: FadeInImage(
              //               //       image: CachedNetworkImageProvider(
              //               //           cartList[index]
              //               //               .productList![0]
              //               //               .image!),
              //               //       height: 125.0,
              //               //       width: 110.0,
              //               //       fit: BoxFit.contain,
              //               //       imageErrorBuilder:
              //               //           (context, error, stackTrace) =>
              //               //               erroWidget(125),
              //               //       placeholder: placeHolder(125),
              //               //     ),
              //               //   ),
              //               // ),
              //               Positioned.fill(
              //                   child: cartList[index]
              //                               .productList![0]
              //                               .availability ==
              //                           "0"
              //                       ? Container(
              //                           height: 55,
              //                           color: Colors.white70,
              //                           // width: double.maxFinite,
              //                           padding: EdgeInsets.all(2),
              //                           child: Center(
              //                             child: Text(
              //                               getTranslated(context,
              //                                   'OUT_OF_STOCK_LBL')!,
              //                               style: Theme.of(context)
              //                                   .textTheme
              //                                   .caption!
              //                                   .copyWith(
              //                                     color: Colors.red,
              //                                     fontWeight:
              //                                         FontWeight.bold,
              //                                   ),
              //                               textAlign: TextAlign.center,
              //                             ),
              //                           ),
              //                         )
              //                       : Container()),
              //             ])),
              //         offPer != null
              //             ? Container(
              //                 decoration: BoxDecoration(
              //                     color: colors.red,
              //                     borderRadius: BorderRadius.circular(10)),
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(5.0),
              //                   child: Text(
              //                     offPer + "%",
              //                     style: TextStyle(
              //                         color: colors.whiteTemp,
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 9),
              //                   ),
              //                 ),
              //                 margin: EdgeInsets.all(5),
              //               )
              //             : Container()
              //       ],
              //     )),
              Padding(
                padding: const EdgeInsetsDirectional.all(3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        cartList[index]
                            .productList![0]
                            .indicator
                            .toString() ==
                            "0"
                            ? SizedBox(
                          width: 12,
                        )
                            : cartList[index]
                            .productList![0]
                            .indicator
                            .toString() ==
                            "1"
                            ? Image.asset(
                          "assets/images/veg.png",
                          height: 15,
                        )
                            : cartList[index]
                            .productList![0]
                            .indicator
                            .toString() ==
                            "2"
                            ? Image.asset(
                          "assets/images/non_veg.jpg",
                          height: 15,
                        )
                            : Image.asset(
                          "assets/images/egg.png",
                          height: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: 130,
                          child: Text(
                            cartList[index].productList![0].name!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .fontColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // GestureDetector(
                        //   child: Padding(
                        //     padding: const EdgeInsetsDirectional.only(
                        //         start: 8.0, end: 8, bottom: 8),
                        //     child: Icon(
                        //       Icons.clear,
                        //       size: 20,
                        //       color:
                        //           Theme.of(context).colorScheme.fontColor,
                        //     ),
                        //   ),
                        //   onTap: () {
                        //     print(index);
                        //     print(cartList);
                        //     print(selectedPos);
                        //     if (context.read<CartProvider>().isProgress ==
                        //         false)
                        //       removeFromCart(index, true, cartList, false,
                        //           selectedPos);
                        //   },
                        // )
                      ],
                    ),
                    cartList[index]
                        .productList![0]
                        .prVarientList![selectedPos]
                        .attr_name !=
                        null &&
                        cartList[index]
                            .productList![0]
                            .prVarientList![selectedPos]
                            .attr_name!
                            .isNotEmpty
                        ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: att.length,
                        itemBuilder: (context, index) {
                          return Row(children: [
                            Flexible(
                              child: Text(
                                att[index].trim() + ":",
                                overflow: TextOverflow.ellipsis,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .lightBlack,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsetsDirectional.only(start: 5.0),
                              child: Text(
                                val[index],
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .lightBlack,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ]);
                        })
                        : Container(),
                    /* Row(
                  children: <Widget>[
                    Text(
                      double.parse(cartList[index]
                                  .productList![0]
                                  .prVarientList![selectedPos]
                                  .disPrice!) !=
                              0
                          ? CUR_CURRENCY! +
                              "" +
                              cartList[index]
                                  .productList![0]
                                  .prVarientList![selectedPos]
                                  .price!
                          : "",
                      style: Theme.of(context)
                          .textTheme
                          .overline!
                          .copyWith(
                              decoration: TextDecoration.lineThrough,
                              letterSpacing: 0.7),
                    ),
                    Text(
                      " " + CUR_CURRENCY! + " " + price.toString(),
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),*/
                    cartList[index]
                        .productList![0]
                        .packing_charge
                        .toString() ==
                        "" ||
                        cartList[index].productList![0].packing_charge ==
                            null
                        ? Container()
                        : Row(
                      children: [
                        Text(
                          getTranslated(context, 'PACKING_CRG')!,
                          style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .lightBlack2),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          CUR_CURRENCY! +
                              " " +
                              cartList[index]
                                  .productList![0]
                                  .packing_charge
                                  .toString(),
                          style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .lightBlack2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: colors.grad1Color,
                      )),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                          ),
                        ),
                        onTap: () {
                          if (context
                              .read<CartProvider>()
                              .isProgress ==
                              false) if (_controller[index].text == "1") {
                            removeFromCart(
                                index,
                                // (int.parse(cartList[index].qty!) -
                                //     int.parse(cartList[index]
                                //         .productList![0]
                                //         .qtyStepSize!)),
                                true,
                                cartList,
                                true,
                                selectedPos);
                          } else if (_controller[0].text == "1") {
                            removeFromCart(
                                index,
                                // (int.parse(cartList[index].qty!) -
                                //     int.parse(cartList[index]
                                //         .productList![0]
                                //         .qtyStepSize!)),
                                true,
                                cartList,
                                true,
                                selectedPos);
                            // Future.delayed(Duration(seconds: 2),(){
                            //   _refresh();
                            // });

                          } else {
                            removeFromCart(
                                index,
                                // (int.parse(cartList[index].qty!) -
                                //     int.parse(cartList[index]
                                //         .productList![0]
                                //         .qtyStepSize!)),
                                false,
                                cartList,
                                true,
                                selectedPos);
                          }
                          // index, false, cartList, false, selectedPos);
                        },
                      ),
                      Container(
                        width: 26,
                        height: 20,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .fontColor),
                          initialValue: cartList[index].qty!,
                          // controller: _controller[index],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.add,
                            size: 16,
                          ),
                        ),
                        onTap: () {
                          if (context
                              .read<CartProvider>()
                              .isProgress ==
                              false)
                            addToCart(
                                index,
                                (int.parse(cartList[index].qty!) +
                                    int.parse(cartList[index]
                                        .productList![0]
                                        .qtyStepSize!))
                                    .toString(),
                                cartList);
                        },
                      )
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 60,
                  child: Column(
                    children: <Widget>[
                      /*Text(
                        double.parse(cartList[index]
                                    .productList![0]
                                    .prVarientList![selectedPos]
                                    .disPrice!) !=
                                0
                            ? CUR_CURRENCY! +
                                "" +
                                cartList[index]
                                    .productList![0].prVarientList![selectedPos]
                                    .price!
                            : "",
                        style: Theme.of(context).textTheme.overline!.copyWith(
                            decoration: TextDecoration.lineThrough,
                            letterSpacing: 0.7),
                      ),*/
                      Text(
                        " " +
                            CUR_CURRENCY! +
                            " " +
                            cartList[index]
                                .productList![0]
                                .totalSpecialPrice
                                .toString(),
                        //price.toString(),
                        style: TextStyle(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .fontColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget cartItem(int index, List<SectionModel> cartList) {
    int selectedPos = 0;
    for (int i = 0;
    i < cartList[index].productList![0].prVarientList!.length;
    i++) {
      if (cartList[index].varientId ==
          cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
    }

    double price = double.parse(
        cartList[index].productList![0].prVarientList![selectedPos].disPrice!);
    if (price == 0)
      price = double.parse(
          cartList[index].productList![0].prVarientList![selectedPos].price!);

    var pack = cartList[index].productList![0].packing_charge.toString() ==
        "" ||
        cartList[index].productList![0].packing_charge == null
        ? "0.0"
        : (double.parse(
        cartList[index].productList![0].packing_charge.toString()) *
        double.parse(cartList[index].qty.toString()))
        .toStringAsFixed(2);
    cartList[index].perItemPrice = price.toString();
    cartList[index].perItemTotal =
        (price * double.parse(cartList[index].qty!)).toString();
    itemTotal = (double.parse(cartList[index].perItemTotal.toString()) +
        double.parse(pack))
        .toString();

    _controller[index].text = cartList[index].qty!;

    List att = [],
        val = [];
    if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
        null) {
      att = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .attr_name!
          .split(',');
      val = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .varient_value!
          .split(',');
    }

    String? id, varId;
    bool? avail = false;
    if (deliverableList.length > 0) {
      id = cartList[index].id;
      varId = cartList[index].productList![0].prVarientList![selectedPos].id;

      for (int i = 0; i < deliverableList.length; i++) {
        if (id == deliverableList[i].prodId &&
            varId == deliverableList[i].varId) {
          avail = deliverableList[i].isDel;

          break;
        }
      }
    }

    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                // Hero(
                //     tag: "$index${cartList[index].productList![0].id}",
                //     child: ClipRRect(
                //         borderRadius: BorderRadius.circular(7.0),
                //         child: FadeInImage(
                //           image: CachedNetworkImageProvider(
                //               cartList[index].productList![0].image!),
                //           height: 80.0,
                //           width: 80.0,
                //           fit: BoxFit.cover,
                //           imageErrorBuilder: (context, error, stackTrace) =>
                //               erroWidget(80),
                //           placeholder: placeHolder(80),
                //         ))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 150,
                              padding:
                              const EdgeInsetsDirectional.only(top: 5.0),
                              child: Text(
                                cartList[index].productList![0].name!,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .lightBlack),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              " " + CUR_CURRENCY! + " " + price.toString(),
                              style: TextStyle(
                                  color:
                                  Theme
                                      .of(context)
                                      .colorScheme
                                      .fontColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            cartList[index].productList![0].availability ==
                                "1" ||
                                cartList[index].productList![0].stockType ==
                                    "null"
                                ? Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: 26,
                                      height: 20,
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        readOnly: true,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme
                                                .of(context)
                                                .colorScheme
                                                .fontColor),
                                        controller: _controller[index],
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                                : Container(),
                            /*    GestureDetector(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 8.0, end: 8, bottom: 8),
                                child: Icon(
                                  Icons.clear,
                                  size: 13,
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                ),
                              ),
                              onTap: () {
                                if (context.read<CartProvider>().isProgress ==
                                    false)
                                  removeFromCartCheckout(index, true, cartList);
                              },
                            )*/
                          ],
                        ),
                        /*  cartList[index]
                                        .productList![0]
                                        .prVarientList![selectedPos]
                                        .attr_name !=
                                    null &&
                                cartList[index]
                                    .productList![0]
                                    .prVarientList![selectedPos]
                                    .attr_name!
                                    .isNotEmpty
                            ? ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: att.length,
                                itemBuilder: (context, index) {
                                  return Row(children: [
                                    Flexible(
                                      child: Text(
                                        att[index].trim() + ":",
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack,
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 5.0),
                                      child: Text(
                                        val[index],
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ]);
                                })
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      double.parse(cartList[index]
                                                  .productList![0]
                                                  .prVarientList![selectedPos]
                                                  .disPrice!) !=
                                              0
                                          ? CUR_CURRENCY! +
                                              "" +
                                              cartList[index]
                                                  .productList![0]
                                                  .prVarientList![selectedPos]
                                                  .price!
                                          : "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .overline!
                                          .copyWith(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              letterSpacing: 0.7),
                                    ),
                                  ),

                                ],
                              ),
                            ),

                          ],
                        ),*/
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'SUBTOTAL')!,
                  style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .lightBlack2),
                ),
                Text(
                  CUR_CURRENCY! + " " + price.toString(),
                  style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .lightBlack2),
                ),
                Text(
                  CUR_CURRENCY! + " " + cartList[index].perItemTotal!,
                  style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .lightBlack2),
                )
              ],
            ),
            cartList[index].productList![0].packing_charge.toString() == ""
                ? Container()
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'PACKING_CRG')!,
                  style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .lightBlack2),
                ),
                cartList[index]
                    .productList![0]
                    .packing_charge
                    .toString() ==
                    "" ||
                    cartList[index].productList![0].packing_charge ==
                        null
                    ? Container()
                    : Text(
                  CUR_CURRENCY! +
                      " " +
                      cartList[index]
                          .productList![0]
                          .packing_charge
                          .toString(),
                  style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .lightBlack2),
                ),
                cartList[index]
                    .productList![0]
                    .packing_charge
                    .toString() ==
                    "" ||
                    cartList[index].productList![0].packing_charge ==
                        null
                    ? Text(
                  CUR_CURRENCY! + " 0",
                  style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .lightBlack2),
                )
                    : Text(
                  CUR_CURRENCY! +
                      " " +
                      (double.parse(cartList[index]
                          .productList![0]
                          .packing_charge
                          .toString()) *
                          double.parse(
                              cartList[index].qty.toString()))
                          .toStringAsFixed(2),
                  style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .lightBlack2),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'TOTAL_LBL')!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .lightBlack2),
                ),
                Text(
                  CUR_CURRENCY! + " " + itemTotal.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .fontColor),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget saveLaterItem(int index) {
    int selectedPos = 0;
    for (int i = 0;
    i < saveLaterList[index].productList![0].prVarientList!.length;
    i++) {
      if (saveLaterList[index].varientId ==
          saveLaterList[index].productList![0].prVarientList![i].id)
        selectedPos = i;
    }

    double price = double.parse(saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .disPrice!);
    if (price == 0) {
      price = double.parse(saveLaterList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .price!);
    }

    double off = (double.parse(saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .price!) -
        double.parse(saveLaterList[index]
            .productList![0]
            .prVarientList![selectedPos]
            .disPrice!))
        .toDouble();
    off = off *
        100 /
        double.parse(saveLaterList[index]
            .productList![0]
            .prVarientList![selectedPos]
            .price!);

    saveLaterList[index].perItemPrice = price.toString();
    if (saveLaterList[index].productList![0].availability != "0") {
      saveLaterList[index].perItemTotal =
          (price * double.parse(saveLaterList[index].qty!)).toString();
    }
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0.1,
              child: Row(
                children: <Widget>[
                  Hero(
                      tag: "$index${saveLaterList[index].productList![0].id}",
                      child: Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(7.0),
                              child: Stack(children: [
                                FadeInImage(
                                  image: CachedNetworkImageProvider(
                                      saveLaterList[index]
                                          .productList![0]
                                          .image!),
                                  height: 100.0,
                                  width: 100.0,
                                  fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                      erroWidget(100),
                                  placeholder: placeHolder(100),
                                ),
                                Positioned.fill(
                                    child: saveLaterList[index]
                                        .productList![0]
                                        .availability ==
                                        "0"
                                        ? Container(
                                      height: 55,
                                      color: Colors.white70,
                                      // width: double.maxFinite,
                                      padding: EdgeInsets.all(2),
                                      child: Center(
                                        child: Text(
                                          getTranslated(context,
                                              'OUT_OF_STOCK_LBL')!,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                            color: Colors.red,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                        : Container()),
                              ])),
                          (off != 0 || off != 0.0 || off != 0.00) &&
                              saveLaterList[index]
                                  .productList![0]
                                  .prVarientList![selectedPos]
                                  .disPrice! !=
                                  "0"
                              ? Container(
                            decoration: BoxDecoration(
                                color: colors.red,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                off.toStringAsFixed(2) + "%",
                                style: TextStyle(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9),
                              ),
                            ),
                            margin: EdgeInsets.all(5),
                          )
                              : Container()
                        ],
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 5.0),
                                  child: Text(
                                    saveLaterList[index].productList![0].name!,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .fontColor),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 8.0, end: 8, bottom: 8),
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color:
                                    Theme
                                        .of(context)
                                        .colorScheme
                                        .fontColor,
                                  ),
                                ),
                                onTap: () {
                                  if (context
                                      .read<CartProvider>()
                                      .isProgress ==
                                      false)
                                    removeFromCart(
                                      // int.parse(cartList[index].qty!) -
                                      // int.parse(cartList[index]
                                      //     .productList![0]
                                      //     .qtyStepSize!)),
                                        index,
                                        false,
                                        saveLaterList,
                                        true,
                                        selectedPos);
                                },
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                double.parse(saveLaterList[index]
                                    .productList![0]
                                    .prVarientList![selectedPos]
                                    .disPrice!) !=
                                    0
                                    ? CUR_CURRENCY! +
                                    "" +
                                    saveLaterList[index]
                                        .productList![0]
                                        .prVarientList![selectedPos]
                                        .price!
                                    : "",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .overline!
                                    .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0.7),
                              ),
                              Text(
                                " " + CUR_CURRENCY! + " " + price.toString(),
                                style: TextStyle(
                                    color:
                                    Theme
                                        .of(context)
                                        .colorScheme
                                        .fontColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            saveLaterList[index].productList![0].availability == "1" ||
                saveLaterList[index].productList![0].stockType == "null"
                ? Positioned(
                bottom: -15,
                right: 0,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.shopping_cart,
                        size: 20,
                      ),
                    ),
                    onTap:
                    !addCart && !context
                        .read<CartProvider>()
                        .isProgress
                        ? () {
                      setState(() {
                        addCart = true;
                      });
                      saveForLater(
                          saveLaterList[index].varientId,
                          "0",
                          saveLaterList[index].qty,
                          double.parse(
                              saveLaterList[index].perItemTotal!),
                          saveLaterList[index],
                          true);
                    }
                        : null,
                  ),
                ))
                : Container()
          ],
        ));
  }

  bool loading = false;

  Future<void> _getCart(String save, {String check = "0"}) async {
    final Distance distance = new Distance();
    var loc = Provider.of<LocationProvider>(context, listen: false);
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};

        Response response =
        await post(getCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print(getdata.toString());
        print(parameter.toString());
        print(getCartApi.toString());
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {

          var data = getdata["data"];
          if (getdata["latitude"] != null && getdata["longitude"] != null) {
            itemLat = double.parse(getdata["latitude"].toString());
            itemLong = double.parse(getdata["longitude"].toString());
            cartCount = getdata['total_quantity'];
            if (addressList.length > 0 && selectedAddress != null) {
              if (itemLong != 0.0 && itemLat != 0.0) {
                final double km = distance.as(
                    LengthUnit.Kilometer,
                    new LatLng(itemLat, itemLong),
                    new LatLng(
                        double.parse(
                            addressList[selectedAddress!].latitude.toString()),
                        double.parse(addressList[selectedAddress!]
                            .longitude
                            .toString())));
                getDeliveryKmsApi(
                    double.parse(
                        addressList[selectedAddress!].latitude.toString()),
                    double.parse(addressList[selectedAddress!]
                        .longitude
                        .toString()), itemLat, itemLong);
                delCharge = await deliveryChargeApi(newKms.toString());


                // delCharge = await deliveryChargeApi(km);
                print("this is kms $km");
              }
            } else {
              if (itemLong != 0.0 && itemLat != 0.0) {
                final double km = distance.as(
                    LengthUnit.Kilometer,
                    new LatLng(itemLat, itemLong),
                    new LatLng(double.parse(loc.lat.toString()),
                        double.parse(loc.lng.toString())));
                delCharge = await deliveryChargeApi(newKms.toString());
              }
            }
          }
          sellerId = data[0]["seller_id"];

          oriPrice = double.parse(getdata[SUB_TOTAL]);
          if (GST_SERVICE_CHARGES != null && GST_SERVICE_CHARGES != "") {
            gstPrice = (oriPrice * double.parse(GST_SERVICE_CHARGES!)) / 100;
          }
          taxPer = double.parse(getdata[TAX_PER]);
          print("$delCharge");

          List<SectionModel> cartList1 = (data as List)
              .map((data) => new SectionModel.fromCart(data))
              .toList();
          context.read<CartProvider>().setProgress(false);
          context.read<CartProvider>().setCartlist(cartList1);
          setState(() {
            cartList = cartList1.toList();
          });
          packagingCharge = 0;
          print("GST SERVICE :=============> $GST_SERVICE_CHARGES");
          for (var i = 0; i < cartList.length; i++) {
            if (cartList[i].productList![0].packing_charge.toString() != "" &&
                cartList[i].productList![0].packing_charge != null) {
              packagingCharge += double.parse(
                  cartList[i].productList![0].packing_charge.toString()) *
                  double.parse(cartList[i].qty.toString());
              oriPrice += double.parse(
                  cartList[i].productList![0].packing_charge.toString()) *
                  double.parse(cartList[i].qty.toString());
              /*    totalPrice +=  double.parse(
                  cartList[i].productList![0].packing_charge.toString())*double.parse(
                  cartList[i].qty.toString());*/
            }
          }
          print("delCharge" + delCharge.toString());
          if (extraDelCharge != 0) {
            totalPrice = delCharge + oriPrice + gstPrice + extraDelCharge;
          } else {
            totalPrice = delCharge + oriPrice + gstPrice;
          }
          if (getdata.containsKey(PROMO_CODES)) {
            var promo = getdata[PROMO_CODES];
            promoList =
                (promo as List).map((e) => new Promo.fromJson(e)).toList();
            // totalPrice = delCharge + oriPrice + gstPrice - promoAmt;
          }

          for (int i = 0; i < cartList.length; i++)
            _controller.add(new TextEditingController());
        }
        else {
          context.read<CartProvider>().setProgress(false);
          if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
        }
        if (mounted)
          setState(() {
            _isCartLoad = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    if (check == "1") {
      List<SectionModel> cartList = context
          .read<CartProvider>()
          .cartList;
      // getDeliveryRadiusApi();
      checkout(cartList);
      // getDeliveryRadiusApi();
      _getExtraDeliveryCharges();
      // if(extraDelCharge == 0 ){
      //   setState((){
      //     extraDelCharge = 0 ;
      //   });
      // }
    }
  }

  bool checkShop = true;

  Future<void> _checkShop() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID};

        Response response =
        await post(checkShopInCart, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.body is! Map) {
          return;
        }
        var getdata = json.decode(response.body);
        print(getdata.toString());
        print(parameter.toString());
        print(getCartApi.toString());
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          checkShop = true;
        } else {
          checkShop = false;
          setSnackbar(msg!, _scaffoldKey);
        }
        if (mounted)
          setState(() {
            //_isCartLoad = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  promoSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
                  child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 50),
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery
                              .of(context)
                              .size
                              .height * 0.9),
                      child: ListView(shrinkWrap: true, children: <Widget>[
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            Container(
                                margin: const EdgeInsetsDirectional.only(
                                    end: 20),
                                decoration: BoxDecoration(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .white,
                                    borderRadius:
                                    BorderRadiusDirectional.circular(10)),
                                child: TextField(
                                  controller: promoC,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .subtitle2,
                                  decoration: InputDecoration(
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                    border: InputBorder.none,
                                    //isDense: true,
                                    hintText:
                                    getTranslated(context, 'PROMOCODE_LBL'),
                                  ),
                                )),
                            Positioned.directional(
                              textDirection: Directionality.of(context),
                              end: 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  (promoAmt != 0 && isPromoValid!)
                                      ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      child: Icon(
                                        Icons.close,
                                        size: 15,
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .fontColor,
                                      ),
                                      onTap: () {
                                        if (promoAmt != 0 && isPromoValid!) {
                                          if (mounted)
                                            setState(() {
                                              totalPrice =
                                                  totalPrice + promoAmt;
                                              promoC.text = '';
                                              isPromoValid = false;
                                              promoAmt = 0;
                                              promocode = '';
                                            });
                                        }
                                      },
                                    ),
                                  )
                                      : Container(),
                                  InkWell(
                                    child: Container(
                                        padding: EdgeInsets.all(11),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colors.primary,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color:
                                          Theme
                                              .of(context)
                                              .colorScheme
                                              .white,
                                        )),
                                    onTap: () {
                                      if (promoC.text
                                          .trim()
                                          .isEmpty)
                                        setSnackbar(
                                            getTranslated(
                                                context, 'ADD_PROMO')!,
                                            _checkscaffoldKey);
                                      else if (!isPromoValid!) {
                                        validatePromo(false);
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Text(
                            getTranslated(context, 'Choose_PROMO') ?? '',
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .fontColor),
                          ),
                        ),
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: promoList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 0,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 80,
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              7.0),
                                          child: Image.network(
                                            promoList[index].image!,
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.fill,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                erroWidget(
                                                  80,
                                                ),
                                          )),
                                    ),
                                    //errorWidget: (context, url, e) => placeHolder(width),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(promoList[index].msg ?? ""),
                                            Text(promoList[index].promoCode ??
                                                ''),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(promoList[index].day ?? ''),
                                    SimBtn(
                                      size: 0.3,
                                      title: getTranslated(context, "APPLY"),
                                      onBtnSelected: () {
                                        promoC.text =
                                        promoList[index].promoCode!;
                                        if (!isPromoValid!) validatePromo(
                                            false);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ])),
                );
                //});
              });
        });
  }

  Future<Null> _getSaveLater(String save) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
        Response response =
        await post(getCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          saveLaterList = (data as List)
              .map((data) => new SectionModel.fromCart(data))
              .toList();

          List<SectionModel> cartList = context
              .read<CartProvider>()
              .cartList;
          for (int i = 0; i < cartList.length; i++)
            _controller.add(new TextEditingController());
        } else {
          if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
        }
        if (mounted) setState(() {});
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }

    return null;
  }

  Future<void> addToCart(int index, String qty,
      List<SectionModel> cartList1) async {
    _isNetworkAvail = await isNetworkAvailable();

    //if (int.parse(qty) >= cartList[index].productList[0].minOrderQuntity) {
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
          qty = cartList[index].productList![0].minOrderQuntity.toString();
          setSnackbar(
              "${getTranslated(context, 'MIN_MSG')}$qty", _checkscaffoldKey);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
          "seller_id": "$sellerId"
        };
        Response response =
        await post(manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          isPromoValid = false;
          promoAmt = 0;
          promocode = null;
          promoC.text = '';
          String qty = data['total_quantity'];
          //CUR_CART_COUNT = data['cart_count'];
          context.read<UserProvider>().setCartCount(data['total_items']);

          oriPrice = double.parse(data['sub_total']);
          if (GST_SERVICE_CHARGES != null && GST_SERVICE_CHARGES != "") {
            gstPrice = (oriPrice * double.parse(GST_SERVICE_CHARGES!)) / 100;
          }
          _controller[index].text = qty;
          totalPrice = 0;

          var cart = getdata["cart"];
          List<SectionModel> uptcartList = (cart as List)
              .map((cart) => new SectionModel.fromCart(cart))
              .toList();
          context.read<CartProvider>().setCartlist(uptcartList);
          setState(() {
            cartList = uptcartList.toList();
          });

          // if (!ISFLAT_DEL) {
          //   if (addressList.length == 0) {
          //     // delCharge = 0;
          //   } else {
          //     // if ((oriPrice) <
          //     //     double.parse(addressList[selectedAddress!].freeAmt!))
          //     //   delCharge =
          //     //       double.parse(addressList[selectedAddress!].deliveryCharge!);
          //     // else
          //     //   delCharge = 0;
          //   }
          // } else {
          //   // if (oriPrice < double.parse(MIN_AMT!))
          //   //   delCharge = double.parse(CUR_DEL_CHR!);
          //   // else
          //   //   delCharge = 0;
          // }
          packagingCharge = 0;
          for (var i = 0; i < cartList.length; i++) {
            if (cartList[i].productList![0].packing_charge.toString() != "" &&
                cartList[i].productList![0].packing_charge != null) {
              packagingCharge += double.parse(
                  cartList[i].productList![0].packing_charge.toString()) *
                  double.parse(cartList[i].qty.toString());
              oriPrice += double.parse(
                  cartList[i].productList![0].packing_charge.toString()) *
                  double.parse(cartList[i].qty.toString());
            }
          }
          print("delChargher" + delCharge.toString());
          totalPrice = delCharge + oriPrice + gstPrice;

          if (isPromoValid!) {
            validatePromo(false);
          } else if (isUseWallet!) {
            context.read<CartProvider>().setProgress(false);
            if (mounted)
              setState(() {
                remWalBal = 0;
                payMethod = null;
                usedBal = 0;
                isUseWallet = false;
                isPayLayShow = true;
                selectedMethod = null;
              });
          } else {
            setState(() {});
            context.read<CartProvider>().setProgress(false);
          }
        } else {
          setSnackbar(msg!, _scaffoldKey);
          context.read<CartProvider>().setProgress(false);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    // } else
    // setSnackbar(
    //     "Minimum allowed quantity is ${cartList[index].productList[0].minOrderQuntity} ",
    //     _scaffoldKey);
  }

  Future<void> addToCartCheckout(int index, String qty,
      List<SectionModel> cartList) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
          qty = cartList[index].productList![0].minOrderQuntity.toString();

          setSnackbar(
              "${getTranslated(context, 'MIN_MSG')}$qty", _checkscaffoldKey);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
          "seller_id": "$sellerId"
        };

        Response response =
        await post(manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            cartList[index].qty = qty;

            oriPrice = double.parse(data['sub_total']) + gstPrice;
            if (GST_SERVICE_CHARGES != null && GST_SERVICE_CHARGES != "") {
              gstPrice = (oriPrice * double.parse(GST_SERVICE_CHARGES!)) / 100;
            }
            _controller[index].text = qty;
            totalPrice = 0;

            if (!ISFLAT_DEL) {
              // if ((oriPrice) <
              //     double.parse(addressList[selectedAddress!].freeAmt!))
              //   delCharge =
              //       double.parse(addressList[selectedAddress!].deliveryCharge!);
              // else
              //   delCharge = 0;
            } else {
              // if ((oriPrice) < double.parse(MIN_AMT!))
              //   delCharge = double.parse(CUR_DEL_CHR!);
              // else
              //   delCharge = 0;
            }
            totalPrice = delCharge + oriPrice + gstPrice;

            if (isPromoValid!) {
              validatePromo(true);
            } else if (isUseWallet!) {
              if (mounted)
                checkoutState!(() {
                  remWalBal = 0;
                  payMethod = null;
                  usedBal = 0;
                  isUseWallet = false;
                  isPayLayShow = true;

                  selectedMethod = null;
                });
              setState(() {});
            } else {
              context.read<CartProvider>().setProgress(false);
              setState(() {});
              checkoutState!(() {});
            }
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        checkoutState!(() {
          _isNetworkAvail = false;
        });
      setState(() {});
    }
  }

  saveForLater(String? id, String save, String? qty, double price,
      SectionModel curItem, bool fromSave) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          PRODUCT_VARIENT_ID: id,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: save,
          "seller_id": "$sellerId"
        };

        print("param****save***********$parameter");

        Response response =
        await post(manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          // CUR_CART_COUNT = data['cart_count'];
          context.read<UserProvider>().setCartCount(data['cart_count']);
          if (save == "1") {
            setSnackbar("Saved For Later", _scaffoldKey);
            saveLaterList.add(curItem);
            //cartList.removeWhere((item) => item.varientId == id);
            context.read<CartProvider>().removeCartItem(id!);
            setState(() {
              saveLater = false;
            });
            oriPrice = oriPrice - price;
          } else {
            setSnackbar("Added To Cart", _scaffoldKey);
            // cartList.add(curItem);
            context.read<CartProvider>().addCartItem(curItem);
            saveLaterList.removeWhere((item) => item.varientId == id);
            setState(() {
              addCart = false;
            });
            oriPrice = oriPrice + price;
          }

          totalPrice = 0;

          if (!ISFLAT_DEL) {
            // if (addressList.length > 0 &&
            //     (oriPrice) <
            //         double.parse(addressList[selectedAddress!].freeAmt!)) {
            //   delCharge =
            //       double.parse(addressList[selectedAddress!].deliveryCharge!);
            // } else {
            //   delCharge = 0;
            // }
          } else {
            // if ((oriPrice) < double.parse(MIN_AMT!)) {
            //   delCharge = double.parse(CUR_DEL_CHR!);
            // } else {
            //   delCharge = 0;
            // }
          }
          totalPrice = delCharge + oriPrice;

          if (isPromoValid!) {
            validatePromo(false);
          } else if (isUseWallet!) {
            context.read<CartProvider>().setProgress(false);
            if (mounted)
              setState(() {
                remWalBal = 0;
                payMethod = null;
                usedBal = 0;
                isUseWallet = false;
                isPayLayShow = true;
              });
          } else {
            context.read<CartProvider>().setProgress(false);
            setState(() {});
          }
        } else {
          setSnackbar(msg!, _scaffoldKey);
        }

        context.read<CartProvider>().setProgress(false);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  removeFromCartCheckout(int index, bool remove,
      List<SectionModel> cartList) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (!remove &&
        int.parse(cartList[index].qty!) ==
            cartList[index].productList![0].minOrderQuntity) {
      setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
          _checkscaffoldKey);
    } else {
      if (_isNetworkAvail) {
        try {
          context.read<CartProvider>().setProgress(true);

          int? qty;
          if (remove)
            qty = 0;
          else {
            qty = (int.parse(cartList[index].qty!) -
                int.parse(cartList[index].productList![0].qtyStepSize!));

            if (qty < cartList[index].productList![0].minOrderQuntity!) {
              qty = cartList[index].productList![0].minOrderQuntity;

              setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
                  _checkscaffoldKey);
            }
          }

          var parameter = {
            PRODUCT_VARIENT_ID: cartList[index].varientId,
            USER_ID: CUR_USERID,
            QTY: qty.toString(),
            "seller_id": "$sellerId"
          };

          Response response =
          await post(manageCartApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

          if (response.statusCode == 200) {
            var getdata = json.decode(response.body);

            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              var data = getdata["data"];

              String? qty = data['total_quantity'];
              // CUR_CART_COUNT = data['cart_count'];

              context.read<UserProvider>().setCartCount(data['cart_count']);
              if (qty == "0") remove = true;

              if (remove) {
                // cartList.removeWhere((item) => item.varientId == cartList[index].varientId);

                context
                    .read<CartProvider>()
                    .removeCartItem(cartList[index].varientId!);
              } else {
                cartList[index].qty = qty.toString();
              }

              oriPrice = double.parse(data[SUB_TOTAL]);
              if (GST_SERVICE_CHARGES != null && GST_SERVICE_CHARGES != "") {
                gstPrice =
                    (oriPrice * double.parse(GST_SERVICE_CHARGES!)) / 100;
              }
              // if (!ISFLAT_DEL) {
              //   if ((oriPrice) <
              //       double.parse(addressList[selectedAddress!].freeAmt!))
              //     delCharge = double.parse(
              //         addressList[selectedAddress!].deliveryCharge!);
              //   else
              //     delCharge = 0;
              // } else {
              //   if ((oriPrice) < double.parse(MIN_AMT!))
              //     delCharge = double.parse(CUR_DEL_CHR!);
              //   else
              //     delCharge = 0;
              // }

              totalPrice = 0;

              totalPrice = delCharge + oriPrice + gstPrice;

              if (isPromoValid!) {
                validatePromo(true);
              } else if (isUseWallet!) {
                if (mounted)
                  checkoutState!(() {
                    remWalBal = 0;
                    payMethod = null;
                    usedBal = 0;
                    isPayLayShow = true;
                    isUseWallet = false;
                  });
                context.read<CartProvider>().setProgress(false);
                setState(() {});
              } else {
                context.read<CartProvider>().setProgress(false);

                checkoutState!(() {});
                setState(() {});
              }
            } else {
              setSnackbar(msg!, _checkscaffoldKey);
              context.read<CartProvider>().setProgress(false);
            }
          }
        } on TimeoutException catch (_) {
          setSnackbar(
              getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
          context.read<CartProvider>().setProgress(false);
        }
      } else {
        if (mounted)
          checkoutState!(() {
            _isNetworkAvail = false;
          });
        setState(() {});
      }
    }
  }

  // removeFromCart(int index, bool remove, List<SectionModel> cartList, bool move,
  //     int selPos) async {
  //   _isNetworkAvail = await isNetworkAvailable();
  //   if (!remove &&
  //       int.parse(cartList[index].qty!) ==
  //           cartList[index].productList![0].minOrderQuntity) {
  //     setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
  //         _scaffoldKey);
  //   } else {
  //     if (_isNetworkAvail) {
  //       try {
  //         context.read<CartProvider>().setProgress(true);
  //
  //         int? qty;
  //         if (remove)
  //           qty = 0;
  //         else {
  //           qty = (int.parse(_controller[index].text) -
  //               int.parse(cartList[index].productList![0].qtyStepSize!));
  //
  //           if (qty < cartList[index].productList![0].minOrderQuntity!) {
  //             qty = cartList[index].productList![0].minOrderQuntity;
  //
  //             setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
  //                 _checkscaffoldKey);
  //           }
  //         }
  //         String varId;
  //         if (cartList[index].productList![0].availability == "0") {
  //           varId = cartList[index].productList![0].prVarientList![selPos].id!;
  //         } else {
  //           varId = cartList[index].varientId!;
  //         }
  //         print("carient**********${cartList[index].varientId}");
  //         var parameter = {
  //           PRODUCT_VARIENT_ID: varId,
  //           USER_ID: CUR_USERID,
  //           QTY: qty.toString(),
  //           "seller_id": "$sellerId"
  //         };
  //
  //         Response response =
  //         await post(manageCartApi, body: parameter, headers: headers)
  //             .timeout(Duration(seconds: timeOut));
  //
  //         var getdata = json.decode(response.body);
  //         print(getdata);
  //
  //         bool error = getdata["error"];
  //         String? msg = getdata["message"];
  //         if (!error) {
  //           print("msg************$msg");
  //           var data = getdata["data"];
  //           // setSnackbar("Deleted", _scaffoldKey);
  //           Fluttertoast.showToast(
  //               msg: "Deleted", backgroundColor: colors.primary);
  //           String? qty = data['total_quantity'];
  //           // CUR_CART_COUNT = data['cart_count'];
  //
  //           context.read<UserProvider>().setCartCount(data['cart_count']);
  //           if (move == false) {
  //             if (qty == "0") remove = true;
  //
  //             if (remove) {
  //               cartList.removeWhere(
  //                       (item) => item.varientId == cartList[index].varientId);
  //             } else {
  //               cartList[index].qty = qty.toString();
  //             }
  //
  //             oriPrice = double.parse(data[SUB_TOTAL]);
  //             if (GST_SERVICE_CHARGES != null && GST_SERVICE_CHARGES != "") {
  //               gstPrice =
  //                   (oriPrice * double.parse(GST_SERVICE_CHARGES!)) / 100;
  //             }
  //             // if (!ISFLAT_DEL) {
  //             //   try {
  //             //     if ((oriPrice) <
  //             //         double.parse(addressList[selectedAddress!].freeAmt!))
  //             //       delCharge = double.parse(
  //             //           addressList[selectedAddress!].deliveryCharge!);
  //             //     else
  //             //       delCharge = 0;
  //             //   } catch (e) {
  //             //     print(e);
  //             //   }
  //             // } else {
  //             //   if ((oriPrice) < double.parse(MIN_AMT!))
  //             //     delCharge = double.parse(CUR_DEL_CHR!);
  //             //   else
  //             //     delCharge = 0;
  //             // }
  //
  //             totalPrice = 0;
  //             packagingCharge = 0;
  //             for (var i = 0; i < cartList.length; i++) {
  //               if (cartList[i].productList![0].packing_charge.toString() !=
  //                   "" &&
  //                   cartList[i].productList![0].packing_charge != null) {
  //                 packagingCharge += double.parse(cartList[i]
  //                     .productList![0]
  //                     .packing_charge
  //                     .toString()) *
  //                     double.parse(cartList[i].qty.toString());
  //                 oriPrice += double.parse(cartList[i]
  //                     .productList![0]
  //                     .packing_charge
  //                     .toString()) *
  //                     double.parse(cartList[i].qty.toString());
  //               }
  //             }
  //             totalPrice = delCharge + oriPrice + gstPrice;
  //             if (isPromoValid!) {
  //               validatePromo(false);
  //             } else if (isUseWallet!) {
  //               context.read<CartProvider>().setProgress(false);
  //               if (mounted)
  //                 setState(() {
  //                   remWalBal = 0;
  //                   payMethod = null;
  //                   usedBal = 0;
  //                   isPayLayShow = true;
  //                   isUseWallet = false;
  //                 });
  //             } else {
  //               context.read<CartProvider>().setProgress(false);
  //               setState(() {});
  //             }
  //           } else {
  //             if (qty == "0") remove = true;
  //
  //             if (remove) {
  //               cartList.removeWhere(
  //                       (item) => item.varientId == cartList[index].varientId);
  //             }
  //           }
  //         } else {
  //           print("msg111************$msg");
  //           // setSnackbar(msg!, _scaffoldKey);
  //           Fluttertoast.showToast(msg: msg!, backgroundColor: colors.primary);
  //         }
  //         if (mounted) setState(() {});
  //         context.read<CartProvider>().setProgress(false);
  //       } on TimeoutException catch (_) {
  //         setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
  //         context.read<CartProvider>().setProgress(false);
  //       }
  //     } else {
  //       if (mounted)
  //         setState(() {
  //           _isNetworkAvail = false;
  //         });
  //     }
  //   }
  // }

  // removeFromCart(int index, bool remove, List<SectionModel> cartList, bool move,
  //     int selPos) async {
  //   _isNetworkAvail = await isNetworkAvailable();
  //   // if (remove &&
  //   //     int.parse(cartList[index].qty!) ==
  //   //         cartList[index].productList![0].minOrderQuntity) {
  //   //   setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
  //   //       _scaffoldKey);
  //   // } else {
  //     if (_isNetworkAvail) {
  //       try {
  //         context.read<CartProvider>().setProgress(true);
  //
  //         int? qty;
  //         if (remove)
  //           qty = 0;
  //         else {
  //           qty = (int.parse(
  //               _controller[index].text)-
  //               //cartList[index].qty!) -
  //               int.parse(cartList[index].productList![0].qtyStepSize!));
  //
  //           // if (qty < cartList[index].productList![0].minOrderQuntity!) {
  //           //   qty = cartList[index].productList![0].minOrderQuntity;
  //           //
  //           //   setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
  //           //       _checkscaffoldKey);
  //           // }
  //         }
  //
  //         var parameter = {
  //           PRODUCT_VARIENT_ID: cartList[index].varientId,
  //           USER_ID: CUR_USERID,
  //           QTY: qty.toString(),
  //           "seller_id": "$sellerId"
  //         };
  //
  //         Response response =
  //         await post(manageCartApi, body: parameter, headers: headers)
  //             .timeout(Duration(seconds: timeOut));
  //
  //         if (response.statusCode == 200) {
  //           var getdata = json.decode(response.body);
  //
  //           bool error = getdata["error"];
  //           String? msg = getdata["message"];
  //           if (!error) {
  //             var data = getdata["data"];
  //
  //             String? qty = data['total_quantity'];
  //             // CUR_CART_COUNT = data['cart_count'];
  //
  //             context.read<UserProvider>().setCartCount(data['cart_count']);
  //             if (qty == "0") remove = true;
  //
  //             if (remove) {
  //               // cartList.removeWhere((item) => item.varientId == cartList[index].varientId);
  //
  //               context
  //                   .read<CartProvider>()
  //                   .removeCartItem(cartList[index].varientId!);
  //             } else {
  //               cartList[index].qty = qty.toString();
  //             }
  //
  //             oriPrice = double.parse(data[SUB_TOTAL]);
  //             if (GST_SERVICE_CHARGES != null && GST_SERVICE_CHARGES != "") {
  //               gstPrice =
  //                   (oriPrice * double.parse(GST_SERVICE_CHARGES!)) / 100;
  //             }
  //             // if (!ISFLAT_DEL) {
  //             //   if ((oriPrice) <
  //             //       double.parse(addressList[selectedAddress!].freeAmt!))
  //             //     delCharge = double.parse(
  //             //         addressList[selectedAddress!].deliveryCharge!);
  //             //   else
  //             //     delCharge = 0;
  //             // } else {
  //             //   if ((oriPrice) < double.parse(MIN_AMT!))
  //             //     delCharge = double.parse(CUR_DEL_CHR!);
  //             //   else
  //             //     delCharge = 0;
  //             // }
  //
  //             totalPrice = 0;
  //
  //             totalPrice = delCharge + oriPrice + gstPrice;
  //
  //             if (isPromoValid!) {
  //               validatePromo(true);
  //             } else if (isUseWallet!) {
  //               if (mounted)
  //                 checkoutState!(() {
  //                   remWalBal = 0;
  //                   payMethod = null;
  //                   usedBal = 0;
  //                   isPayLayShow = true;
  //                   isUseWallet = false;
  //                 });
  //               context.read<CartProvider>().setProgress(false);
  //               setState(() {});
  //             } else {
  //               context.read<CartProvider>().setProgress(false);
  //               //_refresh();
  //
  //              // checkoutState!(() {});
  //              // setState(() {});
  //             }
  //           } else {
  //             setSnackbar(msg!, _checkscaffoldKey);
  //             context.read<CartProvider>().setProgress(false);
  //           }
  //         }
  //       } on TimeoutException catch (_) {
  //         setSnackbar(
  //             getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
  //         context.read<CartProvider>().setProgress(false);
  //       }
  //     } else {
  //       if (mounted)
  //         checkoutState!(() {
  //           _isNetworkAvail = false;
  //         });
  //       setState(() {});
  //     }
  //     // if (_isNetworkAvail) {
  //     //   try {
  //     //     context.read<CartProvider>().setProgress(true);
  //     //
  //     //     int? qty;
  //     //     if (remove)
  //     //       qty = 0;
  //     //     else {
  //     //       qty = (int.parse(cartList[index].qty!) -
  //     //           int.parse(cartList[index].productList![0].qtyStepSize!));
  //     //
  //     //       if (qty < cartList[index].productList![0].minOrderQuntity!) {
  //     //         qty = cartList[index].productList![0].minOrderQuntity;
  //     //
  //     //         setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
  //     //             _checkscaffoldKey);
  //     //       }
  //     //     }
  //     //     String varId;
  //     //     if (cartList[index].productList![0].availability == "0") {
  //     //       varId = cartList[index].productList![0].prVarientList![selPos].id!;
  //     //     } else {
  //     //       varId = cartList[index].varientId!;
  //     //     }
  //     //     print("carient**********${cartList[index].varientId}");
  //     //     var parameter = {
  //     //       PRODUCT_VARIENT_ID: varId,
  //     //       USER_ID: CUR_USERID,
  //     //       QTY: qty.toString(),
  //     //       "seller_id": "$sellerId"
  //     //     };
  //     //
  //     //     Response response =
  //     //     await post(manageCartApi, body: parameter, headers: headers)
  //     //         .timeout(Duration(seconds: timeOut));
  //     //
  //     //     var getdata = json.decode(response.body);
  //     //     print(getdata);
  //     //     print(parameter);
  //     //
  //     //     bool error = getdata["error"];
  //     //     String? msg = getdata["message"];
  //     //     if (!error) {
  //     //       print("msg************$msg");
  //     //       var data = getdata["data"];
  //     //       setSnackbar("Deleted", _scaffoldKey);
  //     //       String? qty = data['total_quantity'];
  //     //       // CUR_CART_COUNT = data['cart_count'];
  //     //
  //     //       context.read<UserProvider>().setCartCount(data['cart_count']);
  //     //       if (move == false) {
  //     //         if (qty == "0") remove = true;
  //     //
  //     //         if (remove) {
  //     //           cartList.removeWhere(
  //     //                   (item) => item.varientId == cartList[index].varientId);
  //     //         } else {
  //     //           cartList[index].qty = qty.toString();
  //     //         }
  //     //         oriPrice = double.parse(data[SUB_TOTAL]);
  //     //         for (var i = 0; i < cartList.length; i++) {
  //     //           if (cartList[i].productList![0].packing_charge.toString() != "") {
  //     //             oriPrice += double.parse(
  //     //                 cartList[i].productList![0].packing_charge.toString());
  //     //           }
  //     //         }
  //     //
  //     //         // if (!ISFLAT_DEL) {
  //     //         //   try {
  //     //         //     if ((oriPrice) <
  //     //         //         double.parse(addressList[selectedAddress!].freeAmt!))
  //     //         //       delCharge = double.parse(
  //     //         //           addressList[selectedAddress!].deliveryCharge!);
  //     //         //     else
  //     //         //       delCharge = 0;
  //     //         //   } catch (e) {
  //     //         //     print(e);
  //     //         //   }
  //     //         // } else {
  //     //         //   if ((oriPrice) < double.parse(MIN_AMT!))
  //     //         //     delCharge = double.parse(CUR_DEL_CHR!);
  //     //         //   else
  //     //         //     delCharge = 0;
  //     //         // }
  //     //
  //     //         // totalPrice = 0;
  //     //
  //     //         totalPrice = delCharge + oriPrice;
  //     //         if (isPromoValid!) {
  //     //           validatePromo(false);
  //     //         } else if (isUseWallet!) {
  //     //           context.read<CartProvider>().setProgress(false);
  //     //           if (mounted)
  //     //             setState(() {
  //     //               remWalBal = 0;
  //     //               payMethod = null;
  //     //               usedBal = 0;
  //     //               isPayLayShow = true;
  //     //               isUseWallet = false;
  //     //             });
  //     //         } else {
  //     //           context.read<CartProvider>().setProgress(false);
  //     //           setState(() {});
  //     //         }
  //     //       } else {
  //     //         if (qty == "0") remove = true;
  //     //
  //     //         if (remove) {
  //     //           cartList.removeWhere(
  //     //                   (item) => item.varientId == cartList[index].varientId);
  //     //         }
  //     //       }
  //     //     } else {
  //     //       print("msg111************$msg");
  //     //       setSnackbar(msg!, _scaffoldKey);
  //     //     }
  //     //     if (mounted) setState(() {});
  //     //     context.read<CartProvider>().setProgress(false);
  //     //   } on TimeoutException catch (_) {
  //     //     setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
  //     //     context.read<CartProvider>().setProgress(false);
  //     //   }
  //     // } else {
  //     //   if (mounted)
  //     //     setState(() {
  //     //       _isNetworkAvail = false;
  //     //     });
  //     // }
  // //  }
  // }

  removeFromCart(int index, bool remove, List<SectionModel> cartList1,
      bool move,
      int selPos) async {
    _isNetworkAvail = await isNetworkAvailable();
    // if (remove &&
    //     int.parse(cartList[index].qty!) ==
    //         cartList[index].productList![0].minOrderQuntity) {
    //   setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
    //       _scaffoldKey);
    // } else {
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);
        int? qty;
        if (remove) {
          qty = 0;
        } else {
          qty = (int.parse(cartList1[index].qty) -
              //cartList[index].qty!) -
              int.parse(
                //cartList![index]!.productList![0].minOrderQuntity!)
                  cartList[index].productList![0].qtyStepSize!));
          /* setState(() {
           _getCart("0");
         });*/
          // if (qty < cartList[index].productList![0].minOrderQuntity!) {
          //   qty = cartList[index].productList![0].minOrderQuntity;
          //
          //   _refresh();
          // }
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty.toString(),
          "seller_id": "$sellerId"
        };
        Response response = await post(
            manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          context.read<CartProvider>().setProgress(false);
          // _refresh();
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            isPromoValid = false;
            promoC.text = '';
            promoAmt = 0;
            promocode = null;
            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];
            /* if (getdata['cart'].length > 0) {
              context.read<UserProvider>().setStoreName(
                  getdata['cart'][0]['product_details'][0]['store_name']);
              context.read<UserProvider>().setSellerProfile(
                  getdata['cart'][0]['product_details'][0]['seller_profile']);
            }*/
            context.read<UserProvider>().setCartCount(data['total_items']);
            context
                .read<UserProvider>()
                .setAmount(getdata['data']['overall_amount']);
            if (qty == "0") remove = true;

            var cart = getdata["cart"];
            List<SectionModel> cartList1 = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList1);
            context.read<CartProvider>().setProgress(false);

            oriPrice = double.parse(data[SUB_TOTAL]);
            if (GST_SERVICE_CHARGES != null && GST_SERVICE_CHARGES != "") {
              gstPrice = (oriPrice * double.parse(GST_SERVICE_CHARGES!)) / 100;
            }
            setState(() {
              cartList = cartList1.toList();
            });
            packagingCharge = 0;
            for (var i = 0; i < cartList.length; i++) {
              if (cartList[i].productList![0].packing_charge.toString() != "" &&
                  cartList[i].productList![0].packing_charge != null) {
                packagingCharge += double.parse(
                    cartList[i].productList![0].packing_charge.toString()) *
                    double.parse(cartList[i].qty.toString());
                oriPrice += double.parse(
                    cartList[i].productList![0].packing_charge.toString()) *
                    double.parse(cartList[i].qty.toString());
              }
            }
            //
            /*if (remove) {
              cartList.removeWhere(
                  (item) => item.varientId == cartList[index].varientId);
              if (cartList.length > 0) {
                context
                    .read<CartProvider>()
                    .removeCartItem(cartList[index].varientId!);
              }

              // setState((){
              //   _refresh();
              // });
              */ /* setState((){
                 _getCart("0");
               });*/ /*
            } else {

            }*/
            // if (!ISFLAT_DEL) {
            //   if ((oriPrice) <
            //       double.parse(addressList[selectedAddress!].freeAmt!))
            //     delCharge = double.parse(
            //         addressList[selectedAddress!].deliveryCharge!);
            //   else
            //     delCharge = 0;
            // } else {
            //   if ((oriPrice) < double.parse(MIN_AMT!))
            //     delCharge = double.parse(CUR_DEL_CHR!);
            //   else
            //     delCharge = 0;
            // }

            totalPrice = 0;

            totalPrice = delCharge + oriPrice + gstPrice;
            //_getCart("0");
            // print("this is total and cartcount ${totalPrice.toString()} ******** ${_controller[index].text} ^^^^^^^^^${qty}");
            if (isPromoValid!) {
              validatePromo(true);
            } else if (isUseWallet!) {
              context.read<CartProvider>().setProgress(false);
              if (mounted)
                checkoutState!(() {
                  remWalBal = 0;
                  payMethod = null;
                  usedBal = 0;
                  isPayLayShow = true;
                  isUseWallet = false;
                });

              //  setState(() {});
            } else {
              context.read<CartProvider>().setProgress(false);
              // _refresh();

              // checkoutState!(() {});
              // setState(() {});
            }
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        checkoutState!(() {
          _isNetworkAvail = false;
        });
    }
    // if (_isNetworkAvail) {
    //   try {
    //     context.read<CartProvider>().setProgress(true);
    //
    //     int? qty;
    //     if (remove)
    //       qty = 0;
    //     else {
    //       qty = (int.parse(cartList[index].qty!) -
    //           int.parse(cartList[index].productList![0].qtyStepSize!));
    //
    //       if (qty < cartList[index].productList![0].minOrderQuntity!) {
    //         qty = cartList[index].productList![0].minOrderQuntity;
    //
    //         setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
    //             _checkscaffoldKey);
    //       }
    //     }
    //     String varId;
    //     if (cartList[index].productList![0].availability == "0") {
    //       varId = cartList[index].productList![0].prVarientList![selPos].id!;
    //     } else {
    //       varId = cartList[index].varientId!;
    //     }
    //     print("carient**********${cartList[index].varientId}");
    //     var parameter = {
    //       PRODUCT_VARIENT_ID: varId,
    //       USER_ID: CUR_USERID,
    //       QTY: qty.toString(),
    //       "seller_id": "$sellerId"
    //     };
    //
    //     Response response =
    //     await post(manageCartApi, body: parameter, headers: headers)
    //         .timeout(Duration(seconds: timeOut));
    //
    //     var getdata = json.decode(response.body);
    //     print(getdata);
    //     print(parameter);
    //
    //     bool error = getdata["error"];
    //     String? msg = getdata["message"];
    //     if (!error) {
    //       print("msg************$msg");
    //       var data = getdata["data"];
    //       setSnackbar("Deleted", _scaffoldKey);
    //       String? qty = data['total_quantity'];
    //       // CUR_CART_COUNT = data['cart_count'];
    //
    //       context.read<UserProvider>().setCartCount(data['cart_count']);
    //       if (move == false) {
    //         if (qty == "0") remove = true;
    //
    //         if (remove) {
    //           cartList.removeWhere(
    //                   (item) => item.varientId == cartList[index].varientId);
    //         } else {
    //           cartList[index].qty = qty.toString();
    //         }
    //         oriPrice = double.parse(data[SUB_TOTAL]);
    //         for (var i = 0; i < cartList.length; i++) {
    //           if (cartList[i].productList![0].packing_charge.toString() != "") {
    //             oriPrice += double.parse(
    //                 cartList[i].productList![0].packing_charge.toString());
    //           }
    //         }
    //
    //         // if (!ISFLAT_DEL) {
    //         //   try {
    //         //     if ((oriPrice) <
    //         //         double.parse(addressList[selectedAddress!].freeAmt!))
    //         //       delCharge = double.parse(
    //         //           addressList[selectedAddress!].deliveryCharge!);
    //         //     else
    //         //       delCharge = 0;
    //         //   } catch (e) {
    //         //     print(e);
    //         //   }
    //         // } else {
    //         //   if ((oriPrice) < double.parse(MIN_AMT!))
    //         //     delCharge = double.parse(CUR_DEL_CHR!);
    //         //   else
    //         //     delCharge = 0;
    //         // }
    //
    //         // totalPrice = 0;
    //
    //         totalPrice = delCharge + oriPrice;
    //         if (isPromoValid!) {
    //           validatePromo(false);
    //         } else if (isUseWallet!) {
    //           context.read<CartProvider>().setProgress(false);
    //           if (mounted)
    //             setState(() {
    //               remWalBal = 0;
    //               payMethod = null;
    //               usedBal = 0;
    //               isPayLayShow = true;
    //               isUseWallet = false;
    //             });
    //         } else {
    //           context.read<CartProvider>().setProgress(false);
    //           setState(() {});
    //         }
    //       } else {
    //         if (qty == "0") remove = true;
    //
    //         if (remove) {
    //           cartList.removeWhere(
    //                   (item) => item.varientId == cartList[index].varientId);
    //         }
    //       }
    //     } else {
    //       print("msg111************$msg");
    //       setSnackbar(msg!, _scaffoldKey);
    //     }
    //     if (mounted) setState(() {});
    //     context.read<CartProvider>().setProgress(false);
    //   } on TimeoutException catch (_) {
    //     setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
    //     context.read<CartProvider>().setProgress(false);
    //   }
    // } else {
    //   if (mounted)
    //     setState(() {
    //       _isNetworkAvail = false;
    //     });
    // }
    //  }
  }

  setSnackbar(String msg,
      GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey) {
    Fluttertoast.showToast(msg: msg);
    /*ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      duration: Duration(seconds: 1),
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));*/
  }

  List<SectionModel> cartList = [];

  _showContent(BuildContext context) {
    //  cartList = context.read<CartProvider>().cartList;
    print("cart list************${cartList.length}");
    return _isCartLoad
        ? shimmer(context)
        : cartList.length == 0 && saveLaterList.length == 0
        ? cartEmpty()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 10.0),
              child: RefreshIndicator(
                  color: colors.primary,
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colors.whiteTemp,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0)),
                            // border: Border(
                            //   bottom: BorderSide(width: 0.8, color: Colors.grey),
                            // ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: cartList.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              sellerName = cartList[index]
                                  .productList![0]
                                  .seller_name;
                              return Column(
                                children: [
                                  listItem(index, cartList[index]),
                                  index + 1 == cartList.length
                                      ? Divider()
                                      : Container(),
                                ],
                              );
                            },
                          ),
                        ),
                        saveLaterList.length > 0
                            ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            getTranslated(
                                context, 'SAVEFORLATER_BTN')!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .fontColor),
                          ),
                        )
                            : Container(),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: saveLaterList.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return saveLaterItem(index);
                          },
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: colors.whiteTemp,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight:
                                    Radius.circular(10.0))),
                            padding:
                            EdgeInsets.symmetric(vertical: 8.0),
                            /*            decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),*/
                            child: TextField(
                              controller: noteC,
                              //style: Theme.of(context).textTheme.subtitle2,
                              decoration: InputDecoration(
                                //border: InputBorder.none,
                                suffixIcon: Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 18,
                                ),
                                // contentPadding
                                // EdgeInsets.symmetric(
                                //     horizontal: 10),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: colors.whiteTemp,
                                //isDense: true,
                                hintStyle: TextStyle(fontSize: 12),
                                hintText:
                                getTranslated(context, 'NOTE'),
                              ),
                            )),
                      ],
                    ),
                  ))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Offer & Benefits",
            style: TextStyle(
                color: colors.blackTemp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Column(mainAxisSize: MainAxisSize.min, children: <
              Widget>[
            promoList.length > 0 && oriPrice > 0 ?
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0),
              child: InkWell(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    AnimatedBuilder(
                        animation: _resizableController!,
                        builder: (context, child) {
                          return Container(
                              decoration: BoxDecoration(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .white,
                                  border: Border.all(
                                      color: colorVariation(
                                          (_resizableController!
                                              .value *
                                              10)
                                              .round())!,
                                      width: 3),
                                  borderRadius:
                                  BorderRadiusDirectional
                                      .circular(10)),
                              child: TextField(
                                textDirection:
                                Directionality.of(context),
                                enabled: false,
                                controller: promoC,
                                readOnly: true,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle2,
                                decoration: InputDecoration(
                                  contentPadding:
                                  EdgeInsets.symmetric(
                                      horizontal: 10),
                                  border: InputBorder.none,
                                  //isDense: true,
                                  hintText: getTranslated(
                                      context,
                                      'PROMOCODE_LBL') ??
                                      '',
                                ),
                              ));
                        }),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      end: 10,
                      child: Container(
                          padding: EdgeInsets.all(11),
                          // decoration: BoxDecoration(
                          //   shape: BoxShape.circle,
                          //   color: colors.primary,
                          // ),
                          child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15,
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .black)),
                    ),
                  ],
                ),
                onTap: promoSheet,
              ),
            )
                : Container(),
            Container(
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                margin:
                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                padding:
                EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                //  width: deviceWidth! * 0.9,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(getTranslated(context, 'TOTAL_PRICE')!),
                        Text(
                          CUR_CURRENCY! +
                              " ${oriPrice.toStringAsFixed(2)}",
                          style: Theme
                              .of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .fontColor),
                        ),
                      ],
                    ),
                    isPromoValid!
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(
                              context, 'PROMO_CODE_DIS_LBL')!,
                          style: Theme
                              .of(context)
                              .textTheme
                              .caption!
                              .copyWith(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .lightBlack2),
                        ),
                        Text(
                          "-" +
                              CUR_CURRENCY! +
                              " " +
                              promoAmt.toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .caption!
                              .copyWith(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .lightBlack2),
                        )
                      ],
                    )
                        : Container(),
                  ],
                )),
            Container(
              //  height: 30,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      checkShop ? "" : "Restraunt is closed",
                      // proStatus==DELIVERD||searchList[index].payMethod.toString()!="COD"?"Paid":"COD",
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                    ),
                  ],
                  pause: Duration(milliseconds: 100),
                  isRepeatingAnimation: true,
                  totalRepeatCount: 100,
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),
            ),
            CupertinoButton(
              child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 35,
                  alignment: FractionalOffset.center,
                  decoration: new BoxDecoration(
                    color: checkShop ? colors.primary : Colors.grey,
                    borderRadius: new BorderRadius.all(
                        const Radius.circular(5.0)),
                  ),
                  child: Text("Checkout",
                      // getTranslated(context, 'PROCEED_CHECKOUT'),
                      textAlign: TextAlign.center,
                      style: Theme
                          .of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(
                          color: colors.whiteTemp,
                          fontWeight: FontWeight.normal))),
              onPressed: () async {
                if (checkShop) {
                  if (oriPrice > 0) {
                    FocusScope.of(context).unfocus();
                    if (isAvailable) {
                      //  _getExtraDeliveryCharges();
                      await checkout(cartList);
                    } else {
                      setSnackbar(
                          getTranslated(
                              context, 'CART_OUT_OF_STOCK_MSG')!,
                          _scaffoldKey);
                    }
                    if (mounted) setState(() {});
                  } else
                    setSnackbar(getTranslated(context, 'ADD_ITEM')!,
                        _scaffoldKey);
                } else {}
              },
            )
            // SimBtn(
            //     size: 0.9,
            //     title: getTranslated(context, 'PROCEED_CHECKOUT'),
            //     onBtnSelected: () async {
            //       if (oriPrice > 0) {
            //         FocusScope.of(context).unfocus();
            //         if (isAvailable) {
            //         //  _getExtraDeliveryCharges();
            //         await checkout(cartList);
            //         } else {
            //           setSnackbar(
            //               getTranslated(
            //                   context, 'CART_OUT_OF_STOCK_MSG')!,
            //               _scaffoldKey);
            //         }
            //         if (mounted) setState(() {});
            //       } else
            //         setSnackbar(getTranslated(context, 'ADD_ITEM')!,
            //             _scaffoldKey);
            //     }),
          ]),
        ),
      ],
    );
  }

  cartEmpty() {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noCartImage(context),
          noCartText(context),
          noCartDec(context),
          shopNow()
        ]),
      ),
    );
  }

  getAllPromo() {}

  noCartImage(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/empty_cart.svg',
      fit: BoxFit.contain,
      color: colors.primary,
    );
  }

  noCartText(BuildContext context) {
    return Container(
        child: Text(getTranslated(context, 'NO_CART')!,
            style: Theme
                .of(context)
                .textTheme
                .headline5!
                .copyWith(
                color: colors.primary, fontWeight: FontWeight.normal)));
  }

  noCartDec(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
      child: Text(getTranslated(context, 'CART_DESC')!,
          textAlign: TextAlign.center,
          style: Theme
              .of(context)
              .textTheme
              .headline6!
              .copyWith(
            color: Theme
                .of(context)
                .colorScheme
                .lightBlack2,
            fontWeight: FontWeight.normal,
          )),
    );
  }

  shopNow() {
    return Padding(
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
              borderRadius: new BorderRadius.all(const Radius.circular(50.0)),
            ),
            child: Text(getTranslated(context, 'SHOP_NOW')!,
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6!
                    .copyWith(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .white,
                    fontWeight: FontWeight.normal))),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        },
      ),
    );
  }

  checkout(List<SectionModel> cartList) async {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _placeOrder = true;
    payMethod = null;
    selectedMethod = null;
    if (extraDelCharge != 0) {
      isExtra = true;
    }
    deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                checkoutState = setState;
                return Container(
                    child: _isNetworkAvail
                        ? cartList.length == 0
                        ? cartEmpty()
                        : _isLoading
                        ? shimmer(context)
                        : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    address(),
                                    payment(),
                                    extraDelCharge != 0
                                        ? extraDelivery()
                                        : SizedBox(
                                      height: 0,
                                    ),
                                    // cartItems(cartList),
                                    // promo(),
                                  ],
                                ),
                              ),
                            ),
                            Selector<CartProvider, bool>(
                              builder: (context, data, child) {
                                return showCircularProgress(
                                    data, colors.primary);
                              },
                              selector: (_, provider) =>
                              provider.isProgress,
                            ),
                            //showCircularProgress(_isProgress, colors.primary),
                          ],
                        ),
                        orderSummary(cartList),
                        Container(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .white,
                          child: Row(children: <Widget>[
                            Padding(
                                padding: EdgeInsetsDirectional.only(
                                    start: 15.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      CUR_CURRENCY! +
                                          " ${totalPrice.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    Text(cartList.length.toString() +
                                        " Items"),
                                  ],
                                )),
                            Spacer(),

                            SimBtn(
                                size: 0.4,
                                title: getTranslated(
                                    context, 'PLACE_ORDER'),
                                onBtnSelected: () async {

                                  try {
                                    context.read<CartProvider>().setProgress(true);

                                    var parameter = {
                                      'distance': '${newKms.toString()}',
                                      USER_ID: CUR_USERID,
                                      'type': '${unit.toString()}',

                                    };
                                    print("this is new parameter ###### ${parameter.toString()}");

                                    Response response =
                                    await post(getDeliveryRadiusUrl, body: parameter, headers: headers)
                                        .timeout(Duration(seconds: timeOut));

                                    var getdata = json.decode(response.body);

                                    bool error = getdata["error"];
                                    if(error == false){
                                      setState(() {
                                        isdeliverable = true;
                                      });
                                      context.read<CartProvider>().setProgress(false);
                                    }
                                    dCheckMsg = getdata["message"];
                                    print(
                                        "this is our new data for check deliverable @@@ $dCheckMsg"
                                    );
                                    if (error) {
                                      context.read<CartProvider>().setProgress(false);
                                      // setState((){
                                      //   deliverableRadius = true;
                                      // });

                                      print("dddddd");
                                      Fluttertoast.showToast(msg: dCheckMsg);
                                      print("this is our status #### $deliverableRadius");
                                    } else {
                                      context.read<CartProvider>().setProgress(false);
                                      // Fluttertoast.showToast(msg: dCheckMsg);
                                      print("this is our status #### $deliverableRadius");
                                      if (!_placeOrder) {
                                        return;
                                      }
                                      checkoutState!(() {
                                        _placeOrder = false;
                                      });

                                      checkoutState!(() {
                                        _placeOrder = false;
                                      });
                                      if (selAddress == null ||
                                          selAddress!.isEmpty) {
                                        msg = getTranslated(
                                            context, 'addressWarning');
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext
                                              context) =>
                                                  ManageAddress(
                                                    home: false,
                                                  ),
                                            ));
                                        checkoutState!(() {
                                          _placeOrder = false;
                                        });
                                      }
                                      print("final check ${deliverableRadius}");
                                      if(deliverableRadius == false)
                                        // context.read<CartProvider>().setProgress(false);
                                          {
                                        print("working here");
                                        if (payMethod == null ||
                                            payMethod!.isEmpty) {
                                          msg = getTranslated(
                                              context, 'payWarning');
                                          var result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext context) =>
                                                      Payment(updateCheckout, msg,
                                                          totalPrice)));
                                          if (mounted)
                                            checkoutState!(() {
                                              _placeOrder = true;
                                              payMethod = result;
                                            });
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (BuildContext
                                          //                 context) =>
                                          //             Payment(
                                          //                 updateCheckout,
                                          //                 msg,
                                          //                 totalPrice)));
                                          // checkoutState!(() {
                                          //   _placeOrder = true;
                                          // });
                                        } else if (isTimeSlot! &&
                                            int.parse(allowDay!) > 0 &&
                                            (selDate == null ||
                                                selDate!.isEmpty)) {
                                          msg = getTranslated(
                                              context, 'dateWarning');
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                  context) =>
                                                      Payment(
                                                          updateCheckout,
                                                          msg,
                                                          totalPrice)));
                                          checkoutState!(() {
                                            _placeOrder = true;
                                          });
                                        } else if (isTimeSlot! &&
                                            timeSlotList.length > 0 &&
                                            (selTime == null ||
                                                selTime!.isEmpty)) {
                                          msg = getTranslated(
                                              context, 'timeWarning');
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                  context) =>
                                                      Payment(
                                                          updateCheckout,
                                                          msg,
                                                          totalPrice)));
                                          checkoutState!(() {
                                            _placeOrder = true;
                                          });
                                        } else if (double.parse(
                                            MIN_ALLOW_CART_AMT!) >
                                            oriPrice) {
                                          setSnackbar(
                                              getTranslated(
                                                  context, 'MIN_CART_AMT')!,
                                              _checkscaffoldKey);
                                        } else if (!deliverable) {
                                          checkDeliverable();
                                          getDeliveryRadiusApi();
                                          //  _getExtraDeliveryCharges();
                                        }
                                        else
                                          doPayment();
                                      } else{
                                        print("ss not working");
                                      }



                                      //  Navigator.pop(context);

                                      // confirmDialog();
                                      // Fluttertoast.showToast(msg: dCheckMsg);
                                    }
                                  } on TimeoutException catch (_) {
                                    setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
                                  }


                               //   getDeliveryRadiusApi();
                                //  print("ooo ${isdeliverable}");
                                  //if(isdeliverable == true){
                                    // if (!_placeOrder) {
                                    //   return;
                                    // }
                                    // checkoutState!(() {
                                    //   _placeOrder = false;
                                    // });
                                    //
                                    // checkoutState!(() {
                                    //   _placeOrder = false;
                                    // });
                                    // if (selAddress == null ||
                                    //     selAddress!.isEmpty) {
                                    //   msg = getTranslated(
                                    //       context, 'addressWarning');
                                    //   Navigator.pushReplacement(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (BuildContext
                                    //         context) =>
                                    //             ManageAddress(
                                    //               home: false,
                                    //             ),
                                    //       ));
                                    //   checkoutState!(() {
                                    //     _placeOrder = false;
                                    //   });
                                    // }
                                    // print("final check ${deliverableRadius}");
                                    // if(deliverableRadius == false)
                                    //   // context.read<CartProvider>().setProgress(false);
                                    //     {
                                    //   print("working here");
                                    //   if (payMethod == null ||
                                    //       payMethod!.isEmpty) {
                                    //     msg = getTranslated(
                                    //         context, 'payWarning');
                                    //     var result = await Navigator.push(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //             builder: (BuildContext context) =>
                                    //                 Payment(updateCheckout, msg,
                                    //                     totalPrice)));
                                    //     if (mounted)
                                    //       checkoutState!(() {
                                    //         _placeOrder = true;
                                    //         payMethod = result;
                                    //       });
                                    //     // Navigator.push(
                                    //     //     context,
                                    //     //     MaterialPageRoute(
                                    //     //         builder: (BuildContext
                                    //     //                 context) =>
                                    //     //             Payment(
                                    //     //                 updateCheckout,
                                    //     //                 msg,
                                    //     //                 totalPrice)));
                                    //     // checkoutState!(() {
                                    //     //   _placeOrder = true;
                                    //     // });
                                    //   } else if (isTimeSlot! &&
                                    //       int.parse(allowDay!) > 0 &&
                                    //       (selDate == null ||
                                    //           selDate!.isEmpty)) {
                                    //     msg = getTranslated(
                                    //         context, 'dateWarning');
                                    //     Navigator.push(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //             builder: (BuildContext
                                    //             context) =>
                                    //                 Payment(
                                    //                     updateCheckout,
                                    //                     msg,
                                    //                     totalPrice)));
                                    //     checkoutState!(() {
                                    //       _placeOrder = true;
                                    //     });
                                    //   } else if (isTimeSlot! &&
                                    //       timeSlotList.length > 0 &&
                                    //       (selTime == null ||
                                    //           selTime!.isEmpty)) {
                                    //     msg = getTranslated(
                                    //         context, 'timeWarning');
                                    //     Navigator.push(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //             builder: (BuildContext
                                    //             context) =>
                                    //                 Payment(
                                    //                     updateCheckout,
                                    //                     msg,
                                    //                     totalPrice)));
                                    //     checkoutState!(() {
                                    //       _placeOrder = true;
                                    //     });
                                    //   } else if (double.parse(
                                    //       MIN_ALLOW_CART_AMT!) >
                                    //       oriPrice) {
                                    //     setSnackbar(
                                    //         getTranslated(
                                    //             context, 'MIN_CART_AMT')!,
                                    //         _checkscaffoldKey);
                                    //   } else if (!deliverable) {
                                    //     checkDeliverable();
                                    //     getDeliveryRadiusApi();
                                    //     //  _getExtraDeliveryCharges();
                                    //   }
                                    //   else
                                    //     doPayment();
                                    // } else{
                                    //   print("ss not working");
                                    // }
                                    //
                                    //
                                    //
                                    // //  Navigator.pop(context);
                                    //
                                    // // confirmDialog();
                                // }

                                })

                            //}),
                          ]),
                        ),
                      ],
                    )
                        : noInternet(context)
                  /* constraints: BoxConstraints(
                   maxHeight: MediaQuery.of(context).size.height * 0.63),*/
                  /* child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  key: _checkscaffoldKey,
                  body: ,
                ),*/
                );
              });
        });
  }

  // doPayment() {
  //   if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
  //     placeOrder('');
  //   } else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
  //     razorpayPayment();
  //   // else if (payMethod == getTranslated(context, 'RAZORPAY_LBL')) {
  //   //   razorpayPayment();
  //     // CashFreeHelper cashFreeHelper =
  //     //     new CashFreeHelper(totalPrice.toString(), context, (result) {
  //     //   print(result['txMsg']);
  //     //   // setSnackbar(result['txMsg'], _checkscaffoldKey);
  //     //   if (result['txStatus'] == "SUCCESS") {
  //     //     placeOrder(result['signature']);
  //     //   } else {
  //     //     if (mounted)
  //     //       checkoutState!(() {
  //     //         _placeOrder = true;
  //     //       });
  //     //     // context.read<CartProvider>().setProgress(false);
  //     //     setSnackbar1("Transaction cancelled and failed", context);
  //     //   }
  //     //   //placeOrder(result.paymentId);
  //     // });
  //     //
  //     // cashFreeHelper.init();
  //   // }
  //   else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
  //     paystackPayment(context);
  //   else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
  //     flutterwavePayment();
  //   else if (payMethod == getTranslated(context, 'STRIPE_LBL'))
  //     stripePayment();
  //   else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
  //     paytmPayment();
  //   /*  else if (payMethod ==
  //                                                       getTranslated(
  //                                                           context, 'GPAY')) {
  //                                                     googlePayment(
  //                                                         "google_pay");
  //                                                   } else if (payMethod ==
  //                                                       getTranslated(context,
  //                                                           'APPLEPAY')) {
  //                                                     googlePayment(
  //                                                         "apple_pay");
  //                                                   }*/
  //
  //   else if (payMethod == getTranslated(context, 'BANKTRAN'))
  //     bankTransfer();
  //   else
  //     placeOrder('');
  // }
  doPayment() {
    if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
      placeOrder('');
    } else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
      razorpayPayment();
    else if (payMethod ==  getTranslated(context, 'PAYNOW_LBL')
    // payMethod == "Pay Now"
    ) {
      razorpayPayment();
      // CashFreeHelper cashFreeHelper =
      // new CashFreeHelper(totalPrice.toString(), context, (result) {
      //   print(result['txMsg']);
      //   // setSnackbar(result['txMsg'], _checkscaffoldKey);
      //   if (result['txStatus'] == "SUCCESS") {
      //     placeOrder(result['signature']);
      //   } else {
      //     if (mounted)
      //       checkoutState!(() {
      //         _placeOrder = true;
      //       });
      //     // context.read<CartProvider>().setProgress(false);
      //     setSnackbar1("Transaction cancelled and failed", context);
      //   }
      //   //placeOrder(result.paymentId);
      // });
      //
      // cashFreeHelper.init();
    }
    else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
      paystackPayment(context);
    else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
      flutterwavePayment();
    else if (payMethod == getTranslated(context, 'STRIPE_LBL'))
      stripePayment();
    else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
      paytmPayment();
    /*  else if (payMethod ==
                                                        getTranslated(
                                                            context, 'GPAY')) {
                                                      googlePayment(
                                                          "google_pay");
                                                    } else if (payMethod ==
                                                        getTranslated(context,
                                                            'APPLEPAY')) {
                                                      googlePayment(
                                                          "apple_pay");
                                                    }*/

    else if (payMethod == getTranslated(context, 'BANKTRAN'))
      bankTransfer();
    else
      placeOrder('');
  }

  Future<void> _getAddress() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
        };
        Response response =
        await post(getAddressApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          // String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            addressList = (data as List)
                .map((data) => new User.fromAddress(data))
                .toList();

            if (addressList.length == 1) {
              selectedAddress = 0;
              selAddress = addressList[0].id;
              // if (!ISFLAT_DEL) {
              //   if (double.parse(totalPrice.toString()) <
              //       double.parse(addressList[0].freeAmt!))
              //     delCharge = double.parse(addressList[0].deliveryCharge!);
              //   else
              //     delCharge = 0;
              // }
            } else {
              for (int i = 0; i < addressList.length; i++) {
                if (addressList[i].isDefault == "1") {
                  selectedAddress = i;
                  selAddress = addressList[i].id;
                  if (!ISFLAT_DEL) {
                    //   if (totalPrice < double.parse(addressList[i].freeAmt!))
                    //     delCharge = double.parse(addressList[i].deliveryCharge!);
                    //   else
                    // delCharge = 0;
                  }
                }
              }
            }

            // if (ISFLAT_DEL) {
            //   if ((oriPrice) < double.parse(MIN_AMT!))
            //     delCharge = double.parse(CUR_DEL_CHR!);
            //   else
            //     delCharge = 0;
            // }
            totalPrice = totalPrice + delCharge;
          } else {
            if (ISFLAT_DEL) {
              // if ((oriPrice) < double.parse(MIN_AMT!))
              //   delCharge = double.parse(CUR_DEL_CHR!);
              // else
              //   delCharge = 0;
            }
            totalPrice = totalPrice + delCharge;
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }

          if (checkoutState != null) checkoutState!(() {});
        } else {
          setSnackbar(
              getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        }
      } on TimeoutException catch (_) {}
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    _getCart("0");
  }

  Future<void> _getExtraDeliveryCharges() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ADD_ID: selAddress.toString(),
        };
        Response response = await post(getExtraDeliveryChargesApi,
            body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          // String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            // addressList = (data as List)
            //     .map((data) => new User.fromAddress(data))
            //     .toList();
            setState(() {
              extraDelCharge = double.parse(getdata["data"]['delivery_c']);
              extraDriverPercent = extraDelCharge *
                  double.parse(getdata["data"]['driver_percetage']) /
                  100;
              print(extraDelCharge);
              print(
                  "$totalPrice && $delCharge && $extraDelCharge && $extraDriverPercent");
              totalPrice = oriPrice + delCharge + gstPrice + extraDelCharge;
            });
            print(totalPrice);
            print(delCharge);
          } else {
            if (ISFLAT_DEL) {
              // if ((oriPrice) < double.parse(MIN_AMT!))
              //   delCharge = double.parse(CUR_DEL_CHR!);
              // else
              //   delCharge = 0;
            }
            totalPrice = totalPrice + delCharge + extraDelCharge;
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }

          if (checkoutState != null) checkoutState!(() {});
        } else {
          setSnackbar(
              getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        }
      } on TimeoutException catch (_) {}
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    //_getCart("0");
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placeOrder(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    var getdata = json.decode(response.message!);
    String errorMsg = getdata["error"]["description"];
    setSnackbar(errorMsg, _checkscaffoldKey);

    if (mounted)
      checkoutState!(() {
        _placeOrder = true;
      });
    context.read<CartProvider>().setProgress(false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  updateCheckout() {
    if (mounted) checkoutState!(() {});
  }

  razorpayPayment() async {
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(this.context, listen: false);

    String? contact = settingsProvider.mobile;
    String? email = settingsProvider.email;

    String amt = ((totalPrice) * 100).toStringAsFixed(2);

    if (contact != '' && email != '') {
      context.read<CartProvider>().setProgress(true);

      checkoutState!(() {});
      var options = {
        KEY: razorpayId,
        AMOUNT: amt,
        NAME: settingsProvider.userName,
        'prefill': {CONTACT: contact, EMAIL: email},
      };

      try {
        _razorpay!.open(options);
      } catch (e) {
        context.read<CartProvider>().setProgress(false);
        debugPrint(e.toString());
      }
    } else {

      if (email == '')
        setSnackbar(getTranslated(context, 'emailWarning')!, _checkscaffoldKey);
      else if (contact == '')
        setSnackbar(getTranslated(context, 'phoneWarning')!, _checkscaffoldKey);
    }
  }

  void paytmPayment() async {
    String? paymentResponse;
    context.read<CartProvider>().setProgress(true);

    String orderId = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    String callBackUrl = (payTesting
        ? 'https://securegw-stage.paytm.in'
        : 'https://securegw.paytm.in') +
        '/theia/paytmCallback?ORDER_ID=' +
        orderId;

    var parameter = {
      AMOUNT: totalPrice.toString(),
      USER_ID: CUR_USERID,
      ORDER_ID: orderId
    };

    try {
      final response = await post(
        getPytmChecsumkApi,
        body: parameter,
        headers: headers,
      );

      var getdata = json.decode(response.body);

      bool error = getdata["error"];

      if (!error) {
        String txnToken = getdata["txn_token"];

        setState(() {
          paymentResponse = txnToken;
        });
        // orderId, mId, txnToken, txnAmount, callback
        print(
            "para are $paytmMerId # $orderId # $txnToken # ${totalPrice
                .toString()} # $callBackUrl  $payTesting");
        var paytmResponse = Paytm.payWithPaytm(
            callBackUrl: callBackUrl,
            mId: paytmMerId!,
            orderId: orderId,
            txnToken: txnToken,
            txnAmount: totalPrice.toString(),
            staging: payTesting);
        paytmResponse.then((value) {
          print("valie is $value");
          value.forEach((key, value) {
            print("key is $key");
            print("value is $value");
          });
          context.read<CartProvider>().setProgress(false);

          _placeOrder = true;
          setState(() {});
          checkoutState!(() {
            if (value['error']) {
              paymentResponse = value['errorMessage'];

              if (value['response'] != null)
                addTransaction(value['response']['TXNID'], orderId,
                    value['response']['STATUS'] ?? '', paymentResponse, false);
            } else {
              if (value['response'] != null) {
                paymentResponse = value['response']['STATUS'];
                if (paymentResponse == "TXN_SUCCESS")
                  placeOrder(value['response']['TXNID']);
                else
                  addTransaction(
                      value['response']['TXNID'],
                      orderId,
                      value['response']['STATUS'],
                      value['errorMessage'] ?? '',
                      false);
              }
            }

            setSnackbar(paymentResponse!, _checkscaffoldKey);
          });
        });
      } else {
        checkoutState!(() {
          _placeOrder = true;
        });

        context.read<CartProvider>().setProgress(false);

        setSnackbar(getdata["message"], _checkscaffoldKey);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> placeOrder(String? tranId) async {
    print("this is a address ID 123456789 $selAddress");
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      context.read<CartProvider>().setProgress(true);

      SettingProvider settingsProvider =
      Provider.of<SettingProvider>(this.context, listen: false);

      String? mob = settingsProvider.mobile;

      String? varientId, quantity;

      List<SectionModel> cartList = context
          .read<CartProvider>()
          .cartList;
      for (SectionModel sec in cartList) {
        varientId = varientId != null
            ? varientId + "," + sec.varientId!
            : sec.varientId;
        quantity = quantity != null ? quantity + "," + sec.qty! : sec.qty;
      }
      String? payVia;
      if (payMethod == getTranslated(context, 'COD_LBL'))
        payVia = "COD";
      else if (payMethod == getTranslated(context, 'PAYPAL_LBL'))
        payVia = "PayPal";
      else if (payMethod == getTranslated(context, 'PAYUMONEY_LBL'))
        payVia = "PayUMoney";
      else if (payMethod == "Pay Now")
        payVia = "RazorPay";
      else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
        payVia = "RazorPay";
      else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
        payVia = "Paystack";
      else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
        payVia = "Flutterwave";
      else if (payMethod == getTranslated(context, 'STRIPE_LBL'))
        payVia = "Stripe";
      else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
        payVia = "Paytm";
      else if (payMethod == "Wallet")
        payVia = "Wallet";
      else if (payMethod == getTranslated(context, 'BANKTRAN'))
        payVia = "bank_transfer";
      try {
        var parameter = {
          USER_ID: CUR_USERID,
          MOBILE: mob,
          PRODUCT_VARIENT_ID: varientId,
          QUANTITY: quantity,
          TOTAL: oriPrice.toString(),
          "packaging_charge": packagingCharge.toString(),
          FINAL_TOTAL: totalPrice.toString(),
          DEL_CHARGE: delCharge.toString(),
          // TAX_AMT: taxAmt.toString(),
          TAX_PER: taxPer.toString(),
          "gst_service_charge": GST_SERVICE_CHARGES,
          "gst_service_charge_amount": gstPrice.toString(),
          "extra_delivery_charge": extraDelCharge.toString(),
          "driver_percentage": extraDriverPercent.toString(),
          PAYMENT_METHOD: payVia,
          ADD_ID: selAddress,
          ISWALLETBALUSED: isUseWallet! ? "1" : "0",
          WALLET_BAL_USED: usedBal.toString(),
          ORDER_NOTE: noteC.text,
          'distance': newKms.toString()
        };

        if (isTimeSlot!) {
          parameter[DELIVERY_TIME] = selTime ?? 'Anytime';
          parameter[DELIVERY_DATE] = selDate ?? '';
        }
        if (isPromoValid!) {
          parameter[PROMOCODE] = promocode;
          parameter[PROMO_DIS] = promoAmt.toString();
        }

        if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
          parameter[ACTIVE_STATUS] = WAITING;
        } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
          if (tranId == "succeeded")
            parameter[ACTIVE_STATUS] = PLACED;
          else
            parameter[ACTIVE_STATUS] = WAITING;
        } else if (payMethod == getTranslated(context, 'BANKTRAN')) {
          parameter[ACTIVE_STATUS] = WAITING;
        }
        print("this is place order response #### ***** ^^^^ ${parameter.toString()}");
        Response response =
        await post(placeOrderApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        print(placeOrderApi);

        _placeOrder = true;
        if (response.statusCode == 200) {


          // setSnackbar("Order Placed Successfully!!", _checkscaffoldKey);

          print("this is our new response **** ${response.body.toString()}");
          var getdata = json.decode(response.body);
          print(getdata);
          bool error = getdata["error"];
          String? msg = getdata["message"];

          if (msg == "Order Placed Successfully") {
            String orderId = getdata["order_id"].toString();
            if (payMethod == getTranslated(context, 'RAZORPAY_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == "RAZORPAY_LBL") {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
              paypalPayment(orderId);
            } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
              addTransaction(stripePayId, orderId,
                  tranId == "succeeded" ? PLACED : WAITING, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYSTACK_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYTM_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else {
              context.read<UserProvider>().setCartCount("0");

              clearAll();

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => OrderSuccess()),
                  ModalRoute.withName('/home'));
            }
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        if (mounted)
          checkoutState!(() {
            _placeOrder = true;
          });
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        checkoutState!(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future<void> paypalPayment(String orderId) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderId,
        AMOUNT: totalPrice.toString()
      };
      Response response =
      await post(paypalTransactionApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        String? data = getdata["data"];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    PaypalWebview(
                      url: data,
                      from: "order",
                      orderId: orderId,
                    )));
      } else {
        setSnackbar(msg!, _checkscaffoldKey);
      }
      context.read<CartProvider>().setProgress(false);
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
    }
  }

  Future<void> addTransaction(String? tranId, String orderID, String? status,
      String? msg, bool redirect) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderID,
        TYPE: payMethod,
        TXNID: tranId,
        AMOUNT: totalPrice.toString(),
        STATUS: status,
        MSG: msg
      };
      Response response =
      await post(addTransactionApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg1 = getdata["message"];
      if (!error) {
        if (redirect) {
          // CUR_CART_COUNT = "0";

          context.read<UserProvider>().setCartCount("0");
          clearAll();

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => OrderSuccess()),
              ModalRoute.withName('/home'));
        }
      } else {
        setSnackbar(msg1!, _checkscaffoldKey);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
    }
  }

  paystackPayment(BuildContext context) async {
    /* context.read<CartProvider>().setProgress(true);

    String? email = context.read<SettingProvider>().email;

    Charge charge = Charge()
      ..amount = totalPrice.toInt()
      ..reference = _getReference()
      ..email = email;

    try {
      CheckoutResponse response = await paystackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );
      if (response.status) {
        placeOrder(response.reference);
      } else {
        setSnackbar(response.message, _checkscaffoldKey);
        if (mounted)
          setState(() {
            _placeOrder = true;
          });
        context.read<CartProvider>().setProgress(false);
      }
    } catch (e) {
      context.read<CartProvider>().setProgress(false);
      rethrow;
    }*/
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime
        .now()
        .millisecondsSinceEpoch}';
  }

  stripePayment() async {
    context.read<CartProvider>().setProgress(true);

    var response = await StripeService.payWithNewCard(
        amount: (totalPrice.toInt() * 100).toString(),
        currency: stripeCurCode,
        from: "order",
        context: context);

    if (response.message == "Transaction successful") {
      placeOrder(response.status);
    } else if (response.status == 'pending' || response.status == "captured") {
      placeOrder(response.status);
    } else {
      if (mounted)
        setState(() {
          _placeOrder = true;
        });

      context.read<CartProvider>().setProgress(false);
    }
    setSnackbar(response.message!, _checkscaffoldKey);
  }

  address() {
    return AnimatedBuilder(
        animation: _resizableController!,
        builder: (context, child) {
          return Container(
              decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .white,
                  border: Border.all(
                      color: colorVariation(
                          (_resizableController!
                              .value *
                              10)
                              .round())!,
                      width: 3),
                  borderRadius:
                  BorderRadiusDirectional
                      .circular(10)),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on),
                          Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: 8.0),
                              child: Text(
                                getTranslated(context, 'SHIPPING_DETAIL') ?? '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                        ],
                      ),
                      Divider(),
                      addressList.length > 0 && selectedAddress != null
                          ? Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child:
                                    Text(addressList[selectedAddress!].name!)),
                                InkWell(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      getTranslated(context, 'CHANGE')!,
                                      style: TextStyle(
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    var result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ManageAddress(
                                                  home: false,
                                                )));

                                    if (result != null && result is int) {
                                      selectedAddress = result;
                                      selAddress = addressList[result].id;
                                      print("adressId@@@@ $selAddress");
                                      Navigator.pop(context);
                                      await _getCart("0");
                                      await checkout(cartList);

                                      // Navigator.pop(context);
                                      // checkout(cartList);

                                      // _getCart("0", check: "1");
                                      // promoC.text = promoList[index].promoCode!;
                                      // validatePromo(true);
                                      // setState((){
                                      //   totalPrice -= promoAmt;
                                      // });
                                    }
                                    //
                                  },
                                ),
                              ],
                            ),
                            Text(
                              addressList[selectedAddress!].landmark! +
                                  ", " +
                                  addressList[selectedAddress!].address!,
                              // ", " +
                              // addressList[selectedAddress!].city! +
                              // ", " +
                              // addressList[selectedAddress!].state! +
                              // ", " +
                              // addressList[selectedAddress!].country! +
                              // ", " +
                              // addressList[selectedAddress!].pincode!,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .lightBlack),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0),
                              child: Row(
                                children: [
                                  Text(
                                    addressList[selectedAddress!].mobile!,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .lightBlack),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                          : addressList.length > 0
                          ? Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8.0),
                        child: GestureDetector(
                          child: Text(
                            "Select and Add New Address",
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .fontColor,
                            ),
                          ),
                          onTap: () async {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ManageAddress(
                                        home: false,
                                      )),
                            );
                            if (result != null && result is int) {
                              selectedAddress = result;
                              selAddress = addressList[result].id;
                              print("adressId@@@@ $selAddress");
                              Navigator.pop(context);
                              // checkout(cartList);
                              // _getCart("0", check: "1");
                              // validatePromo(true);
                              // setState((){
                              //   totalPrice -= promoAmt;
                              // });
                            }
                          },
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8.0),
                        child: GestureDetector(
                          child: Text(
                            getTranslated(context, 'ADDADDRESS')!,
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .fontColor,
                            ),
                          ),
                          onTap: () async {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddAddress(
                                        update: false,
                                        index: addressList.length,
                                      )),
                            );
                            _getCart("0", check: "1");
                            if (result == "yes") {
                              Navigator.pop(context);
                              _getCart("0", check: "1");
                              // getDeliveryKmsApi(
                              //     double.parse(
                              //         addressList[selectedAddress!].latitude.toString()),
                              //     double.parse(addressList[selectedAddress!]
                              //         .longitude
                              //         .toString()), itemLat, itemLong);
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ));
        })
    ;
  }

  payment() {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          msg = '';
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      Payment(updateCheckout, msg, totalPrice)));
          if (mounted)
            checkoutState!(() {
              payMethod = result;
            });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.payment),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Text(
                      //SELECT_PAYMENT,
                      getTranslated(context, 'SELECT_PAYMENT')!,
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .fontColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              payMethod != null && payMethod != ''
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Divider(), Text(payMethod!)],
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  final colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  final colorizeTextStyle = TextStyle(
    fontSize: 14.0,
    fontFamily: 'Horizon',
  );

  extraDelivery() {
    return Card(
      elevation: 0,
      child: Container(
        height: 30,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Center(
          child: AnimatedTextKit(
            animatedTexts: [
              ColorizeAnimatedText(
                "Extra Delivery Charges due to heavy rain : $CUR_CURRENCY ${extraDelCharge
                    .toString()}",
                // proStatus==DELIVERD||searchList[index].payMethod.toString()!="COD"?"Paid":"COD",
                textStyle: colorizeTextStyle,
                colors: colorizeColors,
              ),
            ],
            pause: Duration(milliseconds: 100),
            isRepeatingAnimation: true,
            totalRepeatCount: 100,
            onTap: () {
              print("Tap Event");
            },
          ),
          // GradientText(
          //   "Extra Delivery Charges due to heavy rain : $CUR_CURRENCY ${extraDelCharge.toString()}",
          //   gradient: LinearGradient(
          //       begin:Alignment.topLeft,
          //       end:Alignment.bottomRight,
          //       colors: [
          //       colors: [
          //         Colors.green,
          //         Colors.blue,
          //         Colors.red
          //       ]),
          //     style: TextStyle(
          //       fontWeight: FontWeight.w600,
          //       fontSize: 14
          //     ),
          // ),
        ),
      ),
    );
  }

  cartItems(List<SectionModel> cartList) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: cartList.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return cartItem(index, cartList);
      },
    );
  }

  orderSummary(List<SectionModel> cartList) {
    return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated(context, 'ORDER_SUMMARY')! +
                    " (" +
                    cartList.length.toString() +
                    " items)",
                style: TextStyle(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .fontColor,
                    fontWeight: FontWeight.bold),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'SUBTOTAL')!,
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .lightBlack2),
                  ),
                  Text(
                    CUR_CURRENCY! + " " + oriPrice.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "GST & Service Charge",
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .lightBlack2),
                  ),
                  Text(
                    CUR_CURRENCY! + " " + gstPrice.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              extraDelCharge != 0
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Extra Delivery Charge",
                    //getTranslated(context, 'EXTRA_DELIVERY_CHARGE')!,
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .lightBlack2),
                  ),
                  Text(
                    CUR_CURRENCY! +
                        " " +
                        extraDelCharge.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
                  : SizedBox(
                height: 0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'DELIVERY_CHARGE')!,
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .lightBlack2),
                  ),
                  Text(
                    CUR_CURRENCY! + " " + delCharge.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              /*Row(
                children: [
                  Text('Packing charge',style: TextStyle(
                  color: Color(0xff999999),fontWeight: FontWeight.bold,
                  ),),SizedBox(width: 170,),
                  Text('₹ 0.00',style: TextStyle(
                    color: Color(0xff222222),fontWeight: FontWeight.bold,
                  ),),
                ],
              ),*/

              isPromoValid!
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'PROMO_CODE_DIS_LBL')!,
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .lightBlack2),
                  ),
                  Text(
                    "-" +
                        CUR_CURRENCY! +
                        " " +
                        promoAmt.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
                  : Container(),
              isUseWallet!
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'WALLET_BAL')!,
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .lightBlack2),
                  ),
                  Text(
                    CUR_CURRENCY! + " " + usedBal.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
                  : Container(),
            ],
          ),
        ));
  }

  Future<void> validatePromo(bool check) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);
        if (check) {
          if (this.mounted && checkoutState != null) checkoutState!(() {});
        }
        setState(() {});
        var parameter = {
          USER_ID: CUR_USERID,
          PROMOCODE: promoC.text,
          FINAL_TOTAL: oriPrice.toString()
        };
        print(parameter);
        print(validatePromoApi);
        Response response =
        await post(validatePromoApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"][0];

            totalPrice =
                double.parse(data["final_total"]) + delCharge + gstPrice;

            promoAmt = double.parse(data["final_discount"]);
            promocode = data["promo_code"];
            isPromoValid = true;
            Fluttertoast.showToast(
                msg: getTranslated(context, 'PROMO_SUCCESS')!,
                backgroundColor: colors.primary);
            // setSnackbar(getTranslated(context, 'PROMO_SUCCESS')!, _checkscaffoldKey);
          } else {
            isPromoValid = false;
            promoAmt = 0;
            promocode = null;
            promoC.clear();
            var data = getdata["data"];

            totalPrice =
                double.parse(data["final_total"]) + delCharge + gstPrice;

            setSnackbar(msg!, _checkscaffoldKey);
          }
          if (isUseWallet!) {
            remWalBal = 0;
            payMethod = null;
            usedBal = 0;
            isUseWallet = false;
            isPayLayShow = true;

            selectedMethod = null;
            context.read<CartProvider>().setProgress(false);
            if (mounted && check) checkoutState!(() {});
            setState(() {});
          } else {
            if (mounted && check) checkoutState!(() {});
            setState(() {});
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        if (mounted && check) checkoutState!(() {});
        setState(() {});
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      _isNetworkAvail = false;
      if (mounted && check) checkoutState!(() {});
      setState(() {});
    }
  }

  Future<void> flutterwavePayment() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          AMOUNT: totalPrice.toString(),
          USER_ID: CUR_USERID,
        };
        Response response =
        await post(flutterwaveApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["link"];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        PaypalWebview(
                          url: data,
                          from: "order",
                        )));
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
          }

          context.read<CartProvider>().setProgress(false);
        }
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted)
        checkoutState!(() {
          _isNetworkAvail = false;
        });
    }
  }

  void confirmDialog() {
    showGeneralDialog(
        barrierColor: Theme
            .of(context)
            .colorScheme
            .black
            .withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  contentPadding: const EdgeInsets.all(0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, 'CONFIRM_ORDER')!,
                              style: Theme
                                  .of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .fontColor),
                            )),
                        Divider(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .lightBlack),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'SUBTOTAL')!,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        oriPrice.toStringAsFixed(2),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "GST & Service Charge",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        gstPrice.toStringAsFixed(2),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'DELIVERY_CHARGE')!,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        delCharge.toStringAsFixed(2),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              isPromoValid!
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(
                                        context, 'PROMO_CODE_DIS_LBL')!,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    "-" +
                                        CUR_CURRENCY! +
                                        " " +
                                        promoAmt.toStringAsFixed(2),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                                  : Container(),
                              isUseWallet!
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'WALLET_BAL')!,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        usedBal.toStringAsFixed(2),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                                  : Container(),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getTranslated(context, 'TOTAL_PRICE')!,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .lightBlack2),
                                    ),
                                    Text(
                                      CUR_CURRENCY! +
                                          " ${totalPrice.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              // Container(
                              //     padding: EdgeInsets.symmetric(vertical: 10),
                              //     /* decoration: BoxDecoration(
                              //       color: colors.primary.withOpacity(0.1),
                              //       borderRadius: BorderRadius.all(
                              //         Radius.circular(10),
                              //       ),
                              //     ),*/
                              //     child: TextField(
                              //       controller: noteC,
                              //       style:
                              //           Theme.of(context).textTheme.subtitle2,
                              //       decoration: InputDecoration(
                              //         contentPadding:
                              //             EdgeInsets.symmetric(horizontal: 10),
                              //         border: InputBorder.none,
                              //         filled: true,
                              //         fillColor:
                              //             colors.primary.withOpacity(0.1),
                              //         //isDense: true,
                              //         hintText: getTranslated(context, 'NOTE'),
                              //       ),
                              //     )),
                            ],
                          ),
                        ),
                      ]),
                  actions: <Widget>[
                    new TextButton(
                        child: Text(getTranslated(context, 'CANCEL')!,
                            style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .lightBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          checkoutState!(() {
                            _placeOrder = true;
                          });
                          Navigator.pop(context);
                        }),
                    new TextButton(
                        child: Text(getTranslated(context, 'DONE')!,
                            style: TextStyle(
                                color: colors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);
                          doPayment();
                        })
                  ],
                )),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  void bankTransfer() {
    showGeneralDialog(
        barrierColor: Theme
            .of(context)
            .colorScheme
            .black
            .withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  contentPadding: const EdgeInsets.all(0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, 'BANKTRAN')!,
                              style: Theme
                                  .of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .fontColor),
                            )),
                        Divider(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .lightBlack),
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: Text(getTranslated(context, 'BANK_INS')!,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Text(
                            getTranslated(context, 'ACC_DETAIL')!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .fontColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'ACCNAME')! +
                                " : " +
                                acName!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'ACCNO')! + " : " + acNo!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'BANKNAME')! +
                                " : " +
                                bankName!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'BANKCODE')! +
                                " : " +
                                bankNo!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'EXTRADETAIL')! +
                                " : " +
                                exDetails!,
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle2,
                          ),
                        )
                      ]),
                  actions: <Widget>[
                    new TextButton(
                        child: Text(getTranslated(context, 'CANCEL')!,
                            style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .lightBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          checkoutState!(() {
                            _placeOrder = true;
                          });
                          Navigator.pop(context);
                        }),
                    new TextButton(
                        child: Text(getTranslated(context, 'DONE')!,
                            style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .fontColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);

                          context.read<CartProvider>().setProgress(true);

                          placeOrder('');
                        })
                  ],
                )),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  Future<void> checkDeliverable() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          USER_ID: CUR_USERID,
          ADD_ID: selAddress,
        };
        print(parameter.toString());
        Response response =
        await post(checkCartDelApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        var data = getdata["data"];
        context.read<CartProvider>().setProgress(false);

        if (error) {
          deliverableList = (data as List)
              .map((data) => new Model.checkDeliverable(data))
              .toList();

          checkoutState!(() {
            deliverable = false;
            _placeOrder = true;
          });

          setSnackbar(msg!, _checkscaffoldKey);
        } else {
          deliverableList = (data as List)
              .map((data) => new Model.checkDeliverable(data))
              .toList();

          checkoutState!(() {
            deliverable = true;
          });
          // Navigator.pop(context);
          doPayment();
          // confirmDialog();
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future<double> deliveryChargeApi(String km) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          'distance': newKms.toString(),
          'unit': '${unit.toString()}',
        };
        print("this is new del charge +++++++-----> ${parameter.toString()}");

        Response response =
        await post(deliveryCharge, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        var data = getdata['data'];
          delCharge = double.parse(data.toString());
          showDelCharge = getdata['data'];
        delCharge = double.parse(data.toString());
        print(getdata);
        print("KM this si  + ${km}");
        if (!error) {

          // for (var i = 0; i < charge.length; i++) {
          //   if (km >= double.parse(charge[i]["min_km"]) &&
          //       km <= double.parse(charge[i]["max_km"])) {
          //     setState(() {
          //       delCharge = double.parse(charge[i]["delivery_charge"]);
          //     });
          //   }
          // }
        } else {}
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
      return delCharge;
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
      return delCharge;
    }
  }
  String dCheckMsg = "";

  Future<String> getDeliveryKmsApi(double userLat, userLong, sellerLat,
      sellerLong) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          'user_latitude': '$userLat',
          'user_longitude': '$userLong',
          'seller_latitude': '$sellerLat',
          'seller_longitude': '$sellerLong'
        };
        print("this is new parameter ==========>>>>> ${parameter.toString()}");

        Response response =
        await post(getKmsApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);



        bool error = getdata["error"];
        String? msg = getdata["message"];
        String data = getdata["data"];
        List dat = data.split(' ');
        String kms = dat[0];
        newKms = kms;
        unit = dat[1];
        print("this is new dat %%%% ${data.toString()}");
        print(
            "this is our new data in kms @@@ $kms and %%% $unit"
        );
        delCharge = await deliveryChargeApi(newKms.toString());
        context.read<CartProvider>().setProgress(false);
        print(getdata);
        // print("KM + ${km}");
        if (!error) {
          // delCharge = double.parse(kms.toString());
          // for (var i = 0; i < charge.length; i++) {
          //   if (km >= double.parse(charge[i]["min_km"]) &&
          //       km <= double.parse(charge[i]["max_km"])) {
          //     delCharge = double.parse(charge[i]["delivery_charge"]);
          //   }
          // }
        } else {}
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
      return newKms.toString();
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
      return newKms.toString();
    }
  }
  bool isdeliverable = false;

  Future<String> getDeliveryRadiusApi() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {

      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          'distance': '${newKms.toString()}',
          USER_ID: CUR_USERID,
          'type': '${unit.toString()}',
        };
        print("this is new radius ###### ${parameter.toString()}");

        Response response =
        await post(getDeliveryRadiusUrl, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        if(error == false){
          setState(() {
            isdeliverable = true;
          });
        }
        dCheckMsg = getdata["message"];
        print(
            "this is our new data for check deliverable @@@ $dCheckMsg"
        );
        if (error) {
          setState((){
            deliverableRadius = true;
          });
          print("dddddd");
          Fluttertoast.showToast(msg: dCheckMsg);
          print("this is our status #### $deliverableRadius");
        } else {
          Fluttertoast.showToast(msg: dCheckMsg);
          print("this is our status #### $deliverableRadius");
          // Fluttertoast.showToast(msg: dCheckMsg);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
      return dCheckMsg;
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
      return dCheckMsg;
    }
  }
}