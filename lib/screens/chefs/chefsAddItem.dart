import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/widgets/spinner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ChefsAddItem extends StatefulWidget {
  const ChefsAddItem({ Key? key }) : super(key: key);

  @override
  _ChefsAddItemState createState() => _ChefsAddItemState();
}

class _ChefsAddItemState extends State<ChefsAddItem> {

  final _formKey = GlobalKey<FormState>();
  String name = ''; 
  String desc = '';
  late double price;
  bool loading = false;
  var avatarImgURL = '';

  var userid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    bool avatarImgavailable;
    if (avatarImgURL != '') {avatarImgavailable = true;} else {avatarImgavailable = false;}
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text('New Menu Item', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0,),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    // prefixIcon: Icon(Icons.alternate_email, color: Colors.black54),
                    labelText: 'Item Name',
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
                  decoration: InputDecoration(
                    // prefixIcon: Icon(Icons.alternate_email, color: Colors.black54,),
                    prefixText: '\u{20B9}   ',
                    labelText: 'Price',
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
                  decoration: InputDecoration(
                    // prefixIcon: Icon(Icons.alternate_email, color: Colors.black54,),
                    labelText: 'What\'s special ?',
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

                    if (name != ''){
                    
                      final PickedFile? galImage = await ImagePicker().getImage(source: ImageSource.gallery);
                      final File image = File(galImage!.path);
                      displaySnackBar('Uploading Image. Hold on.');
                      firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref().child('chefs/$userid/$name');                    
                      firebase_storage.TaskSnapshot storageTaskSnapshot = await storageRef.putFile(image);
                      var imgURL = await storageTaskSnapshot.ref.getDownloadURL();

                      setState((){ avatarImgURL = imgURL; });

                    } else {displaySnackBar('Item Name is required for adding image');}
                  },

                  child: avatarImgavailable
                    ? CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 50.0,
                        backgroundImage: NetworkImage(avatarImgURL),
                      )
                      : CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        radius: 50.0,
                        child: Icon(Icons.photo_camera, size: 60.0, color: Colors.white),
                      )
                  ),
                  SizedBox(height: 40.0),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent),),
                  child: Text('Add Menu Item', style: GoogleFonts.robotoCondensed(color: Colors.white, fontSize: 16.0),),
                  onPressed: () async {
                    if (avatarImgURL != '') {
                    if(_formKey.currentState!.validate()){
                    setState(() {
                      loading = true;
                    });
                    await FirebaseFirestore.instance.collection('chefs').doc(userid).collection('menu').add({
                      'itemName' : name,
                      'itemDesc' : desc,
                      'itemPrice' : price,
                      'imgURL' : avatarImgURL,
                      'rating' : 0.0,
                      'active' : true,
                    });
                    await FirebaseFirestore.instance.collection('chefs').doc(userid).update({
                      'menuitemscount': FieldValue.increment(1),
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
}