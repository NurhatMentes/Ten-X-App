import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get currentUser => _auth.currentUser;
  
  String? get currentUserId => _auth.currentUser?.uid;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}