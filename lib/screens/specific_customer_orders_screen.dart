// ignore_for_file: file_names, must_be_immutable, avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/order_model.dart';
import '../utils/constant.dart';
import '../utils/enums.dart';
import 'check_single_order_screen.dart';
class SpecificCustomerOrderScreen extends StatelessWidget {
  final String userId;
  final String customerName;

  const SpecificCustomerOrderScreen({
    super.key,
    required this.userId,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customerName),
        backgroundColor: AppConstant.appMainColor,
      ),

      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)              // 🔥 USER ID
            .collection('Orders')     // 🔥 SUBCOLLECTION
            .orderBy('orderDate', descending: true)
            .get(),

        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching orders'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {

              final doc = orders[index];

              // 🔥 DIRECT MODEL USE
              final order = OrderModel.fromSnapshot(doc);

              return Card(
                elevation: 5,
                margin: EdgeInsets.all(8),

                child: ListTile(

                  onTap: () {
                    Get.to(() => CheckSingleOrderScreen(
                      docId: doc.id,
                      orderModel: order,
                    ));
                  },

                  leading: CircleAvatar(
                    backgroundColor: AppConstant.appScendoryColor,
                    backgroundImage: order.items.isNotEmpty &&
                        order.items[0].image != null &&
                        order.items[0].image!.isNotEmpty
                        ? NetworkImage(order.items[0].image!)
                        : null,
                    child: order.items.isEmpty
                        ? Icon(Icons.shopping_bag)
                        : null,
                  ),

                  // 🛒 FIRST PRODUCT NAME
                  title: Text(
                    order.items.isNotEmpty
                        ? order.items[0].title
                        : "No Item",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // 📦 DETAILS
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total: ₹${order.totalAmount}"),
                      Text("Status: ${order.orderStatusText}"),
                      Text("Date: ${order.formattedOrderDate}"),
                    ],
                  ),

                  trailing: InkWell(
                    onTap: () {
                      showBottomSheet(
                        orderDocId: doc.id, userId: order.userId,
                      );
                    },
                    child: Icon(Icons.more_vert),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🔥 STATUS UPDATE WITH ENUM
  void showBottomSheet({
    required String userId,
    required String orderDocId,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              "Update Order Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [

                // 🔴 Pending
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userId)
                        .collection('Orders')
                        .doc(orderDocId)
                        .update({
                      'status': OrderStatus.pending.toString(),
                    });

                    Get.back();
                  },
                  child: Text("Pending"),
                ),

                // 🔵 Processing
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userId)
                        .collection('Orders')
                        .doc(orderDocId)
                        .update({
                      'status': OrderStatus.processing.toString(),
                    });

                    Get.back();
                  },
                  child: Text("Processing"),
                ),

                // 🟢 Delivered
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userId)
                        .collection('Orders')
                        .doc(orderDocId)
                        .update({
                      'status': OrderStatus.delivered.toString(),
                      'deliveryDate': DateTime.now(), // 🔥 BONUS
                    });

                    Get.back();
                  },
                  child: Text("Delivered"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}