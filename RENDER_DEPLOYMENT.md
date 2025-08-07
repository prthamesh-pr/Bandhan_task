# Render Deployment Guide

## 🚀 Deploy Backend API to Render

### Prerequisites
- GitHub repository: `https://github.com/prthamesh-pr/Bandhan_task.git`
- Render account (free): https://render.com

### Step-by-Step Deployment

#### 1. Connect GitHub to Render
1. Go to https://render.com and sign up/login
2. Click "New +" → "Web Service"
3. Connect your GitHub account
4. Select repository: `prthamesh-pr/Bandhan_task`

#### 2. Configure Web Service
Fill in the following settings:

**Basic Settings:**
- **Name**: `bandhan-api` (or your preferred name)
- **Branch**: `main`
- **Root Directory**: `backend/assis`
- **Runtime**: `Python 3`

**Build & Deploy Settings:**
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `python main.py`

**Advanced Settings:**
- **Auto-Deploy**: Yes
- **Plan**: Free (for development)

#### 3. Environment Variables (Optional)
- `PYTHON_VERSION`: `3.11.0`
- `PORT`: Will be automatically set by Render

#### 4. Deploy
1. Click "Create Web Service"
2. Wait for deployment to complete (~5-10 minutes)
3. Your API will be available at: `https://your-service-name.onrender.com`

### 📡 API Endpoints After Deployment

Once deployed, your API will be available at your Render URL:

- **Health Check**: `GET https://your-service-name.onrender.com/`
- **Object Detection**: `POST https://your-service-name.onrender.com/predict`

### 🔧 Update Flutter App

After deployment, update your Flutter app's API base URL:

```dart
// In lib/services/object_detection_service.dart
const String baseUrl = "https://your-service-name.onrender.com";
```

### 📝 Testing Your Deployed API

#### Using curl:
```bash
# Health check
curl https://your-service-name.onrender.com/

# Object detection with URL
curl -X POST https://your-service-name.onrender.com/predict \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/image.jpg"}'
```

#### Using Postman or similar:
- **Method**: POST
- **URL**: `https://your-service-name.onrender.com/predict`
- **Body**: Form-data with `file` field (image file) OR JSON with `{"url": "image_url"}`

### 🚨 Important Notes

1. **Cold Starts**: Free tier services sleep after 15 minutes of inactivity. First request after sleep may take 30+ seconds.

2. **Model Download**: YOLOv8n model (~6.25MB) downloads automatically on first deployment.

3. **Free Tier Limits**: 
   - 750 hours/month runtime
   - Services sleep after 15 minutes of inactivity
   - 512MB RAM, 0.1 CPU

4. **Logs**: Check deployment logs in Render dashboard for troubleshooting.

### 🔄 Automatic Deployments

Your service is configured for automatic deployment. Every push to the `main` branch will trigger a new deployment.

### 📊 Monitor Your Deployment

- **Render Dashboard**: Monitor performance, logs, and metrics
- **Health Check**: Regularly check the health endpoint
- **Error Monitoring**: Check logs for any runtime errors
