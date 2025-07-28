import 'package:flutter/material.dart';
import '../main.dart';
import 'place_dialog.dart';
import '../dbhelper.dart';

///edit and delete places form the map
class ManagePlaces extends StatelessWidget {
  const ManagePlaces({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Places')),
      body: PlacesList(),
    );
  }
}

///stateful widget to update the db
class PlacesList extends StatefulWidget {
  const PlacesList({super.key});

  @override
  State<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> {
  DbHelper helper = DbHelper();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: helper.places.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          ///this dismissable used the name of the location as the key. Should probaably be a uuid.
          key: Key(helper.places[index].name),
          onDismissed: (direction) {
            String strName = helper.places[index].name;
            helper.deletePlace(helper.places[index]);
            setState(() {
              helper.places.removeAt(index);
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("$strName deleted")));

            ///return to map and refresh.
            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => MainMap(),
            );
            Navigator.push(context, route);
        },
            ///list tile with name of place of current place.

          child: ListTile(
            title: Text(helper.places[index].name),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                ///isNew is false as this is an edit
                PlaceDialog dialog = PlaceDialog(helper.places[index], false);
                showDialog(
                  context: context,
                  builder: (context) => dialog.buildAlert(context, true),
                );
              },
            ),
            onTap: () {
              ///isNew is false as this is an edit
              PlaceDialog dialog = PlaceDialog(helper.places[index], false);
              showDialog(
                context: context,
                builder: (context) => dialog.buildAlert(context, false),
              );
            },
          ),
        );
      },
    );
  }
}
