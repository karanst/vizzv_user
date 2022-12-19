 import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/ClearCartModel.dart';
import 'package:eshop_multivendor/api/globalApi/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Provider/CartProvider.dart';

showToast(msg){
   Fluttertoast.showToast(
       msg: "$msg",
       toastLength: Toast.LENGTH_SHORT,
       gravity: ToastGravity.SNACKBAR,
       timeInSecForIosWeb: 1,
       backgroundColor: Colors.black,
       textColor: Colors.white,
       fontSize: 12.0
   );
 }


 clearCart(context , msg){
  print("CLEAR CART MSG+++=========" + msg);
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Text("Items", style: TextStyle(color: Colors.red),),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () async {
          ClearCartModel? model = await clearCartApi(CUR_USERID);
          print("MODEL ===== $model");
          if(model!.error == false){
            Navigator.pop(context , true);
          }else{
            Navigator.pop(context , false);
          }
        }, child: Text("Yes")),
        TextButton(onPressed: (){
          Navigator.pop(context, false);
          context.read<CartProvider>().setProgress(false);
        }, child: Text("No")),
      ],
    );
  });
 }
 Widget commonHWImage(url, height, width, placeHolder, context, errorImage) {
   return CachedNetworkImage(
     imageUrl: url,
     height:height,
     width: width,
     fit: BoxFit.fill,
    /* placeholder: (context, url) {
       return Container(
         height:height,
         width: width,
         child: Center(
           child: CircularProgressIndicator(
             color: colors.primary,
           ),
         ),
       );
     },*/
     errorWidget: (context, url, error) {
       return Image.asset(
         errorImage,
         fit: BoxFit.fill,
         height:height,
         width: width,
       );
     },
   );
 }
 Widget commonImage(url, placeHolder, context, errorImage) {
   return CachedNetworkImage(
     imageUrl: url,

     fit: BoxFit.fill,
     placeholder: (context, url) {
       return Container(

         child: Center(
           child: CircularProgressIndicator(
             color: colors.primary,
           ),
         ),
       );
     },
     errorWidget: (context, url, error) {
       return Image.asset(
         errorImage,
         fit: BoxFit.fill,
       );
     },
   );
 }
 class GradientText extends StatelessWidget {
   const GradientText(
       this.text, {
         required this.gradient,
         this.style,
       });

   final String text;
   final TextStyle? style;
   final Gradient gradient;

   @override
   Widget build(BuildContext context) {
     return ShaderMask(
       blendMode: BlendMode.srcIn,
       shaderCallback: (bounds) => gradient.createShader(
         Rect.fromLTWH(0, 0, bounds.width, bounds.height),
       ),
       child: Text(text, style: style),
     );
   }
 }