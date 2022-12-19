import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Screen/free_food/free_food_history.dart';
import 'package:eshop_multivendor/api/globalApi/api.dart';
import 'package:flutter/material.dart';

import 'free_food_list.dart';

class FreeSellerLists extends StatefulWidget {
  const FreeSellerLists({Key? key}) : super(key: key);

  @override
  State<FreeSellerLists> createState() => _FreeSellerListsState();
}

class _FreeSellerListsState extends State<FreeSellerLists> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text("Free Food"),
        actions: [
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> FreeFoodHistory()));
          }, child: Text("History" , style: TextStyle(color: Colors.white),))
        ],
      ),
      body: FutureBuilder(
          future: freeSeller(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List data = snapshot.data.data;
              return ListView.builder(
                itemCount: snapshot.data.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 1),
                    child: GestureDetector(
                      onTap: () {

                        if(data[index]
                            .openCloseStatus == "1"){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FreeFoodLists(sellerId: data[index].sellerId,)));
                        }else{
                          showToast("Shop Closed");
                        }

                      },
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10)),
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
                                    height: 70,
                                    width: 80,
                                    padding: EdgeInsets.only(left: 10),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                      child: FadeInImage(
                                        fadeInDuration:
                                        Duration(milliseconds: 150),
                                        image:
                                        CachedNetworkImageProvider(
                                          data[index]
                                              .logo!,
                                        ),
                                        fit: BoxFit.cover,
                                        imageErrorBuilder: (context,
                                            error, stackTrace) =>
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
                                          title: Text(
                                              "${data[index].storeName!}\n ${data[index].sellerId}"),
                                          subtitle: Text(
                                            "${data[index].storeDescription!}\n${data[index]
                                                .openCloseStatus}",
                                            maxLines: 2,
                                          ),
                                          trailing: Text(
                                            data[index]
                                                .openCloseStatus ==
                                                "1"
                                                ? "Open"
                                                : "Closed",
                                            style: TextStyle(
                                                color: data[index]
                                                    .openCloseStatus ==
                                                    "1"
                                                    ? Colors.green
                                                    : Colors.red),
                                          ),
                                        ),
                                        Divider(
                                          height: 0,
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              FittedBox(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .star_rounded,
                                                      color:
                                                      Colors.amber,
                                                      size: 15,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              data[index]
                                                  .estimatedTime !=
                                                  ""
                                                  ? FittedBox(
                                                child: Container(
                                                    child: Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            5,
                                                            vertical:
                                                            2),
                                                        child: Text(
                                                          "${data[index].estimatedTime}",
                                                          style: TextStyle(
                                                              fontSize:
                                                              14),
                                                        ),
                                                      ),
                                                    )),
                                              )
                                                  : Container(),
                                              data[index]
                                                  .foodPerson !=
                                                  ""
                                                  ? FittedBox(
                                                child: Container(
                                                    child:
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                          5,
                                                          vertical:
                                                          1),
                                                      child: Text(
                                                        "${data[index].foodPerson}",
                                                        style: TextStyle(
                                                            fontSize:
                                                            14),
                                                      ),
                                                    )),
                                              )
                                                  : Container(),
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
              );
            } else if (snapshot.hasError) {
              return Icon(Icons.error_outline);
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
