// ignore_for_file: deprecated_member_use

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'interest_selection.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<bool> selectedCategories = [
    false,
    false,
    false,
  ];
 
 

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
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
                  const SizedBox(
                    height: 30,
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Choose your category",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 400),
                    child: Row(
                      children: [
                        const SizedBox(width: 70), // Left padding for 1st image
                        _buildCategoryColumn(
                          'assets/mens.png',
                          'Men', // Category label
                          0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  FadeInRight(
                    duration: const Duration(milliseconds: 450),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildCategoryColumn(
                          'assets/women.jpg',
                          'Women', // Category label
                          1,
                        ),
                        const SizedBox(width: 30), // Right padding for 2nd image
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      children: [
                        const SizedBox(width: 70), // Left padding for 3rd image
                        _buildCategoryColumn(
                          'assets/kids.png',
                          'Kids', // Category label
                          2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    duration: const Duration(milliseconds: 550),
                    child: NextButton(
                      onPressed: () {
                        debugPrint(selectedCategoryNames.toString());
                        if(selectedCategoryNames.isEmpty){
                          showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Selection Required'),
                                              content: const Text(
                                                  'Please select atleast one category'),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                 iterestCategorySelectionScreen(selectedCategoryNames: selectedCategoryNames
                          ),
                        ));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<String> selectedCategoryNames = {};
  Widget _buildCategoryColumn(
      String imagePath, String categoryName, int index) {
      //final isSelected = selectedCategories[index];
        
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // selectedCategories[index] = !selectedCategories[index];
                      selectedCategories[index] = !selectedCategories[index];
              // Get the category name
              // Check if the category is selected, then add its name
              if (selectedCategories[index]) {
                selectedCategoryNames.add(categoryName);
              } else {
                // If it's deselected, remove its name (if it exists)
                selectedCategoryNames.remove(categoryName);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: selectedCategories[index] ? 120 : 100, // Adjust the width
            height: selectedCategories[index] ? 120 : 100, // Adjust the height
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 27, 149, 206),
              border: Border.all(
                color: selectedCategories[index]
                    ? const Color.fromARGB(255, 27, 149, 206)
                    : Colors.black,
                width: selectedCategories[index] ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(
                selectedCategories[index] ? 50 : 40, // Adjust the borderRadius
              ),
              boxShadow: selectedCategories[index]
                  ? [
                      const BoxShadow(
                        color: Color.fromARGB(100, 0, 0, 0),
                        offset: Offset(0, 4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16), // Space between image and text
        Text(
          categoryName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NextButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          right: 20.0, top: 40), // Adjust the position of the FAB
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.lightBlue,
          size: 30.0, // Adjust the size of the icon
        ),
      ),
    );
  }
}
