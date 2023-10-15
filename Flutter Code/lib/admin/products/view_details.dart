// ignore_for_file: library_private_types_in_public_api, unused_import

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class ViewDetails extends StatefulWidget {
  final String imageUrl;
  final String type;
  final String category;
  final String season;
  final double price;
  final String name;

  const ViewDetails({
    Key? key,
    required this.imageUrl,
    required this.type,
    required this.category,
    required this.season,
    required this.price,
    required this.name,
  }) : super(key: key);

  @override
  _ViewDetailsState createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  String imageUrl = '';
  String type = '';
  String category = '';
  String season = '';
  double price = 0.0;
  String name = '';

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
    type = widget.type;
    category = widget.category;
    season = widget.season;
    price = widget.price;
    name = widget.name;
  }
AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Details",
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
    return Scaffold(
     appBar: _buildAppBar(context),
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
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Image.network(
                  widget.imageUrl,
                  width: 389.0, // Set the desired width
                  height: 300.0, // Set the desired height
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Name:                                   ${widget.name}",
                // ignore: prefer_const_constructors
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
           
            ListTile(
              title: Text(
                "Type:                                         ${widget.type}",
                style: const TextStyle(
                  fontSize: 18.0, // Adjust the font size
                  fontWeight: FontWeight.bold, // Add bold styling
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Category:                                     ${widget.category}",
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Season:                                          ${widget.season}",
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Price:                                             \$${widget.price.toStringAsFixed(2)}", // Format the price
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
     ] ),
    );
  }
}
