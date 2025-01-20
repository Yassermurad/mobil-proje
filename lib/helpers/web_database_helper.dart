import 'dart:convert';
import 'dart:html' if (dart.library.html) 'dart:html' as html;
import '../models/note.dart';

class WebDatabaseHelper {
  static final WebDatabaseHelper instance = WebDatabaseHelper._init();
  static const String _notesKey = 'notes';
  static int _currentId = 0;
  static bool _initialized = false;

  WebDatabaseHelper._init();

  static Future<void> initializeDatabase() async {
    if (_initialized) return;
    _initialized = true;
    
    // Initialize current ID from stored notes
    final notesJson = html.window.localStorage[_notesKey];
    if (notesJson != null) {
      final notesList = jsonDecode(notesJson) as List;
      final notes = notesList
          .map((json) => Note.fromMap(Map<String, dynamic>.from(json)))
          .toList();
      if (notes.isNotEmpty) {
        _currentId = notes.map((n) => n.id ?? 0).reduce((max, id) => id > max ? id : max);
      }
    }
  }

  Future<Note> create(Note note) async {
    try {
      await initializeDatabase();
      final notes = await _getAllNotesInternal();
      
      // Increment ID for new note
      _currentId++;
      final newNote = Note(
        id: _currentId,
        title: note.title,
        content: note.content,
        date: note.date,
      );
      
      notes.add(newNote);
      await _saveNotes(notes);
      
      return newNote;
    } catch (e) {
      print('Web note creation error: $e');
      rethrow;
    }
  }

  List<Note> _getAllNotesInternal() {
    final notesJson = html.window.localStorage[_notesKey];
    if (notesJson == null) return [];
    
    final notesList = jsonDecode(notesJson) as List;
    return notesList
        .map((json) => Note.fromMap(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  Future<List<Note>> getAllNotes() async {
    try {
      await initializeDatabase();
      return _getAllNotesInternal();
    } catch (e) {
      print('Web get all notes error: $e');
      rethrow;
    }
  }

  Future<int> update(Note note) async {
    try {
      if (note.id == null) {
        throw Exception('Cannot update note without id');
      }

      await initializeDatabase();
      final notes = _getAllNotesInternal();
      final index = notes.indexWhere((n) => n.id == note.id);
      
      if (index == -1) {
        throw Exception('Note not found');
      }
      
      notes[index] = note;
      await _saveNotes(notes);
      return note.id!;
    } catch (e) {
      print('Web note update error: $e');
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await initializeDatabase();
      final notes = _getAllNotesInternal();
      notes.removeWhere((note) => note.id == id);
      await _saveNotes(notes);
    } catch (e) {
      print('Web note deletion error: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    // No need to close localStorage
  }

  Future<void> _saveNotes(List<Note> notes) async {
    final notesJson = jsonEncode(notes.map((note) => note.toMap()).toList());
    html.window.localStorage[_notesKey] = notesJson;
  }
}
