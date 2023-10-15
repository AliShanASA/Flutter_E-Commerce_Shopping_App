// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, unused_local_variable


import 'package:fashion_ecommerce_app/model/base_model.dart';
import 'package:fashion_ecommerce_app/screens/ProductDetail/details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';


class Bestpairmatch extends StatefulWidget {
  final String imageUrl;
  final String category; 
  final String color;
  final String type;
  final String season; 

  const Bestpairmatch({
    Key? key,
    required this.imageUrl,
    required this.color, 
    required this.category,
    required this.type,
    required this.season, 

  }) : super(key: key);

  @override
  _BestpairmatchState createState() => _BestpairmatchState();
}

class _BestpairmatchState extends State<Bestpairmatch> {
 
 
  String imageUrl = "";
  String category = "";
  String color = "";
  String type = "";
  String season = "";
  List<dynamic> requiredLinks= [];
  List<dynamic> watchesLinks = [];
  List<dynamic> shoesLinks = [];
  bool isLoading = false;
  bool isUserLoggedIn = false; 

   bool checkUserLoggedIn() {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser != null;
  }

  @override
  void initState() {
    imageUrl = widget.imageUrl;
    category = widget.category;
    color = widget.color;
    type = widget.type;
    season = widget.season;
    isUserLoggedIn = checkUserLoggedIn();
    debugPrint(category.toString());
    debugPrint(color.toString());
    debugPrint(type.toString());
    

    fetchBestMatch(type, category, color, season);
    debugPrint(imageUrl.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    return Material(
      child: Scaffold(
        appBar: _buildAppBar(context),
       // bottomNavigationBar: ElevatedButton(onPressed: (){},child:  Text("Back"),style: ElevatedButton.styleFrom(backgroundColor: Colors.black, ),),
        body:  FutureBuilder(
        future: fetchBestMatch(type, category, color, season),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is being fetched, show a circular progress indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Handle any errors that occurred during fetching
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // Data fetched successfully, display the content
            return 
        Stack(   
          children: [
               Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/account_background1.jpg'),
                fit: BoxFit.cover, // Adjust the fit as needed
              ),
            ),
          ),
        SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                        height: 250,
                        child: Stack(
                          children: [  
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                  ),
                              ),
                            ),
       
                          ],
                        ),
                  ),
                ),
                 SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: required_products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Details(data: product, isCameFromMostPopularPart: false, isUserLoggedIn: isUserLoggedIn, isCameFromLogIn: false, fromWhere: 10)));
                        },
                        child: Image.network(product.imageUrl, width: 90, height: 120),
                      ),
                    );
                  }).toList(),
                ),
              ) ,
                SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: watches_products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Details(data: product, isCameFromMostPopularPart: false, isUserLoggedIn: isUserLoggedIn, isCameFromLogIn: false, fromWhere: 10)));
                        },
                        child: Image.network(product.imageUrl, width: 90, height: 120),
                      ),
                    );
                  }).toList(),
                ),
              )
              ,
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: shoes_products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Details(data: product, isCameFromMostPopularPart: false, isUserLoggedIn: isUserLoggedIn, isCameFromLogIn: false, fromWhere: 10)));
                        },
                        child: Image.network(product.imageUrl, width: 90, height: 120),
                      ),
                    );
                  }).toList(),
                ),
              )
              ,

               ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    ),
  );
}
  Widget buildItem(BuildContext context, int index, List<dynamic> imageLinks) {
    var size = MediaQuery.of(context).size;
  return Container(
      width: size.width * 0.5,
      height: size.height * 0.25,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        image: DecorationImage(
          image: NetworkImage(imageLinks[index]),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 4,
            color: Color.fromARGB(61, 0, 0, 0),
          )
        ],
      ),
    );
}
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Your Best Match",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () {
        
            Navigator.pop(context);
         
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

    List<BaseModel> watches_products = [];
    List<BaseModel> shoes_products = [];
    List<BaseModel> required_products= [];

   Future<void> fetchBestMatch(String type, String category, String color, String season) async {
  final url = Uri.parse('https://1d16-2404-3100-1809-9eae-55b-649-33ad-bbb7.ngrok.io/get_best_match');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'type': type,
      'category': category,
      'color': color,
      'season': season, 
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    // Extract the lists of products directly
    List<dynamic> watches = jsonResponse['Watches'] ?? [];
    List<dynamic> shoes = jsonResponse['Shoes'] ?? [];
    List<dynamic> required = jsonResponse['Required'] ?? [];

    // Parse and add products to respective lists
    watches_products = watches.map((product) => BaseModel.fromJson(product)).toList();
    shoes_products = shoes.map((product) => BaseModel.fromJson(product)).toList();
    required_products = required.map((product) => BaseModel.fromJson(product)).toList();

    // Debug print the products in their respective lists
    debugPrint('Watches Products: $watches_products');
    debugPrint('Shoes Products: $shoes_products');
    debugPrint('Required Products: $required_products');
  } else {
    // Handle error cases
    debugPrint('HTTP Error: ${response.statusCode}');
  }
}


}
