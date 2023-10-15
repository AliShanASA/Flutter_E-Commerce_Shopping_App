import os
import numpy as np
import firebase_admin
from firebase_admin import credentials, firestore
import requests
from PIL import Image
from io import BytesIO
from flask_cors import CORS
import cv2
import tensorflow as tf
from keras.applications.resnet50 import ResNet50, preprocess_input
from keras.layers import GlobalAveragePooling2D
from flask import Flask, request, jsonify
from keras.layers import Reshape
import pandas as pd
import pickle

app = Flask(__name__)
app.debug = True
CORS(app)

# Initialize Firebase
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load the CSV files
styles_df = pd.read_csv('pak.csv')
color_styles = pd.read_csv('colorStyles.csv')

# Load the pre-trained ResNet50 model (without the top classification layer)
model = ResNet50(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
model.trainable = False

def extract_image_features(image_url):
    try:
        response = requests.get(image_url)
        image = Image.open(BytesIO(response.content))
        image = image.resize((224, 224))
        image_array = np.array(image)
        image_array_expanded = np.expand_dims(image_array, axis=0)  # Expand dimensions to make it 4D
        preprocessed_image = preprocess_input(image_array_expanded)
        query_features = model.predict(preprocessed_image)
        query_features = GlobalAveragePooling2D()(query_features)
        return query_features
    except Exception as e:
        print(f"Error processing image: {e}")
        return None

@app.route('/get_similar_images', methods=['POST'])
def get_similar_images():
    try:
        # Get image URL from the request sent by the Flutter app
        image_url = request.json.get('imageUrl')

        if not image_url:
            return jsonify({'error': 'No imageUrl provided'}), 400
        
        sample_image_features = extract_image_features(image_url)
        # Load the image features from the pickle file
        with open("image_features.pkl", "rb") as f:
            image_data = pickle.load(f)
        similarity_scores = {}
        for image_url, features in image_data.items():
            similarity = calculate_similarity(sample_image_features, features)
            similarity = float(similarity)
            similarity_scores[image_url] = similarity
            
        sorted_images = sorted(similarity_scores.items(), key=lambda x: x[1], reverse=True)
        top_5_similar_images = sorted_images[:5]
        image_urls = [url for url, _ in top_5_similar_images]
 
        
        filtered_df = styles_df[styles_df['imageUrl'].isin(image_urls)]
        required_products = filtered_df.to_dict(orient='records')
        print('f1')
        print(top_5_similar_images)
        print(image_urls)
        print(required_products)
        return jsonify(required_products)

    except Exception as e:
        print(e)
        return jsonify({'error': str(e)}), 500

def calculate_similarity(vector1, vector2):
    similarity_score = np.dot(vector1, vector2) / (np.linalg.norm(vector1) * np.linalg.norm(vector2))
    return similarity_score





@app.route('/get_best_match', methods=['POST'])
def get_best_match():
    try:
        data = request.json
        
        
        type = data.get('type', '')
        category = data.get('category', '')
        color = data.get('color', '')
        season = data.get('season', '')
        
        print(type)
        print(category)
        print(color)
        print(season)
        # Define a mapping of product types to corresponding types to find
        type_mapping = {
            'T-Shirts': ['Jeans'],
            'Dress Shirts': ['Trousers'],
            'Casual Shirts': ['Jeans', 'Trousers'],
            'Dress Pants': ['Shirts'],
            'Jeans': ['Tshirts'],
            'Shorts': ['Shorts'], 
            'Suits': ['Suits']
        }

        typeToFind = []  # Initialize the list of types to find
        colorsToFind = []  # Initialize the list of colors to find

        # Check if the type is in the type_mapping
        if type in type_mapping:
            typeToFind.extend(type_mapping[type])
            
        shirts = []
        pants = []
        watches = []
        shoes = []
        shirt_colors_new = []

        pant_colors_new = []

        # Search for color in color_styles.csv based on type
        if type in ['T-Shirts', 'Dress Shirts', 'Casual Shirts']:
            shirts = color_styles[color_styles['top'] == color]
            watches_colors = shirts['watches']
            watches = watches_colors.tolist()
            shoes_colors = shirts['shoes']
            shoes = shoes_colors.tolist()
            pant_colors = shirts['bottom']
            pant_colors_new = pant_colors.tolist()
            
        elif type in ['Dress Pants', 'Jeans', 'Shorts']:
            pants = color_styles[color_styles['bottom'] == color]
            watches_colors = pants['watches']
            watches = watches_colors.tolist()
            shoes_colors = pants['shoes']
            shoes = shoes_colors.tolist() 
            shirt_colors = pants['top']
            shirt_colors_new = shirt_colors.tolist()
                    
        shoes_links = []
        watches_links = []


        shoes_links_dict = {}  # Initialize the dictionary for shoes links
        watches_links_dict = {}
        links_dict = {}
        

        if type in ['T-Shirts', 'Dress Shirts', 'Casual Shirts']:
            links = styles_df[
                        (styles_df['category'] == category) &
                        (styles_df['type'].isin(typeToFind)) &
                        (styles_df['color'].isin(pant_colors_new)) &
                        (styles_df['season'] == season) 
            ]['imageUrl'].tolist()
            
            # Reset the links_dict for shi  rts
            links_dict = {}

            for color, link in zip(shirts, links):
                if color not in links_dict:
                    links_dict[color] = link
            links = list(links_dict.values())  
            print(links)  
            
        elif type in ['Dress Pants', 'Jeans', 'Shorts']:
            links = styles_df[
                        (styles_df['category'] == category) &
                        (styles_df['type'].isin(typeToFind)) &
                        (styles_df['color'].isin(shirt_colors_new)) &
                        (styles_df['season'] == season) 
            ]['imageUrl'].tolist()
            
            # Reset the links_dict for pants
            links_dict = {}
            
            for color, link in zip(pants, links):
                if color not in links_dict:
                    links_dict[color] = link
            links = list(links_dict.values())
            
            

        watches_links = styles_df[
            (styles_df['category'] == category) & 
            (styles_df['type'] == 'Watches') & 
            (styles_df['color'].isin(watches)) &
            (styles_df['season'] == season)
        ]['imageUrl'].tolist()
        shoes_links = styles_df[
            (styles_df['category'] == category) & 
            (styles_df['type'] == 'Casual Shoes') & 
            (styles_df['color'].isin(shoes)) &
            (styles_df['season'] == season)
        ]['imageUrl'].tolist()

        # Create dictionaries to store the first link for each color
        watches_links_dict = {}
        shoes_links_dict = {}

        # Iterate through the watches links and store the first link for each color
        for color, link in zip(watches, watches_links):
            if color not in watches_links_dict:
                watches_links_dict[color] = link

        # Iterate through the shoes links and store the first link for each color
        for color, link in zip(shoes, shoes_links):
            if color not in shoes_links_dict:
                shoes_links_dict[color] = link

        # Convert the dictionaries to lists
        watches_links = list(watches_links_dict.values())
        shoes_links = list(shoes_links_dict.values())


        n_colors = ['Black', 'White', 'Grey', 'Brown']
        if not links:
            for c in n_colors: 
                links_colors = styles_df[(styles_df['category'] == category) &
                                (styles_df['type'].isin(typeToFind)) &
                                (styles_df['color'] == c) &
                                (styles_df['season'] == season)
                ]['imageUrl'].tolist()
                if links_colors: 
                    links.append(links_colors[0])

        if not watches_links:
            print('In NOt')
            for color in n_colors:
                print(color)
                watches_colors = styles_df[
                    (styles_df['category'] == category) & 
                    (styles_df['type'] == 'Watches') & 
                    (styles_df['color'] == color) 
            ]['imageUrl'].tolist()
            if watches_colors:
                watches_links.append(watches_colors[0])

        if not shoes_links:
            for c in n_colors:
                links_colors = styles_df[
                    (styles_df['category'] == category) & 
                    (styles_df['type'] == 'Casual Shoes') & 
                    (styles_df['color'] == c)
            ]['imageUrl'].tolist()
                if links_colors: 
                    shoes_links.append(links_colors[0]) 


        filtered_df = styles_df[styles_df['imageUrl'].isin(watches_links)]
        watch_products = filtered_df.to_dict(orient='records')
        
        filtered_df = styles_df[styles_df['imageUrl'].isin(shoes_links)]
        shoes_products = filtered_df.to_dict(orient='records')
        
        filtered_df = styles_df[styles_df['imageUrl'].isin(links)]
        required_products = filtered_df.to_dict(orient='records')
        
        response = {
           'Watches': watch_products, 
           'Shoes': shoes_products,
           'Required': required_products  
        }
        
        print(response)
        return jsonify(response)

    except Exception as e:
        # Handle exceptions appropriately
        return jsonify({"error": str(e)})

if __name__ == '__main__':
    app.run()
