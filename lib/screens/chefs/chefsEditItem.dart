import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/models/chefMenuItemData.dart';
import 'package:home_chef/widgets/spinner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ChefsEditItem extends StatefulWidget {
  // const ChefsEditItem({ Key? key }) : super(key: key);

  final ChefMenuItemsData data;
  ChefsEditItem(this.data);

  @override
  _ChefsEditItemState createState() => _ChefsEditItemState();
}

class _ChefsEditItemState extends State<ChefsEditItem> {

  final _formKey = GlobalKey<FormState>();
  String name = ''; 
  String desc = '';
  double price = 0.0;
  bool loading = false;
  // var avatarImgURL = '';

  var userid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    var avatarImgURL = widget.data.imgURL;

    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text('Edit Item', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
        actions: [
          IconButton(icon: Icon(Icons.delete), onPressed: () async {
            _deleteItem();
          })
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0,),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: '${widget.data.name}',
                  decoration: InputDecoration(
                    // prefixIcon: Icon(Icons.alternate_email, color: Colors.black54),
                    labelText: 'Item Name:',
                    labelStyle: GoogleFonts.robotoCondensed(color: Colors.black,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0),),
                      borderSide: BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0),),
                      borderSide: BorderSide(width: 2.0, color: Colors.redAccent)
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 20,
                  validator: (val) => val!.isEmpty ? 'Please provide a name' : null,
                  onChanged: (val) {
                    setState(() => name = val);
                  }
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: '${widget.data.price.toStringAsFixed(2)}',
                  decoration: InputDecoration(
                    // prefixIcon: Icon(Icons.alternate_email, color: Colors.black54,),
                    prefixText: '\u{20B9}   ',
                    labelText: 'Price:',
                    labelStyle: GoogleFonts.robotoCondensed(color: Colors.black,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0),),
                      borderSide: BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0),),
                      borderSide: BorderSide(width: 2.0, color: Colors.redAccent)
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  //obscureText: true,
                  validator: (val) => val!.isEmpty ? 'Price is mandatory' : null,
                  onChanged: (val) {
                    setState(() => price = double.parse(val));
                  }
                ),
                SizedBox(height: 40),
                TextFormField(
                  initialValue: '${widget.data.desc}',
                  decoration: InputDecoration(
                    // prefixIcon: Icon(Icons.alternate_email, color: Colors.black54,),
                    labelText: 'Description:',
                    labelStyle: GoogleFonts.robotoCondensed(color: Colors.black,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0),),
                      borderSide: BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0),),
                      borderSide: BorderSide(width: 2.0, color: Colors.redAccent)
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  //obscureText: true,
                  maxLines: 3,
                  maxLength: 150,
                  validator: (val) => val!.isEmpty ? 'Please provide a description' : null,
                  onChanged: (val) {
                    setState(() => desc = val);
                  }
                ),
                SizedBox(height: 40),
                GestureDetector(
                  onTap: () async {

                    // if (name != ''){
                    
                      final PickedFile? galImage = await ImagePicker().getImage(source: ImageSource.gallery);
                      final File image = File(galImage!.path);
                      displaySnackBar('Uploading Image. Hold on...');
                      firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref().child('chefs/$userid/${widget.data.name}');                    
                      firebase_storage.TaskSnapshot storageTaskSnapshot = await storageRef.putFile(image);
                      var imgURL = await storageTaskSnapshot.ref.getDownloadURL();

                      setState((){ avatarImgURL = imgURL; });

                    // } else {displaySnackBar('Item Name is required for adding image');}
                  },

                  child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 50.0,
                      backgroundImage: NetworkImage(avatarImgURL),
                    ),
                  ),
                  SizedBox(height: 40.0),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent),),
                  child: Text('Update Item', style: GoogleFonts.robotoCondensed(color: Colors.white, fontSize: 16.0),),
                  onPressed: () async {
                    if (avatarImgURL != '') {
                    if(_formKey.currentState!.validate()){
                    setState(() {
                      loading = true;
                    });
                    var _name, _desc, _price, _imgURL;
                    if (name == '') {_name = widget.data.name;} else {_name = name;}
                    if (desc == '') {_desc = widget.data.desc;} else {_desc = desc;}
                    if (price == 0.0) {_price = widget.data.price;} else {_price = price;}
                    if (avatarImgURL == '') {_imgURL = widget.data.imgURL;} else {_imgURL = avatarImgURL;}
                    await FirebaseFirestore.instance.collection('chefs').doc(userid).collection('menu').doc(widget.data.id).update({
                      'itemName' : _name,
                      'itemDesc' : _desc,
                      'itemPrice' : _price,
                      'imgURL' : _imgURL,
                    });
                    Navigator.of(context).pop();
                  }} else {displaySnackBar('All fields are mandatory');}
                  }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  displaySnackBar(errtext) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errtext),
        duration: const Duration(seconds: 5),
      ));
  }
  _deleteItem() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Are you sure you want to delete the item?'),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'YES',
        onPressed: () async {
          setState(() {loading = true;});
          await FirebaseFirestore.instance.collection('chefs').doc(userid).collection('menu').doc(widget.data.id).delete();
          await FirebaseFirestore.instance.collection('chefs').doc(userid).update({
            'menuitemscount': FieldValue.increment(-1),
          });
          Navigator.of(context).pop();
        }
      )
    ));
  }
}