/// A utility class to construct query parameters for Directus API requests.
class QueryBuilder {
  final Map<String, String> _params = {};

  /// Adds a filter condition to the query.
  void addFilter(String field, String value) {
    _params['filter[$field][_eq]'] = value;
  }

  /// Returns the constructed query string.
  String build() {
    return _params.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}
