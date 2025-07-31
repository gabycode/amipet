import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          Platform.isIOS
              ? '701033692341-6rdhlo1f5v0bjfdvqdr2u13tp327j43g.apps.googleusercontent.com'
              : null,
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }
  }

  static Map<String, String> getUserInfo() {
    final user = _auth.currentUser;
    if (user == null) {
      return {'name': 'Usuario', 'email': 'usuario@email.com'};
    }

    String userName = 'Usuario';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      userName = user.displayName!;
    } else if (user.email != null) {
      final emailName = user.email!.split('@')[0];
      userName = emailName[0].toUpperCase() + emailName.substring(1);
    }

    return {
      'name': userName,
      'email': user.email ?? 'usuario@email.com',
      'firstName': userName.split(' ')[0],
    };
  }

  static bool get isAuthenticated => _auth.currentUser != null;
}
