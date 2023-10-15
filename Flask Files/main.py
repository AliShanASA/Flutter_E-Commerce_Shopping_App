import os
import numpy as np
import firebase_admin
from firebase_admin import credentials, firestore
import requests
from PIL import Image
from io import BytesIO
from flask_cors import CORS
import cv2
from flask import Flask, request, jsonify

app = Flask(__name__)
app.debug = True
CORS(app)

# Initialize Firebase
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Define the similarity score threshold
SIMILARITY_THRESHOLD = 0.1

@app.route('/get_similar_images', methods=['POST'])
def get_similar_images():
    try:
        # Get imageUrl from the request sent by the Flutter app
        image_url = request.json.get('imageUrl')

        if not image_url:
            return jsonify({'error': 'No imageUrl provided'}), 400

        # Load the image from the URL and convert it to grayscale
        response = requests.get(image_url)
        if response.status_code != 200:
            return jsonify({'error': 'Failed to fetch the image'}), 500
        image = Image.open(BytesIO(response.content)).convert('L')
        gray_image = np.array(image)

        # Define a list to store similar products with similarity scores
        similar_products = []

        # Load all product data from Firestore
        products_ref = db.collection('products2').stream()

        for product_doc in products_ref:
            try:
                product_data = product_doc.to_dict()
                product_image_url = product_data.get('imageUrl')

                if product_image_url:
                    # Load the product image from the URL and convert it to grayscale
                    response = requests.get(product_image_url)
                    if response.status_code != 200:
                        print(f"Failed to fetch product image for {product_image_url}")
                        continue

                    product_image = Image.open(BytesIO(response.content)).convert('L')
                    product_gray_image = np.array(product_image)

                    # Calculate histograms for the images
                    hist1 = cv2.calcHist([gray_image], [0], None, [256], [0, 256])
                    hist2 = cv2.calcHist([product_gray_image], [0], None, [256], [0, 256])

                    # Compare histograms using a suitable metric (e.g., Chi-Square)
                    comparison_result = cv2.compareHist(hist1, hist2, cv2.HISTCMP_CHISQR)
                    print(comparison_result)

                    # Create a dictionary to store product information and similarity score
                    product_with_similarity = {
                        'product_data': product_data,
                        'similarity_score': float(comparison_result)  # Convert to Python float
                    }

                    # Append the product dictionary to the list
                    similar_products.append(product_with_similarity)
                   
            except Exception as e:
                # Handle exceptions here (e.g., if imageUrl is not found)
                print(f"Error processing product: {str(e)}")

        # Sort the list of similar products by similarity score in ascending order
        similar_products.sort(key=lambda x: x['similarity_score'], reverse=True)
        print(similar_products)

        # Return all similar products with their similarity scores
        return jsonify(similar_products)

    except Exception as e:
        print(e)
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run()
