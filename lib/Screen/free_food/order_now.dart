import 'dart:io';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Model/FreeFoodOrderModel.dart';
import 'package:eshop_multivendor/api/globalApi/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FreeOrderNow extends StatefulWidget {
  final product;

  const FreeOrderNow({Key? key, this.product}) : super(key: key);

  @override
  State<FreeOrderNow> createState() => _FreeOrderNowState();
}

class _FreeOrderNowState extends State<FreeOrderNow> {
  XFile? _finalPhoto;

  var pickUpType;

  var personController = TextEditingController();
  var addressController = TextEditingController();

  takeImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _finalPhoto = photo;
      });
    } else {}
  }

  _orderFood() async {
    if(personController.text.isNotEmpty && pickUpType!=null &&_finalPhoto!=null){
      showToast('Please Wait');
      var userId = "$CUR_USERID";
      var name = "${personController.text}";
      var productId = "${widget.product.id}";
      var picType = "$pickUpType";
      var address = "${addressController.text}";
      var image = "${_finalPhoto!.path}";
      FreeFoodOrderModel? model =
      await orderFreeFood(userId, name, productId, picType, address, image);
      if (model!.error == false) {
         Navigator.pop(context);
         showToast('${model.message}');
      }else{
        showToast('${model.message}');
      }
    }else{
      showToast('Fill All Details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.primary,
      ),
      body: ListView(
        children: [
          Image.network("$imageUrl${widget.product.image}"),
          ListTile(
            title: Text("${widget.product.name}"),
            subtitle: Text("${widget.product.shortDescription}"),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage("$imageUrl${widget.product.logo}"),
            ),
            title: Text('Store Name : ${widget.product.storeName}'),
            subtitle: Text('Store Name : ${widget.product.storeName}'),
          ),
          Divider(),
          ListTile(
            title: Text("Terms and Condition"),
          ),
          ListTile(
            title: Text("Order Now"),
          ),
          ListTile(
            title: Text("Take Person Picture"),
            subtitle: _finalPhoto != null
                ? Image.file(File(_finalPhoto!.path))
                : Container(),
            trailing: IconButton(
              icon: Icon(
                Icons.camera,
                color: colors.primary,
              ),
              onPressed: () {
                takeImage();
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: personController,
                decoration: InputDecoration(
                    label: Text("Person Name"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text("Delivery Type"),
            subtitle: Row(
              children: [
                Container(
                  child: Row(
                    children: [
                      Radio(
                          value: "self",
                          groupValue: pickUpType,
                          onChanged: (value) {
                            setState(() {
                              pickUpType = value;
                            });
                          }),
                      Text("Self PickUp")
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Radio(
                          value: "cod",
                          groupValue: pickUpType,
                          onChanged: (value) {
                            setState(() {
                              pickUpType = value;
                            });
                          }),
                      Text("COD")
                    ],
                  ),
                ),
              ],
            ),
          ),
          pickUpType != "self" && pickUpType != null
              ? Column(
                  children: [
                    ListTile(
                      title: Text("Address"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: addressController,
                        maxLines: 5,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ],
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(colors.primary)),
                onPressed: () {
                  _orderFood();
                },
                child: Text(
                  "Place Order",
                  style: TextStyle(color: Colors.white),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Notes: First Of all our team will verify the image you send , we will deliver it to the needy person , Thanks For Help",
              style: TextStyle(color: Colors.red, fontSize: 10),
            ),
          )
        ],
      ),
    );
  }
}
