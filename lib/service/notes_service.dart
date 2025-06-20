import 'package:flutter/material.dart';

import 'package:flt_keep/models.dart' show Note, NoteState;
import 'package:flt_keep/styles.dart';
import 'local_storage_service.dart';

/// An undoable action to a [Note].
@immutable
abstract class NoteCommand {
  final String id;
  final bool dismiss;

  /// Defines an undoable action to a note, provides the note [id].
  const NoteCommand({
    required this.id,
    this.dismiss = false,
  });

  /// Returns `true` if this command is undoable.
  bool get isUndoable => true;

  /// Returns message about the result of the action.
  String get message => '';

  /// Executes this command.
  Future<void> execute();

  /// Undo this command.
  Future<void> revert();
}

/// A [NoteCommand] to update state of a [Note].
class NoteStateUpdateCommand extends NoteCommand {
  final NoteState from;
  final NoteState to;

  /// Create a [NoteCommand] to update state of a note [from] the current state [to] another.
  NoteStateUpdateCommand({
    required String id,
    required this.from,
    required this.to,
    bool dismiss = false,
  }) : super(id: id, dismiss: dismiss);

  @override
  String get message {
    switch (to) {
      case NoteState.deleted:
        return 'Note moved to trash';
      case NoteState.archived:
        return 'Note archived';
      case NoteState.pinned:
        return from == NoteState.archived
            ? 'Note pinned and unarchived' // pin an archived note
            : '';
      default:
        switch (from) {
          case NoteState.archived:
            return 'Note unarchived';
          case NoteState.deleted:
            return 'Note restored';
          default:
            return '';
        }
    }
  }

  @override
  Future<void> execute() => LocalStorageService.updateNoteState(id, to);

  @override
  Future<void> revert() => LocalStorageService.updateNoteState(id, from);
}

/// Mixin helps handle a [NoteCommand].
mixin CommandHandler<T extends StatefulWidget> on State<T> {
  /// Processes the given [command].
  Future<void> processNoteCommand(
      ScaffoldState? scaffoldState, NoteCommand? command) async {
    if (command == null) {
      return;
    }
    await command.execute();
    final msg = command.message;
    if (mounted && msg.isNotEmpty && command.isUndoable) {
      if (scaffoldState != null) {
        ScaffoldMessenger.of(scaffoldState.context).showSnackBar(
          SnackBar(
            content: Text(msg),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => command.revert(),
            ),
          ),
        );
      }
    }
  }
}

/// Add local storage related methods to the [Note] model.
extension NoteStore on Note {
  /// Save this note to local storage.
  ///
  /// If this's a new note, it will be created automatically.
  Future<void> saveToLocalStorage() async {
    await LocalStorageService.saveNote(this);
  }

  /// Update this note to the given [state].
  Future<void> updateState(NoteState state) async {
    if (id.isNotEmpty) {
      await LocalStorageService.updateNoteState(id, state);
    } else {
      updateWith(
        title: title,
        content: content,
        color: color,
        state: state,
      );
    }
  }
}

/// Get all notes from local storage
Future<List<Note>> getAllNotes() => LocalStorageService.getNotes();

/// Get notes filtered by state
Future<List<Note>> getNotesByState(NoteState state) =>
    LocalStorageService.getNotesByState(state);

/// Get notes sorted by creation date
Future<List<Note>> getNotesSorted() => LocalStorageService.getNotesSorted();

/// Delete a note
Future<void> deleteNote(String id) => LocalStorageService.deleteNote(id);
