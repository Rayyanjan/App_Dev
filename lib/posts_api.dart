import 'dart:convert';
import 'package:http/http.dart' as http;

class Post {
    const Post({
        required this.id,
        required this.userId,
        required this.title,
        required this.body,
    });

    final int id;
    final int userId;
    final String title;
    final String body;

    factory Post.fromJson(Map<String, dynamic> json) {
        return Post(
            id: json['id'],
            userId: json['userId'],
            title: json['title'],
            body: json['body'],
        );
    }

    Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
    };
}

class ApiResponse<T> {
    const ApiResponse({
        required this.statusCode,
        required this.data,
    });
    final int statusCode;
    final T data;
}

class PostApi {
    PostApi({http.Client? client}) : _client = client ?? http.Client();

    static const String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

    final http.Client _client;

    Future<ApiResponse<List<Post>>> fetchPosts() async {
        final response = await _client.get(Uri.parse(_baseUrl));
        if (response.statusCode != 200) {
            throw Exception('GET /posts failed with: ${response.statusCode}');
        }
        final body = json.decode(response.body) as List<dynamic>;
        final posts = body.cast<Map<String, dynamic>>().map(Post.fromJson).toList();
        return ApiResponse(statusCode: response.statusCode, data: posts);
    }
}