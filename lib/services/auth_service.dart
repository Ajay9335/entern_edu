import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _profileKey(String uid) => 'profile_$uid';

  Future<void> _saveProfile(
    String uid, {
    required String fullName,
    required String mobile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profileKey(uid),
      jsonEncode({'fullName': fullName, 'mobile': mobile}),
    );
  }

  Future<Map<String, String>> _readProfile(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey(uid));
    if (raw == null) return {'fullName': '', 'mobile': ''};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return {
      'fullName': decoded['fullName']?.toString() ?? '',
      'mobile': decoded['mobile']?.toString() ?? '',
    };
  }

  Future<String?> registerUser({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _saveProfile(
        credential.user!.uid,
        fullName: fullName,
        mobile: mobile,
      );
      await credential.user!.updateDisplayName(fullName);

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'An account with this email already exists';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Enter a valid email address';
        default:
          return e.message ?? 'Registration failed';
      }
    } catch (_) {
      return 'Something went wrong. Please try again';
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Enter a valid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        default:
          return e.message ?? 'Login failed';
      }
    } catch (_) {
      return 'Something went wrong. Please try again';
    }
  }

  Future<Map<String, String>?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final profile = await _readProfile(firebaseUser.uid);
    return {
      'fullName': profile['fullName']!.isNotEmpty
          ? profile['fullName']!
          : (firebaseUser.displayName ?? ''),
      'email': firebaseUser.email ?? '',
      'mobile': profile['mobile']!,
    };
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> updateProfile({
    required String email,
    required String fullName,
    required String mobile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not found';

      await _saveProfile(user.uid, fullName: fullName, mobile: mobile);
      await user.updateDisplayName(fullName);
      return null;
    } catch (_) {
      return 'Failed to update profile';
    }
  }

  Future<String?> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not found';

      final cred = EmailAuthProvider.credential(
        email: email.trim(),
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Current password is incorrect';
      }
      return e.message ?? 'Failed to change password';
    } catch (_) {
      return 'Failed to change password';
    }
  }

  Future<String?> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email';
        case 'invalid-email':
          return 'Enter a valid email address';
        default:
          return e.message ?? 'Failed to send reset email';
      }
    } catch (_) {
      return 'Something went wrong. Please try again';
    }
  }
}
