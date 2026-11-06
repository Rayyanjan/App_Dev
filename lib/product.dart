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
 factory Product.fromJson(Map<String, dynamic> json) => Product(
 id: json['id'],
 title: json['title'],
 description: json['description'],
 price: (json['price'] as num).toDouble(),
 category: json['category'],
 image: json['image'],
 rating: (json['rating']?['rate'] as num?)?.toDouble() ?? 0,
 );
}
