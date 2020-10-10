import 'dart:async';
import 'dart:io';
import 'package:task/models/rate.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DataBaseHelper {
  static final DataBaseHelper _instance = new DataBaseHelper.internal();

  factory DataBaseHelper() => _instance;
  static Database _db;

  final String rateTable = "rateTable";
  final String columnId = "id";
  final String columnName = "name";
  final String columnRate = "rate";

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  DataBaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentDirectory.path, "rate.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);

    return ourDb;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute("CREATE TABLE $rateTable( $columnId INTEGER PRIMARY KEY,"
        " $columnName TEXT,"
        " $columnRate DOUBLE"
        ")");
  }
 
  Future<int> saveRate(Rate rate) async {
    var dbClient = await db;
    int res = await dbClient.insert("$rateTable", rate.toMap());

    return res;
  }

  Future<List> getAllRates() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $rateTable");

    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $rateTable"));
  }

  Future<Rate> getRate(int id) async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery("SELECT * FROM $rateTable WHERE $columnId =$id");

    if (result.length == 0)
      return null;
    else
      return new Rate.fromMap(result.first);
  }

  Future<int> deleteRate(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(rateTable, where: "$columnId=?", whereArgs: [id]);
  }

 Future deleteAllRates() async {
    var dbClient = await db;
    return await dbClient.rawDelete("DELETE FROM $rateTable");
  }

  Future<int> updateRate(Rate rate) async {
    var dbClient = await db;
    return await dbClient.update(rateTable, rate.toMap(),
        where: "$columnName=?", whereArgs: [rate.name]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
