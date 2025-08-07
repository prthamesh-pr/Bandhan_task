#!/usr/bin/env python3
"""
Test script for Bandhan Object Detection API
Run this to test your API endpoints locally or after deployment
"""

import requests
import json

# Configuration
BASE_URL = "http://127.0.0.1:5000"  # Change this to your Render URL after deployment
# BASE_URL = "https://your-service-name.onrender.com"

def test_health_check():
    """Test the health check endpoint"""
    print("🔍 Testing health check endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_prediction_with_url():
    """Test object detection with image URL"""
    print("\n🖼️ Testing object detection with image URL...")
    
    # Sample image URL (you can change this)
    test_image_url = "https://ultralytics.com/images/bus.jpg"
    
    try:
        response = requests.post(
            f"{BASE_URL}/predict",
            json={"url": test_image_url},
            headers={"Content-Type": "application/json"}
        )
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            predictions = response.json()
            print(f"Detected {len(predictions)} objects:")
            for i, pred in enumerate(predictions[:5]):  # Show first 5
                print(f"  {i+1}. {pred['class_name']} (confidence: {pred['confidence']})")
        else:
            print(f"Error: {response.text}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_prediction_with_file():
    """Test object detection with file upload"""
    print("\n📁 Testing object detection with file upload...")
    print("Note: This requires a local image file. Skipping for now.")
    print("To test with file upload, use:")
    print("files = {'file': open('path/to/image.jpg', 'rb')}")
    print("response = requests.post(f'{BASE_URL}/predict', files=files)")

if __name__ == "__main__":
    print("🧪 Bandhan API Test Suite")
    print("=" * 40)
    print(f"Testing API at: {BASE_URL}")
    print()
    
    # Run tests
    health_ok = test_health_check()
    prediction_ok = test_prediction_with_url()
    test_prediction_with_file()
    
    print("\n" + "=" * 40)
    print("📊 Test Results:")
    print(f"Health Check: {'✅ PASS' if health_ok else '❌ FAIL'}")
    print(f"URL Prediction: {'✅ PASS' if prediction_ok else '❌ FAIL'}")
    print()
    
    if health_ok and prediction_ok:
        print("🎉 All tests passed! Your API is working correctly.")
    else:
        print("⚠️ Some tests failed. Check the error messages above.")
