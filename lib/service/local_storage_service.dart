import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:flt_keep/models.dart' show Note, NoteState;

/// Service to handle local storage of notes using SharedPreferences
class LocalStorageService {
  static const String _notesKey = 'notes';
  static const String _userKey = 'current_user';

  /// Save a note to local storage
  static Future<void> saveNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();

    // Find existing note or add new one
    final existingIndex = notes.indexWhere((n) => n.id == note.id);
    if (existingIndex >= 0) {
      notes[existingIndex] = note;
    } else {
      // Generate new ID for new notes
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: note.title,
        content: note.content,
        color: note.color,
        state: note.state,
        createdAt: note.createdAt,
        modifiedAt: DateTime.now(),
      );
      notes.add(newNote);
    }

    await _saveNotes(notes);
  }

  /// Get all notes from local storage
  static Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];

    return notesJson.map((json) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return Note(
        id: data['id'] ?? '',
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        color: Color(data['color'] ?? 0xFFFFFFFF),
        state: NoteState.values[data['state'] ?? 0],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
        modifiedAt:
            DateTime.fromMillisecondsSinceEpoch(data['modifiedAt'] ?? 0),
      );
    }).toList();
  }

  /// Delete a note from local storage
  static Future<void> deleteNote(String noteId) async {
    final notes = await getNotes();
    notes.removeWhere((note) => note.id == noteId);
    await _saveNotes(notes);
  }

  /// Update note state
  static Future<void> updateNoteState(String noteId, NoteState state) async {
    final notes = await getNotes();
    final noteIndex = notes.indexWhere((note) => note.id == noteId);

    if (noteIndex >= 0) {
      notes[noteIndex] = notes[noteIndex].copy()
        ..updateWith(
          title: notes[noteIndex].title,
          content: notes[noteIndex].content,
          color: notes[noteIndex].color,
          state: state,
        );
      await _saveNotes(notes);
    }
  }

  /// Save notes list to SharedPreferences
  static Future<void> _saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes
        .map((note) => jsonEncode({
              'id': note.id,
              'title': note.title,
              'content': note.content,
              'color': note.color.value,
              'state': note.state.index,
              'createdAt': note.createdAt.millisecondsSinceEpoch,
              'modifiedAt': note.modifiedAt.millisecondsSinceEpoch,
            }))
        .toList();

    await prefs.setStringList(_notesKey, notesJson);
  }

  /// Clear all notes
  static Future<void> clearAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notesKey);
  }

  /// Get notes filtered by state
  static Future<List<Note>> getNotesByState(NoteState state) async {
    final notes = await getNotes();
    return notes.where((note) => note.state == state).toList();
  }

  /// Get notes sorted by creation date (newest first)
  static Future<List<Note>> getNotesSorted() async {
    final notes = await getNotes();
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }
}
