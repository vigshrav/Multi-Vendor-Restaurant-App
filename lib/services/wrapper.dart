import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_chef/models/userProfileData.dart';
import 'package:home_chef/screens/chefs/chefsMain.dart';
import 'package:home_chef/screens/users/usrMain.dart';
import 'package:home_chef/services/userServices.dart';
import 'package:home_chef/widgets/spinner.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({ Key? key }) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    
      User? user = FirebaseAuth.instance.currentUser;
    
      return StreamBuilder<UserObjs>(
      stream: UserServices(uid: user!.uid).userRootData,
      builder: (context,snapshot){
        UserObjs? userObjs = snapshot.data;
        if (snapshot.hasData){
          var usrType = userObjs!.type;
          if (usrType == true){
            return UserMainPage();
          } else if (usrType == false){
            return ChefsMainPage();
          }
        }
        return Loading();
      }
    );
    
  }
}