class Note {
  int id;
  String title;
  String description;
  String? tags;
  DateTime createdAt;
  DateTime? lastUpdatedAt;
  bool isArchived;

  Note({
    required this.id,
    required this.title,
    required this.description,
    this.tags,
    required this.createdAt,
    this.lastUpdatedAt,
    required this.isArchived,
  });

  static Note create({
    required String title,
    required String description,
    required String? tags,
  }) {
    return Note(
      id: 0,
      title: title,
      description: description,
      tags: tags,
      createdAt: DateTime.now(),
      isArchived: false,
    );
  }

  update({
    required String title,
    required String description,
    required String? tags,
  }) {
    this.title = title;
    this.description = description;
    this.tags = tags;
  }

  @override
  String toString() {
    return title;
  }
}
