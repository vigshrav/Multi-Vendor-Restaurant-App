import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class ChefsOrders extends StatefulWidget {
  const ChefsOrders({ Key? key }) : super(key: key);

  @override
  _ChefsOrdersState createState() => _ChefsOrdersState();
}

class _ChefsOrdersState extends State<ChefsOrders> {

  var filterindex = 1;

  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;
    // var streamQuery = FirebaseFirestore.instance.collection('chefs').doc(user!.uid).collection('orders').orderBy('createdDt').snapshots();
    
    var safeHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom;

    buildquery(){
      var streamQuery;
      switch(filterindex) {
        
        case 1:
        streamQuery =  FirebaseFirestore.instance.collection('chefs').doc(user!.uid).collection('orders').orderBy('status').where('status', isNotEqualTo: 'DELIVERED').orderBy('createdDt').snapshots();
        break;
        
        case 2:
        streamQuery =  FirebaseFirestore.instance.collection('chefs').doc(user!.uid).collection('orders').orderBy('status').where('status', isEqualTo: 'DELIVERED').orderBy('createdDt').snapshots();
        break;
        
        case 3:
        streamQuery =  FirebaseFirestore.instance.collection('chefs').doc(user!.uid).collection('orders').orderBy('status').where('status', isNotEqualTo: 'DELIVERED').orderBy('createdDt', descending: true).snapshots();
        break;

        // case 4:
        // streamQuery =  FirebaseFirestore.instance.collection('polls').orderBy('votes', descending: true).snapshots();
        // break;
      
      }
      return streamQuery;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: safeHeight * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        filterindex = 1;
                      });
                    }, 
                    child: Text('Open Orders', style: GoogleFonts.robotoCondensed(fontSize: 18.0,),), 
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                    )
                  ),
                    backgroundColor: MaterialStateProperty.all<Color>(buttonColor(filterindex, 1)),
                  ),
                  ),
                  SizedBox(width: 4.0),
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        filterindex = 2;
                      });
                    }, 
                    child: Text('Closed Orders', style: GoogleFonts.robotoCondensed(fontSize: 18.0,),),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                    )
                  ),
                    backgroundColor: MaterialStateProperty.all<Color>(buttonColor(filterindex, 2)),
                  )),
                  SizedBox(width: 4.0),
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        filterindex = 3;
                      });
                    }, 
                    child: Text('Newest First', style: GoogleFonts.robotoCondensed(fontSize: 18.0,),),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                    )
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(buttonColor(filterindex, 3)),
                ))
              ],
            )
          ])),
          Container(
            height: safeHeight * 0.885,
            child: SingleChildScrollView(
              child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.87,
                child: StreamBuilder(
                  stream: buildquery(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if( !snapshot.hasData ){ return  Container(color: Colors.grey[200], child: Center(child: SpinKitCircle(color: Colors.redAccent, size: 50.0,)));}
                    else if( snapshot.data!.docs.length == 0) { return Center(child: Text('NO ORDERS PLACED YET.', style: GoogleFonts.robotoCondensed(fontSize: 17.0),),); }
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
                          var custDet = '${(document.data() as dynamic)['cust_door']} - ${(document.data() as dynamic)['cust_society']}';
                          
                          var _createdAt = DateTime.parse(((document.data() as dynamic)['createdDt']).toDate().toString());
                          var crDt = _createdAt.day;
                          var crmnth = _createdAt.month;
                          var cryr = _createdAt.year;
                          var hour = _createdAt.hour;
                          var min = _createdAt.minute;
                          var createdAt = '$crDt-$crmnth-$cryr $hour: $min';
                          // print(createdAt);
                          
                          return Card(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(radius: 20, backgroundColor: Colors.redAccent, child: Icon(Icons.local_restaurant, color: Colors.white),),
                                          ),
                                          SizedBox(width: 10.0,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text((document.data() as dynamic)['orderID'], style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w700),),
                                              Text('\u{20B9} ${(document.data() as dynamic)['billamt']}', style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w700),),
                                            ],
                                          ),
                                        ],
                                      ),
                                      getStatus((document.data() as dynamic)['status'], user!.uid, document.id),
                                    ]),
                                  ),
                                  Text('Ordered at : $createdAt', style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w500),),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: orderItems.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                                        height: 30,
                                        child: ListTile(
                                          title: Row(children: [
                                            // Icon(Icons.label, size: 20.0, color: Colors.redAccent,),
                                            SizedBox(width: 5.0,),
                                            Text(items[index], style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w600),),
                                          ]),
                                          trailing: Text('qty: ${qty[index]}', style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w600),),
                                        ),
                                      );
                                    }
                                  ),
                                  SizedBox(height: 20,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(Icons.person, size: 20.0, color: Colors.redAccent,),
                                                SizedBox(width: 15.0,),
                                                Text((document.data() as dynamic)['cust_name'], style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w500),),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.phone, size: 20.0, color: Colors.redAccent,),
                                                SizedBox(width: 15.0,),
                                                Text((document.data() as dynamic)['cust_phno'], style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w500),),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 5.0,),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 0.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.place, size: 20.0, color: Colors.redAccent,),
                                              SizedBox(width: 15.0,),
                                              Text('$custDet', style: GoogleFonts.robotoCondensed(fontSize: 15.0, fontWeight: FontWeight.w500),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
  getStatus(status, uid, oid){
      if (status == 'PLACED'){
        return (
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('chefs').doc(uid).collection('orders').doc(oid).update({
                    'status' : 'REJECTED'
                  });
                }, 
                icon: Icon(Icons.close, size: 30.0, color: Colors.red,),
                
              ),
              IconButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('chefs').doc(uid).collection('orders').doc(oid).update({
                    'status' : 'PREPARING'
                  });
                }, 
                icon: Icon(Icons.done, size: 30.0, color: Colors.green,))
            ],
          )
        );
      } else {
        return GestureDetector(
          child: Row(
            children: [
              Text(status),
              Icon(Icons.arrow_drop_down)
            ]
          ),
          onTap: (){
            showStatusList(status);
          },
        );
      }
    }

    showStatusList(status){
      showDialog(context: context, builder: (BuildContext context){
        return Dialog(
          elevation: 20.0,
          child: Container(
            height: 300,
            width: 10,
            padding: EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              children: [

                TextButton.icon(onPressed: (){}, label: Text('PLACED', style: GoogleFonts.robotoCondensed(fontSize: 25.0, color: Colors.black)), icon: Icon(Icons.done, color: getStatusColor(0, status)),),
                Divider(thickness: 1.0, indent: 35.0, endIndent: 35.0, color: Colors.black,),
                TextButton.icon(onPressed: (){}, label: Text('PREPARING', style: GoogleFonts.robotoCondensed(fontSize: 25.0, color: Colors.black)), icon: Icon(Icons.done, color: getStatusColor(1, status)),),
                Divider(thickness: 1.0, indent: 35.0, endIndent: 35.0, color: Colors.black,),
                TextButton.icon(onPressed: (){}, label: Text('READY FOR PICKUP', style: GoogleFonts.robotoCondensed(fontSize: 25.0, color: Colors.black)), icon: Icon(Icons.done, color: getStatusColor(2, status)),),
                Divider(thickness: 1.0, indent: 35.0, endIndent: 35.0, color: Colors.black,),
                TextButton.icon(onPressed: (){}, label: Text('REJECTED', style: GoogleFonts.robotoCondensed(fontSize: 25.0, color: Colors.black)), icon: Icon(Icons.done, color: getStatusColor(3, status)),),
                
              ],
            )
          ),
        );
      });
    }
    
    getStatusColor(int, status){
      var statusno;
      
      if (status == 'PLACED') {statusno = 0;}
      if (status == 'PREPARING') {statusno = 1;}
      if (status == 'READY FOR PICKUP') {statusno = 2;}
      if (status == 'REJECTED') {statusno = 3;}

      if (statusno == int) {return Colors.redAccent;}
      else return Colors.transparent;

    }

    Icon iconColor(int filterindex, buttonindex){
      if (filterindex == buttonindex && filterindex < 3) {
        return Icon(Icons.check, color: Colors.white);
      } else if (filterindex == 3 && buttonindex == 3) {
        return Icon(Icons.arrow_downward, color: Colors.white);
        } else if (filterindex == 4 && buttonindex == 3) {
          return Icon(Icons.arrow_upward, color: Colors.white);
          } else return Icon(Icons.clear, color: Colors.white);
    }

    Color buttonColor(int filterindex, buttonindex){
      if (filterindex == buttonindex) {
        return Colors.redAccent;
      } else {return Colors.grey;}
    }
}