import 'package:flutter_map/flutter_map.dart';

///Extending flutter_map Marker to allow for the Id and Name as expected for this chapter.
///May be better  to refactor and take a Place as parameter

class KeyedMarker extends Marker {
  final String markerId;
  final String markerName;

  const KeyedMarker({
    required super.point,
    required super.child,
    super.width = 30.0,
    super.height = 30.0,
    required this.markerId,
    required this.markerName,
  });
}
