import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class UsrOrders extends StatefulWidget {
  const UsrOrders({ Key? key }) : super(key: key);

  @override
  _UsrOrdersState createState() => _UsrOrdersState();
}

class _UsrOrdersState extends State<UsrOrders> {
  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;
    var streamQuery = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('orders').orderBy('createdDt').snapshots();
    var safeHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
        centerTitle: true,
      ),
      body:Column(
        children: [
          Container(
            height: safeHeight * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_restaurant_rounded, color: Colors.redAccent,),
                SizedBox(width: 15.0,),
                Text('Track all your orders here ...', style: GoogleFonts.robotoCondensed(fontSize: 18.0, color: Colors.black87),),
              ],
            ), alignment: Alignment.center,
          ),
          Container(
            height: safeHeight * 0.885,
            child: SingleChildScrollView(
              child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.87,
                child: StreamBuilder(
                  stream: streamQuery,
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if( !snapshot.hasData ){ return  Container(color: Colors.grey[200], child: Center(child: SpinKitCircle(color: Colors.redAccent, size: 50.0,)));}
                    else if( snapshot.data!.docs.length == 0) { return Center(child: Text('NO ORDERS FOUND. NOT HUNGRY KYA?', style: GoogleFonts.robotoCondensed(fontSize: 17.0),),); }
                    else return ListView(
                      children: snapshot.data!.docs.map(
                        (DocumentSnapshot document) {
                          Map<dynamic, dynamic> orderItems = Map.of((document.data() as dynamic)['order']);
                          var items = [];
                          var qty = [];
                          orderItems.forEach((key, value) { 
                            items.add(key);
                            qty.add(value);
                          });
                          return ExpansionTile(
                            leading: CircleAvatar(radius: 20, backgroundColor: Colors.redAccent, child: Icon(Icons.local_restaurant, color: Colors.white),),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text((document.data() as dynamic)['store_name'], style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w500),),
                                Text((document.data() as dynamic)['status'], style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w500),),
                              ],
                            ),
                            subtitle: Text('ORDER #: ${(document.data() as dynamic)['orderID']}', style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w500),),
                            expandedAlignment: Alignment.centerLeft,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: orderItems.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 40,
                                    child: ListTile(
                                      leading: Icon(Icons.restaurant, size: 20.0, color: Colors.redAccent,),
                                      title: Text(items[index], style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w600),),
                                      trailing: Text('qty: ${qty[index]}', style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w600),),
                                    ),
                                  );
                                }
                              ),
                              SizedBox(height: 40,),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('TOTAL PAYABLE : ', style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w700),),
                                    SizedBox(width: 15.0,),
                                    Text('\u{20B9}  ${(document.data() as dynamic)['billamt']}', style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w700),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    
                                      Icon(Icons.directions_walk_outlined, color: Colors.redAccent,),
                                      SizedBox(width: 5.0,),
                                      Icon(Icons.arrow_right_alt),
                                      SizedBox(width: 5.0,),
                                      Text((document.data() as dynamic)['store_add'], style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w500),),
                                    
                                  ],
                                ),
                              ),
                            ],
                            
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
  }
}

class OrderItems{
  String itemname;
  int qty;

  OrderItems({ required this.itemname, required this.qty });

  Map<String, dynamic> toJson() => {
    'itemname' : itemname,
    'qty' : qty
  };


}