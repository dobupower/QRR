import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInViewModel extends StateNotifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  SignInViewModel() : super(null);

  // Google 로그인 메서드
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Firebase로 Google 로그인
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        state = userCredential.user;
      }
    } catch (e) {
      print('Google 로그인 실패: $e');
      state = null;
    }
  }

  // 로그아웃 메서드
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    state = null;
  }

  // 현재 사용자 정보 가져오기
  User? get currentUser => _auth.currentUser;
}

// SignInViewModel 제공자 (Provider)
final signInViewModelProvider = StateNotifierProvider<SignInViewModel, User?>(
  (ref) => SignInViewModel(),
);
