import csv
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
from numpy.linalg import norm

# Load the pre-trained ResNet50 model
model = ResNet50(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
model.trainable = False

# Function to extract image features
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
    

image_url = 'http://assets.myntassets.com/v1/images/style/properties/83f4ab34db71459ba1f80bb8992cf9d5_images.jpg'
image_features = extract_image_features(image_url)
print(image_features)


def calculate_similarity(vector1, vector2):
    similarity_score = np.dot(vector1, vector2) / (np.linalg.norm(vector1) * np.linalg.norm(vector2))
    return similarity_score

# Sample image features (features of the sample image)
sample_image_features = image_features  # Replace with the actual features of your sample image

# Load the image features from the pickle file
with open("image_features.pkl", "rb") as f:
    image_data = pickle.load(f)

# Calculate similarity scores for all images and store them in a dictionary
similarity_scores = {}
for image_url, features in image_data.items():
    similarity = calculate_similarity(sample_image_features, features)
    similarity_scores[image_url] = float(similarity)
    print(float(similarity))
    # print(similarity)

# Sort the images by similarity scores in descending order and get the top 5 similar images
sorted_images = sorted(similarity_scores.items(), key=lambda x: x[1], reverse=True)
top_5_similar_images = sorted_images[:5]
print(similarity_scores)

print(top_5_similar_images)

