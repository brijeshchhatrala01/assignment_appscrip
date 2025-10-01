import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class ApiService {
  static const String baseUrl = "https://jsonplaceholder.typicode.com/users";

  static Future<List<UserModel>> fetchUsers() async {
    try {
      final uri = Uri.parse(baseUrl);

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timed out");
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception("Access forbidden (403). Check API permissions.");
      } else {
        throw Exception("Failed to load users: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("API fetchUsers error: $e");
      throw Exception("Error fetching users: $e");
    }
  }
}
