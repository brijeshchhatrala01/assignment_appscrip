import 'dart:convert';
import 'package:dio/dio.dart';
import '../model/user_model.dart';

class ApiService {
  static const String baseUrl = "https://jsonplaceholder.typicode.com/users";

  static Future<List<UserModel>> fetchUsers() async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));

    try {
      final response = await dio.get('');

      if (response.statusCode == 200) {
        List data = response.data; // Dio automatically parses JSON
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception(
            "Failed to load users. Status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Dio error: ${e.response?.statusCode} - ${e.response?.statusMessage}");
      } else {
        throw Exception("Dio error: ${e.message}");
      }
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
