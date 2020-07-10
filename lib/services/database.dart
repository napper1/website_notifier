import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models.dart';

class ServerDatabaseService {
  String path;

  ServerDatabaseService._();

  static final ServerDatabaseService db = ServerDatabaseService._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await init();
    return _database;
  }

  init() async {
    String path = await getDatabasesPath();
    path = join(path, 'server.db');
    print("Entered path $path");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Server (_id INTEGER PRIMARY KEY, name TEXT, url TEXT);');
      print('New table created at $path');
    });
  }

  Future<List<Server>> getServersFromDB() async {
    final db = await database;
    List<Server> serverList = [];
    List<Map> maps = await db.query('Server',
        columns: ['_id', 'name', 'url']);
    if (maps.length > 0) {
      maps.forEach((map) {
        serverList.add(Server.fromMap(map));
      });
    }
    return serverList;
  }

  updateServerInDB(Server updatedServer) async {
    final db = await database;
    await db.update('Server', updatedServer.toMap(),
        where: '_id = ?', whereArgs: [updatedServer.id]);
    print('Server updated: ${updatedServer.name} ${updatedServer.url}');
  }

  deleteServerInDB(Server serverToDelete) async {
    final db = await database;
    await db.delete('Server', where: '_id = ?', whereArgs: [serverToDelete.id]);
    print('Server deleted');
  }

  Future<Server> addServerInDB(Server newServer) async {
    final db = await database;
    if (newServer.name.trim().isEmpty) newServer.name = 'Untitled Server';
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into Server(name, url) VALUES ("${newServer.name}", "${newServer.url}");');
    });
    newServer.id = id;
    print('Server added: ${newServer.name} ${newServer.url}');
    return newServer;
  }
}
