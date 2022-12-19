import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Screen/OrderDetail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
const double CAMERA_ZOOM = 15;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;


class MapPage extends StatefulWidget {
  bool status;
  LatLng? SOURCE_LOCATION;
  LatLng? DEST_LOCATION;
  bool live;
  String? id;
  String? approxTime;
  MapPage(this.status,{ this.SOURCE_LOCATION, this.DEST_LOCATION,required this.live,this.id,this.approxTime});

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  // this set will hold my markers
  Set<Marker> _markers = {};
  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  //todo change google map api
  String googleAPIKey = "AIzaSyD6Jt-f1wlCIXV146XMOGtxrTNfzVB-2oY";
  // for my custom icons
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? destinationIcon;
  LatLng? SOURCE_LOCATION;
  LatLng? DEST_LOCATION;

  bool status = false;
  @override
  void initState() {
    super.initState();
    setSourceAndDestinationIcons();
    if(widget.live){
      timer = Timer.periodic(Duration(seconds: 10), (timer) {
        getDriver();
      });
    }
    timer1 = Timer.periodic(Duration(minutes: 5), (timer) {
    //  getEstimated();
    });
  // getEstimated();
  }
  var approxTime = "";
  bool est = false;
  Future getEstimated() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${widget.SOURCE_LOCATION!.latitude},${widget.SOURCE_LOCATION!.longitude}&destinations=${widget.DEST_LOCATION!.latitude},${widget.DEST_LOCATION!.longitude}&key=AIzaSyD6Jt-f1wlCIXV146XMOGtxrTNfzVB-2oY'));
   // https://maps.googleapis.com/maps/api/distancematrix/json?origins=${driveLat}%2C${driveLng}&destinations=${widget.SOURCE_LOCATION!.latitude}%2C${widget.SOURCE_LOCATION!.longitude}%7C${widget.DEST_LOCATION!.latitude}%2C${widget.DEST_LOCATION!.longitude}&key=AIzaSyD6Jt-f1wlCIXV146XMOGtxrTNfzVB-2oY
    http.StreamedResponse response = await request.send();
    print(request);
    print(response.statusCode.toString()+"1234");
    if (response.statusCode == 200) {

      final str = await response.stream.bytesToString();
      var data = json.decode(str);
      print(data);
      if (data["status"] == "OK") {
        if(data["rows"][0]["elements"].toString().contains("text")){
          setState(() {
            approxTime =
                data["rows"][0]["elements"][0]["duration"]["text"].toString();
          });
        }else{
          setState(() {
            approxTime = "No Time";
          });
        }

      } else {}
    } else {
      return null;
    }
   /* if(!est){
      timer1 = Timer.periodic(Duration(seconds: 60), (timer) {
        getEstimated();
      });
      est = true;
    }*/

  }
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool acceptStatus = false;

  getDriver() async {
    Query needsSnapshot = FirebaseDatabase.instance.ref('Location/${widget.id}');
    needsSnapshot.onValue.listen((event) {
        print(event.snapshot.children.first.children.last.value);
        driveLat = double.parse(event.snapshot.children.first.children.first.value.toString());
        driveLng = double.parse(event.snapshot.children.first.children.last.value.toString());
        /*  if(!status){
            getEstimated();
          }
        status = true;*/
        updatePinOnMap();

      /*  DataSnapshot data = event.snapshot.children.first.children.first.value;
       */
    }).onError((e){

    });

  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late LatLng latLng;
  getMarkers() async {
    final GoogleMapController controller = await _controller.future;


    final MarkerId markerId =
    MarkerId((widget.id).toString());
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: markers[markerId]!.position, zoom: 15),
      ),
    );
  }

  double driveLat=0,driveLng=0;
  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(driveLat,
          driveLng),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    if(mounted)
    setState(() {
      // updated position
      var pinPosition = LatLng(driveLat,
          driveLng);

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere(
              (m) => m.markerId.value == 'drivePin');
      _markers.add(Marker(
          markerId: MarkerId('drivePin'),
          position: pinPosition, // updated position
          icon: driverIcon!
      ));
    });
  }
  void setSourceAndDestinationIcons() async {
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/driving_pin.png');
    if(widget.live){
      driverIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/driver.png');
    }

    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/destination_map_marker.png');
    if(widget.status){
      setState(() {
        SOURCE_LOCATION = widget.SOURCE_LOCATION;
        DEST_LOCATION = widget.DEST_LOCATION;
        setPolylines();
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }
  final colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  final colorizeTextStyle = TextStyle(
    fontSize: 14.0,
    fontFamily: 'Horizon',
  );
  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: widget.SOURCE_LOCATION!);
    return Stack(
      alignment: Alignment.topRight,
      children: [
        GoogleMap(
            myLocationEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            initialCameraPosition: initialLocation,
            onMapCreated: onMapCreated),
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colors.primary,
        ),
          child: Text("Estimate Time : ${widget.approxTime} Min",style: TextStyle(color: Colors.white),),
        ),
        msgRain!=null?Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width*0.98,
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child:AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  msgRain.toString(),
                  textStyle: colorizeTextStyle,
                  colors: colorizeColors,
                ),
              ],
              pause: Duration(milliseconds: 100),
              isRepeatingAnimation: true,
              totalRepeatCount: 10,
              onTap: () {
                print("Tap Event");
              },
            ),),
        ):SizedBox(),
      ],
    );
  }

  void onMapCreated(GoogleMapController controller) async{
   // controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    var nLat, nLon, sLat, sLon;
  if(widget.status) {
    SOURCE_LOCATION = widget.SOURCE_LOCATION;
    DEST_LOCATION = widget.DEST_LOCATION;
    if (DEST_LOCATION!.latitude <= SOURCE_LOCATION!.latitude) {
      sLat = DEST_LOCATION!.latitude;
      nLat = SOURCE_LOCATION!.latitude;
    } else {
      sLat = SOURCE_LOCATION!.latitude;
      nLat = DEST_LOCATION!.latitude;
    }
    if (DEST_LOCATION!.longitude <= SOURCE_LOCATION!.longitude) {
      sLon = DEST_LOCATION!.longitude;
      nLon = SOURCE_LOCATION!.longitude;
    } else {
      sLon = SOURCE_LOCATION!.longitude;
      nLon = DEST_LOCATION!.longitude;
    }
    LatLngBounds bound =
    LatLngBounds(southwest: LatLng(sLat, sLon), northeast: LatLng(nLat, nLon));
    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 100);
    controller.animateCamera(u2).then((void v) {});
  }
    if(widget.status){
      setMapPins();
      //setPolylines();
    }
  }

  void setMapPins() async{
    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: SOURCE_LOCATION!,
          icon: sourceIcon!));
      if(widget.live){
        _markers.add(Marker(
            markerId: MarkerId('drivePin'),
            position: SOURCE_LOCATION!,
            icon: driverIcon!));
      }

      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: DEST_LOCATION!,
          icon: destinationIcon!));
    });
  }

  setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(SOURCE_LOCATION!.latitude, SOURCE_LOCATION!.longitude),
      PointLatLng(DEST_LOCATION!.latitude, DEST_LOCATION!.longitude),
      travelMode: TravelMode.transit,

      optimizeWaypoints: true
    );
    print("${result.points} >>>>>>>>>>>>>>>>..");
    print("$SOURCE_LOCATION >>>>>>>>>>>>>>>>..");
    print("$DEST_LOCATION >>>>>>>>>>>>>>>>..");
    print(result.errorMessage);
    if (result.points.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }else{
      print("Failed");
    }
    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
        width: 2,
          polylineId: PolylineId("poly"),
          color: Colors.black,
          patterns: [
            PatternItem.dash(8),
            PatternItem.gap(3),
          ],
          points: polylineCoordinates);
      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    });
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}