import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/preferences_manager.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SignInState {
  final bool isLoading;
  final String? errorMessage;
  final String? type;

  SignInState({
    this.isLoading = false,
    this.errorMessage,
    this.type,
  });

  SignInState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? type,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      type: type ?? this.type,
    );
  }
}

class SignInViewModel extends StateNotifier<SignInState> {
  final AuthService _authService = AuthService();

  SignInViewModel() : super(SignInState());

  void setType(String type) {
    state = state.copyWith(type: type);
  }

  Future<void> handleLogin(BuildContext context, String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final collectionName = state.type == 'owners' ? 'owners' : 'users';
      state = state.copyWith(type: collectionName);

      final userDoc = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '해당 이메일이 ${collectionName == "owners" ? "owners" : "users"} 컬렉션에 없습니다.',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('해당 이메일이 ${collectionName == "owners" ? "owners" : "users"} 컬렉션에 없습니다.')),
        );
      } else {
        await PreferencesManager.instance.setEmail(email);
        await PreferencesManager.instance.setType(state.type!);

        if (collectionName == "owners") {
          Navigator.pushReplacementNamed(context, '/owner-home');
        } else {
          Navigator.pushReplacementNamed(context, '/user-home');
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인에 실패했습니다: $e',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패했습니다: $e')),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    final String region = dotenv.env['REGION'] ?? '';
    final String user_email = dotenv.env['USEREMAIL'] ?? '';
    final String owner_email = dotenv.env['OWNEREMAIL'] ?? '';

    try {
      await FirebaseAuth.instance.signOut();

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final functions = FirebaseFunctions.instanceFor(region: region);

      final ownerResponse = await functions.httpsCallable(owner_email).call({'email': googleUser.email});
      final ownerData = ownerResponse.data;

      if (ownerData['exists'] == true) {
        state = state.copyWith(isLoading: false, errorMessage: '해당 이메일은 구글 로그인을 지원하지 않습니다.');
        return;
      }

      final userResponse = await functions.httpsCallable(user_email).call({'email': googleUser.email});
      final userData = userResponse.data;

      if (userData['exists'] == true) {
        final authType = userData['userData']['authType'];

        if (authType == 'google') {
          final userCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
          final currentUser = userCredential.user;

          await _saveLoginInfo(currentUser!, 'users');
          Navigator.pushReplacementNamed(context, '/user-home');
          return;
        } else if (authType == 'email') {
          final password = await _promptForPassword(context, googleUser.email);
          final emailCredential = EmailAuthProvider.credential(
            email: googleUser.email,
            password: password,
          );

          try {
            final emailUserCredential = await FirebaseAuth.instance.signInWithCredential(emailCredential);
            await emailUserCredential.user?.linkWithCredential(googleCredential);
            await _updateAuthTypeInFirestore(emailUserCredential.user!, 'google');

            await _saveLoginInfo(emailUserCredential.user!, 'users');
            Navigator.pushReplacementNamed(context, '/user-home');
          } catch (e) {
            state = state.copyWith(isLoading: false, errorMessage: '로그인에 실패했습니다: $e');
          }
          return;
        }
      } else {
        final userCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
        final newUser = userCredential.user;

        if (newUser != null) {
          final uniqueUID = await _authService.generateUniqueUID();

          await _addUserToFirestore(newUser, uniqueUID);

          await _saveLoginInfo(newUser, 'users');
          Navigator.pushReplacementNamed(context, '/user-home');
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Google 로그인에 실패했습니다: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveLoginInfo(User user, String type) async {
    await PreferencesManager.instance.setEmail(user.email!);
    await PreferencesManager.instance.setType(type);
  }

  Future<void> _addUserToFirestore(User user, String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': user.email,
      'name': user.displayName ?? 'null',
      'points': 0,
      'profilePicUrl': user.photoURL,
      'pubId': null,
      'authType': 'google',
      'uid': uid,
    });
  }

  Future<void> _updateAuthTypeInFirestore(User user, String authType) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'authType': authType,
      });
    }
  }

  Future<String> _promptForPassword(BuildContext context, String userEmail) async {
    String password = '';
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'アカウントが既に存在します',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'すでにアカウントがあるようです。\nログインしてください。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    userEmail[0].toUpperCase(),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(height: 10),
                Text(userEmail, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(password);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('続行', style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('別のアカウントでログイン'),
                ),
              ],
            ),
          ),
        );
      },
    );
    return password;
  }
}

final signinViewModelProvider = StateNotifierProvider<SignInViewModel, SignInState>(
  (ref) => SignInViewModel(),
);
