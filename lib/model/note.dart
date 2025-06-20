import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:flt_keep/services.dart' show LocalStorageService;

/// Data model of a note.
class Note extends ChangeNotifier {
  final String id;
  String title;
  String content;
  Color color;
  NoteState state;
  final DateTime createdAt;
  DateTime modifiedAt;

  /// Instantiates a [Note].
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.state,
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  /// Whether this note is pinned
  bool get pinned => state == NoteState.pinned;

  /// Returns an numeric form of the state
  int get stateValue => state.index;

  bool get isNotEmpty => title.isNotEmpty || content.isNotEmpty;

  /// Formatted last modified time
  String get strLastModified => DateFormat.MMMd().format(modifiedAt);

  /// Save this note to local storage
  Future<void> saveToLocalStorage() async {
    await LocalStorageService.saveNote(this);
  }

  /// Update this note with another one.
  ///
  /// If [updateTimestamp] is `true`, which is the default,
  /// `modifiedAt` will be updated to `DateTime.now()`, otherwise, the value of `modifiedAt`
  /// will also be copied from [other].
  void update(Note other, {bool updateTimestamp = true}) {
    title = other.title;
    content = other.content;
    color = other.color;
    state = other.state;

    if (updateTimestamp) {
      modifiedAt = DateTime.now();
    } else {
      modifiedAt = other.modifiedAt;
    }
    notifyListeners();
  }

  /// Update this note with specified properties.
  ///
  /// If [updateTimestamp] is `true`, which is the default,
  /// `modifiedAt` will be updated to `DateTime.now()`.
  Note updateWith({
    required String title,
    required String content,
    required Color color,
    required NoteState state,
    bool updateTimestamp = true,
  }) {
    this.title = title;
    this.content = content;
    this.color = color;
    this.state = state;
    if (updateTimestamp) modifiedAt = DateTime.now();
    notifyListeners();
    return this;
  }

  /// Serializes this note into a JSON object.
  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'color': color.value,
        'state': stateValue,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'modifiedAt': modifiedAt.millisecondsSinceEpoch,
      };

  /// Make a copy of this note.
  ///
  /// If [updateTimestamp] is `true`, the defaults is `false`,
  /// timestamps both of `createdAt` & `modifiedAt` will be updated to `DateTime.now()`,
  /// or otherwise be identical with this note.
  Note copy({bool updateTimestamp = false}) => Note(
        id: id,
        title: title,
        content: content,
        color: color,
        state: state,
        createdAt: updateTimestamp ? DateTime.now() : createdAt,
        modifiedAt: updateTimestamp ? DateTime.now() : modifiedAt,
      )..update(this, updateTimestamp: updateTimestamp);

  @override
  bool operator ==(other) =>
      other is Note &&
      other.id == id &&
      other.title == title &&
      other.content == content &&
      other.stateValue == stateValue &&
      other.color == color;

  @override
  int get hashCode => id.hashCode;
}

/// State enum for a note.
enum NoteState {
  unspecified,
  pinned,
  archived,
  deleted,
}

/// Add properties/methods to [NoteState]
extension NoteStateX on NoteState {
  /// Checks if it's allowed to create a new note in this state.
  bool get canCreate => this <= NoteState.pinned;

  /// Checks if a note in this state can edit (modify / copy).
  bool get canEdit => this < NoteState.deleted;

  bool operator <(NoteState other) => (this?.index ?? 0) < (other?.index ?? 0);
  bool operator <=(NoteState other) =>
      (this?.index ?? 0) <= (other?.index ?? 0);

  /// Message describes the state transition.
  String get message {
    switch (this) {
      case NoteState.archived:
        return 'Note archived';
      case NoteState.deleted:
        return 'Note moved to trash';
      default:
        return '';
    }
  }

  /// Label of the result-set filtered via this state.
  String get filterName {
    switch (this) {
      case NoteState.archived:
        return 'Archive';
      case NoteState.deleted:
        return 'Trash';
      default:
        return '';
    }
  }

  /// Short message explains an empty result-set filtered via this state.
  String get emptyResultMessage {
    switch (this) {
      case NoteState.archived:
        return 'Archived notes appear here';
      case NoteState.deleted:
        return 'Notes in trash appear here';
      default:
        return 'Notes you add appear here';
    }
  }
}
