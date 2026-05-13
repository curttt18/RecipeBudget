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

  static Future<String?> login({
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
      return _mapLoginError(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static String _mapLoginError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Login failed. Please check your credentials.';
    }
  }

  static Future<String?> verifyCurrentPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return 'No authenticated user found.';
    try {
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Current password is incorrect.';
      }
      return e.message ?? 'Verification failed.';
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> applyNewPassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      await DatabaseService.updateUserPassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password must be at least 6 characters.';
      }
      return e.message ?? 'Failed to update password.';
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found for that email.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        default:
          return e.message ?? 'Something went wrong. Please try again.';
      }
    } catch (_) {
      return 'An unexpected error occurred.';
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
