# QuickSlot

A sports slot booking app (badminton courts & football turf). Browse venues, pick a date, book a slot — with guaranteed no double-booking.

---

## Setup

### Backend
```bash
cd server
npm install
node --experimental-sqlite index.js
# Server starts at http://localhost:3000
# SQLite DB is created and seeded on first run
```

#### Cloud Deployment (Railway / Render)
We've included `railway.json` and `render.yaml` for 1-click free-tier deployments.
- **Render**: Connect your GitHub repo, and Render will automatically use `render.yaml` to deploy.
- **Railway**: Connect your repo and it will use `railway.json` and Nixpacks to build.

### Flutter App
```bash
cd hackathon
flutter pub get
flutter run
```

> If using a **physical device**: update `lib/core/constants.dart` — change `10.0.2.2` to your laptop's local IP (e.g. `192.168.1.x`) or your deployed Railway/Render URL.
> If using an **Android emulator**: `10.0.2.2` already maps to your host machine.

---

## Architecture

```
quickslot/
  /server     Node.js + Express + SQLite (node:sqlite built-in)
  /hackathon  Flutter app
```

### Backend
Express routes → SQLite via `node:sqlite` (Node.js built-in, no native addon).

**Concurrency approach**: The `bookings` table has `UNIQUE(slot_id, booking_date)`. Two simultaneous `POST /bookings` requests are serialized by SQLite's write lock. The second INSERT throws `errcode 2067` (SQLITE_CONSTRAINT_UNIQUE) which we catch and return `409 Conflict`. No application-level locking needed.

### Flutter
Clean 3-layer architecture:
- `data/` — models, ApiService (HTTP), repositories (JSON → domain objects)
- `presentation/providers/` — ChangeNotifier providers, each with `ViewState { idle | loading | data | error }`
- `presentation/screens/` — widgets, zero HTTP code

**Premium UI Features Added:**
- **Shimmer Loading**: Custom skeleton loaders (`shimmer` package) for all API calls to avoid jarring spinners.
- **Micro-animations**: Staggered list reveals, hero avatar transitions, and scale-in grids (`flutter_animate`).
- **Pull-to-refresh**: Available on all data-heavy screens.
- **Smart Feedback**: Animated bottom sheets and styled floating snackbars.

`ApiService` returns a sealed `Result<T>` (`Success` / `Failure`). Providers call repositories. Screens call providers. No business logic in widgets.

State management: **Provider** — chosen for simplicity, zero boilerplate, and full explainability in the defense round.

---

## API Endpoints

| Method | Path | Auth | Notes |
|--------|------|------|-------|
| GET | `/venues` | No | List all venues |
| GET | `/venues/:id/slots?date=YYYY-MM-DD` | No | Slots with availability |
| POST | `/bookings` | X-User-Id | Concurrency-safe booking |
| GET | `/users/:id/bookings` | X-User-Id | My bookings |
| DELETE | `/bookings/:id` | X-User-Id | Cancel (owner only) |

---

## What We Cut and Why

| Cut | Reason |
|-----|--------|
| JWT auth | Hardcoded users + `X-User-Id` header is sufficient for the demo scope |
| Pagination | 5 venues × 16 slots fits on one screen |
| WebSockets | 10s polling achieves the same demo effect with zero infrastructure |
| Dockerized backend | Adds 30 min setup cost with no benefit for local demo |

---

## What We'd Do With One More Day

- Real Firebase Auth (replace hardcoded users)
- WebSocket for instant slot updates instead of polling
- Admin panel to manage venues and slots
- Recurring slot templates (auto-generate slots daily)
- Unit tests for the booking concurrency logic

---

## AI Usage Note

Used AI (Antigravity / Gemini) for:
- Scaffolding the clean architecture folder structure
- Writing boilerplate `fromJson` model code
- The `Result<T>` sealed class pattern
- Slot grid UI layout

**One thing AI got wrong**: Initially used `better-sqlite3` which fails to compile on Node.js v25 due to C++20 incompatibilities. Caught during install — switched to the built-in `node:sqlite` module (available since Node 22+), which is synchronous and works identically. Verified the UNIQUE constraint error code is `errcode: 2067` not the string `'SQLITE_CONSTRAINT_UNIQUE'` that better-sqlite3 uses.
