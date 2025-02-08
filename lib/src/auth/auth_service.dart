import '../core/directus_client.dart';
import '../core/endpoints.dart';
import 'dart:convert';

/// Service to handle authentication with Directus.
class AuthService {
  final DirectusClient client;
  String? _refreshToken;

  /// Constructs `AuthService` with a `DirectusClient`
  AuthService({required this.client});

  /// Refreshes the authentication token.
  Future<void> refreshToken() async {
    if (_refreshToken == null) {
      throw Exception("No refresh token available.");
    }

    final response = await client.post(
      "auth/refresh",
      {'refresh_token': _refreshToken},
    );

    final decodedResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      client.setToken(decodedResponse['data']['access_token']);
      _refreshToken =
          decodedResponse['data']['refresh_token']; // Update refresh token
    } else {
      throw Exception(decodedResponse['errors'][0]['message']);
    }
  }

  /// Logs in a user with the provided [email] and [password].
  /// Returns a map containing authentication tokens.
  /// Throws an exception if authentication fails.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      DirectusEndpoints.login,
      {
        'email': email,
        'password': password,
      },
    );

    final decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      client.setToken(decodedResponse['data']['access_token']);
      return decodedResponse;
    } else {
      throw Exception(decodedResponse['errors'][0]['message']);
    }
  }

  /// Logs out the currently authenticated user.
  Future<void> logout() async {
    await client.post('auth/logout', {});
    client.setToken(null);
  }

  /// Retrieves the currently authenticated user's details.
  Future<Map<String, dynamic>> me() async {
    final response = await client.get('users/me');

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception(jsonDecode(response.body)['errors'][0]['message']);
    }
  }

  /// Registers a new user with the provided data.
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await client.post('users', userData);

    final decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return decodedResponse['data'];
    } else {
      throw Exception(decodedResponse['errors'][0]['message']);
    }
  }

  /// Requests a password reset for the given [email].
  /// Directus will send a password reset email if the email exists.
  Future<void> resetPassword(String email) async {
    final response =
        await client.post('auth/password/request', {'email': email});

    final decodedResponse = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(decodedResponse['errors'][0]['message']);
    }
  }
}
