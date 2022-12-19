import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';


import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/showDialog.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Model/AddRatingModel.dart';
import 'package:eshop_multivendor/Model/Order_Model.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Cart.dart';
import 'package:eshop_multivendor/Screen/Customer_Support.dart';
import 'package:eshop_multivendor/Screen/Dashboard.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/Seller_Details.dart';

import 'package:eshop_multivendor/Screen/live_track/map.dart';
import 'package:eshop_multivendor/Screen/live_track/new_live_tracker.dart';
import 'package:eshop_multivendor/api/reorder_response.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

// import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/User.dart';
import 'live_track.dart';

class OrderDetail extends StatefulWidget {
   OrderModel? model;
  final sellerId;
  final orderId;

  // final Function? updateHome;

   OrderDetail({Key? key, this.model, this.sellerId, this.orderId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

List<OrderModel> searchList = [];
Timer? timer,timer1;
class StateOrder extends State<OrderDetail>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  List<User> tempList = [];
  late bool _isCancleable, _isReturnable;
  bool _isProgress = false;
  int offset = 0;
  int total = 0;
  List<User> reviewList = [];
  bool isLoadingmore = true;
  bool _isReturnClick = true;
  String? proId, image;
  String? activeStatus;
  String? orderStatus;
  String _searchText = "", _lastsearch = "";
  bool isGettingdata = false, isNodata = false;
  bool _isLoading = true;
  final InAppReview _inAppReview = InAppReview.instance;
  List<File> files = [];
  String _phone = '+918069484988';
  bool _hasCallSupport = false;
  Future<void>? _launched;

  int _selectedTabIndex = 0;
  late TabController _tabController;

  List<File> reviewPhotos = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  TextEditingController commentTextController = TextEditingController();
  double curRating = 0.0;
  var rateSeller = false;

  @override
  void initState() {
    super.initState();
    model = widget.model!;
    getStatus();
    files.clear();
    reviewPhotos.clear();
    buttonController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: Interval(
        0.0,
        0.150,
      ),
    ));
    _tabController = TabController(
      length: 5,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });

    canLaunch('tel:123').then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

  @override
  void dispose() {

    if(timer!=null){
      timer!.cancel();
    }
    if(timer1!=null){
      timer1!.cancel();
    }
    buttonController!.dispose();
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
  var model;
  String? pDate, prDate, sDate, pickDate, dDate, cDate, rDate;

  getStatus(){
    if(model!=null) {
      setState(() {
        if (model.listStatus.contains(PLACED)) {
          pDate = model.listDate![model.listStatus.indexOf(PLACED)];

          if (pDate != null) {
            List d = pDate!.split(" ");
            pDate = d[0] + "\n" + d[1];
          }
        }

        if (model.listStatus.contains(CONFIRMED)) {
          prDate = model.listDate![model.listStatus.indexOf(CONFIRMED)];
          if (prDate != null) {
            List d = prDate!.split(" ");
            prDate = d[0] + "\n" + d[1];
          }
        }

        if (model.listStatus.contains(ARRIVED)) {
          sDate = model.listDate![model.listStatus.indexOf(ARRIVED)];
          if (sDate != null) {
            List d = sDate!.split(" ");
            sDate = d[0] + "\n" + d[1];
          }
        }

        if (model.listStatus.contains(PICKED)) {
          pickDate = model.listDate![model.listStatus.indexOf(PICKED)];
          if (pickDate != null) {
            List d = pickDate!.split(" ");
            pickDate = d[0] + "\n" + d[1];
          }
        }

        if (model.listStatus.contains(DELIVERD)) {
          dDate = model.listDate![model.listStatus.indexOf(DELIVERD)];
          if (dDate != null) {
            List d = dDate!.split(" ");
            dDate = d[0] + "\n" + d[1];
          }
        }
        if (model.listStatus.contains(CANCLED)) {
          cDate = model.listDate![model.listStatus.indexOf(CANCLED)];
          if (cDate != null) {
            List d = cDate!.split(" ");
            cDate = d[0] + "\n" + d[1];
          }
        }
        if (model.listStatus.contains(RETURNED)) {
          rDate = model.listDate![model.listStatus.indexOf(RETURNED)];
          if (rDate != null) {
            List d = rDate!.split(" ");
            rDate = d[0] + "\n" + d[1];
          }
        }

        _isCancleable = model.isCancleable == "1" ? true : false;
        _isReturnable = model.isReturnable == "1" ? true : false;
        print(model.listStatus);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;


    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        // appBar: getSimpleAppBar(getTranslated(context, "ORDER_DETAIL")!, context),
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          backgroundColor: Theme.of(context).colorScheme.white,
          leading: Builder(builder: (BuildContext context) {
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
          }),
          title: Text(
            getTranslated(context, "ORDER_DETAIL")!,
            style: TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
          ),
          actions: [
            InkWell(
              onTap: (){
                _refresh();
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(Icons.refresh, color: colors.primary,size: 30,),
              ),
            )
          ],
        ),
        body: _isNetworkAvail
            ? RefreshIndicator(
            color: colors.primary,
            key: _refreshIndicatorKey,
            onRefresh: _refresh,
              child: model!=null&&widget.model!=null?Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    model.itemList![0].status != DELIVERD&&model.itemList![0].status != CANCLED&&model.itemList![0].status != RETURNED?Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.4,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: MapPage(
                          true,
                          live: model.itemList![0].status == PICKED ||
                              model.itemList![0].status == CONFIRMED ||
                              model.itemList![0].status == ARRIVED||model.itemList![0].status == "assign"?true:false,
                          SOURCE_LOCATION: LatLng(double.parse(model.itemList![0].sellerLat.toString()),double.parse(model.itemList![0].sellerLong.toString())),
                          DEST_LOCATION: LatLng(double.parse(model.lat.toString()),double.parse(model.long.toString())),
                          id: model.itemList![0].del_id,
                          approxTime:model.itemList![0].estimated_time ,
                        ),
                      ),
                    ):SizedBox(),
                    Container(
                      margin: EdgeInsets.only(top: model.itemList![0].status != DELIVERD&&model.itemList![0].status != CANCLED&&model.itemList![0].status != RETURNED?MediaQuery.of(context).size.height*0.4:0),
                      child: getOrderDetails(model),
                    ),

                    model.listStatus.contains(DELIVERD)
                        ? InkWell(
                            onTap: () {
                              addToCart("1", true, model.itemList);
                            },
                            child: Column(
                              children: [
                                Container(
                                    width: MediaQuery.of(context).size.width - 10,
                                    height: 48,
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: colors.primary,
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Text(
                                      "Reorder Now",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ],
                            ),
                          )
                        : Container(),
                    Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: getSubHeadingsTabBar(),
                        // ),
                        // Expanded(
                        //   child: TabBarView(
                        //     controller: _tabController,
                        //     children: [
                        //       getOrderDetails(model),
                        //       SingleChildScrollView(
                        //         child: Padding(
                        //           padding:
                        //               const EdgeInsets.symmetric(horizontal: 8.0),
                        //           child: getSingleProduct(model, PROCESSED),
                        //         ),
                        //       ),
                        //       SingleChildScrollView(
                        //         child: Padding(
                        //           padding:
                        //               const EdgeInsets.symmetric(horizontal: 8.0),
                        //           child: getSingleProduct(model, DELIVERD),
                        //         ),
                        //       ),
                        //       SingleChildScrollView(
                        //         child: Padding(
                        //           padding:
                        //               const EdgeInsets.symmetric(horizontal: 8.0),
                        //           child: getSingleProduct(model, CANCLED),
                        //         ),
                        //       ),
                        //       SingleChildScrollView(
                        //         child: Padding(
                        //           padding:
                        //               const EdgeInsets.symmetric(horizontal: 8.0),
                        //           child: getSingleProduct(model, RETURNED),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Expanded(
                        //   child: getOrderDetails(model),
                        // ),
                        // (!widget.model!.itemList![0].listStatus!
                        //             .contains(DELIVERD) &&
                        //         (!widget.model!.itemList![0].listStatus!
                        //             .contains(RETURNED)) &&
                        //         _isCancleable &&
                        //         widget.model!.itemList![0].isAlrCancelled == "0")
                        //     ? cancelable()
                        //     : (widget.model!.itemList![0].listStatus!
                        //                 .contains(DELIVERD) &&
                        //             _isReturnable &&
                        //             widget.model!.itemList![0].isAlrReturned == "0")
                        //         ? returnable()
                        //         : Container(),
                      ],
                    ),
                    showCircularProgress(_isProgress, colors.primary),
                  ],
                ):Center(child: CircularProgressIndicator(),),
            )
            : noInternet(context),
      ),
    );
  }

  /*  returnable() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [colors.grad1Color, colors.grad2Color],
            stops: [0, 1]),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.black26, blurRadius: 10)],
      ),
      width: deviceWidth,
      child: InkWell(
        onTap: _isReturnClick
            ? () {
          setState(() {
            _isReturnClick = false;
            _isProgress = true;
          });
          cancelOrder(RETURNED, updateOrderApi, widget.model!.id);
        }
            : null,
        child: Center(
            child: Text(
              getTranslated(context, 'RETURN_ORDER')!,
              style: Theme
                  .of(context)
                  .textTheme
                  .button!
                  .copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.white),
            )),
      ),
    );
  }*/
  /* cancelable() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [colors.grad1Color, colors.grad2Color],
            stops: [0, 1]),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.black26, blurRadius: 10)],
      ),
      width: deviceWidth,
      child: InkWell(
        onTap: _isReturnClick
            ? () {
          setState(() {
            _isReturnClick = false;
            _isProgress = true;
          });
          cancelOrder(CANCLED, updateOrderApi, widget.model!.id);
        }
            : null,
        child: Center(
            child: Text(
              getTranslated(context, 'CANCEL_ORDER')!,
              style: Theme
                  .of(context)
                  .textTheme
                  .button!
                  .copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.white),
            )),
      ),
    );
  }*/

  Future<Null> _refresh() async{
    if (mounted) {
      setState(() {
        offset = 0;
        total = 0;
        isLoadingmore = true;
        _isLoading = true;
      });
    }
    await getOrder();
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
  priceDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(getTranslated(context, 'PRICE_DETAIL')!,
                          style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding:
                        const EdgeInsetsDirectional.only(top: 5.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,color:widget.model!.itemList![0].status==DELIVERD||widget.model!.payMethod.toString()!="COD"?Colors.green:Colors.red,),
                            AnimatedTextKit(
                              animatedTexts: [
                                ColorizeAnimatedText(
                                  widget.model!.itemList![0].status==DELIVERD|| widget.model!.payMethod.toString()!="COD"?"Paid":"COD",
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
                          ],
                        ),
                      ),
                    ],
                  )),
              Divider(
                color: Theme.of(context).colorScheme.lightBlack,
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${getTranslated(context, 'PRICE_LBL')!}(Include Packaging Charge) :",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2)),
                    Text("${CUR_CURRENCY!} ${widget.model!.subTotal!}",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2))
                  ],
                ),
              ),
             /*     widget.model!.packagingCharge!=null?Padding(
                    padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Packaging Charge :",
                            style: Theme.of(context).textTheme.button!.copyWith(
                                color: Theme.of(context).colorScheme.lightBlack2)),
                        Text("-${CUR_CURRENCY!} ${widget.model!.packagingCharge.toString()}",
                            style: Theme.of(context).textTheme.button!.copyWith(
                                color: Theme.of(context).colorScheme.lightBlack2))
                      ],
                    ),
                  ):SizedBox(),*/
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("GST & Service Charges" + " " + ":",
                            style: Theme.of(context).textTheme.button!.copyWith(
                                color: Theme.of(context).colorScheme.lightBlack2)),
                        Text("+ " + CUR_CURRENCY! + " " + widget.model!.gst_service_charge_amount!,
                            style: Theme.of(context).textTheme.button!.copyWith(
                                color: Theme.of(context).colorScheme.lightBlack2))
                      ],
                    ),
                  ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslated(context, 'DELIVERY_CHARGE')! + " " + ":",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2)),
                    Text("+ " + CUR_CURRENCY! + " " + widget.model!.delCharge!,
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2))
                  ],
                ),
              ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(getTranslated(context, 'EXTRA_DELIVERY_CHARGE')! + " " + ":",
                            style: Theme.of(context).textTheme.button!.copyWith(
                                color: Theme.of(context).colorScheme.lightBlack2)),
                        Text("+ " + CUR_CURRENCY! + " " + widget.model!.extraDelCharge!,
                            style: Theme.of(context).textTheme.button!.copyWith(
                                color: Theme.of(context).colorScheme.lightBlack2))
                      ],
                    ),
                  ),

              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        getTranslated(context, 'PROMO_CODE_DIS_LBL')! +
                            " " +
                            ":",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2)),
                    Text("- " + CUR_CURRENCY! + " " + widget.model!.promoDis!,
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslated(context, 'WALLET_BAL')! + " " + ":",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2)),
                    Text("- " + CUR_CURRENCY! + " " + widget.model!.walBal!,
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2))
                  ],
                ),
              ),
              // Padding(
              //   padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(getTranslated(context, 'PAYABLE') + " " + ":",
              //           style: Theme.of(context)
              //               .textTheme
              //               .button
              //               .copyWith(color: Theme.of(context).colorScheme.lightBlack2)),
              //       Text(CUR_CURRENCY + " " + widget.model.payable,
              //           style: Theme.of(context)
              //               .textTheme
              //               .button
              //               .copyWith(color: Theme.of(context).colorScheme.lightBlack2))
              //     ],
              //   ),
              // ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    start: 15.0, end: 15.0, top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslated(context, 'PAYABLE')! + " " + ":",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold)),
                    Text(CUR_CURRENCY! + " " + widget.model!.payable!,
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ])));
  }

  shippingDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                  child: Text(getTranslated(context, 'SHIPPING_DETAIL')!,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold))),
              Divider(
                color: Theme.of(context).colorScheme.lightBlack,
              ),
              Padding(
                  padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                  child: Text(
                    widget.model!.name.toString() + ",",
                  )),
              Padding(
                  padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                  child: Text(widget.model!.address!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack2))),
              Padding(
                  padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                  child: Text(widget.model!.mobile!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2,
                      ))),
            ])));
  }

  productItem(OrderItem orderItem, OrderModel model, index) {
    String? pDate, prDate,asDate, arDate, picDate, sDate, dDate, cDate, rDate, aDate;
     print(orderItem.listStatus);
    if (orderItem.listStatus!.contains(WAITING)) {
      aDate = orderItem.listDate![orderItem.listStatus!.indexOf(WAITING)];
    }
    if (orderItem.listStatus!.contains(PLACED)) {
      pDate = orderItem.listDate![orderItem.listStatus!.indexOf(PLACED)];
    }
    if (orderItem.listStatus!.contains(CONFIRMED)) {
      prDate = orderItem.listDate![orderItem.listStatus!.indexOf(CONFIRMED)];
    }
    if (orderItem.listStatus!.contains(ASSIGN)) {
      asDate = orderItem.listDate![orderItem.listStatus!.indexOf(ASSIGN)];
    }
    if (orderItem.listStatus!.contains(ARRIVED)) {
      arDate = orderItem.listDate![orderItem.listStatus!.indexOf(ARRIVED)];
    }

    if (orderItem.listStatus!.contains(PICKED)) {
      picDate = orderItem.listDate![orderItem.listStatus!.indexOf(PICKED)];
    }

    if (orderItem.listStatus!.contains(SHIPED)) {
      sDate = orderItem.listDate![orderItem.listStatus!.indexOf(SHIPED)];
    }
    if (orderItem.listStatus!.contains(DELIVERD)) {
      dDate = orderItem.listDate![orderItem.listStatus!.indexOf(DELIVERD)];
    }
    if (orderItem.listStatus!.contains(CANCLED)) {
      cDate = orderItem.listDate![orderItem.listStatus!.indexOf(CANCLED)];
    }
    if (orderItem.listStatus!.contains(RETURNED)) {
      rDate = orderItem.listDate![orderItem.listStatus!.indexOf(RETURNED)];
    }
    List att = [], val = [];
    if (orderItem.attr_name!.isNotEmpty) {
      att = orderItem.attr_name!.split(',');
      val = orderItem.varient_values!.split(',');
    }

    return Column(
      children: [
        index != 0
            ? Container()
            : Divider(
                color: Theme.of(context).colorScheme.lightBlack,
              ),
        index != 0
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    pDate != null ? getPlaced(pDate) : getPlaced(aDate!),
                    getConfirmed(prDate, cDate),
                    getAssigned(asDate, cDate , orderItem),
                    getArrived(arDate, cDate),
                    getPicked(picDate, cDate),
                    // getShipped(sDate, cDate),
                    getDelivered(dDate, cDate),
                    getCanceled(cDate),
                    getReturned(orderItem, rDate, model),
                  ],
                ),
              ),
        index != 0
            ? Container()
            : Divider(
                color: Theme.of(context).colorScheme.lightBlack,
              ),
        index != 0
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${getTranslated(context, "STORE_NAME")!} : ",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Delivery Boy : ",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontWeight: FontWeight.bold),
                          ),
                          // Text(
                          //   "${getTranslated(context, "OTP")!} : ",
                          //   style: TextStyle(
                          //       color: Theme.of(context).colorScheme.lightBlack,
                          //       fontWeight: FontWeight.bold),
                          // ),

                          orderItem.courier_agency! != ""
                              ? Text(
                                  "${getTranslated(context, 'COURIER_AGENCY')!}: ",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(),
                          orderItem.tracking_id! != ""
                              ? Text(
                                  "${getTranslated(context, 'TRACKING_ID')!}: ",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            child: !loading?Text(
                              "${orderItem.store_name}",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack2,
                                  decoration: TextDecoration.underline),
                            ):CircularProgressIndicator(),
                            onTap: () {
                              setState(() {
                                loading = true;
                              });
                              getSeller(orderItem.seller_id.toString());
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => SellerProfile(
                              //           sellerStoreName: orderItem.store_name,
                              //           sellerRating: orderItem.seller_rating,
                              //           sellerImage: orderItem.seller_profile,
                              //           sellerName: orderItem.seller_name,
                              //           sellerID: orderItem.seller_id,
                              //           storeDesc: orderItem.store_description,
                              //         )));
                            },
                          ),
                          Text(
                            "${orderItem.delivery_boy_name} ",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.lightBlack2,
                            ),
                          ),
                          // Text(
                          //   "${orderItem.item_otp} ",
                          //   style: TextStyle(
                          //     color: Theme.of(context).colorScheme.lightBlack2,
                          //   ),
                          // ),
                          orderItem.courier_agency! != ""
                              ? Text(
                                  "${orderItem.courier_agency!}",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack2,
                                  ),
                                )
                              : Container(),
                          orderItem.tracking_id! != ""
                              ? RichText(
                                  text: TextSpan(children: [
                                  TextSpan(
                                    text: "",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                      text: "${orderItem.courier_agency!}",
                                      style: const TextStyle(
                                          color: colors.primary,
                                          decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          var url = "${orderItem.tracking_url}";

                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            setSnackbar(getTranslated(
                                                context, 'URL_ERROR')!);
                                          }
                                        })
                                ]))
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        Card(
            elevation: 0,
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(7.0),
                            child: FadeInImage(
                              fadeInDuration: Duration(milliseconds: 150),
                              image:
                                  CachedNetworkImageProvider(orderItem.image!),
                              height: 50.0,
                              width: 50.0,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) =>
                                  erroWidget(90),
                              placeholder: placeHolder(90),
                            )),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        orderItem.name.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                                fontWeight: FontWeight.normal),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 5.0),
                                      child: Text(
                                        "${orderItem.qty.toString()} x ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack),
                                      ),
                                    ),
                                    Text(
                                      CUR_CURRENCY! + " " + orderItem.price.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          addToCart(
                                              "1", true, orderItem.varientId);
                                        },
                                        icon: Icon(Icons.add_shopping_cart))
                                  ],
                                ),
                                orderItem.attr_name!.isNotEmpty
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
                                                            .lightBlack2),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      start: 5.0),
                                              child: Text(
                                                val[index],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .lightBlack),
                                              ),
                                            )
                                          ]);
                                        })
                                    : Container(),
                                //  Text(orderItem.status)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0, top: 5),
                      height: files.length > 0 ? 180 : 0,
                      child: Row(
                        children: [
                          Expanded(
                              child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: files.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              return InkWell(
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Image.file(
                                      files[i],
                                      width: 180,
                                      height: 180,
                                    ),
                                    Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .black26,
                                        child: Icon(
                                          Icons.clear,
                                          size: 15,
                                        ))
                                  ],
                                ),
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      files.removeAt(i);
                                    });
                                  }
                                },
                              );
                            },
                          )),
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.lightWhite,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(4.0))),
                              child: Text(
                                getTranslated(context, 'SUBMIT_LBL')!,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              ),
                            ),
                            onTap: () {
                              sendBankProof();
                            },
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (orderItem.status == DELIVERD)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                rateSeller = false;
                                openBottomSheet(context, orderItem.productId);
                              },
                              icon: Icon(Icons.rate_review_outlined,
                                  color: colors.primary),
                              label: Text(
                                getTranslated(context, "WRITE_REVIEW_LBL")!,
                                style: TextStyle(color: colors.primary),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.btnColor),
                              ),
                            ),
                          ),
                        SizedBox(
                          width: 15,
                        ),
                        if (orderItem.status == DELIVERD)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                rateSeller = true;
                                openBottomSheet(context, orderItem.productId);
                              },
                              icon: Icon(Icons.rate_review_outlined,
                                  color: colors.primary),
                              label: Text(
                                "Rate Shop",
                                style: TextStyle(color: colors.primary),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.btnColor),
                              ),
                            ),
                          ),
                        if (!orderItem.listStatus!.contains(DELIVERD) &&
                            (!orderItem.listStatus!.contains(RETURNED)) &&
                            orderItem.isCancle == "1" &&
                            orderItem.isAlrCancelled == "0")
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 8.0),
                          //   child: Align(
                          //       alignment: Alignment.bottomRight,
                          //       child: OutlinedButton(
                          //         onPressed: _isReturnClick
                          //             ? () {
                          //                 showDialog(
                          //                   context: context,
                          //                   builder: (BuildContext context) {
                          //                     return AlertDialog(
                          //                       title: Text(
                          //                         getTranslated(
                          //                             context, 'ARE_YOU_SURE?')!,
                          //                         style: TextStyle(
                          //                             color: Theme.of(context)
                          //                                 .colorScheme
                          //                                 .fontColor),
                          //                       ),
                          //                       content: Text(
                          //                         "Would you like to cancel this product?",
                          //                         style: TextStyle(
                          //                             color: Theme.of(context)
                          //                                 .colorScheme
                          //                                 .fontColor),
                          //                       ),
                          //                       actions: [
                          //                         TextButton(
                          //                           child: Text(
                          //                             getTranslated(
                          //                                 context, 'YES')!,
                          //                             style: TextStyle(
                          //                                 color: colors.primary),
                          //                           ),
                          //                           onPressed: () {
                          //                             Navigator.pop(context);
                          //                             setState(() {
                          //                               _isReturnClick = false;
                          //                               _isProgress = true;
                          //                             });
                          //                             cancelOrder(
                          //                                 CANCLED,
                          //                                 updateOrderItemApi,
                          //                                 orderItem.id);
                          //                           },
                          //                         ),
                          //                         TextButton(
                          //                           child: Text(
                          //                             getTranslated(context, 'NO')!,
                          //                             style: TextStyle(
                          //                                 color: colors.primary),
                          //                           ),
                          //                           onPressed: () {
                          //                             Navigator.pop(context);
                          //                           },
                          //                         )
                          //                       ],
                          //                     );
                          //                   },
                          //                 );
                          //               }
                          //             : null,
                          //         child:
                          //             Text(getTranslated(context, 'ITEM_CANCEL')!),
                          //       )),
                          // )
                          Container()
                        else
                          (orderItem.listStatus!.contains(DELIVERD) &&
                                  orderItem.isReturn == "1" &&
                                  orderItem.isAlrReturned == "0")
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: OutlinedButton(
                                    onPressed: _isReturnClick
                                        ? () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    getTranslated(context,
                                                        'ARE_YOU_SURE?')!,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor),
                                                  ),
                                                  content: Text(
                                                    "Would you like to return this product?",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: Text(
                                                        getTranslated(
                                                            context, 'YES')!,
                                                        style: TextStyle(
                                                            color:
                                                                colors.primary),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          _isReturnClick =
                                                              false;
                                                          _isProgress = true;
                                                        });
                                                        cancelOrder(
                                                            RETURNED,
                                                            updateOrderItemApi,
                                                            orderItem.id);
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        getTranslated(
                                                            context, 'NO')!,
                                                        style: TextStyle(
                                                            color:
                                                                colors.primary),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        : null,
                                    child: Text(
                                        getTranslated(context, 'ITEM_RETURN')!),
                                  ),
                                )
                              : Container(),
                      ],
                    ),
                  ],
                ))),
      ],
    );
  }

  bankProof(OrderModel model) {
    String status = model.attachList![0].bankTranStatus!;
    Color clr;
    if (status == "0") {
      status = "Pending";
      clr = Colors.cyan;
    } else if (status == "1") {
      status = "Rejected";
      clr = Colors.red;
    } else {
      status = "Accepted";
      clr = Colors.green;
    }

    return Card(
        elevation: 0,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: model.attachList!.length,
                  //scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        child: Text(
                          "Attachment " + (i + 1).toString(),
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).colorScheme.fontColor),
                        ),
                        onTap: () {
                          _launchURL(model.attachList![i].attachment!);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
                decoration: BoxDecoration(
                    color: clr, borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(status),
                ))
          ],
        ));
  }

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  _imgFromGallery() async {
    var result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();
      if (mounted) setState(() {});
    } else {
      // User canceled the picker
    }
  }

  Future<Null> getOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (isLoadingmore) {
          if (mounted) {
            setState(() {
              isLoadingmore = false;
              isGettingdata = true;
              if (offset == 0) {
                searchList = [];
              }
            });
          }
          if (CUR_USERID != null) {
            var parameter = {
              USER_ID: CUR_USERID,
            //  "order_id":widget.model!.id.toString(),
              OFFSET: offset.toString(),
              LIMIT: perPage.toString(),
              SEARCH: _searchText.trim(),
              SEARCH: _searchText.trim(),
              // "download_invoice": 1
            };
            if (activeStatus != null) {
              if (activeStatus == awaitingPayment) activeStatus = "awaiting";
              parameter[ACTIVE_STATUS] = activeStatus;
            }
            print(getOrderApi);
            print(parameter);
            Response response =
            await post(getOrderApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

            var getdata = json.decode(response.body);
            print(getdata);
            bool error = getdata["error"];

            isGettingdata = false;
            if (offset == 0) isNodata = error;
            String orderId = widget.model!.id.toString();
            setState(() {
              model =  null;
              widget.model = null;
            });
            print(model);
            if (!error) {
              // total = int.parse(getdata["total"]);

              //  if ((offset) < total) {
              var data = getdata["data"];
              if (data.length != 0) {
                List<OrderModel> items = [];
                List<OrderModel> allitems = [];

                items.addAll((data as List)
                    .map((data) => OrderModel.fromJson(data))
                    .toList());
                orderStatus = items[0].activeStatus;
                allitems.addAll(items);
                for (OrderModel item in items) {
                  searchList.where((i) => i.id == item.id).map((obj) {
                    allitems.remove(item);
                    return obj;
                  }).toList();
                }
                searchList.addAll(allitems);
                setState(() {
                  widget.model = searchList[searchList.indexWhere((element) => element.id==orderId)];
                    model = searchList[searchList.indexWhere((element) => element.id==orderId)];

                });
                getStatus();
                isLoadingmore = true;
                offset = offset + perPage;
              } else {
                isLoadingmore = false;
              }
            } else {
              isLoadingmore = false;
            }

            if (mounted) {
              setState(() {
                _isLoading = false;
                //isLoadingmore = false;
              });
            }
          } else {
            if (mounted) if (mounted) {
              setState(() {
                isLoadingmore = false;
                //msg = goToLogin;
              });
            }

            Future.delayed(Duration(seconds: 1)).then((_) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            });
          }
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            isLoadingmore = false;
          });
        }
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
      }
    }

    return null;
  }

  getPlaced(String pDate) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.circle,
          color: colors.primary,
          size: 15,
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated(context, 'ORDER_NPLACED')!,
                style: TextStyle(fontSize: 8),
              ),
              Text(
                pDate,
                style: TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  getConfirmed(String? prDate, String? cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: prDate == null ? Colors.grey : colors.primary,
                      )),
                  Icon(
                    Icons.circle,
                    color: prDate == null ? Colors.grey : colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER CONFIRMED",
                      style: TextStyle(fontSize: 8),
                    ),
                    Text(
                      prDate ?? " ",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          )
        : prDate == null
            ? SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        child: VerticalDivider(
                          thickness: 2,
                          color: colors.primary,
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        color: colors.primary,
                        size: 15,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(start: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, 'ORDER_PROCESSED')!,
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(
                          prDate,
                          style: TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }

  getAssigned(String? prDate, String? cDate ,OrderItem orderItem) {
    return cDate == null
        ? Row(
      crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: prDate == null ? Colors.grey : colors.primary,
                      )),
                  Icon(
                    Icons.circle,
                    color: prDate == null ? Colors.grey : colors.primary,
                    size: 15,
                  ),

                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DB-ASSIGNED-${orderItem.delivery_boy_name}",
                      style: TextStyle(fontSize: 8),
                    ),
                    //  orderItem.del_id!=null?Text("${orderItem.delivery_boy_name}",style: TextStyle(fontSize: 8),):Container(),
                    Text(
                      prDate ?? " ",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          )
        : prDate == null
            ? Container()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        child: VerticalDivider(
                          thickness: 2,
                          color: colors.primary,
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        color: colors.primary,
                        size: 15,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(start: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, 'ORDER_PROCESSED')!,
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(
                          prDate,
                          style: TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }

  getArrived(String? prDate, String? cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: prDate == null ? Colors.grey : colors.primary,
                      )),
                  Icon(
                    Icons.circle,
                    color: prDate == null ? Colors.grey : colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DB-ARRIVED",
                      style: TextStyle(fontSize: 8),
                    ),
                    Text(
                      prDate ?? " ",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          )
        : prDate == null
            ? Container()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        child: VerticalDivider(
                          thickness: 2,
                          color: colors.primary,
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        color: colors.primary,
                        size: 15,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(start: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, 'ORDER_PROCESSED')!,
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(
                          prDate,
                          style: TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }

  getPicked(String? prDate, String? cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: prDate == null ? Colors.grey : colors.primary,
                      )),
                  Icon(
                    Icons.circle,
                    color: prDate == null ? Colors.grey : colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER-PICKED",
                      style: TextStyle(fontSize: 8),
                    ),
                    Text(
                      prDate ?? " ",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          )
        : prDate == null
            ? Container()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        child: VerticalDivider(
                          thickness: 2,
                          color: colors.primary,
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        color: colors.primary,
                        size: 15,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(start: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, 'ORDER_PROCESSED')!,
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(
                          prDate,
                          style: TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }

  getShipped(String? sDate, String? cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: sDate == null ? Colors.grey : colors.primary,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: sDate == null ? Colors.grey : colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER PICKUP",
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      sDate ?? " ",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          )
        : sDate == null
            ? Container()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 30,
                        child: VerticalDivider(
                          thickness: 2,
                          color: colors.primary,
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        color: colors.primary,
                        size: 15,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(start: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, 'ORDER_SHIPPED')!,
                          style: TextStyle(fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          sDate,
                          style: TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }

  getDelivered(String? dDate, String? cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: dDate == null ? Colors.grey : colors.primary,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: dDate == null ? Colors.grey : colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER DELIVERED",
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      dDate ?? " ",
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  getCanceled(String? cDate) {
    return cDate != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: colors.primary,
                    ),
                  ),
                  Icon(
                    Icons.cancel_rounded,
                    color: colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'ORDER_CANCLED')!,
                      style: TextStyle(fontSize: 8),
                    ),
                    Text(
                      cDate,
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  getReturned(OrderItem item, String? rDate, OrderModel model) {
    return item.listStatus!.contains(RETURNED)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: colors.primary,
                    ),
                  ),
                  Icon(
                    Icons.cancel_rounded,
                    color: colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, 'ORDER_RETURNED')!,
                        style: TextStyle(fontSize: 8),
                      ),
                      Text(
                        rDate ?? " ",
                        style: TextStyle(fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
            ],
          )
        : Container();
  }

  Future<void> cancelOrder(String status, Uri api, String? id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {ORDERID: id, STATUS: status};
        var response = await post(api, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          Future.delayed(Duration(seconds: 1)).then((_) async {
            Navigator.pop(context, 'update');
          });
        }

        if (mounted) {
          setState(() {
            _isProgress = false;
            _isReturnClick = true;
          });
        }
        setSnackbar(msg);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
          _isReturnClick = true;
        });
      }
    }
  }

  setSnackbar(String msg) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

  // DwnInvoice() {
  //   return Card(
  //     elevation: 0,
  //     child: InkWell(
  //         child: ListTile(
  //           dense: true,
  //           trailing: Icon(
  //             Icons.keyboard_arrow_right,
  //             color: colors.primary,
  //           ),
  //           leading: Icon(
  //             Icons.receipt,
  //             color: colors.primary,
  //           ),
  //           title: Text(
  //             getTranslated(context, 'DWNLD_INVOICE')!,
  //             style: Theme.of(context)
  //                 .textTheme
  //                 .subtitle2!
  //                 .copyWith(color: Theme.of(context).colorScheme.lightBlack),
  //           ),
  //         ),
  //         onTap: () async {
  //           final status = await Permission.storage.request();
  //
  //           if (status == PermissionStatus.granted) {
  //             if (mounted) {
  //               setState(() {
  //                 _isProgress = true;
  //               });
  //             }
  //             var targetPath;
  //
  //             if (Platform.isIOS) {
  //               var target = await getApplicationDocumentsDirectory();
  //               targetPath = target.path.toString();
  //             } else {
  //               var target = await getApplicationDocumentsDirectory();
  //               targetPath = target.path.toString();
  //             }
  //
  //             var targetFileName = "Invoice_${widget.model!.id}";
  //             var generatedPdfFile, filePath;
  //             try {
  //               generatedPdfFile =
  //                   await FlutterHtmlToPdf.convertFromHtmlContent(
  //                       widget.model!.invoice!, targetPath, targetFileName);
  //               filePath = generatedPdfFile.path;
  //             } on Exception {
  //                filePath = targetPath + "/" + targetFileName + ".html";
  //               generatedPdfFile =
  //                   await FlutterHtmlToPdf.convertFromHtmlContent(
  //                       widget.model!.invoice!, targetPath, targetFileName);
  //               filePath = generatedPdfFile.path;
  //             }
  //
  //             if (mounted) {
  //               setState(() {
  //                 _isProgress = false;
  //               });
  //             }
  //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //               content: Text(
  //                 "${getTranslated(context, 'INVOICE_PATH')} $targetFileName",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(color: Theme.of(context).colorScheme.black),
  //               ),
  //               action: SnackBarAction(
  //                   label: getTranslated(context, 'VIEW')!,
  //                   textColor: Theme.of(context).colorScheme.fontColor,
  //                   onPressed: () async {
  //                     // final result = await OpenFile.open(filePath);
  //                   }),
  //               backgroundColor: Theme.of(context).colorScheme.white,
  //               elevation: 1.0,
  //             ));
  //           }
  //         }),
  //   );
  // }
  // downloadInvoice() {
  //   return Card(
  //     elevation: 0,
  //     child: InkWell(
  //         child: ListTile(
  //           dense: true,
  //           trailing: Icon(
  //             Icons.keyboard_arrow_right,
  //             color: colors.primary,
  //           ),
  //           leading: Icon(
  //             Icons.receipt,
  //             color: colors.primary,
  //           ),
  //           title: Text(
  //             getTranslated(context, 'DWNLD_INVOICE')!,
  //             style: Theme.of(context)
  //                 .textTheme
  //                 .subtitle2!
  //                 .copyWith(color: Theme.of(context).colorScheme.lightBlack),
  //           ),
  //         ),
  //         onTap: () async {
  //           final status = await Permission.storage.request();
  //
  //           if (status == PermissionStatus.granted) {
  //             if (mounted) {
  //               setState(() {
  //                 _isProgress = true;
  //               });
  //             }
  //             var targetPath;
  //
  //             if (Platform.isIOS) {
  //               var target = await getApplicationDocumentsDirectory();
  //               targetPath = target.path.toString();
  //             } else {
  //               var downloadsDirectory =
  //               await DownloadsPathProvider.downloadsDirectory;
  //               targetPath = downloadsDirectory!.path.toString();
  //             }
  //
  //             var targetFileName = "Invoice_${widget.model!.id}";
  //             var generatedPdfFile, filePath;
  //             try {
  //               generatedPdfFile =
  //               await FlutterHtmlToPdf.convertFromHtmlContent(
  //                   widget.model!.invoice!, targetPath, targetFileName);
  //               filePath = generatedPdfFile.path;
  //             } on Exception {
  //               //  filePath = targetPath + "/" + targetFileName + ".html";
  //               generatedPdfFile =
  //               await FlutterHtmlToPdf.convertFromHtmlContent(
  //                   widget.model!.invoice!, targetPath, targetFileName);
  //               filePath = generatedPdfFile.path;
  //             }
  //
  //             if (mounted) {
  //               setState(() {
  //                 _isProgress = false;
  //               });
  //             }
  //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //               content: Text(
  //                 "${getTranslated(context, 'INVOICE_PATH')} $targetFileName",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(color: Theme.of(context).colorScheme.black),
  //               ),
  //               action: SnackBarAction(
  //                   label: getTranslated(context, 'VIEW')!,
  //                   textColor: Theme.of(context).colorScheme.fontColor,
  //                   onPressed: () async {
  //                     final result = await OpenFile.open(filePath);
  //                   }),
  //               backgroundColor: Theme.of(context).colorScheme.white,
  //               elevation: 1.0,
  //             ));
  //           }
  //         }),
  //   );
  // }
  DwnInvoice() {
    print("this is active status @@ $activeStatus ${widget.model!.activeStatus}");
    return Card(
      elevation: 0,
      child: InkWell(
          child: ListTile(
            dense: true,
            trailing: Icon(
              Icons.keyboard_arrow_right,
              color: colors.primary,
            ),
            leading: Icon(
              Icons.receipt,
              color: colors.primary,
            ),
            title: Text(
              getTranslated(context, 'DWNLD_INVOICE')!,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(color: Theme.of(context).colorScheme.lightBlack),
            ),
          ),
          onTap: () async {
            final status = await Permission.storage.request();

            if (status == PermissionStatus.granted) {
              if (mounted) {
                setState(() {
                  _isProgress = true;
                });
              }
              var targetPath;

              if (Platform.isIOS) {
                var target = await getApplicationDocumentsDirectory();
                targetPath = target.path.toString();
              } else {
                var target = await getApplicationDocumentsDirectory();
                targetPath = target.path.toString();
              }

              var targetFileName = "Invoice_${widget.model!.id}";
              var generatedPdfFile, filePath;
              try {
                generatedPdfFile =
                await FlutterHtmlToPdf.convertFromHtmlContent(
                    widget.model!.invoice!, targetPath, targetFileName);
                filePath = generatedPdfFile.path;
              } on Exception {
                 filePath = targetPath + "/" + targetFileName + ".html";
                generatedPdfFile =
                await FlutterHtmlToPdf.convertFromHtmlContent(
                    widget.model!.invoice!, targetPath, targetFileName);
                filePath = generatedPdfFile.path;
              }

              if (mounted) {
                setState(() {
                  _isProgress = false;
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "${getTranslated(context, 'INVOICE_PATH')} $targetFileName",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.black),
                ),
                action: SnackBarAction(
                    label: getTranslated(context, 'VIEW')!,
                    textColor: Theme.of(context).colorScheme.fontColor,
                    onPressed: () async {
                      final result = await OpenFilex.open(filePath);
                    }),
                backgroundColor: Theme.of(context).colorScheme.white,
                elevation: 1.0,
              ));
            }
          }),
    );
  }

  Future<void> sendBankProof() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted) {
          setState(() {
            _isProgress = true;
          });
        }
        var request = http.MultipartRequest("POST", setBankProofApi);
        request.headers.addAll(headers);
        request.fields[ORDER_ID] = widget.model!.id!;

        if (files != null) {
          for (var i = 0; i < files.length; i++) {
            var pic = await http.MultipartFile.fromPath(ATTACH, files[i].path);
            request.files.add(pic);
          }
        }

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool? error = getdata["error"];
        String msg = getdata['message'];

        files.clear();
        if (mounted) {
          setState(() {
            _isProgress = false;
          });
        }
        setSnackbar(msg);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else if (mounted) {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Widget getSubHeadingsTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: TabBar(
        controller: _tabController,
        tabs: [
          getTab("All Details"),
          getTab("Processing"),
          getTab("Delivered"),
          getTab("Cancelled"),
          getTab("Returned"),
        ],
        indicator: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(50),
          color: colors.primary,
        ),
        isScrollable: true,
        unselectedLabelColor: Theme.of(context).colorScheme.black,
        labelColor: Theme.of(context).colorScheme.white,
        automaticIndicatorColorAdjustment: true,
        indicatorPadding: EdgeInsets.symmetric(horizontal: 1.0),
      ),
    );
  }

  getOrderDetails(OrderModel model) {
    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            getOrderNoAndOTPDetails(model),
            // Container(
            //     width: deviceWidth,
            //     child: Card(
            //         elevation: 0,
            //         child: Padding(
            //             padding: EdgeInsets.all(12.0),
            //             child: Text(
            //               "${getTranslated(context, 'ORDER_ID_LBL')!} - ${model.id!}",
            //               style: Theme.of(context)
            //                   .textTheme
            //                   .subtitle2!
            //                   .copyWith(color: Theme.of(context).colorScheme.lightBlack2),
            //             )))),
            // model.otp != null && model.otp!.isNotEmpty && model.otp != "0"
            //     ? Container(
            //         width: deviceWidth,
            //         child: Card(
            //             elevation: 0,
            //             child: Padding(
            //                 padding: EdgeInsets.all(12.0),
            //                 child: Text(
            //                   "${getTranslated(context, 'OTP')!} - ${model.otp!}",
            //                   style: Theme.of(context)
            //                       .textTheme
            //                       .subtitle2!
            //                       .copyWith(color: Theme.of(context).colorScheme.lightBlack2),
            //                 ))))
            //     : Container(),
            model.delDate != null && model.delDate!.isNotEmpty
                ? Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "${getTranslated(context, 'PREFER_DATE_TIME')!}: ${model.delDate!} - ${model.delTime!}",
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2),
                      ),
                    ),
                  )
                : Container(),

            bankTransfer(model),
            getSingleProduct(model, ''),
            shippingDetails(),
            priceDetails(),
            // widget.model!.activeStatus =="delivered" || widget.model!.activeStatus =="cancelled" ?
            widget.model!.itemList![0].status==DELIVERD|| widget.model!.itemList![0].status == CANCLED?
            DwnInvoice()
                : SizedBox.shrink(),
            // downloadInvoice(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(colors.primary)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomerSupport()));
                      },
                      child: Text(
                        "Chat Support",
                        style: TextStyle(color: Colors.black),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(colors.primary)),
                      onPressed: () {
                        _makePhoneCall(_phone);
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => CustomerSupport()));
                      },
                      child: Text(
                        "Call Support",
                        style: TextStyle(color: Colors.black),
                      )),
                ),
              ],
            ),
            SizedBox(height: 100)
          ],
        ),
      ),
    );
  }

  bankTransfer(OrderModel model) {
    return model.payMethod == "Bank Transfer"
        ? Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, 'BANKRECEIPT')!,
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack),
                      ),
                      Container(
                        height: 30,
                        child: IconButton(
                            icon: Icon(
                              Icons.add_photo_alternate,
                              color: colors.primary,
                              size: 20.0,
                            ),
                            onPressed: () {
                              _imgFromGallery();
                            }),
                      ),
                    ],
                  ),
                  model.attachList!.length > 0 ? bankProof(model) : Container(),
                  Container(
                    padding: EdgeInsetsDirectional.only(
                        start: 20.0, end: 20.0, top: 5),
                    height: files.length > 0 ? 180 : 0,
                    child: Row(
                      children: [
                        Expanded(
                            child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: files.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, i) {
                            return InkWell(
                              child: Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  Image.file(
                                    files[i],
                                    width: 180,
                                    height: 180,
                                  ),
                                  Container(
                                      color:
                                          Theme.of(context).colorScheme.black26,
                                      child: Icon(
                                        Icons.clear,
                                        size: 15,
                                      ))
                                ],
                              ),
                              onTap: () {
                                if (mounted) {
                                  setState(() {
                                    files.removeAt(i);
                                  });
                                }
                              },
                            );
                          },
                        )),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.lightWhite,
                                borderRadius: BorderRadius.all(
                                    const Radius.circular(4.0))),
                            child: Text(
                              getTranslated(context, 'SUBMIT_LBL')!,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.fontColor),
                            ),
                          ),
                          onTap: () {
                            sendBankProof();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  getSingleProduct(OrderModel model, String activeStatus) {
    var count = 0;
    return Column(
      children: [

     /*   model.itemList![0].status == PICKED ||
                model.itemList![0].status == CONFIRMED ||
                model.itemList![0].status == ARRIVED||model.itemList![0].status == "assign"
            ? Column(
                children: [
                  Card(
                      elevation: 4,
                      child: ListTile(
                        onTap: () {
                          print(model.itemList![0].del_id);
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => LiveTrackPage(boyId:model.itemList![0].del_id,
                          //           lat: model.lat,
                          //           long: model.long,
                          //         )));

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewLiveTrack(
                                        showSmall: false,
                                        boyId: model.itemList![0].del_id,
                                        lat: model.lat,
                                        long: model.long,
                                        sellerLat: model.itemList![0].sellerLat,
                                        sellerLong:
                                            model.itemList![0].sellerLong,
                                      )));
                        },
                        title: Text("Track Your Order"),
                        trailing: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.location_on_outlined)),
                      )),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .4,
                    child: NewLiveTrack(
                      boyId: model.itemList![0].del_id,
                      showSmall: true,
                      lat: model.lat,
                      long: model.long,
                      sellerLat: model.itemList![0].sellerLat,
                      sellerLong: model.itemList![0].sellerLong,
                    ),
                  )
                ],
              )
            : Container(),*/
        // mounted?
        // model.itemList![0].status==PICKED?
        // Card(
        //   child: LiveTrackPage(boyId:model.itemList![0].del_id,
        //     lat: model.lat,
        //     long: model.long,
        //   ),
        // ):Container():Container(),
        ListView.builder(
          shrinkWrap: true,
          itemCount: model.itemList!.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            var orderItem = model.itemList![i];
            proId = orderItem.id;
            if (activeStatus != '') {
              if (orderItem.status == activeStatus) {
                return productItem(orderItem, model, i);
              }
              if ((orderItem.status == SHIPED || orderItem.status == PLACED) &&
                  activeStatus == PROCESSED) {
                return productItem(orderItem, model, i);
              }
            } else {
              return productItem(orderItem, model, i);
            }
            count++;
            if (count == model.itemList!.length) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(child: Text(getTranslated(context, "noItem")!)),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  void openBottomSheet(BuildContext context, var productID) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    bottomSheetHandle(),
                    rateTextLabel(),
                    ratingWidget(),
                    writeReviewLabel(),
                    writeReviewField(),
                    rateSeller ? Container() : getImageField(),
                    sendReviewButton(productID),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget bottomSheetHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Theme.of(context).colorScheme.lightBlack),
        height: 5,
        width: MediaQuery.of(context).size.width * 0.3,
      ),
    );
  }

  Widget rateTextLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: !rateSeller ? getHeading("PRODUCT_REVIEW") : Text("Rate Shop"),
    );
  }

  Widget ratingWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RatingBar.builder(
        initialRating: 0,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: 32,
        itemPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: colors.yellow,
        ),
        onRatingUpdate: (rating) {
          curRating = rating;
        },
      ),
    );
  }

  Widget writeReviewLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        getTranslated(context, 'REVIEW_OPINION')!,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.subtitle1!,
      ),
    );
  }

  Widget writeReviewField() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: TextField(
          controller: commentTextController,
          style: Theme.of(context).textTheme.subtitle2,
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.lightBlack,
                    width: 1.0)),
            hintText: getTranslated(context, 'REVIEW_HINT_LBL'),
            hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                color:
                    Theme.of(context).colorScheme.lightBlack2.withOpacity(0.7)),
          ),
        ));
  }

  Widget getImageField() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        padding:
            const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 5),
        height: 100,
        child: Row(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(50.0)),
                    child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Theme.of(context).colorScheme.white,
                          size: 25.0,
                        ),
                        onPressed: () {
                          _reviewImgFromGallery(setModalState);
                        }),
                  ),
                  Text(
                    getTranslated(context, 'ADD_YOUR_PHOTOS')!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontSize: 11),
                  )
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: reviewPhotos.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return InkWell(
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Image.file(
                        reviewPhotos[i],
                        width: 100,
                        height: 100,
                      ),
                      Container(
                          color: Theme.of(context).colorScheme.black26,
                          child: const Icon(
                            Icons.clear,
                            size: 15,
                          ))
                    ],
                  ),
                  onTap: () {
                    if (mounted) {
                      setModalState(() {
                        reviewPhotos.removeAt(i);
                      });
                    }
                  },
                );
              },
            )),
          ],
        ),
      );
    });
  }

  void _reviewImgFromGallery(StateSetter setModalState) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null) {
      reviewPhotos = result.paths.map((path) => File(path!)).toList();
      if (mounted) setModalState(() {});
    } else {
      // User canceled the picker
    }
  }

  Widget sendReviewButton(var productID) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: MaterialButton(
              height: 45.0,
              textColor: Theme.of(context).colorScheme.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              onPressed: () async {
                if (rateSeller) {
                  if (curRating != 0 || commentTextController.text != '') {
                    Navigator.pop(context);
                    var user =
                        Provider.of<SettingProvider>(context, listen: false);
                    var userId = "${user.userId.toString()}";
                    AddRatingModel? models = await addComment(userId,
                        widget.sellerId, curRating, commentTextController.text);
                    if (models!.error == false) {
                      showToast(models.message);
                    }
                  } else {
                    Navigator.pop(context);
                    setSnackbar(getTranslated(context, 'REVIEW_W')!);
                  }
                } else {
                  if (curRating != 0 ||
                      commentTextController.text != '' ||
                      (reviewPhotos.isNotEmpty)) {
                    Navigator.pop(context);
                    setRating(curRating, commentTextController.text,
                        reviewPhotos, productID);
                  } else {
                    Navigator.pop(context);
                    setSnackbar(getTranslated(context, 'REVIEW_W')!);
                  }
                }
              },
              child: Text(getTranslated(context, 'SEND_REVIEW')!),
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Text getHeading(
    String title,
  ) {
    return Text(
      getTranslated(context, title)!,
      style: Theme.of(context)
          .textTheme
          .headline6!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }

  Future<void> setRating(
      double rating, String comment, List<File> files, var productID) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var request = http.MultipartRequest("POST", setRatingApi);
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID!;
        request.fields[PRODUCT_ID] = productID;

        if (files != null) {
          for (var i = 0; i < files.length; i++) {
            var pic = await http.MultipartFile.fromPath(IMGS, files[i].path);
            request.files.add(pic);
          }
        }

        if (comment != "") request.fields[COMMENT] = comment;
        if (rating != 0) request.fields[RATING] = rating.toString();
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String? msg = getdata['message'];

        if (!error) {
          setSnackbar(msg!);
        } else {
          setSnackbar(msg!);
        }
        commentTextController.text = "";
        files.clear();
        reviewPhotos.clear();
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else if (mounted) {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Widget getOrderNoAndOTPDetails(OrderModel model) {
    return Card(
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   children: [
            //     Text(
            //       "${getTranslated(context, "ORDER_ID_LBL")!} - ${model.id}",
            //       style: TextStyle(color: Theme.of(context).colorScheme.lightBlack2),
            //     ),
            //     Text(
            //       "${model.dateTime}",
            //       style: TextStyle(color: Theme.of(context).colorScheme.lightBlack2),
            //     )
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${getTranslated(context, "ORDER_ID_LBL")!} - ${model.id}",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
                Text(
                  "${DateFormat("yyyy-MM-dd hh:mm a").format((DateTime.parse(model.dateTime.toString())))}",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                )
              ],
            ),
            model.otp != null && model.otp!.isNotEmpty && model.otp != "0"
                ? Text(
                    "${getTranslated(context, "OTP")!} - ${model.otp}",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  getTab(String title) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      height: 35,
      child: Center(
        child: Text(title),
      ),
    );
  }

  late ReorderResponse reorderResponse;

  void reoder() async {
    MYDialog.loadingDialog(context);
    // String oderid = widget.model!.id.toString();
    // var data = await ChangesApi.reOrder(oderid);
    // reorderResponse = ReorderResponse.fromJson(data);
    Map<String, dynamic> tojson() => {
          'id': widget.model!.id.toString(),
        };
    print(jsonEncode(tojson()));
    Response response = await post(reOrderApi, body: tojson(), headers: headers)
        .timeout(Duration(seconds: timeOut));
    var decodJosn = jsonDecode(response.body);
    print(response.body);
    // print("========");
    setSnackbar(decodJosn["message"]);
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => Dashboard(
                  from: 3,
                )),
        (route) => false);
    //  Cart(
    //           fromBottom: true,
    //         ),
  }

  Future<AddRatingModel?> addComment(userId, sellerId, rating, comment) async {
    var header = headers;
    var request = http.MultipartRequest('POST', addSellerRating);
    request.fields.addAll({
      'user_id': '$userId',
      'seller_id': '$sellerId',
      'rating': '$rating',
      'comment': '$comment'
    });

    request.headers.addAll(header);
    print(request.fields);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      return AddRatingModel.fromJson(json.decode(str));
    } else {
      return null;
    }
  }

  Future<void> addToCart(String qty, bool intent, variant) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        try {
          if (mounted)
            setState(() {
              _isProgress = true;
            });

          // Product model = widget..model;
          //
          // if (int.parse(qty) < model.minOrderQuntity!) {
          //   qty = model.minOrderQuntity.toString();
          //   showToast("${getTranslated(context, 'MIN_MSG')}$qty");
          //
          // }
          // {user_id: 173, product_variant_id: 10, qty: 1}
          OrderDetail detail;
          var parameter = {
            USER_ID: CUR_USERID,
            PRODUCT_VARIENT_ID: variant,
            QTY: qty,
            "seller_id": "${widget.sellerId}"
          };

          print(parameter);
          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            showToast("Done");
            var data = getdata["data"];

            context.read<UserProvider>().setCartCount(data['cart_count']);

            // widget.model!.prVarientList![widget.model!.selVarient!].cartCount =
            //     qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();

            context.read<CartProvider>().setCartlist(cartList);

            if (intent)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Cart(
                    fromBottom: false,
                  ),
                ),
              );
          } else {
            var data = await clearCart(context, msg);
            if (data) {
              setState(() {
                if (mounted)
                  setState(() {
                    _isProgress = false;
                  });
              });
            } else {
              if (mounted)
                setState(() {
                  _isProgress = false;
                });
            }
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        } on TimeoutException catch (_) {
          showToast(getTranslated(context, 'somethingMSg')!);
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }
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
  bool loading = false;
  List<Product> sellerList = [];
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  void getSeller(sellerId) {



    Map parameter = {
      "seller_id": sellerId,
    };
    print(parameter);
    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      setState(() {
        loading = false;
      });
      if (!error) {
        dynamic data = getdata["data"];
        print("Get Seller Api data ==========================> : $data");
        print("Get Seller Parameter ==========================> : $parameter");
        sellerList =
            (data as List).map((data) => new Product.fromSeller(data)).toList();
        if (data.isEmpty) {
          // showToast("No Seller Available");
        }
        if (sellerList[0].open_close_status ==
            "1") {
              // return;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SellerProfile(
                    sellerData: sellerList[0],
                    sellerName: sellerList[0].store_name,
                    sellerImage:
                    "${sellerList[0].seller_profile}",
                    sellerStoreName: sellerList[0].store_name,
                    storeDesc: sellerList[0].store_description ??
                        "",
                    sellerID: sellerList[0].seller_id,
                   sellerId: sellerList[0].seller_id,
                    extraData: sellerList[0],
                    search: true,
                    shop: false,
                    userLocation: currentAddress.text,
                  )));
        } else {
          showToast("Shop Closed");
        }
        /*  sellerList =
            (data as List).map((data) => new Product.fromSeller(data)).toList();*/
      } else {
        // setSnackbar(msg!, context);
      }
    }, onError: (error) {

    });
  }
}
