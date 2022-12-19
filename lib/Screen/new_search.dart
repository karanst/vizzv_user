import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Screen/All_Category.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/Product_Detail.dart';
import 'package:eshop_multivendor/Screen/Seller_Details.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NewSearch extends StatefulWidget {
  const NewSearch({Key? key}) : super(key: key);

  @override
  _NewSearchState createState() => _NewSearchState();
}

class _NewSearchState extends State<NewSearch> {
  TextEditingController searchCon = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getSearch();
  }

  ApiBaseHelper apiBaseHelper = new ApiBaseHelper();
  bool loading = false;
  List<ProductModel> productList = [];
  List<SellerModel> sellerList = [];
  List<Product> searchList = [];

  getSearch() async {
    setState(() {
      loading = true;
      searchList.clear();
    });
    Map param = {
      "search": searchCon.text,
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };
    print("this is search parmas ${param.toString()}");


    Map data = await apiBaseHelper.postAPICall(
        Uri.parse(baseUrl + "search_restaurant"), param);
    print(data);
    setState(() {
      loading = false;
      productList.clear();
      sellerList.clear();
    });
    for (var v in data['product']) {
      setState(() {
        productList.add(ProductModel.fromJson(v));
      });
    }
    setState(() {
      productList = productList.toSet().toList();
    });
    for (var v in data['seller']) {
      setState(() {
        sellerList.add(SellerModel.fromJson(v));
      });
    }
    setState(() {
      sellerList = sellerList.toSet().toList();
    });
  }

  getProduct() async {
    setState(() {
      loading = true;
    });
    Map param = {
      "search": searchCon.text,
      "limit":"50",
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };
    print("this is allso search parameters ${param.toString()}");

    Map data = await apiBaseHelper.postAPICall(getProductApi, param);
    print(data);
    setState(() {
      loading = false;
      productList.clear();
      sellerList.clear();
    });
    for (var v in data['data']) {
      setState(() {
        searchList.add(Product.fromJson(v));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (searchList.length > 0) {
          setState(() {
            searchList.clear();
            productList.clear();
            sellerList.clear();
            searchCon.text = "";
          });
        } else {
          Navigator.pop(context);
        }
        return Future.value();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_sharp,
              color: colors.primary,
            ),
            onPressed: () {
              if (searchList.length > 0) {
                setState(() {
                  searchList.clear();
                  productList.clear();
                  sellerList.clear();
                  searchCon.text = "";
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: TextField(
            controller: searchCon,
            autofocus: true,
            onChanged: (val) {
              if (val.length > 2) {
                getSearch();
              }
            },
            textInputAction: TextInputAction.search,
            onSubmitted: (val) {
              setState(() {
                searchCon.text = val.toString();
              });
              //  if(val.length>2){
              // getSearch();
              getProduct();

              //  }
            },
            decoration: InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "Search for Product and More",
                hintStyle: TextStyle(color: colors.primary)),
          ),
        ),
        body: CustomScrollView(slivers: [
          !loading
              ? searchList.length > 0
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  getSeller(searchList[index].seller_id);
                                  setState(() {
                                    loadingShow = true;
                                    selectedIndex = index;
                                  });
                                  // getSeller(searchList[index].seller_id);
                                  // setState(() {
                                  //   loadingShow = true;
                                  //   selectedIndex = index;
                                  // });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          getSeller(searchList[index].seller_id);
                                          setState(() {
                                            loadingShow = true;
                                            selectedIndex = index;
                                          });
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Text(
                                              searchList[index]
                                                  .store_name
                                                  .toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            )),
                                            Icon(
                                              Icons.arrow_forward_outlined,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              child: Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 16,
                                              )),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            searchList[index]
                                                .seller_rating
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        searchList[index]
                                            .store_description
                                            .toString(),
                                        style:
                                            Theme.of(context).textTheme.bodyText1,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: commonHWImage(
                                                    searchList[index]
                                                        .image
                                                        .toString(),
                                                    80.0,
                                                    80.0,
                                                    "",
                                                    context,
                                                    "assets/images/sliderph.png")),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  searchList[index]
                                                      .name
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                Text(
                                                  "₹" +
                                                      searchList[index]
                                                          .prVarientList![0]
                                                          .disPrice
                                                          .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                        ),
                                                        child: Icon(
                                                          Icons.star,
                                                          color: Colors.white,
                                                          size: 16,
                                                        )),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      searchList[index]
                                                          .rating
                                                          .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              loadingShow && selectedIndex == index
                                  ? Center(child: CircularProgressIndicator())
                                  : SizedBox(),
                            ],
                          );
                        },
                        childCount: searchList.length,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate([
                      SizedBox(
                        height: 10,
                      ),
                      productList.length > 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Products",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                ListView.builder(
                                    itemCount: productList.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            searchCon.text = productList[index]
                                                .name
                                                .toString();
                                          });
                                          getProduct();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          padding: EdgeInsets.all(5),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: commonHWImage(
                                                      "https://vizzvefoods.com/" +
                                                          productList[index]
                                                              .image
                                                              .toString(),
                                                      60.0,
                                                      60.0,
                                                      "",
                                                      context,
                                                      "assets/images/sliderph.png")),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Text(
                                                productList[index]
                                                    .name
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              )),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      sellerList.length > 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sellers",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                ListView.builder(
                                    itemCount: sellerList.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            loadingShow = true;
                                            selectedIndex = index;
                                          });
                                          getSeller(sellerList[index].userId);
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              margin:
                                                  EdgeInsets.only(bottom: 8),
                                              padding: EdgeInsets.all(5),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: commonHWImage(
                                                          "https://vizzvefoods.com/" +
                                                              sellerList[index]
                                                                  .logo
                                                                  .toString(),
                                                          60.0,
                                                          60.0,
                                                          "",
                                                          context,
                                                          "assets/images/sliderph.png")),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                      child: Text(
                                                    sellerList[index]
                                                        .storeName
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  )),
                                                ],
                                              ),
                                            ),
                                            loadingShow &&
                                                    selectedIndex == index
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator())
                                                : SizedBox(),
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            )
                          : Center(),
                    ]))
              : SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: colors.primary,
                        size: 100,
                      ),
                    ),
                  ),
                ),
        ]),
        /*bottomSheet: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: !loading ? searchList.length>0
                ? Column(
              children: [
                ListView.builder(
                    itemCount: searchList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: (){
                                    getSeller(searchList[index].seller_id);
                                    setState(() {
                                      loadingShow = true;
                                      selectedIndex = index;
                                    });
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child:
                                      Text(searchList[index].store_name.toString(),
                                        style: Theme.of(context).textTheme.titleMedium,)),
                                      Icon(Icons.arrow_forward_outlined,color: Colors.black,),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Icon(Icons.star,color: Colors.white,size: 16,)),
                                    SizedBox(width: 5,),
                                    Text(searchList[index].seller_rating.toString(),style: Theme.of(context).textTheme.titleSmall,),
                                  ],
                                ),
                                Text(searchList[index].store_description.toString(),style: Theme.of(context).textTheme.bodyText1,),
                                SizedBox(height: 8,),
                                InkWell(
                                  onTap: (){
                                    if(searchList[index].open_close_status=="1"){
                                      Product model = searchList[index];
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                            pageBuilder: (_, __, ___) => ProductDetail(
                                              model: model,
                                              index: index,
                                              secPos: 0,
                                              list: true,
                                            )),
                                      );
                                    }else{
                                      showToast("Shop Closed");
                                    }

                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: commonHWImage(searchList[index].image.toString(), 80.0, 80.0, "", context, "assets/images/sliderph.png")),
                                        SizedBox(width: 10,),
                                        Expanded(child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(searchList[index].name.toString(),style: Theme.of(context).textTheme.titleMedium,),
                                            Text("₹"+searchList[index].prVarientList![0].disPrice.toString(),style: Theme.of(context).textTheme.bodyMedium,),
                                            Row(
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(100),
                                                    ),
                                                    child: Icon(Icons.star,color: Colors.white,size: 16,)),
                                                SizedBox(width: 5,),
                                                Text(searchList[index].rating.toString(),style: Theme.of(context).textTheme.titleSmall,),
                                              ],
                                            ),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8,),
                              ],
                            ),
                          ),
                          loadingShow && selectedIndex == index ? Center(child: CircularProgressIndicator()):SizedBox(),
                        ],
                      );
                    }),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                productList.length>0?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Products",style: Theme.of(context).textTheme.titleLarge,),
                    SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                        itemCount: productList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (){
                              setState(() {
                                searchCon.text = productList[index].name.toString();
                              });
                              getProduct();
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              padding: EdgeInsets.all(5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: commonHWImage("https://vizzvefoods.com/"+productList[index].image.toString(), 60.0, 60.0, "", context, "assets/images/sliderph.png")),
                                  SizedBox(width: 5,),
                                  Expanded(child: Text(productList[index].name.toString(),style: Theme.of(context).textTheme.titleMedium,)),
                                ],
                              ),
                            ),
                          );
                    }),
                  ],
                ):SizedBox(),
                SizedBox(
                  height: 10,
                ),
                sellerList.length>0?Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sellers",style: Theme.of(context).textTheme.titleLarge,),
                    SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                        itemCount: sellerList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (){
                              setState(() {
                                loadingShow = true;
                                selectedIndex = index;
                              });
                              getSeller(sellerList[index].userId);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: commonHWImage("https://vizzvefoods.com/"+sellerList[index].logo.toString(), 60.0, 60.0, "", context, "assets/images/sliderph.png")),
                                      SizedBox(width: 5,),
                                      Expanded(child: Text(sellerList[index].storeName.toString(),style: Theme.of(context).textTheme.titleMedium,)),
                                    ],
                                  ),
                                ),
                                loadingShow&&selectedIndex==index?Center(child: CircularProgressIndicator()):SizedBox(),
                              ],
                            ),
                          );
                        }),
                  ],
                ):SizedBox(),
              ],
            ): Container(
              height: MediaQuery.of(context).size.height*0.5,
          child: Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: colors.primary,
              size: 100,
            ),
          ),
        ),
          ),
        ),*/
      ),
    );
  }

  bool loadingShow = false;
  List<Product> sellerList1 = [];
  int selectedIndex = 0;

  void getSeller(sellerId) {
    Map parameter = {
      "seller_id": sellerId,
    };
    print(parameter);
    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      setState(() {
        loadingShow = false;
      });
      if (!error) {
        dynamic data = getdata["data"];
        print("Get Seller Api data ==========================> : $data");
        print("Get Seller Parameter ==========================> : $parameter");
        sellerList1 =
            (data as List).map((data) => new Product.fromSeller(data)).toList();
        if (data.isEmpty) {
          // showToast("No Seller Available");
        }
        if (sellerList1[0].open_close_status == "1") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SellerProfile(
                        sellerData: sellerList1[0],
                        sellerName: sellerList1[0].store_name,
                        sellerImage: "${sellerList1[0].seller_profile}",
                        sellerStoreName: sellerList1[0].store_name,
                        storeDesc: sellerList1[0].store_description ?? "",
                        sellerID: sellerList1[0].seller_id,
                        sellerId: sellerList1[0].seller_id,
                        extraData: sellerList1[0],
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
    }, onError: (error) {});
  }
}

class ProductModel {
  String? id;
  String? name;
  String? sellerId;
  String? slug;
  String? image;

  ProductModel({this.id, this.name, this.sellerId, this.slug, this.image});

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sellerId = json['seller_id'];
    slug = json['slug'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['seller_id'] = this.sellerId;
    data['slug'] = this.slug;
    data['image'] = this.image;
    return data;
  }
}

class SellerModel {
  String? userId;
  String? slug;
  String? storeName;
  String? logo;

  SellerModel({this.userId, this.slug, this.storeName, this.logo});

  SellerModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    slug = json['slug'];
    storeName = json['store_name'];
    logo = json['logo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['slug'] = this.slug;
    data['store_name'] = this.storeName;
    data['logo'] = this.logo;
    return data;
  }
}
