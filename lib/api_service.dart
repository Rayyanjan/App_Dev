import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart';
class ApiService {
 static const _base = 'https://fakestoreapi.com';
 Future<List<Product>> fetchAllProducts() async {
 final res = await http.get(Uri.parse('$_base/products'));
 final data = jsonDecode(res.body) as List;
 return data.map((e) => Product.fromJson(e)).toList();
 }
 Future<List<String>> fetchCategories() async {
 final res = await http.get(
 Uri.parse('$_base/products/categories'));
 return List<String>.from(jsonDecode(res.body));
 }
}