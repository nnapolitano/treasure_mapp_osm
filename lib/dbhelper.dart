import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:treasure_mapp/place.dart';

class DbHelper {
  List<Place> places = [];
  final int version = 1;
  late Database db;

  static final DbHelper _dbHelper = DbHelper._internal();

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  Future<Database> openDb() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'mapp.db'),
      onCreate: (database, version) {
        database.execute(
          'CREATE TABLE places(id INTEGER PRIMARY KEY, name TEXT,lat DOUBLE, lon DOUBLE, image TEXT)',
        );
      },
      version: version,
    );
    return db;
  }

  Future insertMockData() async {
    db = await openDb();
    await db.execute(
      'INSERT INTO places VALUES (1,"Beautiful park", 41.9294115, 12.5380785, "")',
    );
    await db.execute(
      'INSERT INTO places VALUES (2,"Best Pizza in the world", 41.9294115, 12.5268947, "")',
    );
    await db.execute(
      'INSERT INTO places VALUES (3,"The best icecream on earth", 41.9349061, 12.5339831, "")',
    );
    List places = await db.rawQuery('select * from places');
    print(places[0].toString());
  }

  Future<List<Place>> getPlaces() async {
    final List<Map<String, dynamic>> maps = await db.query('places');
    this.places = List.generate(maps.length, (i) {
      return Place(
        maps[i]['id'],
        maps[i]['name'],
        maps[i]['lat'],
        maps[i]['lon'],
        maps[i]['image'],
      );
    });
    return places;
  }

  ///Insert a new place to the database
  Future<int> insertPlace(Place place) async {
    int id = await this.db.insert(
      'places',
      place.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  ///delete a recod from the places table
  Future<int> deletePlace(Place place) async {
    int result = await db.delete(
      "places",
      where: "id = ?",
      whereArgs: [place.id],
    );
    return result;
  }
}
