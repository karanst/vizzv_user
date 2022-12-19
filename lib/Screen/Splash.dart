import 'dart:async';

import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Screen/Intro_Slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/Color.dart';
import '../Helper/String.dart';
import 'HomePage.dart';


//splash screen of app
class Splash extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    //  SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          // Image.asset(
          //   'assets/images/doodle.png',
          //  // color: colors.primary,
          //   fit: BoxFit.fill,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/splash.gif')
              )
            ),
          ),
                  ],
      ),
    );
  }
bool? isFirstTime ;
   startTime() async {
    // SettingProvider settingProvider =
    // Provider.of<SettingProvider>(this.context, listen: false);
    //
   // bool isFirstTime1 = await settingProvider.getPrefrenceBool(ISFIRSTTIME);
     SettingProvider settingsProvider =
     Provider.of<SettingProvider>(this.context, listen: false);
    bool isFirstTime1 = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);
     print("is firstTime *** $isFirstTime1");
    if (isFirstTime1) {
      var _duration = Duration(seconds: 2);
      return Timer(_duration, navigationPage);
    } else{
      var _duration = Duration(seconds: 2);
      return Timer(_duration, navigationPage);
    }
  }

  Future<void> navigationPage() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(this.context, listen: false);
     isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);
    print("is firstTime %% $isFirstTime");
   /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IntroSlider(),
        ));*/
    if (isFirstTime!) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IntroSlider(),
          ));
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

  @override
  void dispose() {
    //  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}
