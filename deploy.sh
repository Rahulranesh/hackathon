#!/bin/bash

# QuickSlot Deployment Helper Script
# This script helps you prepare and deploy your backend

echo "🚀 QuickSlot Deployment Helper"
echo "================================"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit - QuickSlot app"
    echo "✅ Git initialized"
else
    echo "✅ Git repository already exists"
fi

echo ""
echo "📋 Deployment Options:"
echo ""
echo "1. Deploy to Render (Recommended - Free tier, easy setup)"
echo "2. Deploy to Railway (Free $5 credit, good for demos)"
echo "3. Deploy to Fly.io (More control, requires CLI)"
echo "4. Just push to GitHub"
echo ""

read -p "Choose an option (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🌐 Deploying to Render:"
        echo ""
        echo "Steps to follow:"
        echo "1. Push your code to GitHub first (if not done)"
        echo "2. Go to https://render.com and sign up/login"
        echo "3. Click 'New +' → 'Web Service'"
        echo "4. Connect your GitHub repository"
        echo "5. Render will auto-detect render.yaml"
        echo "6. Click 'Apply' to deploy"
        echo ""
        read -p "Do you want to push to GitHub now? (y/n): " push
        if [ "$push" = "y" ]; then
            read -p "Enter your GitHub repo URL (e.g., https://github.com/user/quickslot.git): " repo_url
            git remote add origin "$repo_url" 2>/dev/null || git remote set-url origin "$repo_url"
            git branch -M main
            git push -u origin main
            echo "✅ Pushed to GitHub!"
        fi
        ;;
    2)
        echo ""
        echo "🚂 Deploying to Railway:"
        echo ""
        echo "Steps to follow:"
        echo "1. Push your code to GitHub first (if not done)"
        echo "2. Go to https://railway.app and sign up/login"
        echo "3. Click 'New Project' → 'Deploy from GitHub repo'"
        echo "4. Select your repository"
        echo "5. Railway will auto-detect railway.json"
        echo "6. Click 'Deploy'"
        echo ""
        read -p "Do you want to push to GitHub now? (y/n): " push
        if [ "$push" = "y" ]; then
            read -p "Enter your GitHub repo URL (e.g., https://github.com/user/quickslot.git): " repo_url
            git remote add origin "$repo_url" 2>/dev/null || git remote set-url origin "$repo_url"
            git branch -M main
            git push -u origin main
            echo "✅ Pushed to GitHub!"
        fi
        ;;
    3)
        echo ""
        echo "✈️  Deploying to Fly.io:"
        echo ""
        if ! command -v flyctl &> /dev/null; then
            echo "❌ Fly CLI not installed."
            echo "Install with: brew install flyctl"
            echo "Or visit: https://fly.io/docs/hands-on/install-flyctl/"
        else
            echo "Logging in to Fly.io..."
            flyctl auth login
            echo "Launching app..."
            cd server
            flyctl launch
            cd ..
            echo "✅ Deployed to Fly.io!"
        fi
        ;;
    4)
        echo ""
        echo "📤 Pushing to GitHub:"
        read -p "Enter your GitHub repo URL (e.g., https://github.com/user/quickslot.git): " repo_url
        git remote add origin "$repo_url" 2>/dev/null || git remote set-url origin "$repo_url"
        git branch -M main
        git add .
        git commit -m "Update: Ready for deployment" || echo "No changes to commit"
        git push -u origin main
        echo "✅ Pushed to GitHub!"
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "📱 Next Steps:"
echo ""
echo "1. Once deployed, you'll get a URL like:"
echo "   https://quickslot-backend.onrender.com (Render)"
echo "   https://quickslot-production.up.railway.app (Railway)"
echo "   https://quickslot-backend.fly.dev (Fly.io)"
echo ""
echo "2. Update Flutter app with your backend URL:"
echo "   cd hackathon"
echo "   flutter run --dart-define=API_BASE_URL=https://YOUR_BACKEND_URL"
echo ""
echo "3. Or update lib/core/constants.dart with your URL"
echo ""
echo "🎉 Happy deploying!"
