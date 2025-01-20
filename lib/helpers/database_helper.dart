import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, filePath);
      debugPrint('Database path: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';

      await db.execute('''
        CREATE TABLE entries (
          id $idType,
          title $textType,
          content $textType,
          date $textType,
          mood $textType,
          color $intType
        )
      ''');
      debugPrint('Database table created successfully');
    } catch (e) {
      debugPrint('Error creating database table: $e');
      rethrow;
    }
  }

  DiaryEntry createEntry({
    required String title,
    required String content,
    required String date,
    required String mood,
    required int color,
  }) {
    return DiaryEntry(
      title: title,
      content: content,
      date: date,
      mood: mood,
      color: color,
    );
  }

  Future<int> create(DiaryEntry entry) async {
    try {
      final db = await instance.database;
      debugPrint('Inserting entry: ${entry.toJson()}');
      final id = await db.insert('entries', entry.toJson());
      debugPrint('Entry inserted with id: $id');
      return id;
    } catch (e) {
      debugPrint('Error inserting entry: $e');
      rethrow;
    }
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    try {
      final db = await instance.database;
      const orderBy = 'date DESC';
      final result = await db.query('entries', orderBy: orderBy);
      debugPrint('Retrieved ${result.length} entries');
      return result.map((json) => DiaryEntry.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting entries: $e');
      rethrow;
    }
  }

  Future<int> update(DiaryEntry entry) async {
    try {
      final db = await instance.database;
      return await db.update(
        'entries',
        entry.toJson(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    } catch (e) {
      debugPrint('Error updating entry: $e');
      rethrow;
    }
  }

  Future<int> delete(int id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'entries',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting entry: $e');
      rethrow;
    }
  }
}
