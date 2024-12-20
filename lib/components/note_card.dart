import 'package:flutter/material.dart';
import '../models/note.dart';
import '../view_models/bottom_sheet_action.dart';
import 'custom_bottom_sheet.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final void Function() onEdit;
  final void Function() onArchive;
  final void Function() onRestore;
  final void Function() onDelete;

  const NoteCard({
    required this.note,
    required this.onEdit,
    required this.onArchive,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      onLongPress: () => displayOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200]!,
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              note.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                  Text(
                    'Tags: ${note.tags ?? 'None'}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
          ),
        ]),
      ),
    );
  }

  displayOptions(context) {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (builder) {
          return CustomBottomSheet(options: [
            BottomSheetAction(
              label: 'Edit',
              icon: Icons.edit,
              onPressed: onEdit,
            ),
            if (!note.isArchived)
              BottomSheetAction(
                label: 'Archive',
                icon: Icons.archive,
                onPressed: onArchive,
              ),
            if (note.isArchived)
              BottomSheetAction(
                label: 'Restore',
                icon: Icons.restore,
                onPressed: onRestore,
              ),
            BottomSheetAction(
              label: 'Delete',
              icon: Icons.delete,
              onPressed: onDelete,
            ),
          ]);
        });
  }
}
