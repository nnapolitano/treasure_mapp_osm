import 'dart:io';
import 'package:flutter/material.dart';
import 'package:treasure_mapp/main.dart';
import 'package:treasure_mapp/place.dart';
import 'package:treasure_mapp/dbhelper.dart';

class PictureScreen extends StatelessWidget {
  final String imagePath;
  final Place place;

  ///constructor taking imagepath and place
  const PictureScreen(this.imagePath, this.place, {super.key});

  @override
  Widget build(BuildContext context) {
    DbHelper helper = DbHelper();
    return Scaffold(
      appBar: AppBar(
        title: Text('Save picture'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              place.image = imagePath;

              ///save the image
              helper.insertPlace(place);
              MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => MainMap(),
              );
              Navigator.push(context, route);
            },
          ),
        ],
      ),
      body: Container(child: Image.file(File(imagePath))),
    );
  }
}
