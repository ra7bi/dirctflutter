# 🚀 dirctflutter – A Better Directus SDK for Flutter!

## **📖 Story Time: Why This Package?**
I **love Directus** ❤️, and I was looking for a **Flutter SDK** to work with it.  
Then, I found the existing one... **broken**. 😩  

So, I thought:  
_"Why not build my own Directus SDK, one that actually works?"_  

Thus, **`dirctflutter`** was born! 🎉  

---

## **✨ Features**
✔ **Authentication** (`login`, `logout`, `register`, `me`, `resetPassword`)  
✔ **Token Management** (Automatically attach tokens)  
✔ **CRUD Operations** (`fetch`, `create`, `update`, `delete`)  
✔ **Advanced Queries** (Filters, Sorting, and Relations)  
✔ **Custom HTTP Requests** (`GET`, `POST`, `PUT`, `DELETE`)  
✔ **Error Handling** (Proper exceptions, readable errors)  

---

## **📌 Installation**
### **1️⃣ Add to `pubspec.yaml`**
```yaml
dependencies:
  dirctflutter:
    git:
      url: https://github.com/ra7bi/dirctflutter.git
      ref: main
```

### **2️⃣ Get Dependencies**
```sh
flutter pub get
```

---

## **🚀 Getting Started**
### **Initialize the Directus Client**
```dart
import 'package:dirctflutter/dirctflutter.dart';

final client = DirectusClient(baseUrl: "https://your-directus-api.com");
```

---

## **🔐 Authentication**
### **Login**
```dart
final authService = AuthService(client: client);

try {
  final response = await authService.login("email@example.com", "password123");
  print("Logged in! Token: ${response['data']['access_token']}");
} catch (e) {
  print("Login failed: $e");
}
```

---

### **Get Current User**
```dart
final user = await authService.me();
print("User Info: ${user}");
```

---

### **Logout**
```dart
await authService.logout();
print("Logged out successfully!");
```

---

### **Reset Password**
```dart
await authService.resetPassword("email@example.com");
print("Password reset email sent!");
```

---

## **📝 CRUD Operations**
### **Fetch All Items**
```dart
final crudService = CrudService(client: client);

final items = await crudService.fetch("products");
print("Fetched items: $items");
```

---

### **Fetch with Filtering**
```dart
final filteredItems = await crudService.fetch(
  "products",
  filters: {"price": {"_gt": 100}},  // Products where price > 100
  sort: "-created_at",  // Sort by newest first
  relations: ["category"] // Include category details
);

print("Filtered items: $filteredItems");
```

---

### **Create a New Item**
```dart
final newItem = await crudService.create("products", {
  "name": "New Product",
  "price": 199.99,
});

print("Created item: $newItem");
```

---

### **Update an Item**
```dart
final updatedItem = await crudService.update("products", 1, {
  "price": 149.99,
});

print("Updated item: $updatedItem");
```

---

### **Delete an Item**
```dart
final success = await crudService.delete("products", 1);

if (success) {
  print("Item deleted successfully!");
} else {
  print("Failed to delete item.");
}
```

---

## **🌐 Custom API Requests**
### **GET Request**
```dart
final response = await client.get("custom-endpoint");
print("Response: ${response.body}");
```

---

### **POST Request**
```dart
final response = await client.post("custom-endpoint", {
  "key": "value",
});

print("Response: ${response.body}");
```

---

## **⚠ Error Handling**
All functions **throw exceptions on failure**. Always wrap your API calls in a `try-catch` block:

```dart
try {
  final response = await authService.login("wrong@example.com", "wrongpassword");
} catch (e) {
  print("Error: $e"); // Handle errors gracefully
}
```

---

## **🛠 Contributing**
Want to improve `dirctflutter`? Feel free to **fork this repo, submit issues, or open a pull request**.  

---

## **📜 License**
This package is **MIT Licensed**, meaning you can use it freely in your projects.  

---

🎉 **That's it! Now go build something awesome with Directus and Flutter!** 🚀
