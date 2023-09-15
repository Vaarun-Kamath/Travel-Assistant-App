import 'dart:async';
// import 'dart:html';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

class Assistant extends StatefulWidget {
  const Assistant({Key? key}) : super(key: key);

  @override
  State<Assistant> createState() => AssistantState();
}

class AssistantState extends State<Assistant> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.4223, -122.0848);
  static const LatLng destination = LatLng(37.4116, -122.0713);
  Map<String, dynamic> placesRecommendation = {
    "1": {
      "name": "Bangalore Gate Hotel & Conferences",
      "lat": 12.9736482,
      "lng": 77.57919369999999
    },
    "2": {
      "name": "Sri renuka hotel",
      "lat": 12.7829874,
      "lng": 77.371534,
    },
    "3": {
      "name": "Hotel Roopa",
      "lat": 12.3083161,
      "lng": 76.65963219999999,
    },
    "4": {
      "name": "Hotel Roopa",
      "lat": 12.3083161,
      "lng": 76.65963219999999,
    },
    "5": {
      "name": "Hotel Roopa",
      "lat": 12.3083161,
      "lng": 76.65963219999999,
    },
    "6": {
      "name": "Hotel Roopa",
      "lat": 12.3083161,
      "lng": 76.65963219999999,
    }, //! ADD MORE INFORMATION LATER ==============
  };

  TextField InputBox(String val) {
    return TextField(
      decoration: InputDecoration(
        labelText: val,
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(height: 1),
    );
  }

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  Future<void> getCurrrentLocation() async {
    Location location = Location();

    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: LatLng(
              newLoc.latitude!,
              newLoc.longitude!,
            ),
          ),
        ),
      );
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  void getRecommendation() {} // TODO

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Pin_source.png')
        .then((icon) {
      sourceIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Pin_destination.png')
        .then((icon) {
      destinationIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Badge.png')
        .then((icon) {
      currentLocationIcon = icon;
    });
  }

  @override
  void initState() {
    getCurrrentLocation();
    setCustomMarkerIcon();
    getRecommendation();
    // getPolyPoints();
    super.initState();
  }

  static const bool showMap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Plan your trip",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        body: currentLocation == null
            ? const Center(
                child: CircularProgressIndicator()) // Change this (Maybe idk)
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 300,
                          child: !showMap
                              ? const Center(
                                  child: Text("Map is disabled"),
                                )
                              : GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(currentLocation!.latitude!,
                                        currentLocation!.longitude!),
                                    zoom: 13.5,
                                  ),
                                  // polylines: {
                                  //   Polyline(
                                  //     polylineId: const PolylineId("route"),
                                  //     points: polylineCoordinates,
                                  //     color: primaryColor,
                                  //     width: 6,
                                  //   )
                                  // }, //! TEMP COMMENT --------------------------------
                                  markers: {
                                    Marker(
                                      markerId:
                                          const MarkerId("currentLocation"),
                                      position: LatLng(
                                          currentLocation!.latitude!,
                                          currentLocation!.longitude!),
                                      icon: currentLocationIcon,
                                    ),
                                    Marker(
                                      markerId: const MarkerId("source"),
                                      position: sourceLocation,
                                      icon: sourceIcon,
                                    ),
                                    Marker(
                                      markerId: const MarkerId("destination"),
                                      position: destination,
                                      icon: destinationIcon,
                                    ),
                                  },
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  // zoomGesturesEnabled: true,
                                  zoomControlsEnabled: false,
                                  onMapCreated: (mapController) {
                                    _controller.complete(mapController);
                                  },
                                ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          heightFactor: 5,
                          child: RawMaterialButton(
                            onPressed: () {},
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(15.0),
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.fullscreen,
                              size: 25.0,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            for (var i in placesRecommendation.keys)
                              // Card(
                              //   child: SizedBox(
                              //       height: 100,
                              //       child: Center(
                              //         child: Padding(
                              //           padding: const EdgeInsets.all(10),
                              //           child: Column(
                              //             children: [
                              //               Text(placesRecommendation[i]
                              //                   ['name']),
                              //               Text(placesRecommendation[i]['lat']
                              //                   .toString()),
                              //               Text(placesRecommendation[i]['lng']
                              //                   .toString()),
                              //             ],
                              //           ),
                              //         ),
                              //       )),
                              // ),
                              Card(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading:
                                          Icon(Icons.arrow_drop_down_circle),
                                      title:
                                          Text(placesRecommendation[i]['name']),
                                      subtitle: Text(
                                        'Secondary Text',
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(children: [
                                          Text(
                                            placesRecommendation[i]['lat']
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.6)),
                                          ),
                                          Text(
                                            placesRecommendation[i]['lng']
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.6)),
                                          ),
                                        ])),
                                    // ButtonBar(
                                    //   alignment: MainAxisAlignment.start,
                                    //   children: [
                                    //     TextButton(
                                    //       onPressed: () {
                                    //         // Perform some action
                                    //       },
                                    //       child: const Text('ACTION 1'),
                                    //     ),
                                    //     TextButton(
                                    //       onPressed: () {
                                    //         // Perform some action
                                    //       },
                                    //       child: const Text('ACTION 2'),
                                    //     ),
                                    //   ],
                                    // ),
                                    // Image.asset('assets/card-sample-image.jpg'),
                                    // Image.asset(
                                    //     'assets/card-sample-image-2.jpg'),
                                  ],
                                ),
                              ),
                            const SizedBox(
                              height: 10,
                            ),
                            OutlinedButton(
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              onPressed: () {/* ! Navigate to route */},
                              child: const Text('Start Trip'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
