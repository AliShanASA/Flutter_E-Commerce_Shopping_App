// ignore_for_file: use_build_context_synchronously, unused_import, avoid_print, unnecessary_const, non_constant_identifier_names, unused_local_variable

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fashion_ecommerce_app/admin/home/admin_home.dart';
import 'package:fashion_ecommerce_app/main_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../RecommenderScreens/category_selection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isUserLoggedIn = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  final w = Get.width;
  final h = Get.height;
  String? model;
  bool isPreviousUser = false;

 Future<void> checkPreviousUser() async {
  print("Model: $model");
  try {
    CollectionReference<Map<String, dynamic>> data =
        FirebaseFirestore.instance.collection('GuestUsers');

    var snapshot = await data.get();
    bool found = false;

    // Iterate through the documents to check if any document ID matches the model
    for (var doc in snapshot.docs) {
      if (doc.id == model) {
         found = true;
         break;
      }
    }

    if (found) {
      print('Document with model "$model" exists.');
     
        isPreviousUser = true;
     
    } else {
      print('Document with model "$model" does not exist.');
      isPreviousUser = false;
    }
  } catch (e) {
    print('Error fetching data: $e');
  }
}

  Future<String> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;
  String deviceModel = ''; // Initialize the device model
  
  try {
    androidInfo = await deviceInfo.androidInfo;
    deviceModel = androidInfo.model;
    print('Running on $deviceModel');
  } catch (e) {
    print('Error getting device info: $e');
  }
  
  return deviceModel; // Return the device model
}


   @override
  void initState() {
    super.initState();
    initializeScreen();
  }

  Future<void> initializeScreen() async {
    model = await getDeviceInfo();
    print(model.toString());
    checkPreviousUser();
    checkAndNavigate();
  }

  Future<void> checkAndNavigate() async {
    isUserLoggedIn = await checkUserLoggedIn();
    _navigateToNextScreen();
  }

  Future<bool> checkUserLoggedIn() async {
    return auth.currentUser != null;
  }

  Future<void> _navigateToNextScreen() async {
    print(isPreviousUser);
    print('Navigating to the next screen...');
    await Future.delayed(
        const Duration(seconds: 6)); // Adjust the duration as needed

    if (!isUserLoggedIn && !isPreviousUser) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CategorySelectionScreen()),
      );
    } else {
      if (auth.currentUser?.email == 'admin.smart@gmail.com') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminHome()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MainWrapper(isUserLoggedIn: isUserLoggedIn)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              FadeInDown(
                delay: const Duration(milliseconds: 70),
                child: Container(
                  width: w,
                  height: h / 2,
                  decoration: const BoxDecoration(
                    color: const Color.fromARGB(117, 0, 157, 255),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(1000),
                      bottomLeft: Radius.circular(1000),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                left: 60,
                child: FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: w / 1.5,
                    height: h / 10,
                    child: Center(
                      child: Text(
                        "Fashion Shop",
                        style: GoogleFonts.bebasNeue(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 160,
                left: 60,
                child: FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: SizedBox(
                    width: w / 1.5,
                    height: h / 10,
                    child: Center(
                      child: Text(
                        "The joy of dressing is an art",
                        style: GoogleFonts.lato(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 220,
                left: 75,
                child: FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: const SpinKitFadingCircle(
                    // Corrected SpinKitFoldingCube to SpinKitFadingCircle
                    color: const Color.fromARGB(117, 0, 157, 255),
                    size: 35,
                  ),
                ),
              ),
              Positioned(
                top: 350,
                left: 75,
                child: FadeInUp(
                  delay: const Duration(milliseconds: 1000),
                  child: Spin(
                    delay: const Duration(milliseconds: 1000),
                    child: SizedBox(
                      width: w / 1.6,
                      height: h / 3.3,
                      child: Center(
                          child: Image.asset(
                        'assets/logo.png',
                        //color: Colors.black,
                      )),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 70,
                left: 80,
                child: FadeInUp(
                  delay: const Duration(milliseconds: 1300),
                  child: SizedBox(
                    width: w / 1.6,
                    height: h / 19,
                    child: Center(
                      child: Text(
                        "Wait For Beautiful Moment...",
                        style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 155,
                child: FadeInUp(
                  delay: const Duration(milliseconds: 1500),
                  child: SizedBox(
                    width: w / 5,
                    height: h / 15,
                    child: Center(
                      child: SpinKitFoldingCube(
                        size: 35,
                        itemBuilder: (BuildContext context, int index) {
                          return const DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(117, 0, 157, 255),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
