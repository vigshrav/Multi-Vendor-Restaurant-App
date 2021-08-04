import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/models/userProfileData.dart';
import 'package:home_chef/screens/users/usrOrders.dart';
import 'package:home_chef/services/fire_auth.dart';
import 'package:home_chef/services/userServices.dart';
import 'package:home_chef/widgets/spinner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserSettings extends StatefulWidget {
  const UserSettings({ Key? key }) : super(key: key);

  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {

  bool loading = false;

  User? user = FirebaseAuth.instance.currentUser;
  
  @override
  Widget build(BuildContext context) {

    var safeHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom;
    // var safeWidth = MediaQuery.of(context).size.width - MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;

    return StreamBuilder<UserObjs>(
      stream: UserServices(uid: user!.uid).userRootData,
      builder: (context,snapshot){
        UserObjs? userObjs = snapshot.data;
        if (snapshot.hasData){
          var name = userObjs!.uName;
          var email = userObjs.eMail;
          var phone = userObjs.phone;
          var avatarURL = userObjs.avatarURL;
          
          bool avatarImgavailable;
          if (avatarURL != '') {avatarImgavailable = true;} else {avatarImgavailable = false;}

          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text('Your Profile', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Container(
                height: safeHeight,
                child: Column(
                  children: [
                    Container(
                      color: Colors.redAccent,
                      child: Container(
                        width: double.infinity,
                        height: safeHeight * 0.235,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () async {
                                  
                                  displaySnackBar('Uploading your profile picture. Please hold on.');
            
                                  final PickedFile? galImage = await ImagePicker().getImage(source: ImageSource.gallery);
                                  final File image = File(galImage!.path);
                                  firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref().child('users/profile/${user!.uid}/');
                                  
                                  firebase_storage.TaskSnapshot storageTaskSnapshot = await storageRef.putFile(image);
                      
                                  var profileImageUrl = await storageTaskSnapshot.ref.getDownloadURL();
                      
                                  //print(profileImageUrl);
                      
                                  await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                                    'avatarURL' : profileImageUrl
                                  });
                                },
                      
                                child: avatarImgavailable
                                  ? CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 70.0,
                                      backgroundImage: NetworkImage(avatarURL),
                                    )
                                    : CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 70.0,
                                      child: Icon(Icons.account_circle, size: 130.0, color: Colors.black54),
                                    )
                                  
                                // child: CircleAvatar(
                                //       radius: 50.0,
                                //       child: Icon(Icons.photo_camera),
                                //     ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            
                    Container(
                      height: safeHeight * 0.7,
                      child: SettingsList(
                        sections: [
                          SettingsSection(
                            titlePadding: EdgeInsets.all(20),
                            title: 'GENERAL',
                            tiles: [
                              SettingsTile(
                                title: 'Your Name',
                                subtitle: name,
                                leading: Icon(Icons.account_circle_outlined),
                                onPressed: (BuildContext context) {
                                  var _name;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 16,
                                        child: Container(
                                          height: 100,
                                          width: 80,
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(width: 150, child: TextFormField(initialValue: name, onChanged: (val) => _name = val,)),
                                              SizedBox(width: 80, child: ElevatedButton(child: Text('Set'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)), onPressed: () async {
                                                await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                                                  'usrname' : _name,
                                                });
                                                Navigator.of(context).pop();
                                              }))
                                            ],
                                          ),
                                        )
                                      );
                                    }
                                  );
                                },
                              ),
                              SettingsTile(
                                title: 'Contact Number',
                                subtitle: phone,
                                leading: Icon(Icons.phone_outlined),
                                onPressed: (BuildContext context) {
                                  var _phno;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 16,
                                        child: Container(
                                          height: 80,
                                          width: 80,
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              SizedBox(width: 150, child: TextFormField(initialValue: phone, onChanged: (val) => _phno = val,)),
                                              SizedBox(width: 80, child: ElevatedButton(child: Text('Set'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)), onPressed: () async {
                                                await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                                                  'phno' : _phno,
                                                });
                                                Navigator.of(context).pop();
                                              }))
                                            ],
                                          ),
                                        )
                                      );
                                    }
                                  );
                                },
                              ),
                              SettingsTile(
                                title: 'email',
                                subtitle: email,
                                leading: Icon(Icons.mail_outline),
                                onPressed: (BuildContext context) {
                                  var _email;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 16,
                                        child: Container(
                                          height: 80,
                                          width: 80,
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              SizedBox(width: 150, child: TextFormField(initialValue: email, onChanged: (val) => _email = val,)),
                                              SizedBox(width: 80, child: ElevatedButton(child: Text('Set'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)), onPressed: () async {
                                                await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                                                  'email' : _email,
                                                });
                                                Navigator.of(context).pop();
                                              }))
                                            ],
                                          ),
                                        )
                                      );
                                    }
                                  );
                                },
                              ),
                  
                              // SettingsTile.switchTile(
                              //   leading: Icon(Icons.remove_red_eye),
                              //   title: 'Visiblity', 
                              //   onToggle: (val) async {
                              //     await FirebaseFirestore.instance.collection('chefs').doc(id).update({
                              //       'active': val,
                              //     });
                              //   }, 
                              //   switchValue: stActive
                              // ),
                            ],
                          ),
                          SettingsSection(
                            titlePadding: EdgeInsets.all(20),
                            title: 'ACTIVITY',
                            tiles: [
                              SettingsTile(
                                title: 'My Orders',
                                trailing: Icon(Icons.keyboard_arrow_right),
                                leading: Icon(Icons.local_restaurant),
                                onPressed: (BuildContext context) async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => UsrOrders()));
                                }
                              )
                            ]
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
                child: ElevatedButton(
                  child: Text('LOG OUT', style: GoogleFonts.robotoCondensed(fontSize: 20.0)),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.redAccent,
                    )
                  ),
                  onPressed: () async {
                    await AuthService().signOut();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          );
        } else {return Loading();}
      }
    );
  }
  displaySnackBar(errtext) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errtext),
        duration: const Duration(seconds: 3),
      ));
  }
}