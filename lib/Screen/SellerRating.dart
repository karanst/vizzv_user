import 'dart:convert';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/GetSellerRatingModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

class SellerRatingsPage extends StatefulWidget {
  final sellerId;

  const SellerRatingsPage({Key? key, this.sellerId}) : super(key: key);

  @override
  State<SellerRatingsPage> createState() => _SellerRatingsPageState();
}

class _SellerRatingsPageState extends State<SellerRatingsPage> {
  @override
  Widget build(BuildContext context) {
    print(widget.sellerId);
    return Scaffold(
      appBar: AppBar(
        title: Text("Ratings"),
        backgroundColor: colors.primary,
      ),
      body: FutureBuilder(
          future: getSellerRating("${widget.sellerId}"),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(),
                        title: RatingBarIndicator(
                          rating: double.parse(snapshot.data.data[index].rating),
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 15.0,
                          direction: Axis.horizontal,
                        ),
                        subtitle: Text("Customer : ${snapshot.data.data[index].userName}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("${snapshot.data.data[index].comment}",)),
                      ),
                      Divider()
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Icon(Icons.error_outline);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Future<GetSellerRatingModel?> getSellerRating(sellerId) async {
    var header = headers;
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('$getSellerRatingsApi'));
    request.fields.addAll({'seller_id': '$sellerId'});

    request.headers.addAll(header);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      return GetSellerRatingModel.fromJson(json.decode(str));
    } else {
      return null;
    }
  }
}
