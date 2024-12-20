import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

class NoteDetailsPage extends StatefulWidget {
  final Note? note;
  final void Function(Note) onConfirm;

  const NoteDetailsPage({
    required this.onConfirm,
    this.note,
  });

  @override
  State<NoteDetailsPage> createState() => _NoteDetailsPageState();
}

class _NoteDetailsPageState extends State<NoteDetailsPage> {
  late final TextEditingController _titleController =
      TextEditingController(text: widget.note?.title);
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.note?.description);
  late final TextEditingController _tagsController =
      TextEditingController(text: widget.note?.tags);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => save(context),
            splashRadius: 20,
            icon: const Icon(
              Icons.check,
              size: 20,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          width: double.infinity,
          child: TextField(
            maxLines: 1,
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Title',
              hintStyle: TextStyle(fontSize: 20),
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            width: double.infinity,
            child: TextField(
              minLines: null,
              maxLines: null,
              expands: true,
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Write anything...',
                contentPadding: EdgeInsets.all(10),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (widget.note?.lastUpdatedAt != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Last Update: ${DateFormat('EEE, dd MMM yyyy', 'en').format(widget.note!.lastUpdatedAt!)}',
                textAlign: TextAlign.center,
              ),
            ),
        ])
      ]),
    );
  }

  save(BuildContext context) {
    var title = _titleController.value.text;
    var description = _descriptionController.value.text;
    var tags = _tagsController.value.text;

    if (title.isEmpty || description.isEmpty) {
      Fluttertoast.showToast(msg: 'There are empty fields');
      return;
    }

    Navigator.pop(context);

    if (widget.note != null) {
      var editedNote = widget.note!
        ..update(
          title: title,
          description: description,
          tags: tags.isNotEmpty ? tags : null,
        );

      widget.onConfirm(editedNote);
    } else {
      widget.onConfirm(
        Note.create(
          title: title,
          description: description,
          tags: tags.isNotEmpty ? tags : null,
        ),
      );
    }
  }
}
