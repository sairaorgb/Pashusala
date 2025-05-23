import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Database with ChangeNotifier {
  var tempBox = Hive.box('myBox');

  late String userEmail;
  late String password;
  late String userName = '';
  late String role;
  bool switchValue = true;

  late User? user;
  late FirebaseFirestore fbStoreInstance;

  Future<String> validateUser() async {
    if (tempBox.containsKey("userEmail") && tempBox.containsKey("password")) {
      userEmail = tempBox.get("userEmail");
      password = tempBox.get("password");
      role = tempBox.get("role");
      userName = tempBox.get("userName");
      var validateResult = await authenticate(role, userEmail, password);
      if (validateResult == "success") {
        user = FirebaseAuth.instance.currentUser;
        fbStoreInstance = FirebaseFirestore.instance;
        if (role == "user") switchValue = false;
        return "success";
      } else {
        return validateResult;
      }
    } else {
      return "failure";
    }
  }

  Future<String> authenticate(
      String role, String useremail, String password) async {
    try {
      var credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: useremail, password: password);

      user = FirebaseAuth.instance.currentUser;

      var docSnapshot;
      if (role == "doctor") {
        docSnapshot = await FirebaseFirestore.instance
            .collection('doctors_data')
            .doc(user?.uid)
            .get();

        userName = (docSnapshot.data()?['doctorName'] as String?) ?? '';
        userEmail = useremail;
        role = role;
        updateDatabase("userEmail", userEmail);
        updateDatabase("password", password);
        updateDatabase("role", "doctor");
        updateDatabase("userName", userName);
      } else {
        docSnapshot = await FirebaseFirestore.instance
            .collection('users_data')
            .doc(user?.uid)
            .get();
        switchValue = false;
        userName = (docSnapshot.data()?['userName'] as String?) ?? '';
        userEmail = useremail;
        role = role;
        updateDatabase("userEmail", userEmail);
        updateDatabase("password", password);
        updateDatabase("role", "user");
        updateDatabase("userName", userName);
      }

      if (credential.user!.uid.isNotEmpty) return ('success');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        return ('Wrong password provided for that user.');
      } else {
        return ('incorrect credentials');
      }
    } catch (e) {
      return ('Error: $e');
    }
    return "failure";
  }

  void updateDatabase(String key, var value) {
    tempBox.put(key, value);
  }

  void getDatabase(String key) {
    tempBox.get(key);
  }

  Future<void> logOutUser() async {
    await tempBox.clear();
  }
}
