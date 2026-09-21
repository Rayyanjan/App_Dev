import 'dart:convert';     
import 'dart:io';           
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

// ---- Custom exceptions ----
// These let the UI layer show a DIFFERENT message depending on
// what actually went wrong, instead of one generic "Error!" text.

class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);
}

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users'))

          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw ServerException('Server returned status ${response.statusCode}');
      }
    } on SocketException {

      throw NoInternetException('No internet connection. Please check your network.');
    } on FormatException {
     
      throw DataParsingException('Received invalid data from server.');
    } on http.ClientException {
      // Covers other low-level networking issues.
      throw NoInternetException('Could not reach the server.');
    }
    // Note: we deliberately do NOT catch TimeoutException here.
    // We let it bubble up as-is, and the state layer (next step)
    // will catch it and show a "Request timed out" message.
  }

  // Bonus: fetch a single user by id (useful later, and the
  // assignment mentions "GET single user by id" as part of the service).
  Future<UserModel> fetchUserById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/$id'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException('Server returned status ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException('No internet connection. Please check your network.');
    } on FormatException {
      throw DataParsingException('Received invalid data from server.');
    }
  }
}