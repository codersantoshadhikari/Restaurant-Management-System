// services/order_service.dart

import '../models/order.dart';

class OrderService {
  List<Order> orderList = [];

  // Place order
  void placeOrder(Order order) {
    orderList.add(order);
    print("📝 Order added for Table ${order.tableNumber}");
  }

  // Show all orders
  void showOrders() {
    print("\n📦 Orders:");
    for (var order in orderList) {
      print("Table ${order.tableNumber}:");
      for (var item in order.items) {
        print("- ${item.itemName} x${item.quantity} = ₹${item.total.toStringAsFixed(2)}");
      }
      print("Subtotal: ₹${order.subtotal.toStringAsFixed(2)}, GST: ₹${order.gst.toStringAsFixed(2)}, Total: ₹${order.total.toStringAsFixed(2)}");
      print("---------------------------------");
    }
  }

  List<Order> getOrders() {
    return orderList;
  }
}
