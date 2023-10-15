// ignore_for_file: unused_local_variable, avoid_print, avoid_function_literals_in_foreach_calls, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/admin/orders/order_details_new.dart';


import 'package:flutter/material.dart';



class ManageOrders extends StatefulWidget {
  const ManageOrders({super.key});

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  List<Map<String, dynamic>> userOrderInfos = [];
  bool isLoading = true;

  Future<void> fetchData() async {
     setState(() {
    isLoading = true; // Show loading indicator
  });
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('OrdersForAdmin').get();
      print(": TOTAL ORDERS: ${snapshot.docs.length}");

      // Create a map to store order numbers as keys and timestamps as values
      Map<String, Timestamp> orderTimestamps = {};

      // Iterate through the fetched documents and populate the map
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String orderNo = data['orderNo'];
        Timestamp timestamp = data['timestamp'];

        // Update the map with the latest timestamp for each order number
        if (orderTimestamps.containsKey(orderNo)) {
          if (timestamp.compareTo(orderTimestamps[orderNo]!) > 0) {
            orderTimestamps[orderNo] = timestamp;
          }
        } else {
          orderTimestamps[orderNo] = timestamp;
        }
      }

      // Create a list of order numbers and their latest timestamps
      List<Map<String, dynamic>> fetchedUserOrderInfos = [];
      orderTimestamps.forEach((orderNo, timestamp) {
        fetchedUserOrderInfos.add({
          'orderNo': orderNo,
          'timestamp': timestamp,
        });
      });

      // Sort the list by timestamp in descending order
      fetchedUserOrderInfos.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      setState(() {
        userOrderInfos = fetchedUserOrderInfos; // Update the state
      });

      print("Data Fetched Successful");
      print("Number of userOrderInfos: ${userOrderInfos.length}");
       setState(() {
      isLoading = false; // Data fetched, loading indicator should be hidden
    });
    } catch (e) {
      print('Error fetching data: $e');
       setState(() {
      isLoading = false; // Data fetched, loading indicator should be hidden
    });
    }
  }

  Future<void> deleteOrder(String orderNo) async {
  try {
    // Delete orders from the "OrdersForAdmin" collection using the provided orderNo
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('OrdersForAdmin')
        .where('orderNo', isEqualTo: orderNo)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // Remove the deleted order from the userOrderInfos list
    setState(() {
      userOrderInfos.removeWhere((orderInfo) => orderInfo['orderNo'] == orderNo);
    });

    print("Order deleted successfully");
  } catch (e) {
    print('Error deleting order: $e');
  }
}


  @override
  void initState() {
    super.initState();
    fetchData();
  }
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Customer Orders",
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
       appBar: _buildAppBar(context),
      body:Stack(
        children:[ 
           Container( decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/account_background1.jpg'),
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
              ),), 
          isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue,)) // Show loading indicator
          : userOrderInfos.isEmpty
            ?  const Center(
                child:  Text(
                  "No orders yet!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: userOrderInfos.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> userOrderInfo = userOrderInfos[index];
      
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  OrderDetailsNew(orderNo: userOrderInfo['orderNo'],)));
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Order No:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userOrderInfo['orderNo'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        title: Text('Order Date: ${userOrderInfo['timestamp'].toDate().toString()}'),
                        trailing: GestureDetector(
                          onTap: () {
                             deleteOrder(userOrderInfo['orderNo']);
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
     ] ),
    );
  }
}