import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_routes/google_maps_routes.dart';

class LiveTrackPage extends StatefulWidget {
  final boyId;
  final lat;
  final long;

  const LiveTrackPage({Key? key, this.boyId, this.lat, this.long})
      : super(key: key);

  @override
  _LiveTrackPageState createState() => _LiveTrackPageState();
}

class _LiveTrackPageState extends State<LiveTrackPage> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  String googleAPiKey = "AIzaSyBq52y-MtlJa6wtmzZ1XIz3LTbwBpaWXuU";

  MapsRoutes route = new MapsRoutes();

  getRoutes() async {

    List<LatLng> points = [
      LatLng(double.parse(dNewLat), double.parse(dNewLong)),
      LatLng(double.parse(widget.lat.toString()), double.parse(widget.long.toString())),
    ];
   await route.drawRoute(points, "Delivery", Colors.red, googleAPiKey,travelMode: TravelModes.driving);
  }


  var dNewLat = "0.0";
  var dNewLong = "0.0";
  var driverName = "";
  late BitmapDescriptor myIcon;


  // static final CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(22.7196, 75.8577),
  //   zoom: 14.4746,
  // );

  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(dNewLat, dNewLong),
  //     // tilt: 59.440717697143555,
  //     zoom: 19);
  var approxTime = "";

  Future getEstimated() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$dNewLat%2C$dNewLong&destinations=${widget.lat}%2C${widget.long}&key=AIzaSyBq52y-MtlJa6wtmzZ1XIz3LTbwBpaWXuU'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      var data = json.decode(str);
      if (data["status"] == "OK") {
        setState(() {
          approxTime =
              data["rows"][0]["elements"][0]["duration"]["text"].toString();
        });
        print("$approxTime>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      } else {}
    } else {
      return null;
    }
  }

  approxDeliTime() {
    Timer mytimer = Timer.periodic(Duration(seconds: 5), (timer) {
      dNewLat != "0.0" ? getEstimated() : print("wait");
      route.routes.clear();
      getRoutes();
      //code to run on every 5 seconds
    });
    mytimer;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    approxDeliTime();
    super.dispose();
    route.routes.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(10, 10)), 'assets/images/driver.png')
        .then((onValue) {
      myIcon = onValue;
    });
    approxDeliTime();
  }

  // _driver(dNewLat , dNewLong);
  // get driver location
  @override
  Widget build(BuildContext context) {
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('Location/${widget.boyId}');
    var h = MediaQuery.of(context).size.height;

    /// LatLng is included in google_maps_flutter




    return StreamBuilder(
        stream: starCountRef.onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            DataSnapshot snap = snapshot.data.snapshot;
            var lat = snap.child("address").child("lat").value;
            var long = snap.child("address").child("long").value;
            dNewLat = snap.child("address").child("lat").value.toString();
            dNewLong = snap.child("address").child("long").value.toString();

            return snap.children.isNotEmpty?
              Container(
              height: h * .25,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Animarker(
                    useRotation: true,
                    mapId: _controller.future.then ((value) => value.mapId),
                    markers: {
                      RippleMarker(
                        ripple: false,
                        markerId: MarkerId('Driver'),
                        position: LatLng(double.parse(lat.toString()),
                            double.parse(long.toString())),
                        icon: myIcon,
                        infoWindow: InfoWindow(
                          title: '$driverName',
                          snippet: 'address',
                        ),
                      ),
                    },
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        zoom: 50,
                        target: LatLng(double.parse(dNewLat.toString()),
                            double.parse(dNewLong.toString())),
                      ),
                      // markers: markers.values.toSet(),
                      polylines: route.routes,
                      markers: {
                        Marker(
                          markerId: MarkerId('Drop Point'),
                          // position: LatLng(
                          //     double.parse(dNewLat.toString()), double.parse(dNewLong.toString())),
                          position: LatLng(double.parse(widget.lat.toString()),
                              double.parse(widget.long.toString())),
                          icon: BitmapDescriptor.defaultMarker,
                          infoWindow: InfoWindow(
                            title: 'Drop',
                            snippet: 'address',
                          ),
                        ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },

                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        approxTime.isNotEmpty?
                        IconButton(
                            onPressed: () {
                              getRoutes();
                              getLoc();
                            },
                            icon: Icon(Icons.location_searching_sharp)):Container(),
                        approxTime.isNotEmpty
                            ? Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "$approxTime",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Container(),
                        approxTime.isNotEmpty?
                        IconButton(
                            onPressed: () {
                              getRoutes();
                              _driver();
                            },
                            icon: Icon(Icons.delivery_dining)): Container()
                      ],
                    ),
                  )
                ],
              ),
            ):Card(child: ListTile(
              title: Text("Driver Not Available"),
            ),);
          } else if (snapshot.hasError) {
            return Icon(Icons.error_outline);
          } else {
            return CircularProgressIndicator();
          }
        });
  }
 //done
  Future<void> _driver() async {
    print(
        "Driver method Lat && Long ===================== $dNewLat && $dNewLong");
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(

        target: LatLng(double.parse(dNewLat.toString()),
            double.parse(dNewLong.toString())),
        zoom: 50
        // tilt: 59.440717697143555,
        )));
    final marker = Marker(
      markerId: MarkerId('Driver'),
      position: LatLng(
          double.parse(dNewLat.toString()), double.parse(dNewLong.toString())),
      icon: myIcon,
      infoWindow: InfoWindow(
        title: '$driverName',
        snippet: 'address',
      ),
    );
    setState(() {
      markers[MarkerId('place_name')] = marker;
    });
  }

  //done
  Future<void> getLoc() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(double.parse(widget.lat.toString()),
            double.parse(widget.long.toString())),
        zoom: 50
        // tilt: 59.440717697143555,
        )));
  }
}
