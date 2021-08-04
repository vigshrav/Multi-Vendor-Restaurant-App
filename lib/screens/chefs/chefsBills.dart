import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChefsBills extends StatefulWidget {
  const ChefsBills({ Key? key }) : super(key: key);

  @override
  _ChefsBillsState createState() => _ChefsBillsState();
}

class _ChefsBillsState extends State<ChefsBills> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Bills', style: GoogleFonts.robotoCondensed(fontSize: 28.0,),),
        centerTitle: true,
      ),
      body: Center(child: Text('Bills Page'),),
    );
  }
}