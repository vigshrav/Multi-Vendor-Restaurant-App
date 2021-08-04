import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/models/userProfileData.dart';
import 'package:home_chef/screens/users/usrStoreMenu.dart';
import 'package:home_chef/services/userServices.dart';
import 'package:home_chef/widgets/spinner.dart';
import 'package:nanoid/nanoid.dart';

class UserCart extends StatefulWidget {
  // const UserCart({ Key? key }) : super(key: key);

  final cartItemsList, storeID, storeName, door, society;
  UserCart(this.cartItemsList, this.storeID, this.storeName, this.door, this.society);

  @override
  _UserCartState createState() => _UserCartState();
}

class _UserCartState extends State<UserCart> {

  bool loading = false;
  
  @override
  Widget build(BuildContext context) {

    calTotal(){
      var totVal = 0.00;
      for(CartItems cItem in widget.cartItemsList){
        totVal = (cItem.price * cItem.qty) + totVal;
      }
      return totVal;
    }

    _showOrderConfDialog(totAmt, orderList, uid, name, phno, door, society){
      // print(name);
      // print(phno);
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 16,
            child: Container(
              height: 350,
              width: 200,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Text('Order Confirmation', style: GoogleFonts.robotoCondensed(fontSize: 18.0, fontWeight: FontWeight.w700),),
                  SizedBox(height: 20),
                  Text('Total Order Value : \u{20B9} $totAmt', style: GoogleFonts.robotoCondensed(fontSize: 16.0, fontWeight: FontWeight.w700),),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    child: Column(
                      children: [
                        Text('You may pay at the time of Order Pickup, using either of the below modes:', style: GoogleFonts.robotoCondensed(fontSize: 14.0),),
                        SizedBox(height: 10),
                        Text('1. Online Transfer: (Recommended) Using UPI or any of your prefered payment apps', style: GoogleFonts.robotoCondensed(fontSize: 14.0),),
                        SizedBox(height: 10),
                        Text('2. Cash: Please carry exact change to avoid any delays', style: GoogleFonts.robotoCondensed(fontSize: 14.0),),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    child: Text('Continue', style: GoogleFonts.robotoCondensed(fontSize: 16.0,)), 
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)), 
                    onPressed: () async {

                      String st_address = '${widget.door} - ${widget.society}';

                      List months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                      var date = DateTime.now();
                      var dt = date.day;
                      var mnth = date.month;
                      var monthName = months[mnth-1];
                      var yr = date.year;
                      var hr = date.hour;
                      var mns = date.minute;

                      String _today = '$dt $monthName $yr  $hr : $mns';
                      String _todayID = '$dt$mnth$yr';

                      setState(() => loading = true);
                      var orderitems = Map.fromIterable(orderList, key: (e) => e.item, value: (e) => e.qty,);
                      var orderID_01 = customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 5);
                      var orderID_02 = customAlphabet('1234567890', 5);
                      var orderID = '$orderID_01$orderID_02';
                      // print(orderID);
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      batch.set(
                      FirebaseFirestore.instance.collection('chefs').doc(widget.storeID).collection('orders').
                        doc(orderID),
                        {
                          'orderID' : orderID,
                          'createdDt' : date,
                          'dateDisp' : _today,
                          'cust_id': uid,
                          'cust_name' : name,
                          'cust_phno' : phno,
                          'cust_door' : door,
                          'cust_society' : society,
                          'order' : orderitems,
                          'billamt' : totAmt,
                          'status' : 'PLACED',
                        });
                      var docRef = FirebaseFirestore.instance.collection('chefs').doc(widget.storeID).collection('orderStats').doc(_todayID);
                      await docRef.get().then((doc) async => {
                        if (doc.exists){
                          batch.update(
                            FirebaseFirestore.instance.collection('chefs').doc(widget.storeID).collection('orderStats').doc(_todayID),
                              {
                                'activeOrders' : FieldValue.increment(1),
                                'billValue' : FieldValue.increment(double.parse(totAmt)),
                              }
                            )
                          } else {
                            batch.set(
                              FirebaseFirestore.instance.collection('chefs').doc(widget.storeID).collection('orderStats').doc(_todayID),
                                {
                                  'activeOrders' : FieldValue.increment(1),
                                  'billValue' : FieldValue.increment(double.parse(totAmt)),
                                  'closedOrders' : 0,
                                  'amtRealized' : 0.0,
                                }
                            )
                          }
                      });
                      batch.set(
                      FirebaseFirestore.instance.collection('users').doc(uid).collection('orders').
                        doc(orderID),
                        {
                          'orderID' : orderID,
                          'createdDt' : date,
                          'dateDisp' : _today,
                          'store_id': widget.storeID,
                          'store_name' : widget.storeName,
                          'store_add' : st_address,
                          'order' : orderitems,
                          'billamt' : totAmt,
                          'status' : 'PLACED'
                        }
                      );

                      batch.commit();

                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    })
                ],
              ),
            )
          );
        }
      );
    }

    showTile(CartItems cartitem){
      var totCost = cartitem.qty * cartitem.price;
      return ListTile(
      //  leading: CircleAvatar(backgroundColor: Colors.redAccent, radius: 40, backgroundImage: NetworkImage(cartitem.imgURL)),
      leading: Text('${cartitem.qty}  x', style: GoogleFonts.robotoCondensed(fontSize: 16.0, fontWeight: FontWeight.w500),),
       title: Row(
         children: [
           Text(cartitem.item, style: GoogleFonts.robotoCondensed(fontSize: 16.0, fontWeight: FontWeight.w500),),
          //  SizedBox(width: 35),
           
         ],
       ),
       subtitle: Text('\u{20B9}  ${(cartitem.price).toStringAsFixed(2)}', style: GoogleFonts.robotoCondensed(fontSize: 16.0),),
       trailing: Text('\u{20B9}  ${(totCost).toStringAsFixed(2)}', style: GoogleFonts.robotoCondensed(fontSize: 16.0, fontWeight: FontWeight.w500),),
      );
    }

    var safeHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom;
    var cartList = widget.cartItemsList;
    var listLength = cartList.length;

    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<UserObjs>(
      stream: UserServices(uid: user!.uid).userRootData,
      builder: (context,snapshot){
        UserObjs? userObjs = snapshot.data;
        if (snapshot.hasData){

          var name = userObjs!.uName;
          var id = userObjs.id;
          var phone = userObjs.phone;
          var door = userObjs.door;
          var society = userObjs.society;
    
          return loading ? Loading() : Scaffold(
            appBar: AppBar(
              title: Text('Cart', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
              // actions: [IconButton(icon: cartcount == 0 ? Icon(Icons.shopping_cart_outlined) : Icon(Icons.shopping_cart), onPressed: (){}),],
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: safeHeight * 0.05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Home Chef : ', style: GoogleFonts.robotoCondensed(fontSize: 18.0, fontWeight: FontWeight.w700),),
                        Text(widget.storeName, style: GoogleFonts.robotoCondensed(fontSize: 18.0, fontWeight: FontWeight.w700),)
                    ],),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      // padding: EdgeInsets.only(top: 20),
                      height: safeHeight * 0.78,
                      child: listLength == 0 ? 
                      Center(child: Text('No items added to cart!'),) :
                      ListView.builder(
                        itemCount: listLength,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 60,
                            child: showTile(cartList[index]),
                          );
                        }
                      )
                    ),
                  ),
                  Container(
                    height: safeHeight * 0.05,
                    child: Text('Total : \u{20B9} ${calTotal().toStringAsFixed(2)}', style: GoogleFonts.robotoCondensed(fontSize: 18.0, fontWeight: FontWeight.w700),),
                    alignment: Alignment.centerRight,
                  )
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.redAccent,
              child: TextButton(
                child: Text('Place Order', style: GoogleFonts.robotoCondensed(fontSize: 25.0, color: Colors.white),),
                style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.redAccent.shade400)),
                onPressed: () async {
                  var billamt = calTotal();
                  if(billamt > 0) {
                   _showOrderConfDialog(billamt.toStringAsFixed(2), cartList, id, name, phone, door, society);
                  }
                },
              ),
            ),
          );
        } else return Loading();
      }
    );
  }
}