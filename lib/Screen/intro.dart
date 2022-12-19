// import 'dart:async';
//
// import 'package:eshop_multivendor/Screen/HomePage.dart';
// import 'package:eshop_multivendor/Screen/Splash.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Helper/String.dart';
// import '../Provider/SettingProvider.dart';
// import 'Intro_Slider.dart';
//
// class IntroScreen extends StatefulWidget {
//   const IntroScreen({Key? key}) : super(key: key);
//
//   @override
//   State<IntroScreen> createState() => _IntroScreenState();
// }
//
// class _IntroScreenState extends State<IntroScreen> {
//
//   // @override
//   // void afterFirstLayout(BuildContext context) => checkFirstSeen();
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//      checkFirstSeen();
//     startTime();
//   }
//   Future checkFirstSeen() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool _seen = (prefs.getBool('seen') ?? false);
//     if (_seen) {
//       Navigator.of(context).pushReplacement(
//           new MaterialPageRoute(builder: (context) =>  HomePage()));
//     } else {
//       await prefs.setBool('seen', true);
//       Navigator.of(context).pushReplacement(
//           new MaterialPageRoute(builder: (context) =>  Splash()));
//     }
//   }
//
//   startTime() async {
//
//     var _duration = Duration(milliseconds: 100);
//     return Timer(_duration, navigationPage);
//   }
//
//   Future<void> navigationPage() async {
//     SettingProvider settingsProvider =
//     Provider.of<SettingProvider>(this.context, listen: false);
//
//     bool isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);
//     /* Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => IntroSlider(),
//         ));*/
//     if (isFirstTime) {
//       Navigator.pushReplacementNamed(context, "/home");
//     } else {
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => IntroSlider(),
//           ));
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     deviceHeight = MediaQuery.of(context).size.height;
//     deviceWidth = MediaQuery.of(context).size.width;
//
//     return Container(
//     );
//   }
// }
