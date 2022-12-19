import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eshop_multivendor/Helper/AppBtn.dart';
import 'package:eshop_multivendor/Helper/SimBtn.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import 'HomePage.dart';
import 'Login.dart';
import 'Product_Detail.dart';

class ProductList extends StatefulWidget {
  final String? name, id;
  final bool? tag, fromSeller;
  final int? dis;
  final subCatId;
  bool? status;
  ProductList(
      {Key? key,
      this.id,
      this.name,
      this.tag,
      this.fromSeller,
      this.dis,
      this.subCatId,
      this.status})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<ProductList> with TickerProviderStateMixin {
  bool _isLoading = true, _isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  List<Product> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  int offset = 0;
  int total = 0;
  String? totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();
  var filterList;
  String minPrice = "0", maxPrice = "0";
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  bool _isNetworkAvail = true;
  bool listVisible = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;
  var newData;
  StreamController<dynamic> productStream = StreamController();



  String selId = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;
  List<TextEditingController> _controller = [];
  List<String>? tagList = [];
  ChoiceChip? tagChip, choiceChip;
  RangeValues? _currentRangeValues;
  final List<String> items = ['Veg', 'Non-Veg', 'Egg'];
  String? selectedValue;
  String vegPro = "0";
  bool notDeliver = false;

  Future validatePin(String pin, productId, bool first) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {ZIPCODE: pin, PRODUCT_ID: productId};
        Response response =
            await post(checkDeliverableApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        print(getdata);
        if (error) {
          return true;
        } else {
          if (pin != context.read<UserProvider>().curPincode) {
            context.read<HomeProvider>().setSecLoading(true);
          }
          context.read<UserProvider>().setPincode(pin);
          //setPrefrence(PINCODE, curPin);
          /*  setState(() {
            CUR_PINCODE = pin;
          });*/
          return false;
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    getProduct("0");
    getRecommended(widget.id);

    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

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

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getProduct("0");
          });
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    controller.removeListener(() {});
    for (int i = 0; i < _controller.length; i++) _controller[i].dispose();
    productStream.close();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    // userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.fromSeller!
            ? null
            : getAppBar(widget.name!, context, type: "Product"),
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? _isLoading
                ? shimmer(context)
                : Stack(
                    children: <Widget>[
                      _showForm(context),
                      showCircularProgress(_isProgress, colors.primary),
                    ],
                  )
            : noInternet(context),

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
                  offset = 0;
                  total = 0;
                  getProduct("0");
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

  noIntBtn(BuildContext context) {
    double width = deviceWidth!;
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: 10.0, top: 50.0),
        child: Center(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: colors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0)),
          ),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => super.widget));
          },
          child: Ink(
            child: Container(
              constraints: BoxConstraints(maxWidth: width / 1.2, minHeight: 45),
              alignment: Alignment.center,
              child: Text(getTranslated(context, 'TRY_AGAIN_INT_LBL')!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).colorScheme.white,
                      fontWeight: FontWeight.normal)),
            ),
          ),
        )));
  }

  Widget listItem(int index) {
    if (index < productList.length) {
      Product model = productList[index];
      totalProduct = model.total;

      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());

      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;

      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }

      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      double off = 0;
      if (model.prVarientList![model.selVarient!].disPrice! != "0") {
        off = (double.parse(model.prVarientList![model.selVarient!].price!) -
                double.parse(model.prVarientList![model.selVarient!].disPrice!))
            .toDouble();
        off = off *
            100 /
            double.parse(model.prVarientList![model.selVarient!].price!);
      }
      String timeData = "";
      DateTime time = DateTime.now();
      if (model.breakfast_start_product_time != null &&
          model.breakfast_end_product_time != null) {
        List hM =
            model.breakfast_start_product_time.toString().split(":").toList();
        List hM1 =
            model.breakfast_end_product_time.toString().split(":").toList();
        // print("${time.hour}:${time.minute}");
        DateTime t = DateTime(time.year, time.month, time.day, int.parse(hM[0]),
            int.parse(hM[1]));
        DateTime m = DateTime(time.year, time.month, time.day,
            int.parse(hM1[0]), int.parse(hM1[1]));
        if (time.isAfter(t) && time.isBefore(m)) {
          timeData = "Yes";
        } else {
          if (time.isAfter(t)) {
          } else {
            timeData = model.breakfast_start_product_time.toString();
          }
        }
      } else {}
      if (timeData != "Yes" && timeData == "") {
        if (model.lunch_start_product_time != null &&
            model.lunch_end_product_time != null) {
          List hM =
              model.lunch_start_product_time.toString().split(":").toList();
          List hM1 =
              model.lunch_end_product_time.toString().split(":").toList();
          DateTime t = DateTime(time.year, time.month, time.day,
              int.parse(hM[0]), int.parse(hM[1]));
          DateTime m = DateTime(time.year, time.month, time.day,
              int.parse(hM1[0]), int.parse(hM1[1]));
          if (time.isAfter(t) && time.isBefore(m)) {
            timeData = "Yes";
          } else {
            if (time.isAfter(t)) {
            } else {
              timeData = model.lunch_start_product_time.toString();
            }
          }
        } else {}
      }
      if (timeData != "Yes" && timeData == "") {
        if (model.dinner_start_product_time != null &&
            model.dinner_end_product_time != null) {
          List hM =
              model.dinner_start_product_time.toString().split(":").toList();
          List hM1 =
              model.dinner_end_product_time.toString().split(":").toList();
          //  print("${time.hour}:${time.minute}");
          DateTime t = DateTime(time.year, time.month, time.day,
              int.parse(hM[0]), int.parse(hM[1]));
          DateTime m = DateTime(time.year, time.month, time.day,
              int.parse(hM1[0]), int.parse(hM1[1]));
          if (time.isAfter(t) && time.isBefore(m)) {
            timeData = "Yes";
          } else {
            if (time.isAfter(t)) {
            } else {
              timeData = model.dinner_start_product_time.toString();
            }
          }
        } else {}
      }

      if (model.breakfast_start_product_time == null &&
          model.breakfast_end_product_time == null &&
          model.lunch_start_product_time == null &&
          model.lunch_end_product_time == null &&
          model.dinner_start_product_time == null &&
          model.dinner_end_product_time == null) {
        timeData = "No";
      } else {
        if (model.dinner_end_product_time != null &&
            model.dinner_start_product_time != null) {
          List hM =
              model.dinner_start_product_time.toString().split(":").toList();
          DateTime t = DateTime(time.year, time.month, time.day,
              int.parse(hM[0]), int.parse(hM[1]));
          if (time.isAfter(t)) {
            if (model.breakfast_start_product_time != null) {
              timeData =
                  model.breakfast_start_product_time.toString() + ",Tomorrow";
            } else if (model.lunch_start_product_time != null) {
              timeData =
                  model.lunch_start_product_time.toString() + ",Tomorrow";
            } else if (model.dinner_start_product_time != null) {
              timeData =
                  model.dinner_start_product_time.toString() + ",Tomorrow";
            }
          }
        } else if (model.lunch_end_product_time != null) {
          List hM = model.lunch_end_product_time.toString().split(":").toList();
          DateTime t = DateTime(time.year, time.month, time.day,
              int.parse(hM[0]), int.parse(hM[1]));
          if (time.isAfter(t)) {
            if (model.breakfast_start_product_time != null) {
              timeData =
                  model.breakfast_start_product_time.toString() + ",Tomorrow";
            } else if (model.lunch_start_product_time != null) {
              timeData =
                  model.lunch_start_product_time.toString() + ",Tomorrow";
            }
          }
        } else if (model.breakfast_end_product_time != null) {
          List hM =
              model.breakfast_end_product_time.toString().split(":").toList();
          DateTime t = DateTime(time.year, time.month, time.day,
              int.parse(hM[0]), int.parse(hM[1]));
          if (time.isAfter(t)) {
            if (model.breakfast_start_product_time != null) {
              timeData =
                  model.breakfast_start_product_time.toString() + ",Tomorrow";
            }
          }
        }
      }
      print(timeData);
      return Container(
        margin: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0), color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                          minLeadingWidth: 0,
                          dense: true,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              model.indicator == "1"
                                  ? Image.asset(
                                      "assets/images/veg.png",
                                      width: 15,
                                      height: 15,
                                    )
                                  : model.indicator == "2"
                                      ? Image.asset(
                                          "assets/images/non_veg.jpg",
                                          width: 15,
                                          height: 15,
                                        )
                                      : Image.asset(
                                          "assets/images/egg.png",
                                          width: 15,
                                          height: 15,
                                        ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 120,
                                child: Text(
                                  "${model.name!}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              model.prVarientList![model.selVarient!]
                                              .attr_name !=
                                          null &&
                                      model.prVarientList![model.selVarient!]
                                          .attr_name!.isNotEmpty
                                  ? ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          att.length >= 2 ? 2 : att.length,
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
                                                          .lightBlack),
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          )
                                        ]);
                                      })
                                  : Container(),
                              (model.rating! == "0" || model.rating! == "0.0")
                                  ? Container()
                                  : Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating: double.parse(model.rating!),
                                          itemBuilder: (context, index) => Icon(
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
                                          " (" + model.noOfRating! + ")",
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
                                          price.toString() +
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
                                    double.parse(model
                                                .prVarientList![
                                                    model.selVarient!]
                                                .disPrice!) !=
                                            0
                                        ? CUR_CURRENCY! +
                                            "" +
                                            model
                                                .prVarientList![
                                                    model.selVarient!]
                                                .price!
                                        : "",
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
                                width: MediaQuery.of(context).size.width / 2.3,
                                child: Html(
                                  data: "${model.shortDescription}",
                                  style: {
                                    "body": Style(
                                        fontSize: FontSize(12.0),
                                        fontWeight: FontWeight.w400,
                                        maxLines: 2,
                                        padding: EdgeInsets.zero,
                                        margin: EdgeInsets.zero,
                                        textOverflow: TextOverflow.ellipsis),
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                              child: commonImage("${model.image}", "", context,
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
                                child: InkWell(
                                    onTap: () {
                                      if (timeData != "Yes" &&
                                          timeData != "No" &&
                                          timeData != "") {
                                        showToast(
                                            "Item Available After ${timeData}");
                                      } else {
                                        if (_isProgress == false)
                                          addToCart(
                                              index,
                                              (int.parse(_controller[index]
                                                          .text) +
                                                      int.parse(
                                                          model.qtyStepSize!))
                                                  .toString());
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.black, width: 0.7)),
                                      child: Text(
                                        "ADD",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: colors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    )),
                              )
                            : Positioned(
                                top: 100,
                                left: 30,
                                width: 110,
                                // width: 100,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.black, width: 0.7)),
                                    child: Row(
                                      children: <Widget>[
                                        model.availability == "0"
                                            ? Container()
                                            : cartBtnList
                                                ? Container()
                                                : Container(),
                                        GestureDetector(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.remove,
                                              size: 15,
                                            ),
                                          ),
                                          onTap: () {
                                            if (_isProgress == false &&
                                                (int.parse(
                                                        _controller[index].text) >
                                                    0)) removeFromCart(index);
                                          },
                                        ),
                                        Container(
                                          width: 26,
                                          height: 20,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            readOnly: true,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor),
                                            controller: _controller[index],
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
                                              size: 15,
                                            ),
                                          ),
                                          onTap: () {
                                            if (_isProgress == false)
                                              addToCart(
                                                  index,
                                                  (int.parse(model
                                                              .prVarientList![model
                                                                  .selVarient!]
                                                              .cartCount!) +
                                                          int.parse(
                                                              model.qtyStepSize!))
                                                      .toString());
                                          },
                                        )
                                      ],
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
      );
      // return Padding(
      //   padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
      //   child: Stack(
      //     clipBehavior: Clip.none,
      //     children: [
      //
      //       Card(
      //         elevation: 0,
      //         child: InkWell(
      //           borderRadius: BorderRadius.circular(4),
      //           child: Stack(
      //             alignment: Alignment.bottomCenter,
      //               children: <Widget>[
      //             Row(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               mainAxisSize: MainAxisSize.min,
      //               children: <Widget>[
      //                 Hero(
      //                     tag: "ProList$index${model.id}",
      //                     child: InkWell(
      //                       onTap: (){
      //                         if(timeData!="Yes"&&timeData!="No"&&timeData!=""){
      //                           showToast("Item Available After ${timeData}");
      //                         }else{
      //                           Product model = productList[index];
      //                           Navigator.push(
      //                             context,
      //                             PageRouteBuilder(
      //                                 pageBuilder: (_, __, ___) => ProductDetail(
      //                                   model: model,
      //                                   index: index,
      //                                   secPos: 0,
      //                                   list: true,
      //                                   sellerId: widget.id,
      //                                 )),
      //                           );
      //
      //                         }
      //                       },
      //                       child: ClipRRect(
      //                           borderRadius: BorderRadius.only(
      //                               topLeft: Radius.circular(10),
      //                               bottomLeft: Radius.circular(10)),
      //                           child: Stack(
      //
      //                             children: [
      //                               Column(
      //                                 mainAxisAlignment: MainAxisAlignment.center,
      //                                 children: [
      //                                   SizedBox(
      //                                     height: 80,
      //                                     width: 85,
      //                               child: commonImage(model.image.toString(),"",context,"assets/images/placeholder.png")
      //                                   ),
      //                                 ],
      //                               ),
      //                               Positioned.fill(
      //                                   child: model.availability == "0"
      //                                       ? Container(
      //                                           height: 55,
      //                                           color: Colors.white70,
      //                                           // width: double.maxFinite,
      //                                           padding: EdgeInsets.all(2),
      //                                           child: Center(
      //                                             child: Text(
      //                                               getTranslated(context,
      //                                                   'OUT_OF_STOCK_LBL')!,
      //                                               style: Theme.of(context)
      //                                                   .textTheme
      //                                                   .caption!
      //                                                   .copyWith(
      //                                                     color: Colors.red,
      //                                                     fontWeight:
      //                                                         FontWeight.bold,
      //                                                   ),
      //                                               textAlign: TextAlign.center,
      //                                             ),
      //                                           ),
      //                                         )
      //                                       : Container()),
      //                               (off != 0 || off != 0.0 || off != 0.00)
      //                                   ? Container(
      //                                       decoration: BoxDecoration(
      //                                           color: colors.red,
      //                                           borderRadius:
      //                                               BorderRadius.circular(10)),
      //                                       child: Padding(
      //                                         padding: const EdgeInsets.all(5.0),
      //                                         child: Text(
      //                                           off.toStringAsFixed(2) + "%",
      //                                           style: TextStyle(
      //                                               color: colors.whiteTemp,
      //                                               fontWeight: FontWeight.bold,
      //                                               fontSize: 9),
      //                                         ),
      //                                       ),
      //                                       margin: EdgeInsets.all(5),
      //                                     )
      //                                   : Container(),
      //                               timeData!="Yes"&&timeData!="No"&&timeData!=""? Positioned(
      //                                 bottom: 0,
      //                                 child: Container(
      //                                   width: 85,
      //                                   padding: EdgeInsets.all(5),
      //                                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Colors.white),
      //                                   child: Text("Next Available at\n${getTime(timeData)}",
      //                                       textAlign: TextAlign.center,
      //                                       style: Theme.of(context)
      //                                           .textTheme
      //                                           .subtitle2!
      //                                           .copyWith(
      //                                         fontSize: 8.0,
      //                                           color: Colors.red,
      //                                           fontWeight: FontWeight.w400)),
      //                                 ),
      //                               )
      //                                   : Container(),
      //                             ],
      //                           )),
      //                     )),
      //                 Expanded(
      //                   child: Padding(
      //                     padding: const EdgeInsets.all(8.0),
      //                     child: Column(
      //                       mainAxisSize: MainAxisSize.min,
      //                       //mainAxisAlignment: MainAxisAlignment.center,
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       children: <Widget>[
      //                         Text(
      //                           model.name!,
      //                           style: Theme.of(context)
      //                               .textTheme
      //                               .subtitle1!
      //                               .copyWith(
      //                                   color: Theme.of(context)
      //                                       .colorScheme
      //                                       .lightBlack),
      //                           maxLines: 1,
      //                           overflow: TextOverflow.ellipsis,
      //                         ),
      //                        /* Row(
      //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                           children: [
      //                             model.dinner_start_product_time != null
      //                                 ? Text("Start Time : ${model.dinner_start_product_time}")
      //                                 : Container(),
      //                             // SizedBox(width: 10,),
      //                             model.dinner_end_product_time != null
      //                                 ? Text("End Time : ${model.dinner_end_product_time}")
      //                                 : Container(),
      //                           ],
      //                         ),*/
      //                         model.prVarientList![model.selVarient!]
      //                                         .attr_name !=
      //                                     null &&
      //                                 model.prVarientList![model.selVarient!]
      //                                     .attr_name!.isNotEmpty
      //                             ? ListView.builder(
      //                                 physics: NeverScrollableScrollPhysics(),
      //                                 shrinkWrap: true,
      //                                 itemCount:
      //                                     att.length >= 2 ? 2 : att.length,
      //                                 itemBuilder: (context, index) {
      //                                   return Row(children: [
      //                                     Flexible(
      //                                       child: Text(
      //                                         att[index].trim() + ":",
      //                                         overflow: TextOverflow.ellipsis,
      //                                         style: Theme.of(context)
      //                                             .textTheme
      //                                             .subtitle2!
      //                                             .copyWith(
      //                                                 color: Theme.of(context)
      //                                                     .colorScheme
      //                                                     .lightBlack),
      //                                       ),
      //                                     ),
      //                                     Padding(
      //                                       padding: EdgeInsetsDirectional.only(
      //                                           start: 5.0),
      //                                       child: Text(
      //                                         val[index],
      //                                         style: Theme.of(context)
      //                                             .textTheme
      //                                             .subtitle2!
      //                                             .copyWith(
      //                                                 color: Theme.of(context)
      //                                                     .colorScheme
      //                                                     .lightBlack,
      //                                                 fontWeight:
      //                                                     FontWeight.bold),
      //                                       ),
      //                                     )
      //                                   ]);
      //                                 })
      //                             : Container(),
      //                         (model.rating! == "0" || model.rating! == "0.0")
      //                             ? Container()
      //                             : Row(
      //                                 children: [
      //                                   RatingBarIndicator(
      //                                     rating: double.parse(model.rating!),
      //                                     itemBuilder: (context, index) => Icon(
      //                                       Icons.star_rate_rounded,
      //                                       color: Colors.amber,
      //                                       //color: colors.primary,
      //                                     ),
      //                                     unratedColor:
      //                                         Colors.grey.withOpacity(0.5),
      //                                     itemCount: 5,
      //                                     itemSize: 18.0,
      //                                     direction: Axis.horizontal,
      //                                   ),
      //                                   Text(
      //                                     " (" + model.noOfRating! + ")",
      //                                     style: Theme.of(context)
      //                                         .textTheme
      //                                         .overline,
      //                                   )
      //                                 ],
      //                               ),
      //                         Row(
      //                           children: <Widget>[
      //                             Text(
      //                                 CUR_CURRENCY! +
      //                                     " " +
      //                                     price.toString() +
      //                                     " ",
      //                                 style: Theme.of(context)
      //                                     .textTheme
      //                                     .subtitle2!
      //                                     .copyWith(
      //                                         color: Theme.of(context)
      //                                             .colorScheme
      //                                             .fontColor,
      //                                         fontWeight: FontWeight.bold)),
      //                             Text(
      //                               double.parse(model
      //                                           .prVarientList![
      //                                               model.selVarient!]
      //                                           .disPrice!) !=
      //                                       0
      //                                   ? CUR_CURRENCY! +
      //                                       "" +
      //                                       model
      //                                           .prVarientList![
      //                                               model.selVarient!]
      //                                           .price!
      //                                   : "",
      //                               style: Theme.of(context)
      //                                   .textTheme
      //                                   .overline!
      //                                   .copyWith(
      //                                       decoration:
      //                                           TextDecoration.lineThrough,
      //                                       letterSpacing: 0),
      //                             ),
      //                           ],
      //                         ),
      //                         _controller[index].text != "0"
      //                             ? Row(
      //                                 children: [
      //                                   model.availability == "0"
      //                                       ? Container()
      //                                       : cartBtnList
      //                                           ? Container()
      //                                           : Container(),
      //
      //                                   Row(
      //                                     children: <Widget>[
      //                                       Row(
      //                                         children: <Widget>[
      //                                           GestureDetector(
      //                                             child: Card(
      //                                               shape:
      //                                                   RoundedRectangleBorder(
      //                                                 borderRadius:
      //                                                     BorderRadius.circular(
      //                                                         50),
      //                                               ),
      //                                               child: Padding(
      //                                                 padding:
      //                                                     const EdgeInsets.all(
      //                                                         8.0),
      //                                                 child: Icon(
      //                                                   Icons.remove,
      //                                                   size: 15,
      //                                                 ),
      //                                               ),
      //                                             ),
      //                                             onTap: () {
      //                                               if (_isProgress == false &&
      //                                                   (int.parse(_controller[
      //                                                               index]
      //                                                           .text) >
      //                                                       0))
      //                                                 removeFromCart(index);
      //                                             },
      //                                           ),
      //                                           Container(
      //                                             width: 26,
      //                                             height: 20,
      //                                             decoration: BoxDecoration(
      //                                               color: colors.white70,
      //                                               borderRadius:
      //                                                   BorderRadius.circular(
      //                                                       5),
      //                                             ),
      //                                             child: TextField(
      //                                               textAlign: TextAlign.center,
      //                                               readOnly: true,
      //                                               style: TextStyle(
      //                                                   fontSize: 12,
      //                                                   color: Theme.of(context)
      //                                                       .colorScheme
      //                                                       .fontColor),
      //                                               controller:
      //                                                   _controller[index],
      //                                               decoration: InputDecoration(
      //                                                 border: InputBorder.none,
      //                                               ),
      //                                             ),
      //                                           ),
      //                                           GestureDetector(
      //                                             child: Card(
      //                                               shape:
      //                                                   RoundedRectangleBorder(
      //                                                 borderRadius:
      //                                                     BorderRadius.circular(
      //                                                         50),
      //                                               ),
      //                                               child: Padding(
      //                                                 padding:
      //                                                     const EdgeInsets.all(
      //                                                         8.0),
      //                                                 child: Icon(
      //                                                   Icons.add,
      //                                                   size: 15,
      //                                                 ),
      //                                               ),
      //                                             ),
      //                                             onTap: () {
      //                                               if (_isProgress == false)
      //                                                 addToCart(
      //                                                     index,
      //                                                     (int.parse(model
      //                                                                 .prVarientList![
      //                                                                     model
      //                                                                         .selVarient!]
      //                                                                 .cartCount!) +
      //                                                             int.parse(model
      //                                                                 .qtyStepSize!))
      //                                                         .toString());
      //                                             },
      //                                           )
      //                                         ],
      //                                       ),
      //                                     ],
      //                                   )
      //                                 ],
      //                               )
      //                             : Container(),
      //                       ],
      //                     ),
      //                   ),
      //                 )
      //               ],
      //             ),
      //             model.availability == "0"
      //                 ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
      //                     style: Theme.of(context)
      //                         .textTheme
      //                         .subtitle2!
      //                         .copyWith(
      //                             color: Colors.red,
      //                             fontWeight: FontWeight.bold))
      //                 : Container(),
      //
      //           ]),
      //         ),
      //       ),
      //       _controller[index].text == "0"
      //           ? Positioned.directional(
      //               textDirection: Directionality.of(context),
      //               bottom: -15,
      //               end: 45,
      //               child: InkWell(
      //                 onTap: () {
      //                   if(timeData!="Yes"&&timeData!="No"&&timeData!=""){
      //                     showToast("Item Available After ${timeData}");
      //                   }else{
      //                     if (_isProgress == false)
      //                       addToCart(
      //                           index,
      //                           (int.parse(_controller[index].text) +
      //                               int.parse(model.qtyStepSize!))
      //                               .toString());
      //                   }
      //                 },
      //                 child: Card(
      //                   elevation: 1,
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(50),
      //                   ),
      //                   child: Padding(
      //                     padding: const EdgeInsets.all(12.0),
      //                     child: Text("ADD +" , style: TextStyle(
      //                       color: colors.primary,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 18
      //                     ),),
      //                   ),
      //                 ),
      //               ),
      //             )
      //           : Container(),
      //       Positioned.directional(
      //           textDirection: Directionality.of(context),
      //           bottom: -15,
      //           end: 0,
      //           child: Card(
      //               elevation: 1,
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(50),
      //               ),
      //               child: model.isFavLoading!
      //                   ? Padding(
      //                       padding: const EdgeInsets.all(8.0),
      //                       child: Container(
      //                           height: 20,
      //                           width: 20,
      //                           child: CircularProgressIndicator(
      //                             strokeWidth: 0.7,
      //                           )),
      //                     )
      //                   : Selector<FavoriteProvider, List<String?>>(
      //                       builder: (context, data, child) {
      //                         return InkWell(
      //                           child: Padding(
      //                             padding: const EdgeInsets.all(8.0),
      //                             child: Icon(
      //                               !data.contains(model.id)
      //                                   ? Icons.favorite_border
      //                                   : Icons.favorite,
      //                               size: 20,
      //                             ),
      //                           ),
      //                           onTap: () {
      //                             if (CUR_USERID != null) {
      //                               !data.contains(model.id)
      //                                   ? _setFav(-1, model)
      //                                   : _removeFav(-1, model);
      //                             } else {
      //                               Navigator.push(
      //                                 context,
      //                                 MaterialPageRoute(
      //                                     builder: (context) => Login()),
      //                               );
      //                             }
      //                           },
      //                         );
      //                       },
      //                       selector: (_, provider) => provider.favIdList,
      //                     ))),
      //       widget.status!=null&&!widget.status!?Row(
      //           mainAxisAlignment: MainAxisAlignment.end,
      //         children: [
      //           Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: productList[index].indicator.toString()=="0"?
      //                 Container():productList[index].indicator.toString()=="1"?
      //             Image.asset("assets/images/veg.png",height: 15,):productList[index].indicator.toString()=="2"?Image.asset("assets/images/non_veg.jpg",height: 15,):Image.asset("assets/images/egg.png",height: 15,),
      //           ),
      //         ],
      //       ):SizedBox(),
      //     ],
      //   ),
      // );
    } else
      return Container();
  }

  getTime(data) {
    String time = data.toString().split(",").length > 0
        ? data.toString().split(",")[0]
        : "10:00";
    String ext = data.toString().split(",").length > 1
        ? data.toString().split(",")[1]
        : "";
    DateTime date = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(time.toString().split(":")[0]),
        int.parse(time.toString().split(":")[1]));
    return DateFormat.jm().format(date).toString() + "," + ext;
  }

  _setFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : productList[index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        print(parameter);
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "1" : productList[index].isFav = "1";

          context.read<FavoriteProvider>().addFavItem(model);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : productList[index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  _removeFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : productList[index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        Response response =
            await post(removeFavApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "0" : productList[index].isFav = "0";
          context
              .read<FavoriteProvider>()
              .removeFavItem(model.prVarientList![0].id!);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : productList[index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  removeFromCart(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        int qty;

        qty = (int.parse(_controller[index].text) -
            int.parse(productList[index].qtyStepSize!));

        if (qty < productList[index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: productList[index]
              .prVarientList![productList[index].selVarient!]
              .id,
          USER_ID: CUR_USERID,
          QTY: qty.toString(),
          "seller_id": "${widget.id}"
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = ;

            context.read<UserProvider>().setCartCount(data['cart_count']);
            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
            _isProgress = false;
          } else {
            var data = await clearCart(context, msg);
            if (data) {
              setState(() {
                if (mounted)
                  setState(() {
                    context.read<UserProvider>().setCartCount(0.toString());
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

  void getProduct(String top) {
    //_currentRangeValues.start.round().toString(),
    // _currentRangeValues.end.round().toString(),
    Map parameter = {
      SORT: sortBy,
      ORDER: orderBy,
      SUB_CAT_ID: widget.subCatId ?? "",
      LIMIT: perPage.toString(),
      OFFSET: offset.toString(),
      TOP_RETAED: top,
    };
    if (selId != null && selId != "") {
      parameter[ATTRIBUTE_VALUE_ID] = selId;
    }
    if (foodType && !nonType) {
      parameter['veg_nonveg'] = "1";
    }
    if (!foodType && nonType) {
      parameter['veg_nonveg'] = "2";
    }
    if (widget.tag!) parameter[TAG] = widget.name!;
    if (widget.fromSeller!) {
      parameter["seller_id"] = widget.id!;
    } else {
      parameter[CATID] = widget.id ?? '';
    }
    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

    if (widget.dis != null) parameter[DISCOUNT] = widget.dis.toString();

    if (_currentRangeValues != null &&
        _currentRangeValues!.start.round().toString() != "0") {
      parameter[MINPRICE] = _currentRangeValues!.start.round().toString();
    }

    if (_currentRangeValues != null &&
        _currentRangeValues!.end.round().toString() != "0") {
      parameter[MAXPRICE] = _currentRangeValues!.end.round().toString();
    }
    print(parameter);
    apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        total = int.parse(getdata["total"]);

        if (_isFirstLoad) {
          filterList = getdata["filters"];

          minPrice = getdata[MINPRICE];
          maxPrice = getdata[MAXPRICE];
          _currentRangeValues =
              RangeValues(double.parse(minPrice), double.parse(maxPrice));
          _isFirstLoad = false;
        }

        if ((offset) < total) {
          tempList.clear();

          var data = getdata["data"];

          tempList =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          for (int i = 0; i < tempList.length; i++) {
            if (tempList[i].indicator == "1") {
              setState(() {
                vegPro = "1";
              });
            } else {
              setState(() {
                vegPro = "0";
              });
            }
          }

          if (getdata.containsKey(TAG)) {
            List<String> tempList = List<String>.from(getdata[TAG]);
            if (tempList != null && tempList.length > 0) tagList = tempList;
          }

          getAvailVarient();

          offset = offset + perPage;
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg!, context);
          isLoadingmore = false;
        }
      } else {
        isLoadingmore = false;
        if (msg != "Products Not Found !") setSnackbar(msg!, context);
      }

      setState(() {
        _isLoading = false;
      });
      // context.read<ProductListProvider>().setProductLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      setState(() {
        _isLoading = false;
      });
      //context.read<ProductListProvider>().setProductLoading(false);
    });
  }

  void getAvailVarient() {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == "1") {
            tempList[j].selVarient = i;

            break;
          }
        }
      }
    }
    productList.addAll(tempList);
  }

  Widget productItem(int index, bool pad) {
    if (index < productList.length) {
      Product model = productList[index];

      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      double off = 0;
      if (model.prVarientList![model.selVarient!].disPrice! != "0") {
        off = (double.parse(model.prVarientList![model.selVarient!].price!) -
                double.parse(model.prVarientList![model.selVarient!].disPrice!))
            .toDouble();
        off = off *
            100 /
            double.parse(model.prVarientList![model.selVarient!].price!);
      }

      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());

      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;

      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }
      double width = deviceWidth! * 0.5;

      return InkWell(
        child: Card(
          elevation: 0.2,
          margin: EdgeInsetsDirectional.only(
              bottom: 10, end: 10, start: pad ? 10 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        tag: "ProGrid$index${model.id}",
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: CachedNetworkImageProvider(model.image!),
                          height: 50.0,
                          width: 50.0,
                          fit: extendImg ? BoxFit.fill : BoxFit.fitHeight,
                          placeholder: placeHolder(width),
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(width),
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: model.availability == "0"
                            ? Container(
                                height: 55,
                                color: Colors.white70,
                                padding: EdgeInsets.all(2),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Container()),
                    (off != 0 || off != 0.0 || off != 0.00)
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: colors.red,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  off.toStringAsFixed(2) + "%",
                                  style: TextStyle(
                                      color: colors.whiteTemp,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9),
                                ),
                              ),
                              margin: EdgeInsets.all(5),
                            ),
                          )
                        : Container(),
                    Divider(
                      height: 1,
                    ),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      end: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          model.availability == "0" && !cartBtnList
                              ? Container()
                              : _controller[index].text == "0"
                                  ? InkWell(
                                      onTap: () {
                                        if (_isProgress == false)
                                          addToCart(
                                              index,
                                              (int.parse(_controller[index]
                                                          .text) +
                                                      int.parse(
                                                          model.qtyStepSize!))
                                                  .toString());
                                      },
                                      child: Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 3.0, bottom: 5, top: 3),
                                      child: Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              if (_isProgress == false &&
                                                  (int.parse(_controller[index]
                                                          .text) >
                                                      0)) removeFromCart(index);
                                            },
                                          ),
                                          Container(
                                            width: 26,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: colors.white70,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              readOnly: true,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor),
                                              controller: _controller[index],
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ), // ),
                                          GestureDetector(
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                                    (int.parse(_controller[
                                                                    index]
                                                                .text) +
                                                            int.parse(model
                                                                .qtyStepSize!))
                                                        .toString());
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                          Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: model.isFavLoading!
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 0.7,
                                          )),
                                    )
                                  : Selector<FavoriteProvider, List<String?>>(
                                      builder: (context, data, child) {
                                        return InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              !data.contains(model.id)
                                                  ? Icons.favorite_border
                                                  : Icons.favorite,
                                              size: 15,
                                            ),
                                          ),
                                          onTap: () {
                                            if (CUR_USERID != null) {
                                              !data.contains(model.id)
                                                  ? _setFav(-1, model)
                                                  : _removeFav(-1, model);
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Login()),
                                              );
                                            }
                                          },
                                        );
                                      },
                                      selector: (_, provider) =>
                                          provider.favIdList,
                                    )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              (model.rating! == "0" || model.rating! == "0.0")
                  ? Container()
                  : Row(
                      children: [
                        RatingBarIndicator(
                          rating: double.parse(model.rating!),
                          itemBuilder: (context, index) => Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber,
                            //color: colors.primary,
                          ),
                          unratedColor: Colors.grey.withOpacity(0.5),
                          itemCount: 5,
                          itemSize: 12.0,
                          direction: Axis.horizontal,
                          itemPadding: EdgeInsets.all(0),
                        ),
                        Text(
                          " (" + model.noOfRating! + ")",
                          style: Theme.of(context).textTheme.overline,
                        )
                      ],
                    ),
              Row(
                children: [
                  Text(" " + CUR_CURRENCY! + " " + price.toString() + " ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold)),
                  double.parse(model
                              .prVarientList![model.selVarient!].disPrice!) !=
                          0
                      ? Flexible(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  double.parse(model
                                              .prVarientList![model.selVarient!]
                                              .disPrice!) !=
                                          0
                                      ? CUR_CURRENCY! +
                                          "" +
                                          model
                                              .prVarientList![model.selVarient!]
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
                                          letterSpacing: 0),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: model.prVarientList![model.selVarient!]
                                      .attr_name !=
                                  null &&
                              model.prVarientList![model.selVarient!].attr_name!
                                  .isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: att.length >= 2 ? 2 : att.length,
                              itemBuilder: (context, index) {
                                return Row(children: [
                                  Flexible(
                                    child: Text(
                                      att[index].trim() + ":",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 5.0),
                                      child: Text(
                                        val[index],
                                        maxLines: 1,
                                        overflow: TextOverflow.visible,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ]);
                              })
                          : Container(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: 5.0, bottom: 5),
                child: Text(
                  model.name!,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        onTap: () {},
      );
    } else
      return Container();
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
                          productList.clear();
                        });
                      getProduct("1");
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
                        getProduct("0");
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
                        getProduct("0");
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
                        getProduct("0");
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
                        getProduct("0");
                        Navigator.pop(context, 'option 4');
                      }),
                ]),
          );
        });
      },
    );
  }

  Future<void> addToCart(int index, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        if (int.parse(qty) < productList[index].minOrderQuntity!) {
          qty = productList[index].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_VARIENT_ID: productList[index]
              .prVarientList![productList[index].selVarient!]
              .id,
          QTY: qty,
          "seller_id": "${widget.id}"
        };
        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            var data = await clearCart(context, msg);
            if (data) {
              if (mounted)
                setState(() {
                  context.read<UserProvider>().setCartCount(0.toString());
                  _isProgress = false;
                });
              addToCart(index, qty);
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

  _showForm(BuildContext context) {
    var checkOut = Provider.of<UserProvider>(context, listen: false);
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 40,
          margin: EdgeInsets.only(left: 8.0, right: 8.0),
          child: Image.asset(
            "assets/images/menu.png",
            width: 120,
          ),
          // Text("MENU",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold
          //   ),
          // ),
        ),
        Container(
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          height: 70,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
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
                      print("SELECTED ====== $selectedValue");
                      getProduct("0");
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
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width: 0.6,color: Colors.grey,)
                ),
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
        ),
        Container(
          margin: EdgeInsets.all(10.0),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 40,
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recommended',
                  style: TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
              ),
              InkWell(
                child: !listVisible ? Icon(Icons.keyboard_arrow_down_outlined) : Icon(Icons.keyboard_arrow_up),
                onTap: (){
                  setState(() {
                    listVisible = !listVisible;
                    if(listVisible){
                      productStream.close();
                    }
                  });
                },
              ),
            ],
          ),
        ),
        listVisible ? Container(
          child: StreamBuilder<dynamic>(
              stream: productStream.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    child: Text(snapshot.error.toString()),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    // height: MediaQuery.of(context).size.height / 2,
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
                        Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  );
                }else if(snapshot.connectionState == ConnectionState.done){
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 90),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: snapshot.data["data"].length,
                      itemBuilder: (BuildContext context, int indexR) {
                        // dynamic model = snapshot.data["data"][index];
                        return recommendedItem(indexR, snapshot.data);
                      },
                    ),
                  );
                }else{
                  return SizedBox();
                }
              }),
        ) : SizedBox.shrink(),
        Expanded(
          child: productList.length == 0
              ? getNoItem(context)
              : listType
                  ? ListView.separated(
                      controller: controller,
                      itemCount: (offset < total)
                          ? productList.length + 1
                          : productList.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (context, index) {
                        return (index == productList.length && isLoadingmore)
                            ? singleItemSimmer(context)
                            : listItem(index);
                      },
                    )
                  : GridView.count(
                      padding: EdgeInsetsDirectional.only(top: 5),
                      crossAxisCount: 2,
                      controller: controller,
                      childAspectRatio: 0.78,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: List.generate(
                        (offset < total)
                            ? productList.length + 1
                            : productList.length,
                        (index) {
                          return (index == productList.length && isLoadingmore)
                              ? simmerSingleProduct(context)
                              : productItem(
                                  index, index % 2 == 0 ? true : false);
                        },
                      )),
        ),
        checkOut.curCartCount != "" &&
                checkOut.curCartCount != null &&
                int.parse(checkOut.curCartCount) > 0
            ? Container(
                height: MediaQuery.of(context).size.height * .08,
              )
            : Container(),
        SizedBox(height: 100,),
      ],
    );
  }

  Widget recommendedItem(int index, response){
    if (_controller.length < index + 1)
      _controller.add(new TextEditingController());

    _controller[index].text = response["data"][index]["variants"][0]["cart_count"];

    String timeData = "";
    DateTime time = DateTime.now();
    if (response["data"][index]["breakfast_start_product_time"] != null &&
        response["data"][index]["breakfast_start_product_time"] != null) {
      List hM =
      response["data"][index]["breakfast_start_product_time"].split(":").toList();
      List hM1 =
      response["data"][index]["breakfast_end_product_time"].toString().split(":").toList();
      // print("${time.hour}:${time.minute}");
      DateTime t = DateTime(time.year, time.month, time.day, int.parse(hM[0]),
          int.parse(hM[1]));
      DateTime m = DateTime(time.year, time.month, time.day,
          int.parse(hM1[0]), int.parse(hM1[1]));
      if (time.isAfter(t) && time.isBefore(m)) {
        timeData = "Yes";
      } else {
        if (time.isAfter(t)) {
        } else {
          timeData = response["data"][index]["breakfast_start_product_time"].toString();
        }
      }
    } else {}
    if (timeData != "Yes" && timeData == "") {
      if (response["data"][index]["lunch_start_product_time"] != null &&
          response["data"][index]["lunch_end_product_time"] != null) {
        List hM =
        response["data"][index]["lunch_start_product_time"].toString().split(":").toList();
        List hM1 =
        response["data"][index]["lunch_end_product_time"].toString().split(":").toList();
        DateTime t = DateTime(time.year, time.month, time.day,
            int.parse(hM[0]), int.parse(hM[1]));
        DateTime m = DateTime(time.year, time.month, time.day,
            int.parse(hM1[0]), int.parse(hM1[1]));
        if (time.isAfter(t) && time.isBefore(m)) {
          timeData = "Yes";
        } else {
          if (time.isAfter(t)) {
          } else {
            timeData = response["data"][index]["lunch_start_product_time"].toString();
          }
        }
      } else {}
    }
    if (timeData != "Yes" && timeData == "") {
      if (response["data"][index]["dinner_start_product_time"] != null &&
          response["data"][index]["dinner_end_product_time"] != null) {
        List hM =
        response["data"][index]["dinner_start_product_time"].toString().split(":").toList();
        List hM1 =
        response["data"][index]["dinner_end_product_time"].toString().split(":").toList();
        //  print("${time.hour}:${time.minute}");
        DateTime t = DateTime(time.year, time.month, time.day,
            int.parse(hM[0]), int.parse(hM[1]));
        DateTime m = DateTime(time.year, time.month, time.day,
            int.parse(hM1[0]), int.parse(hM1[1]));
        if (time.isAfter(t) && time.isBefore(m)) {
          timeData = "Yes";
        } else {
          if (time.isAfter(t)) {
          } else {
            timeData = response["data"][index]["dinner_start_product_time"].toString();
          }
        }
      } else {}
    }

    if (response["data"][index]["breakfast_start_product_time"] == null &&
        response["data"][index]["breakfast_end_product_time"] == null &&
        response["data"][index]["lunch_start_product_time"] == null &&
        response["data"][index]["lunch_end_product_time"] == null &&
        response["data"][index]["dinner_start_product_time"] == null &&
        response["data"][index]["dinner_end_product_time"] == null) {
      timeData = "No";
    } else {
      if (response["data"][index]["dinner_end_product_time"] != null &&
          response["data"][index]["dinner_start_product_time"] != null) {
        List hM =
        response["data"][index]['dinner_start_product_time'].toString().split(":").toList();
        DateTime t = DateTime(time.year, time.month, time.day,
            int.parse(hM[0]), int.parse(hM[1]));
        if (time.isAfter(t)) {
          if (response["data"][index]["breakfast_start_product_time"] != null) {
            timeData =
                response["data"][index]["breakfast_start_product_time"].toString() + ",Tomorrow";
          } else if (response["data"][index]["lunch_start_product_time"] != null) {
            timeData =
                response["data"][index]["lunch_start_product_time"].toString() + ",Tomorrow";
          } else if (response["data"][index]["dinner_start_product_time"] != null) {
            timeData =
                response["data"][index]["dinner_start_product_time"].toString() + ",Tomorrow";
          }
        }
      } else if (response["data"][index]["lunch_end_product_time"] != null) {
        List hM = response["data"][index]["lunch_end_product_time"].toString().split(":").toList();
        DateTime t = DateTime(time.year, time.month, time.day,
            int.parse(hM[0]), int.parse(hM[1]));
        if (time.isAfter(t)) {
          if (response["data"][index]["breakfast_start_product_time"] != null) {
            timeData =
                response["data"][index]["breakfast_start_product_time"].toString() + ",Tomorrow";
          } else if (response["data"][index]["lunch_start_product_time"] != null) {
            timeData =
                response["data"][index]["lunch_start_product_time"].toString() + ",Tomorrow";
          }
        }
      } else if (response["data"][index]["breakfast_end_product_time"] != null) {
        List hM =
        response["data"][index]["breakfast_end_product_time"].toString().split(":").toList();
        DateTime t = DateTime(time.year, time.month, time.day,
            int.parse(hM[0]), int.parse(hM[1]));
        if (time.isAfter(t)) {
          if (response["data"][index]["breakfast_start_product_time"] != null) {
            timeData =
                response["data"][index]["breakfast_start_product_time"].toString() + ",Tomorrow";
          }
        }
      }
    }
    print(timeData);

    return InkWell(
      onTap: () => onTapGoDetails(
          index: index, response: response),
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                          minLeadingWidth: 0,
                          dense: true,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  : Image.asset(
                                "assets/images/egg.png",
                                width: 15,
                                height: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 120,
                                child: Text(
                                  "${response["data"][index]["name"]}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /*model.prVarientList![model.selVarient!]
                                                      .attr_name !=
                                                      null &&
                                                      model.prVarientList![model.selVarient!]
                                                          .attr_name!.isNotEmpty
                                                      ? ListView.builder(
                                                      physics: NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount:
                                                      att.length >= 2 ? 2 : att.length,
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
                                                                      .lightBlack),
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
                                                                  fontWeight:
                                                                  FontWeight.bold),
                                                            ),
                                                          )
                                                        ]);
                                                      })
                                                      : Container(),*/
                              (response["data"][index]["rating"] == "0" || response["data"][index]["rating"] == "0.0")
                                  ? Container()
                                  : Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: double.parse(response["data"][index]["rating"]),
                                    itemBuilder: (context, index) => Icon(
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
                                    " (" + response["data"][index]["no_of_ratings"] + ")",
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
                                          response["data"][index]["min_max_price"]["max_special_price"].toString() +
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
                                width: MediaQuery.of(context).size.width / 2.3,
                                child: Html(
                                  data: "${response["data"][index]["short_description"]}",
                                  style: {
                                    "body": Style(
                                        fontSize: FontSize(12.0),
                                        fontWeight: FontWeight.w400,
                                        maxLines: 2,
                                        padding: EdgeInsets.zero,
                                        margin: EdgeInsets.zero,
                                        textOverflow: TextOverflow.ellipsis),
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                              child: commonHWImage(response["data"][index]["image"]
                                  .toString(),120.0,MediaQuery.of(context).size.width, "", context, "assets/images/placeholder.png"),
                            ),
                          ),
                        ),
                        _controller[index].text == "0"
                            ? Positioned(
                          top: 100,
                          left: 25,
                          width: 100,
                          height: 30,
                          child: InkWell(
                              onTap: () {
                                if (timeData != "Yes" &&
                                                        timeData != "No" &&
                                                        timeData != "") {
                                                      showToast(
                                                          "Item Available After ${timeData}");
                                                    } else {
                                                      if (_isProgress == false)
                                                        addToCart(
                                                            index,
                                                            (int.parse(_controller[index]
                                                                .text) +
                                                                int.parse(
                                                                    response["data"][index]["quantity_step_size"]))
                                                                .toString());
                                                    }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(5.0),
                                    shape: BoxShape.rectangle,
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 0.7)),
                                child: Text(
                                  "ADD",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              )),
                        )
                            : Positioned(
                          top: 100,
                          left: 30,
                          width: 110,
                          // width: 100,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.black, width: 0.7)),
                              child: Row(
                                children: <Widget>[
                                  response["data"][index]["availability"] == "0"
                                      ? Container()
                                      : cartBtnList
                                      ? Container()
                                      : Container(),
                                  GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.remove,
                                        size: 15,
                                      ),
                                    ),
                                    onTap: () {
                                      if (_isProgress == false &&
                                          (int.parse(
                                              _controller[index].text) >
                                              0)) removeFromCart(index);
                                    },
                                  ),
                                  Container(
                                    width: 26,
                                    height: 20,
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      readOnly: true,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor),
                                      controller: _controller[index],
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
                                        size: 15,
                                      ),
                                    ),
                                    onTap: () {
                                      if (_isProgress == false)
                                        addToCart(
                                            index,
                                            (int.parse(response["data"][index]["variants"][index]["cart_count"])
                                                // model
                                                // .prVarientList![model
                                                // .selVarient!]
                                                // .cartCount!)
                                                + int.parse(
                                                    response["data"][index]["quantity_step_size"]))
                                                .toString());
                                    },
                                  )
                                ],
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
    );
  }

  Widget _tags() {
    if (tagList != null && tagList!.length > 0) {
      List<Widget> chips = [];
      for (int i = 0; i < tagList!.length; i++) {
        tagChip = ChoiceChip(
          selected: false,
          label: Text(tagList![i],
              style: TextStyle(color: Theme.of(context).colorScheme.white)),
          backgroundColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          onSelected: (bool selected) {
            if (selected) if (mounted)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductList(
                      name: tagList![i],
                      tag: true,
                      fromSeller: false,
                    ),
                  ));
          },
        );

        chips.add(Padding(
            padding: EdgeInsets.symmetric(horizontal: 5), child: tagChip));
      }

      return Container(
        height: 50,
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: chips),
      );
    } else {
      return Container();
    }
  }

  getRecommended(sellerId) async {
    var parm = {"seller_id": sellerId};
    print(parm);
    var data = await apiBaseHelper.postAPINew(recommendedProductapi, parm);
    newData = data;
    setState(() {});
    if (newData["data"].isNotEmpty) {
      productStream.sink.add(newData);
    } else {
      productStream.sink.addError("");
    }
  }

  onTapGoDetails({response, index}) {
    Product model = Product.fromJson(response["data"][index]);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetail(
          index: index,
          model: model,
          secPos: 0,
          list: false,
          sellerId: widget.id,
        )
    )
    );
  }

  var foodType = false;
  var nonType = false;
  filterOptions() {
    return Container(
      color: Theme.of(context).colorScheme.gray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: filterDialog,
            icon: Icon(
              Icons.filter_list,
              color: colors.primary,
            ),
            label: Text(
              getTranslated(context, 'FILTER')!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontSize: 10.0),
            ),
          ),
          TextButton.icon(
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
          widget.status != null && !widget.status!
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Veg",
                      style: TextStyle(color: Colors.green, fontSize: 10.0),
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Switch(
                          value: foodType,
                          onChanged: (val) {
                            setState(() {
                              foodType = val;
                              offset = 0;
                              productList.clear();
                            });
                            getProduct("0");
                          }),
                    ),
                  ],
                )
              : SizedBox(),
          widget.status != null && !widget.status!
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Non-Veg",
                      style: TextStyle(color: Colors.red, fontSize: 10.0),
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Switch(
                          value: nonType,
                          activeColor: Colors.red,
                          onChanged: (val) {
                            setState(() {
                              nonType = val;
                              offset = 0;
                              productList.clear();
                            });
                            getProduct("0");
                          }),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsetsDirectional.only(top: 30.0),
                child: AppBar(
                  title: Text(
                    getTranslated(context, 'FILTER')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 5,
                  backgroundColor: Theme.of(context).colorScheme.white,
                  leading: Builder(builder: (BuildContext context) {
                    return Container(
                      margin: EdgeInsets.all(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 4.0),
                          child: Icon(Icons.arrow_back_ios_rounded,
                              color: colors.primary),
                        ),
                      ),
                    );
                  }),
                )),
            Expanded(
                child: Container(
              color: Theme.of(context).colorScheme.lightWhite,
              padding:
                  EdgeInsetsDirectional.only(start: 7.0, end: 7.0, top: 7.0),
              child: filterList != null
                  ? ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsetsDirectional.only(top: 10.0),
                      itemCount: filterList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              Container(
                                  width: deviceWidth,
                                  child: Card(
                                      elevation: 0,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Price Range',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .lightBlack,
                                                    fontWeight:
                                                        FontWeight.normal),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          )))),
                              RangeSlider(
                                values: _currentRangeValues!,
                                min: double.parse(minPrice),
                                max: double.parse(maxPrice),
                                divisions: 10,
                                labels: RangeLabels(
                                  _currentRangeValues!.start.round().toString(),
                                  _currentRangeValues!.end.round().toString(),
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    _currentRangeValues = values;
                                  });
                                },
                              ),
                            ],
                          );
                        } else {
                          index = index - 1;
                          attsubList =
                              filterList[index]['attribute_values'].split(',');

                          attListId = filterList[index]['attribute_values_id']
                              .split(',');

                          List<Widget?> chips = [];
                          List<String> att =
                              filterList[index]['attribute_values']!.split(',');

                          List<String> attSType =
                              filterList[index]['swatche_type'].split(',');

                          List<String> attSValue =
                              filterList[index]['swatche_value'].split(',');

                          for (int i = 0; i < att.length; i++) {
                            Widget itemLabel;
                            if (attSType[i] == "1") {
                              String clr = (attSValue[i].substring(1));

                              String color = "0xff" + clr;

                              itemLabel = Container(
                                width: 25,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(int.parse(color))),
                              );
                            } else if (attSType[i] == "2") {
                              itemLabel = ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(attSValue[i],
                                      width: 80,
                                      height: 80,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              erroWidget(80)));
                            } else {
                              itemLabel = Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(att[i],
                                    style: TextStyle(
                                        color:
                                            selectedId.contains(attListId![i])
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .white
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .fontColor)),
                              );
                            }

                            choiceChip = ChoiceChip(
                              selected: selectedId.contains(attListId![i]),
                              label: itemLabel,
                              labelPadding: EdgeInsets.all(0),
                              selectedColor: colors.primary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    attSType[i] == "1" ? 100 : 10),
                                side: BorderSide(
                                    color: selectedId.contains(attListId![i])
                                        ? colors.primary
                                        : colors.black12,
                                    width: 1.5),
                              ),
                              onSelected: (bool selected) {
                                attListId = filterList[index]
                                        ['attribute_values_id']
                                    .split(',');

                                if (mounted)
                                  setState(() {
                                    if (selected == true) {
                                      selectedId.add(attListId![i]);
                                    } else {
                                      selectedId.remove(attListId![i]);
                                    }
                                  });
                              },
                            );

                            chips.add(choiceChip);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: deviceWidth,
                                child: Card(
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new Text(
                                      filterList[index]['name'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.normal),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                              chips.length > 0
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: new Wrap(
                                        children:
                                            chips.map<Widget>((Widget? chip) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: chip,
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : Container()
                            ],
                          );
                        }
                      })
                  : Container(),
            )),
            Container(
              color: Theme.of(context).colorScheme.white,
              child: SimBtn(
                  size: 1.0,
                  title: getTranslated(context, 'APPLY'),
                  onBtnSelected: () {
                    if (selectedId != null) {
                      selId = selectedId.join(',');
                    }

                    if (mounted)
                      setState(() {
                        _isLoading = true;
                        total = 0;
                        offset = 0;
                        productList.clear();
                      });
                    getProduct("0");
                    Navigator.pop(context, 'Product Filter');
                  }),
            )
          ]);
        });
      },
    );
  }
}
