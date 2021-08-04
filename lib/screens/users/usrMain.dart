import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/models/userProfileData.dart';
import 'package:home_chef/screens/auth/usrSetting.dart';
import 'package:home_chef/screens/users/usrOrders.dart';
import 'package:home_chef/screens/users/usrStoreMenu.dart';
import 'package:home_chef/services/userServices.dart';
import 'package:home_chef/widgets/spinner.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({ Key? key }) : super(key: key);

  @override
  _UserMainPageState createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {

  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;
    var streamQuery = FirebaseFirestore.instance.collection('chefs').snapshots();

    var safeHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom;
    // var safeWidth = MediaQuery.of(context).size.width - MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;

    return StreamBuilder<UserObjs>(
      stream: UserServices(uid: user!.uid).userRootData,
      builder: (context,snapshot){
        UserObjs? userObjs = snapshot.data;
        if (snapshot.hasData){
          var cartcount = userObjs!.cartcount;  // ==> NOT USING
        return Scaffold(
          appBar: AppBar(
            // backgroundColor: Colors.white,
            elevation: 0.0,
            title: Text('Home Chefs', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
            // centerTitle: true,
            actions: [
              IconButton(icon: Icon(Icons.local_restaurant), onPressed: () async {await Navigator.push(context, MaterialPageRoute(builder: (context) => UsrOrders()));}),
              IconButton(onPressed: () async {await Navigator.push(context, MaterialPageRoute(builder: (context) => UserSettings()));}, icon: Icon(Icons.account_circle_outlined,)),
              IconButton(onPressed: () async {SystemNavigator.pop();}, icon: Icon(Icons.power_settings_new,))
            ],
          ),
          body: Column(
            children: [
              Container(
                height: safeHeight * 0.05,
                child: Text('Tasty home-made food awaits you ...', style: GoogleFonts.robotoCondensed(fontSize: 18.0, color: Colors.black87),), alignment: Alignment.center,
              ),
              Container(
                height: safeHeight * 0.885,
                child: SingleChildScrollView(
                  child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.87,
                    child: StreamBuilder(
                      stream: streamQuery,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if( !snapshot.hasData ){ return  Container(color: Colors.grey[200], child: Center(child: SpinKitCircle(color: Colors.redAccent, size: 50.0,)));}
                        else if( snapshot.data!.docs.length == 0) { return Center(child: Text('No products found'),); }
                        else return ListView(
                          children: snapshot.data!.docs.map(
                            (DocumentSnapshot document) {
                              return ListTile(
                                leading: CircleAvatar(radius: 20, backgroundColor: Colors.redAccent, child: Icon(Icons.restaurant, color: Colors.white),),
                                title: Text((document.data() as dynamic)['storename'], style: GoogleFonts.robotoCondensed(fontSize: 17.0, fontWeight: FontWeight.w700),),
                                subtitle: Text('Door #: 86'), // ==> TO BE FIXED ***
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star),
                                    SizedBox(width: 3.0,),
                                    Text('${(document.data() as dynamic)['rating']}', style: GoogleFonts.robotoCondensed(fontSize: 16.0,),),
                                  ],
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context, MaterialPageRoute(
                                      builder: (context) => UserStoreMenu(document.id, (document.data() as dynamic)['storename'], (document.data() as dynamic)['door'], (document.data() as dynamic)['society']),
                                    ),
                                  );
                                },
                              );
                            }
                          ).toList(),
                        );
                      }
                    )
                  )
                )
              )
            ],
          ),
          
        );
        } else {return Loading();}
      }
    );
  }
}