# Bandhan Object Detection API

A Flask-based REST API for object detection using YOLOv8.

## Features

- Real-time object detection using YOLOv8n model
- Support for image file upload and URL-based detection
- RESTful API with JSON responses
- CORS enabled for frontend integration
- Health check endpoint

## API Endpoints

### Health Check
- **GET /** - API health status and information

### Object Detection
- **POST /predict** - Detect objects in images
  - **File upload**: Send `multipart/form-data` with `file` field
  - **URL**: Send JSON with `{"url": "image_url"}`

## Response Format

```json
[
  {
    "class_id": 0,
    "class_name": "person",
    "confidence": 0.89,
    "bbox": {
      "x1": 100.5,
      "y1": 150.2,
      "x2": 200.7,
      "y2": 300.8
    }
  }
]
```

## Deployment

### Render.com
1. Connect your GitHub repository to Render
2. Create a new Web Service
3. Set the root directory to `backend/assis`
4. Render will automatically use the `render.yaml` configuration

### Manual Deployment
```bash
pip install -r requirements.txt
python main.py
```

## Environment Variables

- `PORT`: Server port (default: 5000)
- `PYTHON_VERSION`: Python version for deployment

## Model

The API uses YOLOv8n model which is automatically downloaded on first run. The model file is approximately 6.25MB and supports detection of 80 object classes from the COCO dataset.
