import 'dart:async';
import 'package:flutter/material.dart';
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
  // ignore: unused_field
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.4223, -122.0848);
  static const LatLng destination = LatLng(37.4116, -122.0713);

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

  void getCurrrentLocation() async {
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
    // getCurrrentLocation();
    // setCustomMarkerIcon();
    // getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Assistant",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        body: currentLocation != null
            ? const Center(child: Text("Loading")) // Change this (Maybe idk)
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      // child: GoogleMap(
                      //   initialCameraPosition: CameraPosition(
                      //     target: LatLng(currentLocation!.latitude!,
                      //         currentLocation!.longitude!),
                      //     zoom: 13.5,
                      //   ),
                      //   polylines: {
                      //     Polyline(
                      //       polylineId: const PolylineId("route"),
                      //       points: polylineCoordinates,
                      //       color: primaryColor,
                      //       width: 6,
                      //     )
                      //   },
                      //   markers: {
                      //     Marker(
                      //       markerId: const MarkerId("currentLocation"),
                      //       position: LatLng(currentLocation!.latitude!,
                      //           currentLocation!.longitude!),
                      //       icon: currentLocationIcon,
                      //     ),
                      //     Marker(
                      //       markerId: const MarkerId("source"),
                      //       position: sourceLocation,
                      //       icon: sourceIcon,
                      //     ),
                      //     Marker(
                      //       markerId: const MarkerId("destination"),
                      //       position: destination,
                      //       icon: destinationIcon,
                      //     ),
                      //   },
                      //   onMapCreated: (mapController) {
                      //     _controller.complete(mapController);
                      //   },
                      // ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                            child: SizedBox(
                              height: 100,111
                              child: Center(child: Text("Test 1")),
                            ),
                          ),
                          Card(
                            child: SizedBox(
                              height: 100,
                              child: Center(child: Text("Test 2")),
                            ),
                          ),
                          Card(
                            child: SizedBox(
                              height: 100,
                              child: Center(child: Text("Test 3")),
                            ),
                          ),
                          Card(
                            child: SizedBox(
                              height: 100,
                              child: Center(child: Text("Test 3")),
                            ),
                          ),
                          Card(
                            child: SizedBox(
                              height: 100,
                              child: Center(child: Text("Test 3")),
                            ),
                          ),
                          Card(
                            child: SizedBox(
                              height: 100,
                              child: Center(child: Text("Test 3")),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )));
  }
}
