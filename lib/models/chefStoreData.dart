
import 'package:firebase_auth/firebase_auth.dart';

String uid = FirebaseAuth.instance.currentUser!.uid;

class ChefStoreData {

  String id;
  String stName;
  String stPhNo;
  String stEmail;
  double stRating;
  String stUsrName;
  int stMnuCount;
  int stMnuInactive;
  bool stActive;
  String stDoorNo;
  String stSociety;
 

  ChefStoreData({ required this.id, required this.stName, required this.stPhNo, required this.stEmail, 
  required this.stRating, required this.stUsrName, required this.stMnuCount, required this.stMnuInactive,
  required this.stActive, required this.stDoorNo, required this.stSociety });

}