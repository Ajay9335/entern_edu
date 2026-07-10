import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Simple local authentication using SharedPreferences.
/// Stores registered users as a JSON-encoded list and tracks
/// the currently logged-in user's email.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user_email';

  Future<List<Map<String, String>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }

  Future<void> _saveUsers(List<Map<String, String>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> registerUser({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    final users = await _getUsers();

    final alreadyExists = users.any(
      (u) => u['email']?.toLowerCase() == email.toLowerCase(),
    );
    if (alreadyExists) {
      return 'An account with this email already exists';
    }

    users.add({
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'password': password, // NOTE: plain text for demo/local use only
    });

    await _saveUsers(users);
    return null;
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();

    final match = users.firstWhere(
      (u) => u['email']?.toLowerCase() == email.toLowerCase(),
      orElse: () => {},
    );

    if (match.isEmpty) {
      return 'No account found with this email';
    }
    if (match['password'] != password) {
      return 'Incorrect password';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, email);
    return null;
  }

  Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentUserKey);
    if (email == null) return null;

    final users = await _getUsers();
    final match = users.firstWhere(
      (u) => u['email']?.toLowerCase() == email.toLowerCase(),
      orElse: () => {},
    );
    return match.isEmpty ? null : match;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey) != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// Returns null on success, or an error message on failure.
Future<String?> updateProfile({
  required String email,
  required String fullName,
  required String mobile,
}) async {
  final users = await _getUsers();
  final index = users.indexWhere(
    (u) => u['email']?.toLowerCase() == email.toLowerCase(),
  );

  if (index == -1) return 'User not found';

  users[index]['fullName'] = fullName;
  users[index]['mobile'] = mobile;

  await _saveUsers(users);
  return null;
}

/// Returns null on success, or an error message on failure.
Future<String?> changePassword({
  required String email,
  required String currentPassword,
  required String newPassword,
}) async {
  final users = await _getUsers();
  final index = users.indexWhere(
    (u) => u['email']?.toLowerCase() == email.toLowerCase(),
  );

  if (index == -1) return 'User not found';

  if (users[index]['password'] != currentPassword) {
    return 'Current password is incorrect';
  }

  users[index]['password'] = newPassword;
  await _saveUsers(users);
  return null;
}

}
