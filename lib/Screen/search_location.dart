import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:eshop_multivendor/Screen/Map.dart';

import 'Add_Address.dart';

class SearchLocationPage extends StatefulWidget {
  const SearchLocationPage({Key? key}) : super(key: key);

  @override
  _SearchLocationPageState createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  String location = "";
  var savePlace;

  search() async {
    var googlePlace = GooglePlace("AIzaSyBOhH-_4E4BPqgKR21SUOcMwqpzo_Cmt7o");
    var result = await googlePlace.search.getTextSearch(location);
    return result;
  }

  Position? position;

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (position != null) {
      setState(() {});
    } else {
      showToast("Current Location Fetch Failed");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Location"),
      // ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Select a Location",
          style: TextStyle(fontSize: 10),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: SizedBox(
              height: 45,
              child: TextField(
                cursorColor: Colors.grey,
                autofocus: true,
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.bold),
                // decoration: InputDecoration(
                //   hintText: "Search Here",
                //   fillColor: Colors.grey
                //
                // ),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 2)),

                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),

                  contentPadding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                  //  hintText: searchType ? "Search Food" : "Search Restaurant",
                  // hintText: getTranslated(context, 'SEARCH_LBL'),
                  hintStyle: TextStyle(color: Colors.grey),
                  // enabledBorder: UnderlineInputBorder(
                  //   borderSide:
                  //       BorderSide(color: Theme.of(context).colorScheme.white),
                  // ),
                  // focusedBorder: UnderlineInputBorder(
                  //   borderSide:
                  //       BorderSide(color: Colors.grey),
                  // ),
                ),
                onChanged: (value) {
                  setState(() {
                    location = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: height * 0.01),
          position != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Map(
                                      // latitude: latitude == null || latitude == ""
                                      //     ? position.latitude
                                      //     : double.parse(latitude!),
                                      // longitude:
                                      // longitude == null || longitude == ""
                                      //     ? position.longitude
                                      //     : double.parse(longitude!),
                                      latitude: position!.latitude,
                                      longitude: position!.longitude,
                                      from:
                                          getTranslated(context, 'ADDADDRESS'),
                                    )));
                        if (mounted) setState(() {});
                        List<Placemark> placemark =
                            await placemarkFromCoordinates(
                                double.parse(latitude!),
                                double.parse(longitude!));
                        print("====================");
                        if (placemark.isNotEmpty) {
                          Navigator.pop(
                              context, [placemark, latitude, longitude]);
                        }
                        print(placemark);
                        print(latitude);
                        print(longitude);
                        print("====================");
                        var landmark;
                        var address;
                        landmark = placemark[0].street;
                        address = placemark[0].locality;
                        // address = address + "," + placemark[0].street;
                        landmark = landmark + "," + placemark[0].subLocality;
                        address =
                            address + "," + placemark[0].administrativeArea;
                        address = address + " - " + placemark[0].postalCode;

                        // state = placemark[0].administrativeArea;
                        // country = placemark[0].country;
                        // pincode = placemark[0].postalCode;
                        // address = placemark[0].name;
                        // if (mounted) {
                        //   setState(() {
                        //     // countryC!.text = country!;
                        //     // stateC!.text = state!;
                        //     // addressC!.text = address;
                        //     // landmarkC!.text = landmark;
                        //     //  pincodeC!.text = pincode!;
                        //     // addressC!.text = address!;
                        //   });
                        // }
                      },
                      dense: true,
                      leading: Icon(
                        Icons.location_searching,
                        color: colors.primary,
                      ),
                      title: Text("Use Current Location"),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                )
              : CircularProgressIndicator(),
          Expanded(
            child: FutureBuilder(
                future: search(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: snapshot.data.results.length,
                      itemBuilder: (BuildContext context, int index) {
                        var data = snapshot.data.results[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              ListTile(
                                dense: true,
                                onTap: () async {
                                  List<Placemark> placemarks =
                                      await placemarkFromCoordinates(
                                          data.geometry.location.lat,
                                          data.geometry.location.lng);
                                  if (placemarks.isNotEmpty) {
                                    Navigator.pop(context, [
                                      placemarks,
                                      data.geometry.location.lat,
                                      data.geometry.location.lng
                                    ]);
                                  }
                                },
                                leading: Icon(
                                  Icons.location_on_outlined,
                                  color: colors.primary,
                                ),
                                title: Text(
                                  data.formattedAddress,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              Divider()
                            ],
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("No Place"));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          )
        ],
      ),
    );
  }
}
