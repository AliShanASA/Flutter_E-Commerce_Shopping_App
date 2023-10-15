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
        query_features = Reshape((2048, 1))(query_features)
        return query_features
    except Exception as e:
        print(f"Error processing image: {e}")
        return None

# Read image URLs from the CSV file
csv_file = "imagesURLS.csv"  # Replace with your CSV file path
image_data = {}

with open(csv_file, newline='') as csvfile:
    reader = csv.reader(csvfile)
    next(reader)  # Skip header row if it exists
    for row in reader:
        image_url = row[0]
        features = extract_image_features(image_url)
        if features is not None:
            image_data[image_url] = features

# Save the dictionary as a pickle file
pickle_file = "image_features.pkl"  # Replace with your desired pickle file path
with open(pickle_file, 'wb') as f:
    pickle.dump(image_data, f)

print("Image features saved as a pickle file.")
