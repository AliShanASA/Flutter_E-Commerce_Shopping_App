// ignore_for_file: deprecated_member_use, avoid_function_literals_in_foreach_calls, avoid_print, unused_label, prefer_final_fields, unused_local_variable, use_rethrow_when_possible

import 'dart:typed_data';
import 'package:fashion_ecommerce_app/main_wrapper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../../model/base_model.dart';
import '../../utils/constants.dart';
import '../../widget/add_to_cart.dart';
import '../../data/app_data.dart';
import '../LogInSignUp/login.dart';
import '../LogInSignUp/user_account.dart';
import '../ProductDetail/details.dart';
import '../cart/cart.dart';
import '../category/category.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late TextEditingController controller;
  List<BaseModel> products = [];
  bool isUserLoggedIn = false;
  final int _index = 1;
  int cartItemCount = 0;

  // Uint8List? _image;
  final ImagePicker _imagePicker = ImagePicker();

  SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  bool isLoading = false;
  bool isVisualSearch = false;
  void getCartItemCount() async {
    // Call the getCartItemCount method in the Cart class to retrieve the item count
    int itemCount = await Cart.getCartItemCount();
    setState(() {
      cartItemCount = itemCount;
    });
  }
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    // itemsOnSearch = products;
    getCartItemCount();
    checkUserLoggedIn().then((isLoggedIn) {
      setState(() {
        isUserLoggedIn = isLoggedIn;
      });
    });
    fetchData().then((data) {
      setState(() {
        products = data;
      });
    });
  }

  List<BaseModel> searchedResults = [];
  // List<BaseModel> similarResults = []; // List to store researched products

  Future<void> captureImageFromCamera({required int c}) async {
    try {
      Uint8List? img;
      if (c == 0) {
        img = await pickImage(ImageSource.camera);
      } else {
        img = await pickImage(ImageSource.gallery);
      }
      print("jaffar");
      print(img.toString());
      if (img != null) {

        setState(() {
          isLoading = true;
          isVisualSearch = true;
        });
        // Upload the image to Firebase Storage
        // print('f1');
        String imageUrl = await uploadImageToFirebaseStorage(img);
        // print('f2');
        // String imageUrl = '.https://images.assetsdelivery.com/compings_v2/kchung/kchung1411/kchung141100305.jpg';

        // Pass the image URL to Flask server
        String flaskServerUrl =
            'https://5248-2404-3100-1819-492b-55b-649-33ad-bbb7.ngrok.io/get_similar_images'; // Replace with your Flask server URL

        // Create a JSON object with the image URL
        Map<String, dynamic> requestData = {
          'imageUrl': imageUrl
        }; // Change key to "imageUrl"

        // Send a POST request to the Flask server
        final response = await http.post(
          Uri.parse(flaskServerUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

      if (response.statusCode == 200) {
  print('Response body: ${response.body}');
  List<dynamic> responseData = jsonDecode(response.body);

  // Create a list to store the converted products
  List<BaseModel> resultModels = [];

  // Iterate through the response data and map each dictionary to a BaseModel
  for (var productData in responseData) {
     BaseModel product = BaseModel(
      id: productData['id'],
      imageUrl: productData['imageUrl'],
      name: productData['name'],
      category: productData['category'],
      price: productData['price'].toDouble(),
      review: productData['review'].toDouble(),
      value: productData['value'],
      selectedSize: productData['selectedSize'],
      selectedColor: productData['selectedColor'],
      type: productData['type'],
      color: productData['color'],
      season: productData['season'],
    );

    // Add the BaseModel to the list
    resultModels.add(product);
  }
  print(searchedResults.toString());
  print(searchedResults.toString());
  searchedResults = resultModels;
  print(searchedResults.toString());

  setState(() {
    isLoading = false;
  });
} else {
  print('Failed to get data from Flask server. Status code: ${response.statusCode}');
  setState(() {
    isLoading = false;
  });
}

      }
    } catch (e) {
      print('Error: $e');   
      setState(() {
        isLoading = false;
      });
    }
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
      throw e;
    }
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image != null) {
      return await image.readAsBytes();
    }
    return null;
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
              controller.text = _recognizedText;
              onSearch(_recognizedText);
            });
          },
        );
        setState(() {
          _isListening = true;
        });
      }
    } else {
      debugPrint('Not Worked');
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }

  // Searching Function for TextField
  onSearch(String search) {
    setState(() {
      itemsOnSearch = products
          .where((element) =>
              element.name.toLowerCase().contains(search.toLowerCase()) ||
              element.type.toLowerCase().contains(search.toLowerCase()) ||
              element.category.toLowerCase().contains(search.toLowerCase()))
          .toList();
    });
  }

  Future<bool> checkUserLoggedIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    int selectedSize = 1;
    int selectedColor = 1;
    const int x = 1;
    const bool isCameFromLogIn = false;

    return Material(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: WillPopScope(
          onWillPop: () async {
            controller.clear();
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(context, isUserLoggedIn),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: const Color.fromARGB(
                  109, 0, 140, 255), // Make the background transparent
              elevation: 0, // Remove the shadow
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search), label: 'Search'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.category), label: 'Category'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Person'),
              ],
              currentIndex: _index,
              onTap: (index) {
                if (index == 3) {
                  if (isUserLoggedIn) {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserAccount(
                                  email: auth.currentUser!.email ?? '',
                                  username: auth.currentUser!.displayName ?? '',
                                )));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Login(
                                  x: x,
                                  fromWhere: 0,
                                  data: products.isNotEmpty
                                      ? products[0]
                                      : BaseModel(
                                          id: 1,
                                          imageUrl: "imageUrl",
                                          name: "name",
                                          category: "category",
                                          price: 1.0,
                                          review: 1.2,
                                          value: 1,
                                          selectedSize: 1,
                                          selectedColor: 1,
                                          type: "",
                                          color: "None",
                                          season: 'None'
                                        ),
                                )));
                  }
                } else if (index == 2) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CategoryScreen(isUserLoggedIn: isUserLoggedIn)));
                } else if (index == 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainWrapper(
                                isUserLoggedIn: isUserLoggedIn,
                              )));
                }
              },

              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              iconSize: 20,
            ),
            body: Stack(children: [
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        // Search Box
                        FadeInUp(
                          delay: const Duration(milliseconds: 50),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.03),
                            child: SizedBox(
                              width: size.width,
                              height: size.height * 0.07,
                              child: Center(
                                child: TextField(
                                  controller: controller,
                                  onChanged: (value) {
                                    onSearch(value);
                                  },
                                  style: textTheme.headline3?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 20,
                                    ),
                                    filled: true,
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: _listen,
                                          icon: Icon(_isListening
                                              ? Icons.mic
                                              : Icons.mic_none),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              _showImageOptionsDialog(context);
                                            },
                                            icon: const Icon(
                                              Icons.camera_alt,
                                            )),
                                        IconButton(
                                          onPressed: () {
                                            controller.clear();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            setState(() {
                                              itemsOnSearch = [];
                                              isVisualSearch = false;
                                            });
                                          },
                                          icon: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                    hintStyle: textTheme.headline3?.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                    hintText: "e.g. Casual Jeans",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: size.height * 0.01,
                        ),

                        /// Main Item List For Searching

                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 250),
                            child: Column(
                              children: [
                                Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.blue),
                                ),
                                SizedBox(
                                    height:
                                        16), // Add some space between the indicator and text
                                Text(
                                  "Searching!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!isLoading && !isVisualSearch)
                          SizedBox(
                            width: size.width,
                            height: size.height,
                            child: Column(children: [
                              Expanded(
                                child: itemsOnSearch.isNotEmpty
                                    ? GridView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: itemsOnSearch.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.63,
                                        ),
                                        itemBuilder: (context, index) {
                                          BaseModel current =
                                              itemsOnSearch[index];
                                          return FadeInUp(
                                            delay: Duration(
                                                milliseconds: 100 * index),
                                            child: GestureDetector(
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    return Details(
                                                      data: current,
                                                      isCameFromMostPopularPart:
                                                          false,
                                                      isUserLoggedIn:
                                                          isUserLoggedIn,
                                                      isCameFromLogIn:
                                                          isCameFromLogIn,
                                                      fromWhere: 1,
                                                    );
                                                  },
                                                ),
                                              ),
                                              child: Hero(
                                                tag: '${current.id}_$index',
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Positioned(
                                                      top: size.height * 0.02,
                                                      left: size.width * 0.01,
                                                      right: size.width * 0.01,
                                                      child: Container(
                                                        width: size.width * 0.5,
                                                        height:
                                                            size.height * 0.28,
                                                        margin: const EdgeInsets
                                                            .all(10),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                current
                                                                    .imageUrl),
                                                            fit: BoxFit.cover,
                                                          ),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              offset:
                                                                  Offset(0, 4),
                                                              blurRadius: 4,
                                                              color: Color
                                                                  .fromARGB(61,
                                                                      0, 0, 0),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom:
                                                          size.height * 0.04,
                                                      child: Text(
                                                        current.name,
                                                        style:
                                                            textTheme.headline2,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom:
                                                          size.height * 0.01,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          text: "\$",
                                                          style: textTheme
                                                              .subtitle2
                                                              ?.copyWith(
                                                            color: primaryColor,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: current
                                                                  .price
                                                                  .toString(),
                                                              style: textTheme
                                                                  .subtitle2
                                                                  ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: size.height * 0.01,
                                                      right: 0,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            primaryColor,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            if (isUserLoggedIn) {
                                                              AddToCart
                                                                  .addToCart(
                                                                current,
                                                                context,
                                                                selectedColor,
                                                                selectedSize,
                                                              );
                                                            } else {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Login Required'),
                                                                    content:
                                                                        const Text(
                                                                            'Please log in to add items to your cart.'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Cancel',
                                                                          style:
                                                                              TextStyle(color: Colors.orange),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => Login(
                                                                                        x: x,
                                                                                        fromWhere: 0,
                                                                                        data: products.isNotEmpty
                                                                                            ? products[0]
                                                                                            : BaseModel(
                                                                                                id: 1,
                                                                                                imageUrl: "imageUrl",
                                                                                                name: "name",
                                                                                                category: "category",
                                                                                                price: 1.0,
                                                                                                review: 1.2,
                                                                                                value: 1,
                                                                                                selectedSize: 1,
                                                                                                selectedColor: 1,
                                                                                                type: "",
                                                                                                color: "None",
                                                                                                season: 'None'
                                                                                              ),
                                                                                      ))); // Close the dialog
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Log In',
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
                                                          icon: const Icon(
                                                            LineIcons
                                                                .addToShoppingCart,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: size.height * 0.001,
                                          ),
                                          FadeInUp(
                                            delay: const Duration(
                                                milliseconds: 200),
                                            child: const Image(
                                              image: AssetImage(
                                                  "assets/images/search_fail.png"),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 0.01,
                                          ),
                                          FadeInUp(
                                            delay: const Duration(
                                                milliseconds: 250),
                                            child: const Text(
                                              "No Result Found          :(",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ]),
                          ),
                        //------------------------------------visual search----------------------------
                        if (!isLoading && isVisualSearch)
                          SizedBox(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: FadeInUp(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: const Text(
                                        "Your searched Results Says:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: searchedResults.isNotEmpty
                                      ? GridView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: searchedResults.length,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.63,
                                          ),
                                          itemBuilder: (context, index) {
                                            BaseModel current =
                                                searchedResults[index];
                                            return FadeInUp(
                                              delay: Duration(
                                                  milliseconds: 100 * index),
                                              child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                      return Details(
                                                        data: current,
                                                        isCameFromMostPopularPart:
                                                            false,
                                                        isUserLoggedIn:
                                                            isUserLoggedIn,
                                                        isCameFromLogIn:
                                                            isCameFromLogIn,
                                                        fromWhere: 1,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                child: Hero(
                                                  tag: '${current.id}_$index',
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Positioned(
                                                        top: size.height * 0.02,
                                                        left: size.width * 0.01,
                                                        right:
                                                            size.width * 0.01,
                                                        child: Container(
                                                          width:
                                                              size.width * 0.5,
                                                          height: size.height *
                                                              0.28,
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                            image:
                                                                DecorationImage(
                                                              image: NetworkImage(
                                                                  current
                                                                      .imageUrl),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                offset: Offset(
                                                                    0, 4),
                                                                blurRadius: 4,
                                                                color: Color
                                                                    .fromARGB(
                                                                        61,
                                                                        0,
                                                                        0,
                                                                        0),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom:
                                                            size.height * 0.04,
                                                        child: Text(
                                                          current.name,
                                                          style: textTheme
                                                              .headline2,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom:
                                                            size.height * 0.01,
                                                        child: RichText(
                                                          text: TextSpan(
                                                            text: "\$",
                                                            style: textTheme
                                                                .subtitle2
                                                                ?.copyWith(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                text: current
                                                                    .price
                                                                    .toString(),
                                                                style: textTheme
                                                                    .subtitle2
                                                                    ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: size.height * 0.01,
                                                        right: 0,
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              primaryColor,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              if (isUserLoggedIn) {
                                                                AddToCart
                                                                    .addToCart(
                                                                  current,
                                                                  context,
                                                                  selectedColor,
                                                                  selectedSize,
                                                                );
                                                              } else {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Login Required'),
                                                                      content:
                                                                          const Text(
                                                                              'Please log in to add items to your cart.'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            'Cancel',
                                                                            style:
                                                                                TextStyle(color: Colors.orange),
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                    builder: (context) => Login(
                                                                                          x: x,
                                                                                          fromWhere: 0,
                                                                                          data: products.isNotEmpty
                                                                                              ? products[0]
                                                                                              : BaseModel(
                                                                                                  id: 1,
                                                                                                  imageUrl: "imageUrl",
                                                                                                  name: "name",
                                                                                                  category: "category",
                                                                                                  price: 1.0,
                                                                                                  review: 1.2,
                                                                                                  value: 1,
                                                                                                  selectedSize: 1,
                                                                                                  selectedColor: 1,
                                                                                                  type: "",
                                                                                                  color: "None",
                                                                                                  season: 'None'
                                                                                                ),
                                                                                        ))); // Close the dialog
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            'Log In',
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
                                                            icon: const Icon(
                                                              LineIcons
                                                                  .addToShoppingCart,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: FadeInUp(
                                            delay: const Duration(
                                                milliseconds: 250),
                                            child: const Text(
                                              "No Result Found :(",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        //------------------similar results ----------------------
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<List<BaseModel>> fetchData() async {
    List<BaseModel> products = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('products2').get();

      snapshot.docs.forEach((doc) {
        BaseModel product = BaseModel.fromMap(doc.data());
        products.add(product);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }

    return products;
  }

  void _showImageOptionsDialog(BuildContext context) {
    int c = 0;
    int g = 1;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  captureImageFromCamera(c: c);
                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
                child: const Text("Open Camera"),
              ),
              const SizedBox(height: 16.0), // Add some spacing between buttons
              ElevatedButton(
                onPressed: () {
                  captureImageFromCamera(c: g);
                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Pick Image From Gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    bool isUserLoggedIn,
  ) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Search",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MainWrapper(isUserLoggedIn: isUserLoggedIn)));
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.white,
        ),
         ), 
         actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  LineIcons.shoppingCart,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cart(
                        isUserLoggedIn: isUserLoggedIn,
                        isCameFromUser: false,
                      ),
                    ),
                  );
                },
              ),
              if (cartItemCount >= 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartItemCount.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      );

    //===================================
  }
}
