import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/models/chefStoreData.dart';
import 'package:home_chef/models/orderStatsData.dart';
import 'package:home_chef/screens/chefs/chefsBills.dart';
import 'package:home_chef/screens/chefs/chefsMenu.dart';
import 'package:home_chef/screens/chefs/chefsOrders.dart';
import 'package:home_chef/screens/auth/usrSetting.dart';
import 'package:home_chef/services/orderStats.dart';
import 'package:home_chef/services/storeServices.dart';
import 'package:home_chef/screens/chefs/storeSettings.dart';
import 'package:home_chef/widgets/spinner.dart';

class ChefsMainPage extends StatefulWidget {
  const ChefsMainPage({ Key? key }) : super(key: key);

  @override
  _ChefsMainPageState createState() => _ChefsMainPageState();
}

class _ChefsMainPageState extends State<ChefsMainPage> {
  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;

    var safeHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom;
    var safeWidth = MediaQuery.of(context).size.width - MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;

    return StreamBuilder<ChefStoreData>(
      stream: StoreServices().storeData,
      builder: (context,snapshot){
        ChefStoreData? storeObjs = snapshot.data;
         if (snapshot.hasData){
           
          var storeName = storeObjs!.stName;
        //  var stPhNo = storeObjs.stPhNo;
        //  var stEmail = storeObjs.stEmail;
          var stRating = storeObjs.stRating;
        //  var stUsrName = storeObjs.stUsrName;
          var _stMnuCount = storeObjs.stMnuCount;
          var _stMnuInactive = storeObjs.stMnuInactive;
          var mnuCountDisp = (_stMnuCount - _stMnuInactive).toString().padLeft(2, '0');
          var stMnuInactive = storeObjs.stMnuInactive.toString().padLeft(2, '0');
          var stActive = storeObjs.stActive;

          var date = DateTime.now();
          var dt = date.day;
          var mnth = date.month;
          var yr = date.year;

          String _todayID = '$dt$mnth$yr';
          // print(_todayID);

          return StreamBuilder<OrderStatsData>(
            stream: OrderStatsServices(todayID: _todayID, uid: user!.uid).orderStatsData,
            builder: (context, snapshot) {
              OrderStatsData? orderstats = snapshot.data;
              if (snapshot.hasData){
                
                var ordersActive = orderstats!.ordersActive.toString().padLeft(2, '0');
                var ordersClosed = orderstats.ordersClosed.toString().padLeft(2, '0');
                var amtBilled = orderstats.billedAmt.toStringAsFixed(2);
                var amtRealized = orderstats.realizedAmt.toStringAsFixed(2);

                return Scaffold(
                  appBar: AppBar(
                    // backgroundColor: Colors.white,
                    elevation: 0.0,
                    title: storeName == '' ? Text('Home Chef Title', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),) : Text('$storeName', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
                    // centerTitle: true,
                    actions: [
                      IconButton(onPressed: () async {
                        await Navigator.push(
                          context, MaterialPageRoute(
                                builder: (context) => StoreSettings())
                              );
                            }, icon: Icon(Icons.store_outlined,)),
                      IconButton(onPressed: () async {
                        await Navigator.push(
                          context, MaterialPageRoute(
                                builder: (context) => UserSettings())
                              );
                            }, icon: Icon(Icons.account_circle_outlined,)),
                      IconButton(onPressed: () async {SystemNavigator.pop();}, icon: Icon(Icons.power_settings_new,))
                    ],
                  ),
                  body: Column(
                    children: [
                      Container(
                        height: safeHeight * 0.4,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: safeHeight * 0.39,
                                child: GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context, MaterialPageRoute(
                                        builder: (context) => ChefsOrders(),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: safeHeight * 0.2,
                                            child: Center(child: Text('$ordersActive', style: GoogleFonts.robotoCondensed(fontSize: 90.0),)),
                                          ),
                                          SizedBox(height: 50.0,),
                                          Center(child: Text('ACTIVE ORDERS', style: GoogleFonts.robotoCondensed(fontSize: 24.0),)),
                                          SizedBox(height: 20.0,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children:[ 
                                              Text('CLOSED ORDERS :', style: GoogleFonts.robotoCondensed(fontSize: 16.0),),
                                              SizedBox(width: 5.0,),
                                              Text('$ordersClosed', style: GoogleFonts.robotoCondensed(fontSize: 16.0),),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    elevation: 5,
                                    margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: safeHeight * 0.39,
                                child: GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context, MaterialPageRoute(
                                        builder: (context) => ChefsMenu(),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: safeHeight * 0.2,
                                            child: Center(child: Text('$mnuCountDisp', style: GoogleFonts.robotoCondensed(fontSize: 90.0),)),
                                          ),
                                          SizedBox(height: 50.0,),
                                          Center(child: Text('ITEMS IN MENU', style: GoogleFonts.robotoCondensed(fontSize: 24.0),)),
                                          SizedBox(height: 20.0,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children:[ 
                                              Text('INACTIVE ITEMS :', style: GoogleFonts.robotoCondensed(fontSize: 16.0),),
                                              SizedBox(width: 5.0,),
                                              Text('$stMnuInactive', style: GoogleFonts.robotoCondensed(fontSize: 16.0),),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    elevation: 5,
                                    margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: safeHeight * 0.35,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: safeHeight * 0.34,
                                child: GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context, MaterialPageRoute(
                                        builder: (context) => ChefsBills(),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: safeHeight * 0.175,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                                children: [ 
                                                Text('\u{20B9}', style: GoogleFonts.robotoCondensed(fontSize: 40.0), textAlign: TextAlign.start,), 
                                                SizedBox(width: 15.0,),
                                                Text('$amtBilled', style: GoogleFonts.robotoCondensed(fontSize: 90.0),)]),
                                          ),
                                          SizedBox(height: 25.0,),
                                          Center(child: Text('ORDER VALUE', style: GoogleFonts.robotoCondensed(fontSize: 24.0),)),
                                          SizedBox(height: 20.0,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children:[ 
                                              Text('AMOUNT REALIZED :', style: GoogleFonts.robotoCondensed(fontSize: 16.0),),
                                              SizedBox(width: 5.0,),
                                              Text('\u{20B9}', style: GoogleFonts.robotoCondensed(fontSize: 20.0)), 
                                              SizedBox(width: 5.0,),
                                              Text('$amtRealized', style: GoogleFonts.robotoCondensed(fontSize: 20.0),),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    elevation: 5,
                                    margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5),
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(
                            //   child: Container(
                            //     height: safeHeight * 0.34,
                            //     child: Card(
                            //       semanticContainer: true,
                            //       clipBehavior: Clip.antiAliasWithSaveLayer,
                            //       child: Text('To Collect'),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(10.0),
                            //       ),
                            //       elevation: 5,
                            //       margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5),
                            //     ),
                            //   ),
                            // ),
                          ],
                        )
                      ),
                      Container(
                        height: safeHeight * 0.185,
                        width: safeWidth,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: safeHeight * 0.175,
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          RatingBar.builder(
                                            ignoreGestures: true,
                                            initialRating: stRating,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                            },
                                          ),
                                          SizedBox(height: 20.0,),
                                          Text('$stRating', style: GoogleFonts.robotoCondensed(fontSize: 35.0,),),
                                        ],
                                      ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // floatingActionButton: FloatingActionButton(
                  //   child: Icon(Icons.store),
                  //   onPressed: () {},
                  // ),
                );
              } else {return Loading();}
            }
          );
         } else {return Loading();}
      }
    );
  }
}