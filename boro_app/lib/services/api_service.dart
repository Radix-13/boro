import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: await _headers(auth: auth),
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> get(String path, {Map<String, String>? params}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path').replace(queryParameters: params);
    final response = await http.get(uri, headers: await _headers());
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: await _headers(),
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  Future<void> delete(String path) async {
    await http.delete(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: await _headers(),
    );
  }

  dynamic _handleResponse(http.Response response) {
    final body = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    throw ApiException(
      statusCode: response.statusCode,
      message: body['detail'] ?? body.toString(),
    );
  }

  // ─── Auth ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post('/auth/login/', {'email': email, 'password': password}, auth: false);
    await _storage.write(key: AppConstants.accessTokenKey, value: data['access']);
    await _storage.write(key: AppConstants.refreshTokenKey, value: data['refresh']);
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    return post('/auth/register/', body, auth: false);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>> getMe() async => await get('/auth/me/');

  // ─── Items ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> getItems({Map<String, String>? params}) async {
    return await get('/items/', params: params);
  }

  Future<Map<String, dynamic>> getItem(int id) async => await get('/items/$id/');

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> body) async {
    return post('/items/', body);
  }

  Future<List<dynamic>> getCategories() async => await get('/items/categories/');

  Future<Map<String, dynamic>> getMyListings() async => await get('/items/my_listings/');

  // ─── Rentals ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> body) async {
    return post('/rentals/offers/', body);
  }

  Future<Map<String, dynamic>> acceptOffer(int offerId) async {
    return post('/rentals/offers/$offerId/accept/', {});
  }

  Future<Map<String, dynamic>> declineOffer(int offerId) async {
    return post('/rentals/offers/$offerId/decline/', {});
  }

  Future<Map<String, dynamic>> counterOffer(int offerId, double newPrice, String message) async {
    return post('/rentals/offers/$offerId/counter/', {
      'new_price': newPrice.toString(),
      'message': message,
    });
  }

  Future<List<dynamic>> getOffers() async => await get('/rentals/offers/');

  Future<List<dynamic>> getAgreements() async => await get('/rentals/agreements/');

  // ─── Reviews ─────────────────────────────────────────────────
  Future<List<dynamic>> getReviews({int? userId, int? itemId}) async {
    final params = <String, String>{};
    if (userId != null) params['user_id'] = userId.toString();
    if (itemId != null) params['item_id'] = itemId.toString();
    return await get('/reviews/', params: params);
  }

  Future<Map<String, dynamic>> createReview(Map<String, dynamic> body) async {
    return post('/reviews/', body);
  }

  Future<Map<String, dynamic>> getReputation(int userId) async {
    return await get('/reviews/reputation/$userId/');
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
