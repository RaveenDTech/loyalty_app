class Vendor {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;
  final String? location;
  final double? rating;
  final bool isActive;

  Vendor({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
    this.location,
    this.rating,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'location': location,
      'rating': rating,
      'isActive': isActive,
    };
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      isActive: json['isActive'] ?? true,
    );
  }
}
