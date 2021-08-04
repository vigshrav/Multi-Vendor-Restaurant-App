import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/models/chefMenuItemData.dart';
import 'package:home_chef/screens/chefs/chefsAddItem.dart';
import 'package:home_chef/screens/chefs/chefsEditItem.dart';

class ChefsMenu extends StatefulWidget {
  const ChefsMenu({ Key? key }) : super(key: key);

  @override
  _ChefsMenuState createState() => _ChefsMenuState();
}

class _ChefsMenuState extends State<ChefsMenu> {

  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;
    var streamQuery = FirebaseFirestore.instance.collection('chefs').doc(user!.uid).collection('menu').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Store Menu', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.95,
            child: StreamBuilder(
              stream: streamQuery,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if( !snapshot.hasData ){ return new Text('Loading...'); }
                else if( snapshot.data!.docs.length == 0) { return Center(child: Text('No products found'),); }
                else return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: (2 / 2.5),
                  padding: EdgeInsets.all(0.0),
                  children: snapshot.data!.docs.map(
                    (DocumentSnapshot document) {
                      
                      var imgAvbl = (document.data() as dynamic)['imgURL'] != '' ? 'YES' : 'NO';
                      var toggleval = (document.data() as dynamic)['active'];
                      return Container(
                        child: GestureDetector(
                          child: Card(
                            shadowColor: Colors.redAccent.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: 
                              Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.max,
                                    children: [ 
                                      (Switch(inactiveThumbColor: Colors.grey, inactiveTrackColor: Colors.grey.shade300, activeTrackColor: Colors.red.shade100, activeColor: Colors.redAccent, 
                                      value: toggleval, onChanged: (bool val) async {
                                        // setState(() { toggleval = val;});
                                        await document.reference.update({ 'active' : val, });
                                        if (val == false){
                                          await FirebaseFirestore.instance.collection('chefs').doc(user.uid).update({ 'menuitemsinactive' : FieldValue.increment(1) });
                                        }
                                        if (val == true){
                                          await FirebaseFirestore.instance.collection('chefs').doc(user.uid).update({ 'menuitemsinactive' : FieldValue.increment(-1) });
                                        }
                                      })),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  imgAvbl == 'YES' ? CircleAvatar(backgroundColor: Colors.redAccent, radius: 40, backgroundImage: NetworkImage((document.data() as dynamic)['imgURL']),) : CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.restaurant, size: 50)),
                                  SizedBox(height: 20,),
                                  Flexible(child: Text('${(document.data() as dynamic)['itemName']}', style: GoogleFonts.robotoCondensed(fontSize: 16.0,), softWrap: true,)),
                                  SizedBox(height: 20,),
                                  Text('\u{20B9}  ${(document.data() as dynamic)['itemPrice'].toStringAsFixed(2)}', style: GoogleFonts.robotoCondensed(fontSize: 16.0,), softWrap: true,),
                                ],
                              ),
                          ),
                          onTap: () async {
                            var data = ChefMenuItemsData(
                              id: document.id, 
                              name: (document.data() as dynamic)['itemName'], 
                              desc: (document.data() as dynamic)['itemDesc'], 
                              price: (document.data() as dynamic)['itemPrice'],
                              imgURL: (document.data() as dynamic)['imgURL'],
                            );
                            await Navigator.push(
                              context, MaterialPageRoute(
                                builder: (context) => ChefsEditItem(data),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                );
              }
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('New Item', style: GoogleFonts.robotoCondensed(fontSize: 18.0,)),
        icon: Icon(Icons.add),
        onPressed: ()async {
          await Navigator.push(
            context, MaterialPageRoute(
              builder: (context) => ChefsAddItem(),
            ),
          );
        },
      ),
    );
  }
}