# ⚡ QuickSlot - Quick Start Guide

## 🚀 Deploy Backend in 5 Minutes

### Option 1: Render (Easiest - Click & Deploy)

```bash
# 1. Push to GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/quickslot.git
git push -u origin main

# 2. Go to https://render.com
# 3. New + → Web Service → Connect your repo
# 4. Render auto-detects render.yaml → Click "Apply"
# 5. Wait 2 minutes → Get URL: https://quickslot-backend.onrender.com
```

### Option 2: Railway (Good for Demos)

```bash
# 1. Push to GitHub (same as above)
# 2. Go to https://railway.app
# 3. New Project → Deploy from GitHub → Select repo
# 4. Railway auto-detects railway.json → Deploy
# 5. Settings → Generate Domain → Copy URL
```

### Option 3: Local (Fastest for Testing)

```bash
cd server
npm install
npm start
# Server at http://localhost:3000
```

---

## 📱 Run Flutter App

### With Deployed Backend

```bash
cd hackathon
flutter pub get
flutter run --dart-define=API_BASE_URL=https://YOUR_BACKEND_URL
```

### With Local Backend

```bash
cd hackathon
flutter pub get
flutter run
# Uses localhost:3000 automatically
```

---

## 🎨 What's New in UI

### 3D Effects
- **Touch and drag** any card → See 3D tilt
- **Press** cards → Scale animation
- **Navigate** → Hero animations

### Color Palette
- Purple primary (`#8B5CF6`)
- Blue secondary (`#3B82F6`)
- Pink accents (`#EC4899`)
- Gradient backgrounds

### Animations
- Typewriter text on login
- Animated gradient background
- Shimmer effects on cards
- Smooth transitions

---

## 🧪 Test the Key Feature

### Two-Device Booking Test

**Terminal 1:**
```bash
cd server
npm start
```

**Terminal 2 & 3:**
```bash
cd hackathon
flutter run -d <device1>
flutter run -d <device2>
```

1. Login as different users (Alice & Bob)
2. Open same venue → same date → same slot
3. **Both tap "Book"** at the same time
4. ✅ One succeeds (201)
5. ✅ One fails gracefully (409 "Slot taken")

---

## 📊 Quick Health Check

```bash
# Backend running?
curl http://localhost:3000/health
# Expected: {"status":"ok"}

# Data seeded?
curl http://localhost:3000/venues
# Expected: Array of 5 venues

curl http://localhost:3000/users
# Expected: Array of 3 users
```

---

## 🎯 Interactive Deployment

```bash
./deploy.sh
```

Guides you through:
1. Platform selection (Render/Railway/Fly.io)
2. GitHub push
3. Deployment steps
4. Flutter app configuration

---

## 🆘 Quick Fixes

### Backend won't start
```bash
# Check Node version (need 22+)
node --version

# Kill port 3000
lsof -ti:3000 | xargs kill -9
```

### Flutter build fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Can't connect to backend
```bash
# iOS Simulator: use localhost
flutter run --dart-define=API_BASE_URL=http://localhost:3000

# Android Emulator: use 10.0.2.2
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000

# Physical device: use your machine's IP
flutter run --dart-define=API_BASE_URL=http://192.168.1.X:3000
```

---

## 📚 Full Documentation

- **DEPLOYMENT.md** → Complete deployment guide
- **UI_UX_IMPROVEMENTS.md** → Design system
- **DEPLOYMENT_SUMMARY.md** → What's been done
- **README.md** → Project overview
- **BACKEND_GUIDE.md** → API documentation

---

## ✅ Success Checklist

- [ ] Backend deployed and responding at `/health`
- [ ] Flutter app builds without errors
- [ ] Can login and see venues
- [ ] Can view slots and book one
- [ ] 3D card effects work smoothly
- [ ] Animations are smooth (60 FPS)
- [ ] Two-device test shows one success, one conflict

---

## 🎉 You're Done!

**App is ready for demo with:**
- ✨ Premium 3D UI
- 🎨 Modern color palette
- 🚀 Cloud-deployed backend
- 📱 Smooth animations
- ✅ No double-booking guarantee

**Time to shine! 🌟**
