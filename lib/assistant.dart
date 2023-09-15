import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Assistant extends StatefulWidget {
  const Assistant({Key? key}) : super(key: key);

  @override
  State<Assistant> createState() => AssistantState();
}

class AssistantState extends State<Assistant> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(12.972442, 77.580643);
  static const LatLng destination = LatLng(12.31261, 76.65303);
  List places = [];
  Set<Marker> marker = new Set();
  List<LatLng> polylineCoordinates = [];
  int Numfactor = 100;

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

  Marker MarkerMaker(Map<String, dynamic> place) {
    return Marker(
        markerId: MarkerId("souuu"),
        position: LatLng(place['results'][0]['geometry']['location']['lat'],
            place['results'][0]['geometry']['location']['lng']));
  }

  TextField InputBox(String val) {
    return TextField(
      decoration: InputDecoration(
        labelText: val,
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(height: 1),
    );
  }

  // LocationData? currentLocation;
  static const LatLng currentLocation = sourceLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  // Future<void> getCurrrentLocation() async {
  //   Location location = Location();

  //   location.getLocation().then(
  //     (location) {
  //       currentLocation = location;
  //     },
  //   );

  //   GoogleMapController googleMapController = await _controller.future;

  //   location.onLocationChanged.listen((newLoc) {
  //     currentLocation = newLoc;
  //     googleMapController.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(
  //           zoom: 13.5,
  //           target: LatLng(
  //             newLoc.latitude!,
  //             newLoc.longitude!,
  //           ),
  //         ),
  //       ),
  //     );
  //     setState(() {});
  //   });
  // }

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

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    final Set<Marker> tempMarker = new Set();
    List tempPlaces = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    print(result.errorMessage);

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    // var len = polylineCoordinates.length;
    double lat, lang;

    for (var i = 0; i < 30; i += 10) {
      lat = polylineCoordinates[i].latitude;
      lang = polylineCoordinates[i].longitude;
      var res = await http.get(Uri.https(
          'maps.googleapis.com', '/maps/api/place/nearbysearch/json', {
        'location': '$lat,$lang',
        'radius': '1500',
        'type': 'restaurant',
        'key': google_api_key
      }));
      // print(res.statusCode);
      if (res.statusCode == 200) {
        tempMarker
            .add(MarkerMaker(json.decode(res.body) as Map<String, dynamic>));
        tempPlaces.add(json.decode(res.body) as Map<String, dynamic>);
      }
    }
    setState(() {
      places = tempPlaces;
      marker = tempMarker;
    });
  }

  @override
  void initState() {
    // marker.add(Marker(
    //   markerId: const MarkerId("currentLocation"),
    //   position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
    //   icon: currentLocationIcon,
    // ));
    marker.add(
      Marker(
        markerId: const MarkerId("source"),
        position: sourceLocation,
        icon: sourceIcon,
      ),
    );
    marker.add(Marker(
      markerId: const MarkerId("destination"),
      position: destination,
      icon: destinationIcon,
    ));
    // getCurrrentLocation();
    // setCustomMarkerIcon();
    getPolyPoints();
    getRecommendation();
    super.initState();
  }

  static const bool showMap = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Plan your trip",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        body: currentLocation == null || marker.length != 3
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
                                    target: LatLng(sourceLocation.latitude,
                                        sourceLocation.longitude),
                                    zoom: 13.5,
                                  ),
                                  polylines: {
                                    Polyline(
                                      polylineId: const PolylineId("route"),
                                      points: polylineCoordinates,
                                      color: primaryColor,
                                      width: 6,
                                    )
                                  }, //! TEMP COMMENT --------------------------------
                                  markers: marker,
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
                            for (var i = 0; i < places.length; i++)
                              Card(
                                child: SizedBox(
                                    height: 100,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Text(places[i]['results'][0]
                                                ['name']),
                                            Text(places[i]['results'][0]
                                                        ['geometry']['location']
                                                    ['lat']
                                                .toString()),
                                            Text(places[i]['results'][0]
                                                        ['geometry']['location']
                                                    ['lng']
                                                .toString()),
                                          ],
                                        ),
                                      ),
                                    )),
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
