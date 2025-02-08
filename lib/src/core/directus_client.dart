import 'dart:convert';
import 'package:http/http.dart' as http;

/// A simple HTTP client to communicate with the Directus API.
class DirectusClient {
  late final String baseUrl;
  String? _token;
  http.Client httpClient;

  /// Constructs a `DirectusClient` with the given [baseUrl].
  /// Allows injection of an optional [httpClient] for testing.
  DirectusClient({required String baseUrl, http.Client? httpClient})
      : this.httpClient = httpClient ?? http.Client() {
    this.baseUrl = baseUrl.replaceAll(RegExp(r'\/+$'), '');
  }

  /// Allows setting a mock HTTP client for testing.
  void setHttpClient(http.Client mockClient) {
    httpClient = mockClient;
  }

  /// Sets the authentication token.
  void setToken(String? token) {
    _token = token;
  }

  /// Sends a `POST` request to the given [endpoint] with optional [data].
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    return _request('POST', endpoint, body: data);
  }

  /// Sends a `GET` request to the given [endpoint] with optional query parameters.
  Future<http.Response> get(String endpoint,
      [Map<String, String>? params]) async {
    return _request('GET', endpoint, queryParams: params);
  }

  /// Sends a `PUT` request to update data at the given [endpoint].
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    return _request('PUT', endpoint, body: data);
  }

  /// Sends a `DELETE` request to remove an item from the given [endpoint].
  Future<http.Response> delete(String endpoint) async {
    return _request('DELETE', endpoint);
  }

  /// Handles all HTTP requests and ensures the correct format.
  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final cleanEndpoint = endpoint.replaceAll(RegExp(r'^/+'), '');
    final uri = Uri.parse('$baseUrl/$cleanEndpoint')
        .replace(queryParameters: queryParams);
    final headers = _headers();

    late http.Response response;

    try {
      switch (method) {
        case 'POST':
          response = await httpClient.post(uri,
              headers: headers, body: jsonEncode(body));
          break;
        case 'GET':
          response = await httpClient.get(uri, headers: headers);
          break;
        case 'PUT':
          response = await httpClient.put(uri,
              headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await httpClient.delete(uri, headers: headers);
          break;
        default:
          throw Exception("Unsupported HTTP method: $method");
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Failed to connect to server: $e");
    }
  }

  /// Returns headers including authentication token if available.
  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  /// Handles the HTTP response and ensures errors are properly handled.
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception("HTTP Error ${response.statusCode}: ${response.body}");
    }
  }

  /// Retrieves the currently stored authentication token.
  String? getToken() {
    return _token;
  }

  /// Handles API errors by parsing the response and throwing an exception.
  void handleAPIError(http.Response response) {
    final decodedResponse = jsonDecode(response.body);

    if (decodedResponse['errors'] != null) {
      throw Exception(decodedResponse['errors'][0]['message']);
    } else {
      throw Exception("Unexpected API error: ${response.body}");
    }
  }
}
