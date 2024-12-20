class DynamicRecord<T> {
  String description;
  T value;

  DynamicRecord({
    required this.description,
    required this.value,
  });

  @override
  String toString() {
    return description;
  }
}
