// ignore_for_file: prefer_const_declarations, no_leading_underscores_for_local_identifiers

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ReviewsRatings extends StatefulWidget {
  const ReviewsRatings({
    
    Key? key,
    required this.itemPic,
    required this.itemName,
    required this.price,

  }) : super(key: key);

  final String itemName;
  final String itemPic;
  final double price;

  @override
  State<ReviewsRatings> createState() => _ReviewsRatingsState();
}

class _ReviewsRatingsState extends State<ReviewsRatings> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children:[
           Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/account_background1.jpg'),
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
          ),
        ),
         SingleChildScrollView(
          child: Column(
            children: [
              FadeIn(
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: 350,
                  height: 350,
                  child: Image.network(
                    widget.itemPic,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    FadeIn(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        widget.itemName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FadeIn(
                      delay: const Duration(milliseconds: 500),
                      child: Text(
                        '\$${widget.price.toStringAsFixed(2)}',
                        style:const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeIn(
                      delay: const Duration(milliseconds: 600),
                      child: TextFormField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'Add a Comment',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeIn(
                      delay: const Duration(milliseconds: 700),
                      child: RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 40,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.blue,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeIn(
                      delay: const Duration(milliseconds: 800),
                      child: ElevatedButton(
                        onPressed: () {
                          saveCommentAndRating();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(100 , 50),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 20,
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
        ),
     ] ),
    );
  }

  void saveCommentAndRating() {
    final String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? currentUser = auth.currentUser;
      if (currentUser != null) {
        final String commenterName =
            currentUser.displayName ?? 'Anonymous';
        final String commenterImage = currentUser.photoURL ?? '';
        final String userEmail = currentUser.email ?? '';

        final String productName = widget.itemName;

        FirebaseFirestore.instance
            .collection('comments')
            .doc(productName)
            .collection('users')
            .doc(userEmail)
            .set({
          'commenterName': commenterName,
          'commentText': commentText,
          'commenterImage': commenterImage,
          'commenterEmail': currentUser.email,
          'rating': _rating, // Save the rating value
        });

        _commentController.clear();
        setState(() {
          _rating = 0; // Reset the rating after saving
        });
       showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Successfull!'),
            content: const Text(
                'Your comment and rating has been saved successfully. '),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              
            ],
          );
        },
      );
      

      }
    } else {
                                          showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Field Required!'),
                                              content: const Text(
                                                  'Please fill the comment field. '),
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
                                          }
   ); }
  }
    AppBar _buildAppBar(BuildContext context) {
   return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Reviews And Ratings",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(
              context,);
             
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}