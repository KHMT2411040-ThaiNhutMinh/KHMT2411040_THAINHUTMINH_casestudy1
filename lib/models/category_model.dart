class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'income' | 'expense'
  final int iconCode;
  final int color;

  const CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'icon_code': iconCode,
    'color': color,
  };

  factory CategoryModel.fromMap(Map<String, dynamic> m) => CategoryModel(
    id: m['id'] as int?,
    name: m['name'] as String,
    type: m['type'] as String,
    iconCode: m['icon_code'] as int,
    color: m['color'] as int,
  );
}