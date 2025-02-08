class DirectusEndpoints {
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";
  static const String me = "/users/me";
  static const String register = "/users";
  static const String resetPassword = "/auth/password/request";
  static const String twoFactorAuth = "/auth/tfa/verify";
  static const String role = "/roles";

  // CRUD Operations
  static String fetch(String collection) => "/items/$collection";
  static String create(String collection) => "/items/$collection";
  static String update(String collection, String id) =>
      "/items/$collection/$id";
  static String delete(String collection, String id) =>
      "/items/$collection/$id";
}
