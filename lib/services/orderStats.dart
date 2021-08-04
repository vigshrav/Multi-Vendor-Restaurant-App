
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_chef/models/orderStatsData.dart';

class OrderStatsServices {

  final String todayID, uid;
  OrderStatsServices({ required this.todayID, required this.uid });
  
  Stream<OrderStatsData> get orderStatsData {
    return FirebaseFirestore.instance.collection('chefs').doc(uid).collection('orderStats').doc(todayID).snapshots()
    .map(_orderStatsData);
  }

  OrderStatsData _orderStatsData(DocumentSnapshot snapshot) {

    return OrderStatsData(
      ordersActive: (snapshot.data() as dynamic)['activeOrders'],
      ordersClosed: (snapshot.data() as dynamic)['closedOrders'],
      billedAmt: (snapshot.data() as dynamic)['billValue'],
      realizedAmt: (snapshot.data() as dynamic)['amtRealized'],
    );

  }

}