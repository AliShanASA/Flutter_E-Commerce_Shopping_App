// ignore_for_file: camel_case_types, avoid_print, sort_child_properties_last, deprecated_member_use, use_build_context_synchronously, avoid_function_literals_in_foreach_calls, unused_local_variable, non_constant_identifier_names

import 'package:animate_do/animate_do.dart';
import 'package:fashion_ecommerce_app/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/base_model.dart';


class iterestCategorySelectionScreen extends StatefulWidget {
  final Set<String> selectedCategoryNames;
  const iterestCategorySelectionScreen({Key? key, required this.selectedCategoryNames}) : super(key: key);

  @override
  State<iterestCategorySelectionScreen> createState() =>
      _iterestCategorySelectionScreenState();
}

class _iterestCategorySelectionScreenState
    extends State<iterestCategorySelectionScreen> {
      Set<String> selectedCategoryNames = {};
  List<String> categories = [
   'T-Shirts',
    'Dress Shirts',
    'Casual Shirts',
    'Dress Pants',
    'Jeans',
    'Shorts',
    'Suits'
  ]; // List of categories
  List<bool> selectedCategories = List.filled(7, false);
  bool isLoading = false;

  // Map of category images
  Map<String, String> categoryImages = {
    'Dress Shirts': 'assets/dress_shirt.png',
    'Casual Shirts': 'assets/casual_shirts.png',
    'Jeans': 'assets/jeans.png',
    'Dress Pants': 'assets/dress_pants.png',
    'T-Shirts': 'assets/t_shirts.png',
    'Suits': 'assets/suit.png',
    'Shorts': 'assets/shorts.png',
  };
  String model = '';
    Future<void> getDeviceInfo() async {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo;

      try {
        androidInfo = await deviceInfo.androidInfo;
        AndroidBuildVersion version = androidInfo.version;
        model = androidInfo.model;
        print('Running on $model');
      } catch (e) {
        print('Error getting device info: $e');
      }
    }
  @override
  void initState() {
    super.initState();
    selectedCategoryNames = widget.selectedCategoryNames;
    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 70),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Smart",
                            style: textTheme.headline1,
                            children: [
                              TextSpan(
                                text: " Shopping",
                                style: textTheme.headline1?.copyWith(
                                  color: Colors.blueAccent,
                                  fontSize: 45,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50,),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: const Center(
                      child: Text(
                        "Tell Us About Your Interests",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1100),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        categories.length,
                        (index) => _buildCategoryButton(categories[index], index),
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1200),
                    child: Row(
                      children: [
                        const SizedBox(width: 160),
                  
                        // Add some space between the buttons
                        FloatingActionButton(
                          onPressed: () async{
                            
                            if(selectedInterest.isEmpty){
                               showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Selection Required'),
                                                content: const Text(
                                                    'Please select atleast one of your interests'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      'Ok',
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                  ),
                                                 
                                                ],
                                              );
                                            },
                                          );
                            } else {
                           
                              setState(() {
                                    isLoading = true; // Show circular progress indicator
                                  });
                              await fetchAndSaveData(selectedCategoryNames, selectedInterest, model);
                              setState(() {
                                isLoading = false;
                              });

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainWrapper(
                                  isUserLoggedIn: false,
                                ), // Replace with the actual screen you want to navigate to
                              ),
                            );
                          }
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.lightBlue,
                            size: 30.0, // Adjust the size of the icon
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
           if (isLoading)
           const Center(
              child: CircularProgressIndicator(
                color: Colors.blue, // Customize the color if needed
              ),
            ),
        ],
      ),
    );
  }

  Set<String> selectedInterest = {};
  Widget _buildCategoryButton(String category, int index) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategories[index] = !selectedCategories[index];
           if (selectedCategories[index]) {
                selectedInterest.add(category);
              } else {
                // If it's deselected, remove its name (if it exists)
                selectedInterest.remove(category);
              }
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor:
            selectedCategories[index] ? Colors.lightBlue : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selectedCategories[index] ? Colors.white : Colors.white,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            categoryImages[category]!, // Display category image
            width: 60,
            height: 60,
          ),
          const SizedBox(width: 8),
          Text(category),
        ],
      ),
    );
  }

Future<void> fetchAndSaveData(
  Set<String> selectedCategoryNames,
  Set<String> selectedInterest,
  String model,
) async {
  
   List<BaseModel> products = [];
     try {
     
   QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('products2').get();

       snapshot.docs.forEach((doc) {
      final BaseModel product = BaseModel.fromMap(doc.data());
      final String category = doc['category'] as String;
      final String type = doc['type'] as String;

      if (selectedCategoryNames.contains(category) && selectedInterest.contains(type)) {
        products.add(product);
      }
    });
    print(products.toString());

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference dataCollection = firestore.collection('GuestUsers').doc(model).collection('data');
    CollectionReference<Map<String, dynamic>> data =
        FirebaseFirestore.instance.collection('GuestUsers');
     await data.doc(model).set({
      // Add other data if needed
      'field1': 'value1',
    });

    for (final product in products) {
      final Map<String, dynamic> productData = product.toMap(); // Assuming BaseModel has a toMap() method
      await dataCollection.doc().set(productData);
    }

    print("Data saved successfully");
   
  } catch (e) {
    print('Error fetching and saving data: $e');
    
  }
}

}
