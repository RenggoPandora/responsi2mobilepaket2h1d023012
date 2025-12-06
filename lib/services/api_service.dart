import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Gunakan localhost untuk Windows Desktop
  static const String baseUrl = 'http://localhost:8080/api';

  // Register user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Koneksi gagal: $e'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      // Simpan user data jika berhasil login
      if (data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        // Convert to int safely
        final userId = data['data']['id'];
        await prefs.setInt(
          'user_id',
          userId is int ? userId : int.parse(userId.toString()),
        );
        await prefs.setString('username', data['data']['username'].toString());
        await prefs.setString('email', data['data']['email'].toString());
      }

      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Koneksi gagal: $e'};
    }
  }

  // Get user ID from SharedPreferences
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get all inventaris
  static Future<List<dynamic>> getInventaris() async {
    try {
      final userId = await getUserId();
      final response = await http.get(
        Uri.parse('$baseUrl/inventaris?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get single inventaris
  static Future<Map<String, dynamic>?> getInventarisById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inventaris/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create inventaris
  static Future<Map<String, dynamic>> createInventaris({
    required String nama,
    required int harga,
    required int jumlah,
    required String tanggalMasuk,
    required String tanggalKedaluwarsa,
  }) async {
    try {
      final userId = await getUserId();
      final response = await http.post(
        Uri.parse('$baseUrl/inventaris'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'nama': nama,
          'harga': harga,
          'jumlah': jumlah,
          'tanggal_masuk': tanggalMasuk,
          'tanggal_kedaluwarsa': tanggalKedaluwarsa,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Koneksi gagal: $e'};
    }
  }

  // Update inventaris
  static Future<Map<String, dynamic>> updateInventaris({
    required int id,
    required String nama,
    required int harga,
    required int jumlah,
    required String tanggalMasuk,
    required String tanggalKedaluwarsa,
  }) async {
    try {
      print('Updating inventaris ID: $id'); // Debug log
      final url = '$baseUrl/inventaris/$id';
      print('URL: $url'); // Debug log

      final response = await http
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nama': nama,
              'harga': harga,
              'jumlah': jumlah,
              'tanggal_masuk': tanggalMasuk,
              'tanggal_kedaluwarsa': tanggalKedaluwarsa,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      return jsonDecode(response.body);
    } catch (e) {
      print('Error updating: $e'); // Debug log
      return {'status': 'error', 'message': 'Koneksi gagal: $e'};
    }
  }

  // Delete inventaris
  static Future<Map<String, dynamic>> deleteInventaris(int id) async {
    try {
      print('Deleting inventaris ID: $id'); // Debug log
      final url = '$baseUrl/inventaris/$id';
      print('Delete URL: $url'); // Debug log

      final response = await http
          .delete(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print('Delete response status: ${response.statusCode}'); // Debug log
      print('Delete response body: ${response.body}'); // Debug log

      return jsonDecode(response.body);
    } catch (e) {
      print('Error deleting: $e'); // Debug log
      return {'status': 'error', 'message': 'Koneksi gagal: $e'};
    }
  }
}
