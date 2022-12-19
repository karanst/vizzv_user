import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class NewLiveTrack extends StatefulWidget {
  final boyId;
  final lat;
  final long;
  final sellerLat;
  final sellerLong;
  final showSmall;

  const NewLiveTrack(
      {Key? key,
      this.boyId,
      this.lat,
      this.long,
      this.sellerLat,
      this.sellerLong, this.showSmall})
      : super(key: key);

  @override
  State<NewLiveTrack> createState() => _NewLiveTrackState();
}

class _NewLiveTrackState extends State<NewLiveTrack> {
  Completer<GoogleMapController> _controller = Completer();
  Logger _log = Logger();
  var driverName = "";
  late BitmapDescriptor myIcon;
  late BitmapDescriptor shopIcon;
  late BitmapDescriptor dropIcon;
  var dNewLat = "0.0";
  var dNewLong = "0.0";
  var approxTime = "";
  MapsRoutes route = new MapsRoutes();

  bool createdMap = true;

  getRoutes() async {
    List<LatLng> points = [
      LatLng(double.parse(dNewLat), double.parse(dNewLong)),
      LatLng(double.parse(widget.sellerLat.toString()),
          double.parse(widget.sellerLong.toString())),
      LatLng(double.parse(widget.lat.toString()),
          double.parse(widget.long.toString())),
    ];
    await route.drawRoute(points, "Delivery", Colors.red,
        "AIzaSyD6Jt-f1wlCIXV146XMOGtxrTNfzVB-2oY",
        travelMode: TravelModes.driving);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future getEstimated() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$dNewLat%2C$dNewLong&destinations=${widget.sellerLat}%2C${widget.sellerLong}%7C${widget.lat}%2C${widget.long}&key=AIzaSyD6Jt-f1wlCIXV146XMOGtxrTNfzVB-2oY'));
    http.StreamedResponse response = await request.send();
    print(request);
    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      var data = json.decode(str);
      _log.d(data);
      if (data["status"] == "OK") {
        setState(() {
          approxTime =
              data["rows"][0]["elements"][0]["duration"]["text"].toString();
        });
      } else {}
    } else {
      return null;
    }
  }

  approxDeliTime() {
    Timer mytimer = Timer.periodic(Duration(seconds: 10), (timer) {
      dNewLat != "0.0" ? getEstimated() : print("wait");

      // route.routes.clear();
      // getRoutes();
      //code to run on every 5 seconds
    });
    mytimer;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    approxDeliTime();
    super.dispose();
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
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(.3, .3)), 'assets/images/Loc_2.png')
        .then((onValue) {
      shopIcon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(.3, .3)), 'assets/images/loc_1.png')
        .then((onValue) {
      dropIcon = onValue;
    });
    approxDeliTime();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('Location/${widget.boyId}');
    return StreamBuilder(
        stream: starCountRef.onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            DataSnapshot snap = snapshot.data.snapshot;
            var lat;
            var long;
            if (snap.children.isNotEmpty) {
              lat = snap.child("address").child("lat").value;
              long = snap.child("address").child("long").value;
              dNewLat = snap.child("address").child("lat").value.toString();
              dNewLong = snap.child("address").child("long").value.toString();
            } else {}

            return snap.children.isNotEmpty
                ? Scaffold(
                    body: Animarker(
                      mapId: _controller.future.then((value) => value.mapId),
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
                        markers: {
                          Marker(
                            markerId: MarkerId('Shop'),
                            position: LatLng(
                                double.parse(widget.sellerLat.toString()),
                                double.parse(widget.sellerLong.toString())),
                            icon: shopIcon,
                            infoWindow: InfoWindow(
                              title: '',
                              snippet: 'address',
                            ),
                          ),
                          Marker(
                            markerId: MarkerId('Drop'),
                            position: LatLng(
                                double.parse(widget.lat.toString()),
                                double.parse(widget.long.toString())),
                            icon: dropIcon,
                            infoWindow: InfoWindow(
                              title: '',
                              snippet: 'address',
                            ),
                          ),
                        },
                        //driver location
                        initialCameraPosition: CameraPosition(
                          target: LatLng(double.parse(lat.toString()),
                              double.parse(long.toString())),
                          zoom: 20,
                        ),
                        polylines: route.routes,
                        onMapCreated: (GoogleMapController controller) {
                          if (createdMap) {
                            _controller.complete(controller);
                            setState(() {
                              createdMap = false;
                            });
                          } else {
                            print("nothing");
                          }
                        },
                      ),
                    ),
                    floatingActionButton:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        //driver get
                        FloatingActionButton(
                          onPressed: () {
                            _log.d(route.routes);
                            route.routes.clear();
                            getRoutes();
                            _driverLocation(lat, long);
                          },
                          child: Icon(
                            Icons.delivery_dining,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //estimated time
                        widget.showSmall?Container():
                        FloatingActionButton.extended(
                          onPressed: () {
                            _log.d(route.routes);
                            route.routes.clear();
                            getRoutes();
                          },
                          icon: Icon(
                            Icons.access_time,
                            color: Colors.white,
                          ),
                          label: Text(
                            "$approxTime",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //drop location
                        widget.showSmall?Container():
                        FloatingActionButton(
                          onPressed: () {
                            _log.d(route.routes);
                            route.routes.clear();
                            getRoutes();
                            _dropLocation();
                          },
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        widget.showSmall?Container():
                        FloatingActionButton(
                          onPressed: () {
                            _log.d(route.routes);
                            route.routes.clear();
                            getRoutes();
                            _shopLocation(
                                double.parse(widget.sellerLat.toString()),
                                double.parse(widget.sellerLong.toString()));
                          },
                          child: Icon(
                            Icons.house_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : Scaffold(
                    body: Center(
                      child: Text("No Data"),
                    ),
                  );
          } else if (snapshot.hasError) {
            return Icon(Icons.error_outline);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

//press Location
  Future<void> _dropLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(double.parse(widget.lat), double.parse(widget.long)),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414)));
  }

  Future<void> _driverLocation(lat, long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(double.parse(lat), double.parse(long)),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414)));
  }

  Future<void> _shopLocation(lat, long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(lat, long),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414)));
  }
}
