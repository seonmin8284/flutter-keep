import 'package:flutter/material.dart';
import 'package:flt_keep/model/note.dart';

import 'note_item.dart';

/// ListView for notes
class NotesList extends StatelessWidget {
  final List<Note> notes;
  final void Function(Note)? onTap;

  const NotesList({
    Key? key,
    required this.notes,
    this.onTap,
  }) : super(key: key);

  static NotesList create({
    Key? key,
    required List<Note> notes,
    void Function(Note)? onTap,
  }) =>
      NotesList(
        key: key,
        notes: notes,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            notes.asMap().entries.expand((entry) {
              final i = entry.key;
              final note = entry.value;
              return <Widget>[
                InkWell(
                  onTap: onTap != null ? () => onTap!(note) : null,
                  child: NoteItem(note: note),
                ),
                if (i < notes.length - 1) const SizedBox(height: 10),
              ];
            }).toList(),
          ),
        ),
      );
}
