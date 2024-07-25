import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborative_cargo_managment_app/services/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createNewUser(String email, String password) async {
    try {
      final credidentials = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credidentials.user;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<User?> signInUser(String email, String password,UserProvider userProvider) async {
     
    try {
      final credidentials = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
     
    userProvider.setUserId(credidentials.user!.uid);
      return credidentials.user;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String email,
    required String password,
    required String operatorName,
    required String phone,
    required String companyID,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Add user to Firestore collection
        await _firestore.collection('Operators').doc(user.uid).set({
          'companyID': companyID,
          'email': email,
          'operatorID': user.uid,
          'operatorName': operatorName,
          'phone': phone,
          'role': 'normal',
        });
      }
    } catch (e) {
      // Handle errors
      print('Error: $e');
      throw e;
    }
  }
}
