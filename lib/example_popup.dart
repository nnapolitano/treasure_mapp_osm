import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:treasure_mapp/extentions/keyed_marker.dart';

///ExamplePopup used from flutter_map_marker_popup github, only change was markerName, markerId, and getName()
class ExamplePopup extends StatefulWidget {
  final Marker marker;

  const ExamplePopup(this.marker, {super.key});

  @override
  State<StatefulWidget> createState() => _ExamplePopupState();
}

class _ExamplePopupState extends State<ExamplePopup> {
  String markerName = "";
  String markerId = "";

  /// extracting the name of the point from the extended Marker
  void getName() {
    if (widget.marker is Marker) {
      KeyedMarker keyedMarker = widget.marker as KeyedMarker;
      markerId = keyedMarker.markerId;
      markerName = keyedMarker.markerName;
    }
  }

  final List<IconData> _icons = [
    Icons.star_border,
    Icons.star_half,
    Icons.star,
  ];
  int _currentIcon = 0;

  @override
  void initState() {
    getName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() {
          _currentIcon = (_currentIcon + 1) % _icons.length;
        }),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Icon(_icons[_currentIcon]),
            ),
            _cardDescription(context),
          ],
        ),
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              markerName,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text(
              'Position: ${widget.marker.point.latitude}, ${widget.marker.point.longitude}',
              style: const TextStyle(fontSize: 12.0),
            ),
            Text(
              'Marker size: ${widget.marker.width}, ${widget.marker.height}',
              style: const TextStyle(fontSize: 12.0),
            ),

          ],
        ),
      ),
    );
  }
}
