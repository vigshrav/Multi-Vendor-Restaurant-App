import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/screens/users/usrCart.dart';

class UserStoreMenu extends StatefulWidget {
  // const UserStoreMenu({ Key? key }) : super(key: key);

  final storeID, storeName, door, society;
  UserStoreMenu(this.storeID, this.storeName, this.door, this.society);

  @override
  _UserStoreMenuState createState() => _UserStoreMenuState();
}

class _UserStoreMenuState extends State<UserStoreMenu> {

  var cartcount = 0;

  @override
  Widget build(BuildContext context) {

    List cartItemsList = [];

    var streamQuery = FirebaseFirestore.instance.collection('chefs').doc(widget.storeID).collection('menu').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
        actions: [IconButton(icon: cartcount == 0 ? Icon(Icons.shopping_cart_outlined) : Icon(Icons.shopping_cart), onPressed: () async {
          await Navigator.push(
            context, MaterialPageRoute(
              builder: (context) => UserCart(cartItemsList, widget.storeID, widget.storeName, widget.door, widget.society),
            ),
          );
        }),],
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.95,
            child: StreamBuilder(
              stream: streamQuery,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if( !snapshot.hasData ){ return  Container(color: Colors.grey[200], child: Center(child: SpinKitCircle(color: Colors.redAccent, size: 50.0,)));}
                else if( snapshot.data!.docs.length == 0 ) { return Center(child: Text('No products found'),); }
                else return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: (2 / 2.5),
                  padding: EdgeInsets.all(0.0),
                  children: snapshot.data!.docs.map(
                    (DocumentSnapshot document) {
                      int _itemcount = 0;
                      var textController = TextEditingController(text: '$_itemcount');
                      var imgAvbl = (document.data() as dynamic)['imgURL'] != '' ? 'YES' : 'NO';
                      
                      return Container(
                        child: GestureDetector(
                          child: Card(
                            shadowColor: Colors.redAccent.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: 
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  imgAvbl == 'YES' ? CircleAvatar(backgroundColor: Colors.redAccent, radius: 40, backgroundImage: NetworkImage((document.data() as dynamic)['imgURL']),) : CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.restaurant, size: 50)),
                                  SizedBox(height: 20,),
                                  Flexible(child: Text('${(document.data() as dynamic)['itemName']}', style: GoogleFonts.robotoCondensed(fontSize: 16.0,), softWrap: true,)),
                                  SizedBox(height: 20,),
                                  Text('\u{20B9}  ${(document.data() as dynamic)['itemPrice'].toStringAsFixed(2)}', style: GoogleFonts.robotoCondensed(fontSize: 16.0,), softWrap: true,),
                                  SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(color: Colors.redAccent, icon: Icon(Icons.remove), onPressed: () async {
                                        if (_itemcount > 1){
                                          _itemcount = _itemcount - 1;
                                          textController.text = '$_itemcount';
                                          final _cartItem = cartItemsList.firstWhere((element) => element.id == document.id, orElse: () => null);
                                          if(_cartItem!=null){_cartItem.qty = _itemcount;}
                                          // for(CartItems cItem in cartItemsList){
                                            // print(cItem.item);
                                            // print(cItem.qty);
                                          // }
                                        } else if (_itemcount == 1){
                                          _itemcount = _itemcount - 1;
                                          textController.text = '$_itemcount';
                                          cartItemsList.removeWhere((element) => element.id == document.id);
                                          // for(CartItems cItem in cartItemsList){
                                            // print(cItem.item);
                                            // print(cItem.qty);
                                          // }
                                        }
                                      }),
                                      SizedBox(width: 10, child: TextFormField(controller: textController, decoration: new InputDecoration(border: InputBorder.none,))),
                                      IconButton(color: Colors.redAccent, icon: Icon(Icons.add), onPressed: () async {
                                        _itemcount = _itemcount + 1;
                                        // setState(() => cartcount = cartcount + 1);
                                        textController.text = '$_itemcount';
                                        final _cartItem = cartItemsList.firstWhere((element) => element.id == document.id, orElse: () => null);
                                        if(_cartItem!=null){_cartItem.qty = _itemcount;}
                                        else
                                        {cartItemsList.add(
                                            CartItems(
                                              id: document.id,
                                              item: (document.data() as dynamic)['itemName'], 
                                              qty: _itemcount,
                                              price: (document.data() as dynamic)['itemPrice'],
                                              imgURL: (document.data() as dynamic)['imgURL'],
                                            )
                                          );
                                        }
                                        // print(cartItemsList);
                                        // for(CartItems cItem in cartItemsList){
                                        //     print(cItem.item);
                                        //     print(cItem.qty);
                                        // }
                                      }),
                                    ],
                                  )
                                ],
                              ),
                          ),
                          onTap: () async {
                            
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
    );
  }
}

class CartItems {

  String id;
  String item;
  int qty;
  double price;
  String imgURL;

  CartItems({ required this.id, required this.item, required this.qty, required this.price, required this.imgURL });

   Map<String, dynamic> toJson() => {
     'id' : id,
     'item' : item,
     'qty' : qty,
     'price': price,
     'img': imgURL
   };
}