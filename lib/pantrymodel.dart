class PantryItem {
  String id;
  String name;
  DateTime? expiryDate;

  PantryItem({
    required this.id,
    required this.name,
    this.expiryDate,
  });

  factory PantryItem.fromDocument(Map<String, dynamic> doc, String id) {
    return PantryItem(
      id: id,
      name: doc['name'] ?? '',
      expiryDate: doc['expiryDate'] != null
          ? DateTime.parse(doc['expiryDate'])
          : null,
    );
  }
}
