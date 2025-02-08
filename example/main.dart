import 'package:dirctflutter/dirctflutter.dart';

void main() async {
  final client = DirectusClient(baseUrl: "https://directus.server.local");
  final auth = AuthService(client: client);

  try {
    final user = await auth.login("owner2@localhost.com", "password");
    print("Logged in as: ${user['first_name']}");
  } catch (e) {
    print(e);
  }
}
