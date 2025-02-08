import 'package:flutter_test/flutter_test.dart';
import 'package:dirctflutter/src/auth/auth_service.dart';
import 'package:dirctflutter/src/core/directus_client.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group("AuthService Tests", () {
    late DirectusClient client;
    late AuthService authService;

    setUp(() {
      // ✅ Create a new DirectusClient and AuthService for each test
      client = DirectusClient(baseUrl: "https://directus.local");
      authService = AuthService(client: client);
    });

    test("Login should return a valid token", () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith("auth/login") &&
            request.method == "POST") {
          return http.Response(
            jsonEncode({
              "data": {
                "access_token": "mock-access-token",
                "refresh_token": "mock-refresh-token"
              }
            }),
            200,
          ); // ✅ Simulate a successful login
        }
        return http.Response("Unauthorized", 401);
      });

      // ✅ Inject mock client
      client.setHttpClient(mockClient);

      final response =
          await authService.login("owner2@localhost.com", "123123");

      expect(response["data"]["access_token"], equals("mock-access-token"));
      expect(response["data"]["refresh_token"], equals("mock-refresh-token"));
    });

    test("Login should return an error on invalid credentials", () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith("auth/login") &&
            request.method == "POST") {
          return http.Response(
            jsonEncode({
              "errors": [
                {
                  "message": "Invalid user credentials.",
                  "extensions": {"code": "INVALID_CREDENTIALS"}
                }
              ]
            }),
            401,
          );
        }
        return http.Response("Bad Request", 400);
      });

      // ✅ Inject mock client
      client.setHttpClient(mockClient);

      try {
        await authService.login("wrong@example.com", "wrongpassword");
        fail("Login should have thrown an exception");
      } catch (e) {
        expect(e.toString(), contains("Invalid user credentials."));
      }
    });
  });
}
