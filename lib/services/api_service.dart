
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tugasmobile7/models/clothing.dart';

class ApiService {
  static const String baseUrl =
      'https://tpm-api-tugas-872136705893.us-central1.run.app/api';

  static Future<List<Clothing>> getClothes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clothes'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((item) => Clothing.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load clothes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Clothing> getClothingById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clothes/$id'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Clothing.fromJson(jsonResponse['data'] ?? jsonResponse);
      } else {
        throw Exception('Failed to load clothing detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<bool> createClothing(Clothing clothing) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clothes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(clothing.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateClothing(int id, Clothing clothing) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/clothes/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(clothing.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteClothing(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/clothes/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
