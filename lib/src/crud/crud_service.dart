import 'dart:convert';
import '../core/directus_client.dart';

/// Service for handling CRUD operations with Directus.
class CrudService {
  final DirectusClient client;

  /// Constructs `CrudService` with a `DirectusClient`.
  CrudService({required this.client});

  /// Fetches items from a collection with optional filters, sorting, and relations.
  Future<List<dynamic>> fetch(
    String collectionName, {
    Map<String, dynamic>? filters,
    String? sort,
    List<String>? relations,
  }) async {
    final queryParams = <String, String>{};

    if (filters != null) {
      queryParams['filter'] = jsonEncode(filters);
    }
    if (sort != null) {
      queryParams['sort'] = sort;
    }
    if (relations != null && relations.isNotEmpty) {
      queryParams['fields'] = relations.join(',');
    }

    final response = await client.get("items/$collectionName", queryParams);
    final decodedResponse = jsonDecode(response.body);
    return decodedResponse['data'];
  }

  /// Creates a new item in the specified collection.
  Future<Map<String, dynamic>> create(
      String collectionName, Map<String, dynamic> data) async {
    final response = await client.post("items/$collectionName", data);
    return jsonDecode(response.body);
  }

  /// Updates an existing item in the specified collection.
  Future<Map<String, dynamic>> update(
      String collectionName, int itemId, Map<String, dynamic> data) async {
    final response = await client.put("items/$collectionName/$itemId", data);
    return jsonDecode(response.body);
  }

  /// Deletes an item from the specified collection.
  /// Returns `true` if the deletion was successful.
  Future<bool> delete(String collectionName, int itemId) async {
    final response = await client.delete("items/$collectionName/$itemId");

    final decodedResponse = jsonDecode(response.body);

    if (decodedResponse["data"] == null) {
      return true;
    } else {
      throw Exception("Failed to delete item: ${decodedResponse["data"]}");
    }
  }
}
