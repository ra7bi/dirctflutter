import '../core/directus_client.dart';
import '../core/endpoints.dart';
import 'dart:convert';

/// Service to handle authentication with Directus.
class AuthService {
  final DirectusClient client;

  /// Constructs `AuthService` with a `DirectusClient`
  AuthService({required this.client});

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
}
