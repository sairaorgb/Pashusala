import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class Database {
  var tempBox = Hive.box('myBox');

  late String userEmail;
  late String password;
  late String role;
  bool switchValue = true;

  String? currLandmark;
  String? currTown;
  String? currDistrict;
  String? currState;
  String? currPinCode;
  late String currAddress = '';
  double? currLatitude;
  double? currLongitude;
  late String? geoLandmark;
  late String? geoTown;
  late String? geoDistrict;
  late String? geoState;
  late String? geoPostalCode;
  late double? userLatitude;
  late double? userLongitude;
  late String homeAddress;
  bool isAddressModified = false;
  bool usingHomeAddress = false;

  late User? user;
  late FirebaseFirestore fbStoreInstance;

  Future<String> validateUser() async {
    if (tempBox.containsKey("userEmail") && tempBox.containsKey("password")) {
      userEmail = tempBox.get("userEmail");
      password = tempBox.get("password");
      role = tempBox.get("role");
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
      geoLandmark = tempBox.get("geoLandmark");
      geoTown = tempBox.get("geoTown");
      geoDistrict = tempBox.get("geoDistrict");
      geoState = tempBox.get("geoState");
      geoPostalCode = tempBox.get("geoPostalCode");
      userLatitude = tempBox.get("userLatitude");
      userLongitude = tempBox.get("userLongitude");
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

  void setUserLocation(String? landmark, String? town, String? district,
      String? state, String? postalCode, double? latitude, double? longitude) {
    geoLandmark = landmark;
    geoTown = town;
    geoDistrict = district;
    geoState = state;
    geoPostalCode = postalCode;
    userLatitude = latitude;
    userLongitude = longitude;
    updateDatabase("geoLandmark", geoLandmark);
    updateDatabase("geoTown", geoTown);
    updateDatabase("geoDistrict", geoDistrict);
    updateDatabase("geoState", geoState);
    updateDatabase("geoPostalCode", geoPostalCode);
    updateDatabase("userLatitude", userLatitude);
    updateDatabase("userLongitude", userLongitude);
    homeAddress = (landmark ?? '') +
        (town ?? '') +
        (district ?? '') +
        (state ?? '') +
        (postalCode ?? '');
    updateDatabase("homeAddress", homeAddress);
  }
}
