// ignore_for_file: prefer_const_declarations, no_leading_underscores_for_local_identifiers, avoid_function_literals_in_foreach_calls, avoid_print, await_only_futures, unused_local_variable, depend_on_referenced_packages

import 'package:animate_do/animate_do.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import '../../model/order_model.dart';

class OrderDetailsNew extends StatefulWidget {
  const OrderDetailsNew({super.key, required this.orderNo});
  final String orderNo;

  @override
  State<OrderDetailsNew> createState() => _OrderDetailsNewState();
}

class _OrderDetailsNewState extends State<OrderDetailsNew> {
  List<RecentOrder> _recentOrders = [];
  bool isLoading = false;

  Future<List<RecentOrder>> fetchData() async {
    final user = await FirebaseAuth.instance.currentUser;
    List<RecentOrder> products = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('OrdersForAdmin')
          .where('orderNo',
              isEqualTo: widget.orderNo) // Filter for isCompleted = false
          .get();

      snapshot.docs.forEach((doc) {
        RecentOrder product = RecentOrder.fromMap(doc.data());
        products.add(product);
      });

      // Sort the products list by dateTime in descending order (latest first)
      products.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      print("Data Fetched Successful");
    } catch (e) {
      print('Error fetching data: $e');
    }

    return products;
  }

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        _recentOrders = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      // bottomNavigationBar: _buildNavBar(),
      body: Stack(
        children:[ 
           Container( decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/account_background1.jpg'),
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
              ),), 
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text(
                    "Order Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    widget.orderNo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FadeIn(
                delay: const Duration(milliseconds: 800),
                child: _recentOrders.isEmpty
                    ? const Center(
                        child: Text(
                          "No orders yet!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _recentOrders.length,
                        itemBuilder: (context, index) {
                          final sizeString =
                              getSizeString(_recentOrders[index].size);
                          final colorString =
                              getColorString(_recentOrders[index].color);
      
                          final formattedDateTime =
                              DateFormat('yyyy-MM-dd        HH:mm:ss')
                                  .format(_recentOrders[index].dateTime);
      
                          return ListTile(
                            leading: Image.network(
                              _recentOrders[index].itemPic,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                                "Item Name:   ${_recentOrders[index].itemName}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Size:               $sizeString"),
                                Text(
                                    "Quantity:      ${_recentOrders[index].quantity}"),
                                Text("Color:              $colorString"),
                                Text(
                                    "Price:              \$${_recentOrders[index].totalPrice}"),
                                Text("Placed On:    $formattedDateTime"),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Shipping Address",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _recentOrders.isNotEmpty
                          ? _recentOrders[0].shippingAddress
                          : '',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null // Disable the button when isLoading is true
                          : () {
                              if (_recentOrders[0].isCompleted == false) {
                                sendEmail(_recentOrders[0].userEmail,
                                        widget.orderNo)
                                    .then((sent) {
                                  setState(() {
                                    isLoading = true; // Show loading indicator
                                  });
                                  if (sent) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Order Confirmation!'),
                                          content: const Text(
                                              'An email has been sent to the customer email address.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Order Confirmation!'),
                                          content: const Text(
                                              'Failed to send the order confirmation email.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(
                                                    color: Colors.orange),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                });
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Order Confirmation!'),
                                      content: const Text(
                                          'Order has been completed before!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'OK',
                                            style:
                                                TextStyle(color: Colors.orange),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Confirm Order",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    ]  ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Order Details",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
    icon: const Icon(
      Icons.arrow_back, // Use the back arrow icon
      color: Colors.white,
      size: 30,
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
     
    );

  }

  String getSizeString(int size) {
    switch (size) {
      case 0:
        return "S";
      case 1:
        return "M";
      case 2:
        return "L";
      case 3:
        return "XL";
      case 4:
        return "XXL";
      default:
        return "N/A";
    }
  }

  // Function to get the human-readable color based on the integer value
  String getColorString(int color) {
    switch (color) {
      case 0:
        return "White";
      case 1:
        return "Black";
      case 2:
        return "Blue";
      case 3:
        return "Green";
      case 4:
        return "Grey";
      case 5:
        return "Blue Grey";
      case 6:
        return "Yellow";
      default:
        return "N/A";
    }
  }

  Future<bool> sendEmail(String userEmail, String orderNo) async {
    String username = 'alishan3331212112@gmail.com';
    String password = 'lzfwfoxqawgjfyeo';
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Smart Shopping')
      ..recipients.add(userEmail)
      ..subject = 'Order Confirmation!'
      ..text = 'Your order is on the way. Thank you for shopping with us!';

    try {
      final sendReport = await send(message, smtpServer);
      try {
        // Update the isCompleted value to true in "orders" collection
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(userEmail)
            .collection('data')
            .where('orderNo', isEqualTo: orderNo)
            .get()
            .then((snapshot) {
          for (QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            doc.reference.update({'isCompleted': true});
          }
        });

        // Update the isCompleted value to true in "CompletedOrders" collection
        await FirebaseFirestore.instance
            .collection('CompletedOrders')
            .doc(userEmail)
            .collection('data')
            .where('orderNo', isEqualTo: orderNo)
            .get()
            .then((snapshot) {
          for (QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            doc.reference.update({'isCompleted': true});
          }
        });

        await FirebaseFirestore.instance
            .collection('OrdersForAdmin')
            .where('orderNo', isEqualTo: orderNo)
            .get()
            .then((snapshot) {
          for (QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            doc.reference.update({'isCompleted': true});
          }
        });

        print('Order status updated successfully');
      } catch (e) {
        print('Error updating order status: $e');
      }
      return true;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
}
