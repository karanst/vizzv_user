import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Model/response_recomndet_products.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/Product_Detail.dart';
import 'package:eshop_multivendor/Screen/Seller_Details.dart';
import 'package:flutter/material.dart';

class SubCategory extends StatefulWidget {
  final String title;
  final sellerId;
  final catId;
  final sellerData;
  final userCurrentLocation;
  bool shop;
   SubCategory(
      {Key? key,
      required this.title,
      this.sellerId,
      this.sellerData,
      this.catId,required this.shop, this.userCurrentLocation})
      : super(key: key);

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  dynamic subCatData = [];
  var recommendedProductsData = [];
  bool mount = false;
  late ResponseRecomndetProducts responseProducts;
  var newData;
  StreamController<dynamic> productStream = StreamController<dynamic>.broadcast();
  var imageBase = "";
  List<TextEditingController> _controller = [];
  bool _isLoading = true, _isProgress = false;
  bool _isNetworkAvail = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.catId);
    print(widget.sellerId);
    getSubCategory(widget.sellerId, widget.catId);
    getRecommended(widget.sellerId);
  }

  @override
  void dispose() {
    super.dispose();
    productStream.close();
  }

  @override
  Widget build(BuildContext context) {
    print(imageBase);
    return Scaffold(
      appBar: getSimpleAppBar(widget.title, context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<dynamic>(
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
                          Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    );
                  }
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 90),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 60,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 40,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Recommended Products',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 150,
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: snapshot.data["data"].length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 1.0,
                            childAspectRatio: 1.0,
                            mainAxisSpacing: 4.5,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            dynamic model = snapshot.data["data"][index];
                            return InkWell(
                              onTap: () => onTapGoDetails(
                                  index: index, response: snapshot.data!),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width / 50),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  child: new Card(
                                      child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        child:commonHWImage(snapshot.data["data"][index]
                                        ["image"]
                                            .toString(),120.0,MediaQuery.of(context).size.width, "", context, "assets/images/placeholder.png"),

                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding:
                                            EdgeInsets.only(top: 5, left: 5),
                                        child: Text(
                                          snapshot.data["data"][index]["name"]
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                        Row(
                                        children: [
                                          SizedBox(width: 5,),
                                          Text(MONEY_TYPE),
                                          Text("${snapshot.data["data"][index]["min_max_price"]["max_special_price"]}"),
                                          Text(" ${snapshot.data["data"][index]["min_max_price"]["max_price"]}" , style: TextStyle(
                                            decoration: TextDecoration.lineThrough , fontSize: 10
                                          ),),
                                        ],
                                      ),
                                    ],
                                  )),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
            mount
                ? subCatData.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: subCatData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              onTap: () {
                                if (CUR_USERID == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Login(),
                                    ),
                                  );
                                }else{
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SellerProfile(
                                            search: false,
                                            sellerID: widget.sellerId,
                                            subCatId: subCatData[index]["id"],
                                            sellerData: widget.sellerData,
                                            userLocation: widget.userCurrentLocation,
                                            shop: widget.shop,
                                            title: widget.title,
                                            catId: widget.catId,
                                              sellerId: widget.sellerId,
                                          )));
                                }
                              },
                              leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: commonHWImage("$imageBase${subCatData[index]["image"] ?? ""}", 50.0,50.0,"", context, "assets/images/placeholder.png")),
                              title: Text(subCatData[index]["name"] ?? ""),
                              trailing: Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          );
                        },
                      )
                    : Center(child: Text("No Sub Category"))
                : Text(""),
          ],
        ),
      ),
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
        imageBase = value["image_path"];
        mount = true;
      });
    });
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
          sellerId: widget.sellerId,
            )
    )
    );
  }
}
