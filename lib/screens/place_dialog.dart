import 'dart:io';

import 'package:flutter/material.dart';
import 'package:treasure_mapp/screens/camera_screen.dart';
import '../dbhelper.dart';
import '../main.dart';
import '../place.dart';

///UI for adding a new place
class PlaceDialog {
  final txtName = TextEditingController();
  final txtLat = TextEditingController();
  final txtLong = TextEditingController();

  ///field for if new place
  late final bool isNew;
  late final Place place;

  ///constructor for a new place
  PlaceDialog(this.place, this.isNew);

  ///widget for for showing a dialog window
  Widget buildAlert(BuildContext context, bool isEdit) {
    DbHelper helper = DbHelper();
    txtName.text = place.name;
    txtLat.text = place.lat.toString();
    txtLong.text = place.lon.toString();

    ///only show edit options if in edit mode
    if (isEdit) {
      ///pop up dialog with fields to enter
      return AlertDialog(
        title: Text('Place'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: txtName,
                decoration: InputDecoration(hintText: 'Name'),
              ),
              TextField(
                controller: txtLat,
                decoration: InputDecoration(hintText: 'Latitude'),
              ),
              TextField(
                controller: txtLong,
                decoration: InputDecoration(hintText: 'Longitude'),
              ),

              ///show picture if present
              (place.image != '')
                  ? Container(child: Image.file(File(place.image)))
                  : Container(),

              ///open camera for picture
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  /// Update place with user input before insert
                  place.name = txtName.text;
                  place.lat = double.tryParse(txtLat.text) ?? 0.0;
                  place.lon = double.tryParse(txtLong.text) ?? 0.0;

                  if (isNew) {
                    helper.insertPlace(place).then((data) {
                      place.id = data;
                      MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) => CameraScreen(place),
                      );
                      Navigator.push(context, route);
                    });
                  } else {
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => CameraScreen(place),
                    );
                    Navigator.push(context, route);
                  }
                },
              ),

              ElevatedButton(
                onPressed: () async {
                  place.name = txtName.text;
                  place.lat = double.parse(txtLat.text);
                  place.lon = double.parse(txtLong.text);
                  await helper.insertPlace(place);

                  ///push the main route to return to map
                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => MainMap(),
                  );
                  Navigator.push(context, route);

                },
                child: Text('OK'),
              ),
            ],
          ),
        ),
      );
    } else {
      ///read only fields
      return AlertDialog(
        title: Text(place.name),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Text("Latitude: ${place.lat.toString()}"),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text("Longitude: ${place.lon.toString()}"),
              ),

              ///show picture if present
              (place.image != '')
                  ? Container(child: Image.file(File(place.image)))
                  : Container(),
            ],
          ),
        ),
      );
    }
  }
}
