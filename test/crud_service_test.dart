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
      client = DirectusClient(baseUrl: "https://vs.r7b.uk");
      crudService = CrudService(client: client);
    });

    test("Fetch should return a list of items", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": [
                {"id": 1, "name": "Test Item"}
              ]
            }),
            200);
      });

      client.httpClient = mockClient;

      final response = await crudService.fetch("products");

      expect(response, isNotEmpty);
      expect(response.first["name"], equals("Test Item"));
    });

    test("Create should add a new item", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": {"id": 1, "name": "New Item"}
            }),
            201);
      });

      client.httpClient = mockClient;

      final response =
          await crudService.create("products", {"name": "New Item"});

      expect(response["data"]["name"], equals("New Item"));
    });

    test("Update should modify an existing item", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": {"id": 1, "name": "Updated Item"}
            }),
            200);
      });

      client.httpClient = mockClient;

      final response =
          await crudService.update("products", 1, {"name": "Updated Item"});

      expect(response["data"]["name"], equals("Updated Item"));
    });

    test("Delete should remove an item", () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({"data": null}), 200);
      });

      client.httpClient = mockClient;

      final result = await crudService.delete("products", 1);

      expect(result, isTrue);
    });

    test("Fetch should support filtering", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": [
                {"id": 2, "name": "Filtered Item"}
              ]
            }),
            200);
      });

      client.httpClient = mockClient;

      final response = await crudService
          .fetch("products", filters: {"category": "electronics"});

      expect(response, isNotEmpty);
      expect(response.first["name"], equals("Filtered Item"));
    });

    test("Fetch should support relations", () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              "data": [
                {
                  "id": 3,
                  "name": "Item with Relation",
                  "category": {"id": 1, "name": "Books"}
                }
              ]
            }),
            200);
      });

      client.httpClient = mockClient;

      final response =
          await crudService.fetch("products", relations: ["category"]);

      expect(response.first["category"]["name"], equals("Books"));
    });
  });
}
