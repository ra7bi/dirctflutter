library dirctflutter;

/// Directus Flutter SDK
///
/// A Dart package for integrating Directus with Flutter applications.
/// Provides authentication, CRUD operations, and utilities for working with Directus API.
///
/// Exporting core functionalities.
export 'src/auth/auth_service.dart';
export 'src/auth/token_manager.dart';

export 'src/core/directus_client.dart';
export 'src/core/endpoints.dart';
export 'src/core/error_handler.dart';

export 'src/crud/crud_service.dart';

export 'src/models/user.dart';

export 'src/utils/query_builder.dart';
