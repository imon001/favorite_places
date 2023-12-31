import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import '../models/place.dart';

Future<Database> _getDb() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'), //create or open exist db
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places(id TEXT PRIMARY KEY,title TEXT,image TEXT,lat REAL,lng REAL,address TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class HandleUserPlacesNotifier extends StateNotifier<List<Place>> {
  HandleUserPlacesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    final db = await _getDb();

    final data = await db.query(
      'user_places',
    );
    final places = data.map((row) {
      return Place(
        id: row['id'] as String,
        title: row['title'] as String,
        image: File(
          row['image'] as String,
        ),
        location: PlaceLocation(
          latitude: row['lat'] as double,
          longitude: row['lng'] as double,
          address: row['address'] as String,
        ),
      );
    }).toList();
    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final cpyedImg = await image.copy('${appDir.path}/$fileName');
    final newPlace = Place(title: title, image: cpyedImg, location: location);
    final db = await _getDb();
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });
    state = [newPlace, ...state];
  }

  // Future<void> deleteAllData() async {
  //   final db = await _getDb();
  //   await db.delete('user_places'); // Replace 'your_table_name' with your actual table name
  // }
}

final handleUserPlaceProvider = StateNotifierProvider<HandleUserPlacesNotifier, List<Place>>(
  (ref) => HandleUserPlacesNotifier(),
);
