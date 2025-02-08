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
      client = DirectusClient(baseUrl: "https://vs.r7b.uk");
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

      client.httpClient = mockClient;

      final response = await authService.login("test@example.com", "password");

      expect(response["data"]["access_token"], equals("mock-access-token"));
    });

    test("Login should return an error on invalid credentials", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "errors": [
                {
                  "message": "Invalid user credentials.",
                  "extensions": {"code": "INVALID_CREDENTIALS"}
                }
              ]
            }),
            401);
      });

      client.httpClient = mockClient;

      expect(
        () async =>
            await authService.login("wrong@example.com", "wrongpassword"),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'contains invalid credentials',
          contains("Invalid user credentials."),
        )),
      );
    });

    test("Logout should clear the authentication token", () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({"data": "Logged out"}), 200);
      });

      client.httpClient = mockClient;

      await authService.logout();

      expect(client.getToken(), isNull);
    });

    test("Me should return the current authenticated user", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": {"id": "1", "email": "test@example.com"}
            }),
            200);
      });

      client.httpClient = mockClient;

      final user = await authService.me();

      expect(user["email"], equals("test@example.com"));
    });

    test("Register should create a new user", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": {"id": "1", "email": "new@example.com"}
            }),
            201);
      });

      client.httpClient = mockClient;

      final response = await authService
          .register({"email": "new@example.com", "password": "123456"});

      expect(response["email"], equals("new@example.com"));
    });

    test("Reset password should send a password reset request", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({"data": "Password reset email sent"}), 200);
      });

      client.httpClient = mockClient;

      expect(() async => await authService.resetPassword("test@example.com"),
          returnsNormally);
    });
  });
}
