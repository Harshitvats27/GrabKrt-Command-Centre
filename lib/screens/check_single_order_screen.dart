// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../utils/constant.dart';

class CheckSingleOrderScreen extends StatelessWidget {
  String docId;
  OrderModel orderModel;

  CheckSingleOrderScreen({
    super.key,
    required this.docId,
    required this.orderModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: Text('Order Details'),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🛒 ITEMS
              Text(
                "Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              ListView.builder(
                itemCount: orderModel.items.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {

                  final item = orderModel.items[index];

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 6),

                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: item.image != null &&
                            item.image!.isNotEmpty
                            ? NetworkImage(item.image!)
                            : null,
                        child: item.image == null
                            ? Icon(Icons.shopping_bag)
                            : null,
                      ),

                      title: Text(
                        item.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Price: ₹${item.price}"),
                          Text("Qty: ${item.quantity}"),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 20),

              /// 💰 TOTAL
              Text(
                "Total Amount: ₹${orderModel.totalAmount}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              /// 📦 STATUS
              Text("Status: ${orderModel.orderStatusText}"),

              SizedBox(height: 10),

              /// 📅 DATE
              Text("Order Date: ${orderModel.formattedOrderDate}"),

              Divider(height: 30),

              /// 👤 CUSTOMER DETAILS (🔥 FIXED)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(orderModel.userId)
                    .get(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text("User not found");
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>;

                  // 🔥 ADDRESS from ORDER
                  final address = orderModel.address;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Customer Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 10),

                      /// 👤 NAME (Users)
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                          "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}",
                        ),
                      ),

                      /// 📞 PHONE (Users)
                      ListTile(
                        leading: Icon(Icons.phone),
                        title: Text(userData['phoneNumber'] ?? "N/A"),
                      ),

                      /// 📍 ADDRESS (Orders)
                      ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text(
                          address == null
                              ? "No Address"
                              : "${address.street ?? ''}, "
                              "${address.city ?? ''}, "
                              "${address.state ?? ''}, "
                              "${address.country ?? ''} - "
                              "${address.postalCode ?? ''}",
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}