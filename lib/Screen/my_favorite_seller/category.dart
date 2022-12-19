import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Screen/SellerList.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../Model/Section_Model.dart';
import '../HomePage.dart';

class Category extends StatefulWidget {
  List<Product> catList;

  Category(this.catList);

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  void initState() {
    super.initState();
    catList = widget.catList;
    //getCat();
  }
  List<Product> catList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getSimpleAppBar("All Category", context),
      body: Container(
        padding: EdgeInsets.all(10),
        child: GridView.count(
            padding: EdgeInsets.symmetric(horizontal: 20),
            crossAxisCount: 3,
            shrinkWrap: true,
            childAspectRatio: 0.85,
            crossAxisSpacing: 10,
            mainAxisSpacing: 15,
            children: List.generate(
              catList.length,
                  (index) {
                return subCatItem(catList, index, context);
              },
            )),
      ),
    );
  }
  

  subCatItem(List<Product> subList, int index, BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(color:  Theme.of(context)
            .cardColor,borderRadius: BorderRadius.circular(15.0)),
        child: Column(
          children: <Widget>[
             ClipRRect(
               borderRadius: BorderRadius.circular(15),
               child: Container(
                   height: MediaQuery.of(context).size.height*0.09,
                   child: commonImage('${subList[index].image!}',"",context,"assets/images/placeholder.png")),
             ),

           /* Container(
              height: MediaQuery.of(context).size.height*0.09,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage('${subList[index].image!}'))),
              // child: FadeInImage(
              //   image: CachedNetworkImageProvider(subList[index].image!),
              //   fadeInDuration: Duration(milliseconds: 150),
              //   fit: BoxFit.cover,
              //   imageErrorBuilder: (context, error, stackTrace) =>
              //       erroWidget(50),
              //   placeholder: placeHolder(50),
              // ),
            ),*/
            SizedBox(height: 5,),
            Text(
              subList[index].name! + "\n",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SellerList(
                  catId: catList[index].id,
                  catName: catList[index].name,
                  subId: catList[index].subList,
                  userLocation: currentAddress.text,
                  getByLocation: false,
                )));
        },
    );
  }
}
