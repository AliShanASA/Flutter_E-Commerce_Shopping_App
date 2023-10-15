// ignore_for_file: avoid_print, unused_local_variable

import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/base_model.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final nameController = TextEditingController();
   final imageUrlController = TextEditingController();
  final priceController = TextEditingController();
  String selectedCategory = 'None';
  String selectedType = 'None';
  String selectedColors = 'None';
  String selectedSeason  = 'None';
  

  List<String> categories = ['None', 'Men', 'Women', 'Kid'];
   List<String> seasons = ['None', 'Spring', 'Summer', 'Fall', 'Winter'];
  List<String> types = [
    'None',
    'T-Shirts',
    'Dress Shirts',
    'Casual Shirts',
    'Dress Pants',
    'Jeans',
    'Shorts',
    'Suits'
  ];

   List<String> colors = [
    'None',
    'Blue',
    'Black',
    'Brown', 
    'Green',
    'White',
    'Yellow',
    'Orange',
    'Sky Blue',
    'Pink', 
    'Purple', 
    'Grey', 
    'Red',
    
  ];

  bool isImagePicked = false;
  final ImagePicker _imagePicker = ImagePicker();


   Future<void> captureImageFromCamera() async {
    Uint8List? img = await pickImage(ImageSource.gallery);

    if(img != null){
      setState(() {
        isImagePicked = true;
      });
      String imageUrl = await uploadImageToFirebaseStorage(img);
      imageUrlController.text = imageUrl; 
    setState(() {
      isImagePicked = false;
    });


    }  
   }


   Future<Uint8List?> pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image != null) {
      return await image.readAsBytes();
    }
    return null;
  }

  Future<String> uploadImageToFirebaseStorage(Uint8List imageBytes) async {
    String imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload the image to Firebase Storage
    try {
      final firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images/$imageName');
      final firebase_storage.UploadTask uploadTask = ref.putData(imageBytes);

      final firebase_storage.TaskSnapshot storageTaskSnapshot =
          await uploadTask;

      final imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
      print('Image uploaded to Firebase Storage: $imageUrl');

      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      rethrow;
    }
  }

 AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Add Product",
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
        children: [
           Container( decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/account_background1.jpg'),
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
              ),), 
          Padding(
          padding: const EdgeInsets.all(25.0),
          child: ListView(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image Url'),
              ),
              Padding(
                padding:const EdgeInsets.only(left: 140),
                child: Row(
                          children: [
                Checkbox(
                value: isImagePicked,
                onChanged: isImagePicked
                    ? (newValue) {
                      }
                    : null, // Disable the checkbox if isImagePicked is false
              ),
                GestureDetector(
                  onTap: captureImageFromCamera,
                  child: const Text(
                'Choose Image from Gallery',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline, // Add underline
                ),
              ),
                ),
                          ],
                        ),
              ),

               TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  const Text('Select Category: '),
                  const Spacer(),
                  DropdownButton<String>(
                    value: selectedCategory.isNotEmpty ? selectedCategory : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: categories.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Select Type: '),
                  const Spacer(),
                  DropdownButton<String>(
                    value: selectedType.isNotEmpty ? selectedType : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    items: types.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
               Row(
                children: [
                  const Text('Select Color: '),
                  const Spacer(),
                  DropdownButton<String>(
                    value: selectedColors.isNotEmpty ? selectedColors : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedColors = newValue!;
                      });
                    },
                    items: colors.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                          
                        );
                       
                      },
                    ).toList(),
                    
                  ),
                ],
              ),
               Row(
                children: [
                  const Text('Select Season: '),
                  const Spacer(),
                  DropdownButton<String>(
                    value: selectedSeason.isNotEmpty ? selectedSeason : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSeason = newValue!;
                      });
                    },
                    items: seasons.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                          
                        );
                       
                      },
                    ).toList(),
                    
                  ),
                ],
              ),
             
             
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (validateFields()) {
                    final product = BaseModel(
                      name: nameController.text,
                      imageUrl: imageUrlController.text,
                      category: selectedCategory,
                      type: selectedType,
                      price: double.parse(priceController.text),
                      review: 0.0,
                      value: 1,
                      id: Random().nextInt(100000),
                      selectedColor: 1,
                      selectedSize: 1,
                      color: selectedColors,
                      season: selectedSeason,
                    );
                    await createProduct(product);
                    clearFields();
                    showSuccessMessage();
                  } else {
                    showErrorMessage();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Add Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
     ] ),
    );
  }

Future<void> createProduct(BaseModel product) async {
  
  try {
    final updatedProduct = BaseModel(
      id: product.id,
      imageUrl: product.imageUrl,
      name: product.name,
      category: product.category,
      price: product.price,
      review: product.review,
      value: 1,
      selectedSize: 1,
      selectedColor: 1,
      type: selectedType,
      color: selectedColors, 
      season: selectedSeason
      
    );

    final collectionPath = selectedCategory.toLowerCase(); // Adjust based on your collection structure
    final documentPath = selectedType.toLowerCase(); // Adjust based on your collection structure

    await FirebaseFirestore.instance
        .collection('products')
        .doc(collectionPath)
        .collection(documentPath)
        .add(updatedProduct.toMap());

     await FirebaseFirestore.instance
          .collection('products2')
          .add(updatedProduct.toMap());

    print('Product created successfully');
  } catch (e) {
    print('Error creating product: $e');
  }
}


  void clearFields() {
    nameController.clear();
    imageUrlController.clear();
    priceController.clear();
  }

  void showSuccessMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Product added successfully.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool validateFields() {
    if (nameController.text.isEmpty ||
        imageUrlController.text.isEmpty ||
        priceController.text.isEmpty ||
        selectedCategory == 'None' ||
        selectedType == 'None' || selectedColors == 'None' || selectedSeason == 'None') {
      return false;
    }

    double parsedPrice;
    try {
      parsedPrice = double.parse(priceController.text);
    } catch (e) {
      return false;
    }

    // Additional validation checks can be added here if needed

    return true;
  }

  void showErrorMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Something\'s Missing'),
        content: const Text('Please fill all the required fields.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
