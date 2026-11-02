class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.category,
    required this.description,
    required this.thumbnail,
    required this.images,
    this.brand,
  });

  final int id;
  final String title;
  final double price;
  final double rating;
  final String category;
  final String description;
  final String thumbnail;
  final List<String> images;
  final String? brand;

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      images: images,
      brand: json['brand'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'rating': rating,
    'category': category,
    'description': description,
    'thumbnail': thumbnail,
    'images': images,
    'brand': brand,
  };
}

class ProductPage {
  const ProductPage(this.products, this.total);
  final List<Product> products;
  final int total;
}
