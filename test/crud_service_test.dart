import 'package:flutter_test/flutter_test.dart';
import 'package:dirctflutter/src/crud/crud_service.dart';
import 'package:dirctflutter/src/core/directus_client.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group("CrudService Tests", () {
    late DirectusClient client;
    late CrudService crudService;

    setUp(() {
      client = DirectusClient(baseUrl: "https://directus.local");
      crudService = CrudService(client: client);
    });

    test("Fetch should return a list of items", () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith("/items/test_collection")) {
          return http.Response(
              jsonEncode({
                "data": [
                  {"id": 1, "name": "Test Item"}
                ]
              }),
              200);
        }
        return http.Response("Not Found", 404);
      });

      client.setHttpClient(mockClient);

      final response = await crudService.fetch("test_collection");

      expect(response, isA<List<dynamic>>());
      expect(response.first["name"], equals("Test Item"));
    });

    test("Create should return the created item", () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith("/items/test_collection") &&
            request.method == "POST") {
          return http.Response(
              jsonEncode({
                "data": {"id": 1, "name": "New Item"}
              }),
              200);
        }
        return http.Response("Bad Request", 400);
      });

      client.setHttpClient(mockClient);

      final response =
          await crudService.create("test_collection", {"name": "New Item"});

      expect(response["data"]["id"], equals(1));
      expect(response["data"]["name"], equals("New Item"));
    });

    test("Update should modify an item", () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith("/items/test_collection/1") &&
            request.method == "PUT") {
          return http.Response(
              jsonEncode({
                "data": {"id": 1, "name": "Updated Item"}
              }),
              200);
        }
        return http.Response("Not Found", 404);
      });

      client.setHttpClient(mockClient);

      final response = await crudService
          .update("test_collection", 1, {"name": "Updated Item"});

      expect(response["data"]["name"], equals("Updated Item"));
    });
    test("Delete should remove an item", () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith("/items/test_collection/1") &&
            request.method == "DELETE") {
          return http.Response(
              jsonEncode({"data": null}), // ✅ Simulate successful deletion
              200);
        }
        return http.Response("Not Found", 404);
      });

      client.setHttpClient(mockClient);

      final result = await crudService.delete("test_collection", 1);

      expect(result, isTrue); // ✅ Expect `true` for successful deletion
    });
  });
}
