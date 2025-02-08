import 'package:flutter_test/flutter_test.dart';
import 'package:dirctflutter/src/auth/auth_service.dart';
import 'package:dirctflutter/src/core/directus_client.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group("AuthService Tests", () {
    late AuthService authService;
    late DirectusClient client;

    setUp(() {
      client = DirectusClient(baseUrl: "https://vs.test.local");
      authService = AuthService(client: client);
    });

    test("Login should return a valid token", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": {
                "access_token": "mock-access-token",
                "refresh_token": "mock-refresh-token"
              }
            }),
            200);
      });

      client = DirectusClient(
          baseUrl: "https://vs.test.local", httpClient: mockClient);
      authService = AuthService(client: client);

      final response =
          await authService.login("owner2@localhost.com", "123123");

      expect(response["data"]["access_token"], equals("mock-access-token"));
    });

    test("Get current user details", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": {"id": "123", "email": "test@example.com"}
            }),
            200);
      });

      client = DirectusClient(
          baseUrl: "https://vs.test.local", httpClient: mockClient);
      authService = AuthService(client: client);

      final user = await authService.me();
      expect(user["email"], equals("test@example.com"));
    });

    test("Register a new user", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": {"id": "456", "email": "new@example.com"}
            }),
            201);
      });

      client = DirectusClient(
          baseUrl: "https://vs.test.local", httpClient: mockClient);
      authService = AuthService(client: client);

      final user = await authService
          .register({"email": "new@example.com", "password": "123456"});
      expect(user["email"], equals("new@example.com"));
    });
    test("Logout user", () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == "/auth/logout" && request.method == "POST") {
          return http.Response(jsonEncode({}), 200);
        }
        if (request.url.path == "/users/me") {
          return http.Response(
              jsonEncode({
                "errors": [
                  {
                    "message": "Token expired.",
                    "extensions": {"code": "TOKEN_EXPIRED"}
                  }
                ]
              }),
              401);
        }
        return http.Response("Unauthorized", 401);
      });

      final client = DirectusClient(
          baseUrl: "https://vs.test.local", httpClient: mockClient);
      final authService = AuthService(client: client);

      await authService.logout();

      expect(
        () async => await authService.me(),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains("Token expired."))),
      );
    });

    test("Request password reset", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({"data": "Password reset email sent"}), 200);
      });

      client = DirectusClient(
          baseUrl: "https://vs.test.local", httpClient: mockClient);
      authService = AuthService(client: client);

      await authService.resetPassword("test@example.com");
    });
  });
}
