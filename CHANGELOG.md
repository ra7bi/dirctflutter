# Changelog

## 0.1.0 - Initial Release
- Added authentication (`login`, `logout`, `me`, `register`, `resetPassword`).
- Implemented CRUD operations (`fetch`, `create`, `update`, `delete`).
- Included filtering, sorting, and relation handling.
- Added HTTP request support (`GET`, `POST`, `PUT`, `DELETE`).
- Improved error handling.

# Changelog

## 0.1.1 - Improved Features
- Added logout functionality.
- Fixed authentication issues.
- Improved error handling.



## 0.1.2 - Bug Fixes & Improvements
- Fixed `bodyAsJson()` issue by replacing it with `jsonDecode(response.body)`.
- Improved error handling in `AuthService` and `CrudService`.
- Passed all tests successfully.