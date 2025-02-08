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
    final queryParams = applyFilters(
      filters: filters,
      sort: sort,
      relations: relations,
    );
    queryParams['fields'] = includeRelations(relations);

    final response = await client.get("items/$collectionName", queryParams);
    final decodedResponse = jsonDecode(response.body);

    return decodedResponse['data'];
  }

  /// Returns a formatted string for including related collections.
  String includeRelations(List<String>? relations) {
    return relations != null && relations.isNotEmpty ? relations.join(',') : '';
  }

  /// Creates a new item in the specified collection.
  Future<Map<String, dynamic>> create(
      String collectionName, Map<String, dynamic> data) async {
    final response = await client.post("items/$collectionName", data);

    if (response.statusCode != 200 && response.statusCode != 201) {
      client.handleAPIError(response);
    }

    return jsonDecode(response.body);
  }

  /// Updates an existing item in the specified collection.
  Future<Map<String, dynamic>> update(
      String collectionName, int itemId, Map<String, dynamic> data) async {
    final response = await client.put("items/$collectionName/$itemId", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      client.handleAPIError(response);
    }
    return jsonDecode(response.body);
  }

  /// Deletes an item from the specified collection.
  /// Returns `true` if the deletion was successful.
  Future<bool> delete(String collectionName, int itemId) async {
    final response = await client.delete("items/$collectionName/$itemId");

    final decodedResponse = jsonDecode(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      client.handleAPIError(response);
    }
    if (decodedResponse["data"] == null) {
      return true;
    } else {
      throw Exception("Failed to delete item: ${decodedResponse["data"]}");
    }
  }

  /// Builds query parameters for filtering data in Directus collections.
  Map<String, String> applyFilters({
    Map<String, dynamic>? filters,
    String? sort,
    List<String>? relations,
  }) {
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

    return queryParams;
  }
}
