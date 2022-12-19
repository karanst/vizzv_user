import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/FreeFoodModel.dart';
import 'package:eshop_multivendor/Screen/Free_Food.dart';
import 'package:eshop_multivendor/Screen/free_food/order_now.dart';
import 'package:eshop_multivendor/api/globalApi/api.dart';
import 'package:flutter/material.dart';

class FreeFoodLists extends StatefulWidget {
  final sellerId;
  const FreeFoodLists({Key? key, this.sellerId}) : super(key: key);

  @override
  State<FreeFoodLists> createState() => _FreeFoodListsState();
}

class _FreeFoodListsState extends State<FreeFoodLists> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.primary,
      ),
      body: FutureBuilder<FreeFoodModel?>(
          future: freeFoodList(widget.sellerId),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data.data;
              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2 , children: data.map<Widget>((i){
                return InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> FreeOrderNow(
                      product: i,
                    )));
                  },
                  child: Container(child: Column(children: [
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Image.network("$imageUrl${i.image}"),
                   ),
                    Text("${i.name}")
                  ],),),
                );
              }).toList(),);
            } else if (snapshot.hasError) {
              return Icon(Icons.error_outline);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
