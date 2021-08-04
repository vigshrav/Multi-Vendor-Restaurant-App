import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_chef/screens/auth/otp.dart';
import 'package:home_chef/screens/auth/signin.dart';
import 'package:home_chef/services/fire_auth.dart';
import 'package:home_chef/widgets/spinner.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  late String phoneNo, uname, email, usrType, verificationId, smsCode;
  
  bool toggleval = false;
  bool loading = false;

  //To Validate email
  String? validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }  
  
  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: HexColor('#2D7A98'),
      //   title: Text('Register', style: GoogleFonts.openSans(fontSize: 30.0) ,),
      //   centerTitle: true,),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container(
            //     height: 100.0,
            //     width: 100.0,
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage(
            //             'assets/login_signup_screen_logo.png'),
            //         fit: BoxFit.fill,
            //       ),
            //       shape: BoxShape.rectangle,
            //     ),
            //   ),
              SizedBox(height: 50.0,),
            Form(key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.alternate_email, color: Colors.redAccent,),
                      labelText: 'username',
                      labelStyle: GoogleFonts.robotoCondensed(color: Colors.redAccent,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(width: 2.0, color: Colors.redAccent,)
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    //obscureText: true,
                    validator: (val) => val!.isEmpty ? 'Please provide a username' : null,
                    onChanged: (val) {
                      setState(() => uname = val);
                    }
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.mail, color: Colors.redAccent,),
                      labelText: 'email',
                      labelStyle: GoogleFonts.robotoCondensed(color: Colors.redAccent,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(width: 2.0, color: Colors.redAccent,)
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    //obscureText: true,
                    validator: (val) => val!.isEmpty ? 'Please provide an email id' : validateEmail(val),
                    onChanged: (val) {
                      setState(() => email = val);
                    }
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Colors.redAccent,),
                      labelText: 'Phone Number',
                      labelStyle: GoogleFonts.robotoCondensed(color: Colors.redAccent,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(width: 2.0, color: Colors.redAccent,)
                      ),
                    ),
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    validator: (val) => val!.isEmpty ? 'Please provide a valid phone number to login' : null,
                    onChanged: (val) {
                      setState(() => phoneNo = val);
                    }
                  ),
                  SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Home Chef', style: GoogleFonts.robotoCondensed(color: Colors.redAccent, fontSize: 16.0),),
                        SizedBox(width: 15.0,),
                        (Switch(inactiveThumbColor: Colors.redAccent, inactiveTrackColor: Colors.redAccent.shade100, activeTrackColor: Colors.red.shade100, activeColor: Colors.redAccent, 
                        value: toggleval, onChanged: (val) {setState(() { toggleval = val;});})),
                        SizedBox(width: 15.0,),
                        Text('Foodie', style: GoogleFonts.robotoCondensed(color: Colors.redAccent, fontSize: 16.0),),
                      ],
                    ),
                    SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent,),),
                    child: Text('Register', style: GoogleFonts.robotoCondensed(fontSize: 18),),
                    onPressed: () async {
                      if(_formKey.currentState!.validate()){
                        setState(() {
                          loading = true;
                        });
                        var inPhoneNo = '+91 '+ phoneNo.trim();
                        await verifyPhone(inPhoneNo);
                      }
                    }
                  ),
                  TextButton(
                    child: Text('Sign In', style: GoogleFonts.robotoCondensed(color: Colors.redAccent,),),
                    onPressed: () async {
                      await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignIn())
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
  Future<void> verifyPhone(phoneNo) async {
    
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      _auth.signIn(authResult);
    };

    final PhoneVerificationFailed verificationfailed =
        (FirebaseAuthException authException) {
      //print('${authException.message}');
      displaySnackBar('Validation error, please try again later');
    };

    final void Function(String verId, [int? forceResend]) smsSent = (String verId, [int? forceResend]) async {
      this.verificationId = verId;
      await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => OTP(verId, 'signup', uname, phoneNo, email, toggleval)));           
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        //timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  displaySnackBar(errtext) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errtext),
        duration: const Duration(seconds: 3),
      ));
  }


}