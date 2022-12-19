
import 'dart:io';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';

class UpdateScreen extends StatefulWidget {
  String desc;


  UpdateScreen(this.desc);

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return Future.value();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: SizedBox(),
          centerTitle: true,
          backgroundColor: colors.primary,
          title: Text("Maintenance",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/update.png"),
            SizedBox(height:50),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.desc,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(height:50),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(colors.primary),
              ),
              onPressed: (){
                exit(0);
            }, child:Text("     Exit     ",
              style: Theme.of(context).textTheme.titleMedium,
            ), ),
          ],
        ),
      ),
    );
  }
}
