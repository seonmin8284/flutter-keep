import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flt_keep/icons.dart';
import 'package:flt_keep/models.dart';
import 'package:flt_keep/services.dart';
import 'package:flt_keep/styles.dart';

/// Provide actions for a single [Note], used in a [BottomSheet].
class NoteActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final note = Provider.of<Note>(context);
    final state = note.state;
    final id = note.id;

    final textStyle = const TextStyle(
      color: kHintTextColorLight,
      fontSize: 16,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (id.isNotEmpty && state < NoteState.archived)
          ListTile(
            leading: const Icon(AppIcons.archive_outlined),
            title: Text('Archive', style: textStyle),
            onTap: () => Navigator.pop(
                context,
                NoteStateUpdateCommand(
                  id: id,
                  from: state,
                  to: NoteState.archived,
                  dismiss: true,
                )),
          ),
        if (state == NoteState.archived)
          ListTile(
            leading: const Icon(AppIcons.unarchive_outlined),
            title: Text('Unarchive', style: textStyle),
            onTap: () => Navigator.pop(
                context,
                NoteStateUpdateCommand(
                  id: id,
                  from: state,
                  to: NoteState.unspecified,
                )),
          ),
        if (id.isNotEmpty && state != NoteState.deleted)
          ListTile(
            leading: const Icon(AppIcons.delete_outline),
            title: Text('Delete', style: textStyle),
            onTap: () => Navigator.pop(
                context,
                NoteStateUpdateCommand(
                  id: id,
                  from: state,
                  to: NoteState.deleted,
                  dismiss: true,
                )),
          ),
        if (state == NoteState.deleted)
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text('Restore', style: textStyle),
            onTap: () => Navigator.pop(
                context,
                NoteStateUpdateCommand(
                  id: id,
                  from: state,
                  to: NoteState.unspecified,
                )),
          ),
        ListTile(
          leading: const Icon(AppIcons.share_outlined),
          title: Text('Send', style: textStyle),
        ),
      ],
    );
  }
}
