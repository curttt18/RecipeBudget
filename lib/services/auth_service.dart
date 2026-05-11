import 'package:firebase_auth/firebase_auth.dart';
import 'database.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  /// Returns null on success, or an error message string on failure.
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
    required double budget,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await DatabaseService.createUser(
        uid: credential.user!.uid,
        displayName: name,
        email: email,
        password: password,
        budget: budget,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      default:
        return 'Registration failed. Please try again.';
    }
  }
}
