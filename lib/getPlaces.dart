import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'constants.dart';

class getPlaces extends StatefulWidget {
  getPlaces({Key? key}) : super(key: key);

  @override
  _getPlacesState createState() => _getPlacesState();
}

class _getPlacesState extends State<getPlaces> {
  static const LatLng sourceLocation = LatLng(12.972442, 77.580643);
  static const LatLng destination = LatLng(12.31261, 76.65303);
  List places = [];
  Set<Marker> marker = new Set();
  List<LatLng> polylineCoordinates = [];
  var Numfactor = 10;

  Marker MarkerMaker(Map<String, dynamic> place) {
    return Marker(
        markerId: MarkerId("souuu"),
        position: LatLng(place['results'][0]['geometry']['location']['lat'],
            place['results'][0]['geometry']['location']['lng']));
  }

  Future<List> getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    final Set<Marker> tempMarker = new Set();
    List tempPlaces = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    // var len = polylineCoordinates.length;
    double lat, lang;

    for (var i = 0; i < polylineCoordinates.length; i += Numfactor) {
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
    });

    return tempPlaces;
  }

  @override
  void initState() {
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (marker.length != 0) {
      print("Length of marker: ");
      print(marker.length);
      print(marker);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: marker.length == (polylineCoordinates.length / Numfactor).toInt()
          ? GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: sourceLocation, zoom: 13.5),
              polylines: {
                Polyline(
                  polylineId: PolylineId("route"),
                  color: primaryColor,
                  width: 6,
                  points: polylineCoordinates,
                ),
              },
              markers: marker)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
