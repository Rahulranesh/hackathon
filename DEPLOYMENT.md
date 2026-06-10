# QuickSlot Backend Deployment Guide

## Option 1: Deploy to Render (Recommended - Easiest)

### Prerequisites
- A GitHub account
- Git installed on your machine

### Step-by-Step Render Deployment

1. **Push your code to GitHub:**
   ```bash
   # Initialize git if not already done
   git init
   
   # Add all files
   git add .
   
   # Commit
   git commit -m "Initial commit - QuickSlot backend and Flutter app"
   
   # Create a new repository on GitHub (via browser)
   # Then add the remote and push
   git remote add origin https://github.com/YOUR_USERNAME/quickslot.git
   git branch -M main
   git push -u origin main
   ```

2. **Deploy to Render:**
   - Go to https://render.com and sign up/login
   - Click "New +" and select "Web Service"
   - Connect your GitHub repository
   - Render will automatically detect the `render.yaml` file
   - Click "Apply" to use the configuration
   
   **Manual Configuration (if needed):**
   - **Name:** quickslot-backend
   - **Root Directory:** `server`
   - **Environment:** Node
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Plan:** Free
   
3. **Get your deployment URL:**
   - After deployment completes, you'll get a URL like: `https://quickslot-backend.onrender.com`
   - Copy this URL

4. **Update Flutter app to use the deployed backend:**
   ```bash
   cd hackathon
   flutter run --dart-define=API_BASE_URL=https://quickslot-backend.onrender.com
   ```
   
   Or update `lib/core/constants.dart`:
   ```dart
   const String kBaseUrl = String.fromEnvironment(
     'API_BASE_URL',
     defaultValue: 'https://quickslot-backend.onrender.com',
   );
   ```

### Important Notes for Render Free Tier:
- Free tier services spin down after 15 minutes of inactivity
- First request after spin-down takes 30-60 seconds to wake up
- SQLite database persists but may be reset on redeploys
- For production, consider upgrading to paid tier or use Render Disk for persistence

---

## Option 2: Deploy to Railway

### Step-by-Step Railway Deployment

1. **Push your code to GitHub** (same as above)

2. **Deploy to Railway:**
   - Go to https://railway.app and sign up/login
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your repository
   - Railway will automatically detect `railway.json`
   - Click "Deploy"

3. **Configure Environment:**
   - Railway will automatically use Node.js 22
   - No additional configuration needed

4. **Get your deployment URL:**
   - Go to Settings → Generate Domain
   - Copy the generated URL (e.g., `https://quickslot-production.up.railway.app`)

5. **Update Flutter app** (same as Render step 4)

---

## Option 3: Deploy to Fly.io

1. **Install Fly CLI:**
   ```bash
   # macOS
   brew install flyctl
   
   # Or via curl
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login to Fly:**
   ```bash
   flyctl auth login
   ```

3. **Create Fly configuration:**
   ```bash
   cd server
   flyctl launch
   ```
   
   Answer the prompts:
   - App name: quickslot-backend (or your choice)
   - Region: Choose closest to you
   - PostgreSQL: No
   - Redis: No

4. **Deploy:**
   ```bash
   flyctl deploy
   ```

5. **Get your URL:**
   ```bash
   flyctl info
   ```
   Look for the hostname (e.g., `quickslot-backend.fly.dev`)

---

## Testing Your Deployment

Once deployed, test the backend:

```bash
# Health check
curl https://YOUR_BACKEND_URL/health

# Get venues
curl https://YOUR_BACKEND_URL/venues

# Get users (for login)
curl https://YOUR_BACKEND_URL/users
```

Expected responses:
- `/health`: `{"status":"ok"}`
- `/venues`: Array of venue objects
- `/users`: Array of user objects

---

## Local Development

To continue developing locally while having a deployed backend:

```bash
# Terminal 1: Run local backend
cd server
npm start

# Terminal 2: Run Flutter with local backend
cd hackathon
flutter run --dart-define=API_BASE_URL=http://localhost:3000

# Or for iOS Simulator (use your machine's IP)
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:3000
```

---

## Troubleshooting

### Backend won't start on Render/Railway
- Check that Node.js version is 22+ (required for `node:sqlite`)
- Verify `package.json` has correct start script
- Check deployment logs for errors

### Flutter can't connect to backend
- Verify backend URL is correct (include `https://`)
- Check that backend is running: visit `/health` in browser
- For iOS simulator: use actual backend URL, not `localhost`
- For Android emulator: use `10.0.2.2` for local, or backend URL for deployed

### Database resets on Render
- Free tier doesn't guarantee persistent disk
- Consider upgrading to paid tier with Render Disk
- Or use external database (PostgreSQL on Render)

### CORS errors
- Backend already has CORS enabled in `src/app.js`
- If issues persist, check browser console for specific error
- Verify origin is allowed in CORS configuration

---

## Next Steps After Deployment

1. **Update README with your backend URL**
2. **Test the full booking flow** with your iOS simulator
3. **Test concurrent booking** with two devices
4. **Monitor logs** on your deployment platform
5. **Consider database backup** strategy for production use

---

## Environment Variables (Optional)

If you need to configure additional settings:

### Render Dashboard:
- Go to your service → Environment
- Add variables like `PORT` (usually auto-set)
- Render automatically restarts on env changes

### Railway Dashboard:
- Go to your service → Variables
- Add key-value pairs
- Railway auto-deploys on changes

### Fly.io:
```bash
flyctl secrets set KEY=value
```

---

## Cost Breakdown

| Platform | Free Tier | Notes |
|----------|-----------|-------|
| **Render** | 750 hours/month | Best for demos, spins down after inactivity |
| **Railway** | $5 credit/month | Good for small projects, pay as you go |
| **Fly.io** | 3 VMs free | Great for production, more complex setup |

**Recommendation:** Start with Render for quick demo, migrate to Fly.io for production.
