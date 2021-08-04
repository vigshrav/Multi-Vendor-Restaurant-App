import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/models/chefStoreData.dart';
import 'package:home_chef/services/storeServices.dart';
import 'package:home_chef/widgets/spinner.dart';
import 'package:settings_ui/settings_ui.dart';

class StoreSettings extends StatefulWidget {
  const StoreSettings({ Key? key }) : super(key: key);

  @override
  _StoreSettingsState createState() => _StoreSettingsState();
}

class _StoreSettingsState extends State<StoreSettings> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChefStoreData>(
      stream: StoreServices().storeData,
      builder: (context,snapshot){
        ChefStoreData? storeObjs = snapshot.data;
         if (snapshot.hasData){
           
           var id = storeObjs!.id;
           var storeName = storeObjs.stName;
           var stPhNo = storeObjs.stPhNo;
           var stEmail = storeObjs.stEmail;
           var stRating = storeObjs.stRating;
           var stUsrName = storeObjs.stUsrName;
           var _stMnuCount = storeObjs.stMnuCount;
           var _stMnuInactive = storeObjs.stMnuInactive;
           var mnuCountDisp = (_stMnuCount - _stMnuInactive).toString().padLeft(2, '0');;
           var stMnuInactive = storeObjs.stMnuInactive.toString().padLeft(2, '0');
           var stActive = storeObjs.stActive;

          return Scaffold(
            appBar: AppBar(
              title: Text('Store Settings', style: GoogleFonts.raleway(fontSize: 28.0,),),
              centerTitle: true,
            ),
            body: SettingsList( 
              sections: [
                SettingsSection(
                  titlePadding: EdgeInsets.all(20),
                  title: 'General',
                  tiles: [
                    SettingsTile(
                      title: 'Title',
                      subtitle: storeName,
                      leading: Icon(Icons.store),
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
                                    SizedBox(width: 150, child: TextFormField(maxLength: 20, initialValue: storeName, onChanged: (val) => _name = val,)),
                                    SizedBox(width: 80, child: ElevatedButton(child: Text('Set'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)), onPressed: () async {
                                      await FirebaseFirestore.instance.collection('chefs').doc(id).update({
                                        'storename' : _name,
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
                      subtitle: stPhNo,
                      leading: Icon(Icons.phone),
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
                                    SizedBox(width: 150, child: TextFormField(initialValue: stPhNo, onChanged: (val) => _phno = val,)),
                                    SizedBox(width: 80, child: ElevatedButton(child: Text('Set'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)), onPressed: () async {
                                      await FirebaseFirestore.instance.collection('chefs').doc(id).update({
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
                      subtitle: stEmail,
                      leading: Icon(Icons.mail),
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
                                    SizedBox(width: 150, child: TextFormField(initialValue: stEmail, onChanged: (val) => _email = val,)),
                                    SizedBox(width: 80, child: ElevatedButton(child: Text('Set'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)), onPressed: () async {
                                      await FirebaseFirestore.instance.collection('chefs').doc(id).update({
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
      
                    SettingsTile.switchTile(
                      leading: Icon(Icons.remove_red_eye),
                      title: 'Visiblity', 
                      onToggle: (val) async {
                        await FirebaseFirestore.instance.collection('chefs').doc(id).update({
                          'active': val,
                        });
                      }, 
                      switchValue: stActive),
                  ],
                )
              ],
            )
          );
         } else {return Loading();}
      }
    );
  }
}