import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:treasure_mapp/extentions/keyed_marker.dart';
import 'package:treasure_mapp/screens/manage_places.dart';

import 'package:treasure_mapp/screens/place_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dbhelper.dart';
import 'example_popup.dart';
import 'place.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

///using flutter_map import, see docs.fleaflet.dev
///location permissions added in manifest

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainMap(),
    );
  }
}

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late DbHelper helper;
  late Position currentPos;

  ///Marker imported from flutter_map and modified to contain name and Id
  List<KeyedMarker> markers = [];

  @override
  void initState() {
    helper = DbHelper();
    _getCurrentLocation()
        .then((pos) {
          addMarker(pos, 'currpos', 'You are here');
          currentPos = pos;
        })
        .catchError((err) => print(err.toString()));
    super.initState();

    ///uncomment the following for inserting mock data
    // helper.insertMockData();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The Treasure Mapp'),

        ///app bar action
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => ManagePlaces(),
              );
              Navigator.push(context, route);
            },
          ),
        ],
      ),
      ///FAB for adding new location to map
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_location),
        onPressed: () {
          Place place;
          int here = markers.indexWhere((p) => p.markerId == 'currpos');
          if (here == -1) {
            ///current position is not aval
            place = Place(0, '', 0, 0, '');
          } else {
            LatLng pos = markers[here].point;
            place = Place(0, '', pos.latitude, pos.longitude, '');
          }
          PlaceDialog placeDialog = PlaceDialog(place, true);
          showDialog(
            context: context,
            builder: (context) => placeDialog.buildAlert(context, true),
          );
        },
      ),

      body: Container(
        child: FlutterMap(
          options: MapOptions(
            ///initial center set to columbus, oh
            initialCenter: LatLng(39.9625, -83.0032),

            ///inital center set to Rome
            //initialCenter: LatLng(41.9028, 12.4964),
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              //userAgentPackageName cannot be default
              userAgentPackageName: 'com.franklin.treasure_mapp',
            ),

            ///use PopupMarkerLayer for tappable markers
            PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                ///converting KeyedMarker to Marker for the PopupLayer
                markers: markers
                    .map((KeyedMarker) => KeyedMarker as Marker)
                    .toList(),
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) =>
                      ExamplePopup(marker),
                ),
              ),
            ),

            ///attribution required for OSM + flutter_maps
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',

                  ///Using url_launcher package for link
                  onTap: () => launchUrl(
                    Uri.parse('https://openstreetmap.org/copyright'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _getCurrentLocation() async {
    ///check if location is enabled
    bool isGeolocationAval = await Geolocator.isLocationServiceEnabled();

    ///mandatory permission check
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ///user denied permissions, handle exception here
        throw Exception(
          'Location permissions are denied. Restart App or enable in settings',
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ///user denied permissions forever, handle exception here
      throw Exception(
        'Location permissions are permanently denied and must be manually enabled in settings',
      );
    }

    ///if available, return the current position
    if (isGeolocationAval) {
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        throw Exception('Failed to get location: $e');
      }
    }
  }

  void addMarker(Position pos, String markerId, String markerName) {
    ///if current position, use blue marker, else use orange
    final Color markerColor = (markerId == 'currpos')
        ? Colors.blue
        : Colors.orange;

    final marker = KeyedMarker(
      markerId: markerId,
      markerName: markerName,
      point: LatLng(pos.latitude, pos.longitude),

      ///marker can be any type of widget, thus defining a widget for when tapped
      child: Icon(
        Icons.location_pin,
        color: markerColor,
        size: 40.0,
        semanticLabel: markerName,
      ),
    );
    markers.add(marker);
    setState(() {
      markers = markers;
    });
  }

  ///get marker data from database
  Future _getData() async {
    await helper.openDb();

    ///uncomment the following for testing
    // await helper.testDb();
    List<Place> _places = await helper.getPlaces();
    for (Place p in _places) {
      addMarker(
        Position(
          latitude: p.lat,
          longitude: p.lon,
          timestamp: DateTime(0),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
        p.id.toString(),
        p.name,
      );
    }
    setState(() {
      markers = markers;
    });
  }
}
