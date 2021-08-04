
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_chef/models/chefStoreData.dart';

class StoreServices {
  
  //Get Store Details from DB and Stream it

    Stream<ChefStoreData> get storeData {
      return FirebaseFirestore.instance.collection('chefs').doc(uid).snapshots()
      .map(_storedata);
    }

  // User root data stream
    ChefStoreData _storedata(DocumentSnapshot snapshot) {
    
        return ChefStoreData(
          
          id: snapshot.id,
          stActive: (snapshot.data() as dynamic)['active'],
          stName: (snapshot.data() as dynamic)['storename'],
          stPhNo: (snapshot.data() as dynamic)['phno'],
          stEmail: (snapshot.data() as dynamic)['email'],
          stRating: (snapshot.data() as dynamic)['rating'],
          stUsrName: (snapshot.data() as dynamic)['usrname'],
          stMnuCount: (snapshot.data() as dynamic)['menuitemscount'],
          stMnuInactive: (snapshot.data() as dynamic)['menuitemsinactive'],
          stDoorNo: (snapshot.data() as dynamic)['door'],
          stSociety: (snapshot.data() as dynamic)['society'],
         
        );

    }
}