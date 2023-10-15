class BaseModel {
  final int id;
  final String imageUrl;
  final String name;
  final String category;
  final double price;
  double review;
  late int value;
  late int selectedSize;
  late int selectedColor;
  final String type;
  final String color;
  final String season;

  BaseModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.price,
    required this.review,
    required this.value,
    required this.selectedSize,
    required this.selectedColor,
    required this.type,
    required this.color, 
    required this.season,
  });

  factory BaseModel.fromMap(Map<String, dynamic> map) {
    return BaseModel(
      id: map['id'] as int,
      imageUrl:
          map['imageUrl'] as String? ?? '', // Provide a default value if null
      name: map['name'] as String? ?? '', // Provide a default value if null
      category:
          map['category'] as String? ?? '', // Provide a default value if null
      price: (map['price'] as num?)?.toDouble() ??
          0.0, // Provide a default value if null
      review: (map['review'] as num?)?.toDouble() ??
          0.0, // Provide a default value if null
      value: map['value'] as int? ?? 0, // Provide a default value if null
      selectedSize:
          map['selectedSize'] as int? ?? 0, // Provide a default value if null
      selectedColor:
          map['selectedColor'] as int? ?? 0, // Provide a default value if null
      type: map['type'] as String? ?? '',
      color: map['color'] as String? ?? '',
      season: map['season'] as String? ?? '',  // Provide a default value if null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'category': category,
      'price': price,
      'review': review,
      'value': value,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'type': type,
      'color': color,
      'season': season
    };
  }

  factory BaseModel.fromJson(Map<String, dynamic> json) {
    return BaseModel(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
      type: json['type'] as String,
      value: json['value'] as int,
      price: json['price'] as double,
      category: json['category'] as String,
      color: json['color'] as String,
      selectedSize: json['selectedSize'] as int,
      selectedColor: json['selectedColor'] as int,
      name: json['name'] as String,
      review: json['review'] as double,
      season: json['season'] as String, 
    );
  }
}
