class OrderStatsData {
  int ordersActive, ordersClosed;
  double billedAmt, realizedAmt;

  OrderStatsData({
    required this.ordersActive, required this.ordersClosed, required this.billedAmt, required this.realizedAmt
  });
}