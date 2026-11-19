class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String image;
  final double rating;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> j) {
    return Product(
      id: j['id'],
      title: j['title'],
      description: j['description'],
      price: (j['price'] as num).toDouble(),
      category: j['category'],
      image: j['image'],
      rating: (j['rating']['rate'] as num).toDouble(),
    );
  }
}