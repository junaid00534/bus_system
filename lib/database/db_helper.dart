// lib/database/db_helper.dart

import 'dart:io';
import 'package:bus_ticket_system/admin/models/bus_model.dart';
import 'package:bus_ticket_system/database/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  // ============================================================
  // INIT DATABASE
  // ============================================================
  Future<Database> get database async {
    if (_database != null) return _database!;

    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDB('junaid_bus.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, fileName);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 10,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  // ============================================================
  // CREATE TABLES
  // ============================================================
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT,
        lastName TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        cnic TEXT,
        gender TEXT,
        password TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS routes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        busNo TEXT,
        fromCity TEXT,
        toCity TEXT,
        via TEXT,
        date TEXT,
        time TEXT,
        busType TEXT,
        refreshment INTEGER,
        routeName TEXT,
        seats INTEGER,
        fare REAL,
        originalFare REAL,
        discount REAL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS buses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        busName TEXT,
        routeName TEXT,
        fromCity TEXT,
        toCity TEXT,
        routeVia TEXT,
        date TEXT,
        day TEXT,
        time TEXT,
        busClass TEXT,
        seats INTEGER,
        fare REAL,
        originalFare REAL,
        discount INTEGER,
        discountLabel TEXT,
        refreshment INTEGER,
        busNumber TEXT,
        driverName TEXT,
        createdAt TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        busId INTEGER,
        seatNumber INTEGER,
        gender TEXT,
        bookingDate TEXT,
        status TEXT
      );
    ''');

    // ---------------- PAYMENT TABLE ----------------
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        busId INTEGER,
        seats TEXT,
        amount REAL,
        date TEXT,
        passengerName TEXT,
        passengerCnic TEXT,
        passengerPhone TEXT,
        paymentMethod TEXT,
        accountNumber TEXT,
        email TEXT
      );
    ''');
  }

  // ============================================================
  // ON UPGRADE
  // ============================================================
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS bookings');
    await db.execute('DROP TABLE IF EXISTS buses');
    await db.execute('DROP TABLE IF EXISTS routes');
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS payments');

    await _createDB(db, newVersion);
  }

  // ============================================================
  // ROUTES CRUD
  // ============================================================
  Future<int> insertRoute(Map<String, dynamic> route) async {
    final db = await database;

    return await db.insert('routes', {
      "busNo": route["busNo"],
      "fromCity": route["fromCity"],
      "toCity": route["toCity"],
      "via": route["via"],
      "date": route["date"],
      "time": route["time"],
      "busType": route["busType"] ?? "",
      "refreshment": route["refreshment"] ?? 0,
      "routeName": route["routeName"],
      "seats": route["seats"],
      "fare": route["fare"],
      "originalFare": route["originalFare"],
      "discount": route["discount"],
    });
  }

  Future<List<Map<String, dynamic>>> getRoutes() async {
    final db = await database;
    return await db.query('routes', orderBy: "date ASC, time ASC");
  }

  Future<int> updateRoute(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'routes',
      data,
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<int> deleteRoute(int id) async {
    final db = await database;
    return await db.delete('routes', where: "id=?", whereArgs: [id]);
  }

  // ============================================================
  // BUSES CRUD
  // ============================================================
  Future<void> insertBus(BusModel bus) async {
    final db = await database;
    await db.insert("buses", bus.toMap());
  }

  Future<List<Map<String, dynamic>>> getBusesByDate(String dateKey) async {
    final db = await database;

    return await db.query(
      'buses',
      where: 'date=?',
      whereArgs: [dateKey],
      orderBy: "time ASC",
    );
  }

  Future<void> updateBus(int id, BusModel bus) async {
    final db = await database;

    await db.update(
      "buses",
      bus.toMap(),
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<void> deleteBus(int id) async {
    final db = await database;
    await db.delete("buses", where: "id=?", whereArgs: [id]);
  }

  // ============================================================
  // USER AUTH
  // ============================================================
  Future<void> registerUser(UserModel user) async {
    final db = await database;

    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<dynamic> loginUser(String email, String pass) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, pass],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<dynamic> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email=?', whereArgs: [email]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updatePassword(String email, String pass) async {
    final db = await database;

    await db.update(
      'users',
      {"password": pass},
      where: "email=?",
      whereArgs: [email],
    );
  }

  // ============================================================
  // USER-SIDE BUS SEARCH
  // ============================================================
  Future<List<Map<String, dynamic>>> getBusesByRoute(
      String from, String to) async {
    final db = await database;

    return await db.rawQuery(
      '''
      SELECT * FROM buses
      WHERE LOWER(fromCity) = LOWER(?)
        AND LOWER(toCity) = LOWER(?)
      ORDER BY time ASC
      ''',
      [from, to],
    );
  }

  // ============================================================
  // GET BOOKED SEATS (WITH GENDER)
  // ============================================================
  Future<List<Map<String, dynamic>>> getBookedSeatsWithGender(int busId) async {
    final db = await database;

    return await db.query(
      'bookings',
      columns: ['seatNumber', 'gender'],
      where: 'busId = ?',
      whereArgs: [busId],
    );
  }

  // ============================================================
  // BOOK SEATS
  // ============================================================
  Future<void> bookSeats({
    required int busId,
    required List<String> seats,
    required String gender,
    required String date,
    int userId = 0,
  }) async {
    final db = await database;

    Batch batch = db.batch();

    for (String seat in seats) {
      batch.insert("bookings", {
        "userId": userId,
        "busId": busId,
        "seatNumber": int.parse(seat),
        "gender": gender,
        "bookingDate": date,
        "status": "booked",
      });
    }

    await batch.commit(noResult: true);
  }

  // ============================================================
  // INSERT PAYMENT  (✔ MATCHES PaymentScreen)
  // ============================================================
  Future<int> insertPayment({
    required int busId,
    required List<int> seats,
    required String passengerName,
    required String passengerEmail,
    required String paymentMethod,
    required String accountNumber,

    String? date,
    double? amount,
    String? passengerCnic,
    String? passengerPhone,
  }) async {
    final db = await database;

    return await db.insert("payments", {
      "busId": busId,
      "seats": seats.join(","),

      "amount": amount ?? 0.0,
      "date": date ?? DateTime.now().toString(),

      "passengerName": passengerName,
      "passengerCnic": passengerCnic ?? "",
      "passengerPhone": passengerPhone ?? "",

      "paymentMethod": paymentMethod,
      "accountNumber": accountNumber,
      "email": passengerEmail,
    });
  }

  Future<List<Map<String, dynamic>>> getPayments() async {
    final db = await database;
    return await db.query('payments', orderBy: "id DESC");
  }

  Future<Map<String, dynamic>?> getPaymentById(int id) async {
    final db = await database;
    final result = await db.query("payments", where: "id=?", whereArgs: [id]);

    return result.isNotEmpty ? result.first : null;
  }
}
