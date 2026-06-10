# QuickSlot Backend Guide

This document explains the Node.js backend file-by-file for demo and defense. The backend is a small REST API using Express and SQLite.

The hard rule is: one slot for one date can only have one booking. This is enforced by the database, not by frontend checks.

## Backend Stack

- Runtime: Node.js
- Framework: Express
- Database: SQLite through built-in `node:sqlite`
- Persistence: local `quickslot.db`
- Auth: DB-backed demo users with `X-User-Id` header
- Concurrency protection: SQLite unique constraint on `(slot_id, booking_date)`

Why this stack:

- Fast to run locally in a hackathon.
- Real persistence without external services.
- SQLite constraints are reliable and easy to defend.
- No native addon dependency like `better-sqlite3`.

## Folder Structure

```text
server/
  index.js
  package.json
  src/
    app.js
    db/
      schema.js
      seed.js
    middleware/
      auth.js
    routes/
      venues.js
      bookings.js
      users.js
  test/
    booking-concurrency.test.js
```

## Data Model

### `venues`

Stores sports venues.

Columns:

- `id`: integer primary key
- `name`: venue name
- `sport`: sport type, currently `badminton` or `football`
- `address`: venue address
- `locality`: display area such as Koramangala or Indiranagar
- `rating`: public listing rating where available
- `review_count`: public listing review count where available
- `source_name`: public source used for the seed record
- `source_url`: URL for the public listing
- `open_time`: venue opening time used by app display
- `close_time`: venue closing time used by app display

Seeded source-backed examples:

- Krishna Premier Badminton Arena
- The Bull Ring
- Elite Badminton Arena
- Golden Leg
- The Majesstine Sports

These records are real Bengaluru sports venues seeded into local SQLite so the app can run fully offline during demo while still using non-placeholder venue data.

### `users`

Stores selectable demo users in SQLite.

Columns:

- `id`: text primary key used in `X-User-Id`
- `name`: display name shown in Flutter login
- `phone`: demo phone number
- `created_at`: timestamp

Seeded users:

- `u1`: Alice Kumar
- `u2`: Bob Mathew
- `u3`: Charlie Rao

These are persisted rows, not Flutter constants or in-memory backend objects.

### `slots`

Stores recurring hourly slot templates for each venue.

Columns:

- `id`: integer primary key
- `venue_id`: foreign key to `venues.id`
- `start_time`: text time, for example `06:00`
- `end_time`: text time, for example `07:00`

Important design decision:

Slots are templates, not date-specific rows. The selected date comes from the booking request.

Why:

- Seed data stays small.
- Same venue schedule can be reused for any date.
- Availability is calculated by joining `slots` with `bookings` for the selected date.

### `bookings`

Stores actual user bookings.

Columns:

- `id`: integer primary key
- `slot_id`: foreign key to `slots.id`
- `user_id`: persisted user id from `users.id`, for example `u1`
- `booking_date`: date string in `YYYY-MM-DD`
- `created_at`: timestamp

Critical constraint:

```sql
UNIQUE(slot_id, booking_date)
```

This is the most important backend line. It means the same slot on the same date cannot be inserted twice.

## Concurrency Guarantee

The backend does not rely on checking availability first and then inserting later. That pattern can race.

Instead, booking works like this:

1. Validate request.
2. Confirm slot exists.
3. Try one `INSERT INTO bookings`.
4. If insert succeeds, return `201 Created`.
5. If SQLite rejects the unique constraint, return `409 Conflict`.

Why it is safe:

- SQLite serializes writes.
- The unique index is checked atomically inside the database.
- If two users book the same slot at the same time, only one insert can commit.
- The losing request gets constraint error `errcode === 2067`.

Defense sentence:

"The app-level check is only for UX; the actual no-double-booking guarantee is the SQLite unique constraint on `(slot_id, booking_date)`, and the API maps that constraint failure to HTTP `409 Conflict`."

## API Endpoints

### `GET /health`

Returns backend health.

Response:

```json
{ "status": "ok" }
```

Use this for quick deployment/local checks.

### `GET /venues`

Lists all venues.

Auth: no.

Response:

```json
[
  {
    "id": 1,
    "name": "Smash Arena",
    "sport": "badminton",
    "address": "12 Court Lane, Koramangala"
  }
]
```

### `GET /venues/:id/slots?date=YYYY-MM-DD`

Lists all slots for a venue and date with booking status.

Auth: no.

Validation:

- Missing/invalid `date`: `400`
- Unknown venue: `404`

Response shape:

```json
{
  "venue": {
    "id": 1,
    "name": "Smash Arena",
    "sport": "badminton",
    "address": "12 Court Lane, Koramangala"
  },
  "slots": [
    {
      "id": 1,
      "venue_id": 1,
      "start_time": "06:00",
      "end_time": "07:00",
      "is_booked": 0,
      "booked_by": null
    }
  ]
}
```

Logic:

- Reads venue by id.
- Queries all slots for that venue.
- Left joins bookings for the requested date.
- Returns `is_booked = 1` if a booking row exists.

### `POST /bookings`

Books one slot for the current user.

Auth: yes, `X-User-Id` header.

Request:

```json
{
  "slot_id": 1,
  "booking_date": "2026-06-10"
}
```

Success response: `201 Created`

```json
{
  "booking": {
    "id": 10,
    "slot_id": 1,
    "user_id": "u1",
    "booking_date": "2026-06-10",
    "created_at": "2026-06-10 12:00:00",
    "start_time": "06:00",
    "end_time": "07:00",
    "venue_name": "Smash Arena",
    "venue_id": 1,
    "sport": "badminton",
    "address": "12 Court Lane, Koramangala"
  }
}
```

Error cases:

- Missing/invalid auth: `401`
- Missing `slot_id` or `booking_date`: `400`
- Bad date format: `422`
- Slot not found: `404`
- Slot already booked: `409`
- Unexpected server error: `500`

Why `409`:

`409 Conflict` means the request is valid, but conflicts with current resource state. Here, the slot was already taken.

### `GET /users/:id/bookings`

Lists bookings for one user.

Auth: yes, `X-User-Id` header.

Rules:

- User can only fetch their own bookings.
- If path user id does not match header user id, return `403`.

Response:

```json
[
  {
    "id": 10,
    "slot_id": 1,
    "user_id": "u1",
    "booking_date": "2026-06-10",
    "created_at": "2026-06-10 12:00:00",
    "start_time": "06:00",
    "end_time": "07:00",
    "venue_id": 1,
    "venue_name": "Smash Arena",
    "sport": "badminton",
    "address": "12 Court Lane, Koramangala"
  }
]
```

Sort order:

- Newer dates first.
- Within a date, earlier slots first.

### `DELETE /bookings/:id`

Cancels one booking.

Auth: yes, `X-User-Id` header.

Rules:

- Booking must exist.
- Current user must own booking.

Success response:

```json
{ "message": "Booking cancelled" }
```

Error cases:

- Missing/invalid auth: `401`
- Booking not found: `404`
- Trying to cancel another user's booking: `403`

## File-by-File Logic

### `server/package.json`

Defines backend metadata, dependencies, and scripts.

Scripts:

- `npm start`: runs server with `node --experimental-sqlite`.
- `npm run dev`: runs server in watch mode.
- `npm test`: runs Node test runner.
- `npm run test:concurrency`: runs the booking race test.

Dependencies:

- `express`: REST routing.
- `cors`: allow Flutter/web clients to call API.

### `server/index.js`

Production/local entry point.

Logic:

- Imports Express app from `src/app.js`.
- Reads port from `process.env.PORT` or uses `3000`.
- Starts listening.

Why small:

- Keeps app setup testable.
- Tests can import `app` without opening the production port.

### `server/src/app.js`

Builds the Express app.

Logic:

1. Imports Express, CORS, database setup, seed, and route files.
2. Calls `initDb()` to create tables.
3. Calls `seed()` to insert starter venues/slots if database is empty.
4. Creates Express app.
5. Enables CORS and JSON body parsing.
6. Registers `/health`, `/venues`, `/bookings`, and `/users` routes.
7. Exports `app`.

Defense point: app creation is separated from listening, which makes API tests clean.

### `server/src/db/schema.js`

Owns database connection and schema creation.

Important lines:

- `const db = new DatabaseSync(DB_PATH)`: opens SQLite database.
- `PRAGMA journal_mode = WAL`: improves concurrent read/write behavior.
- `PRAGMA foreign_keys = ON`: enforces foreign keys.
- `CREATE TABLE IF NOT EXISTS`: creates all tables safely on startup.

Tables created:

- `venues`
- `slots`
- `bookings`

Critical schema rule:

- `UNIQUE(slot_id, booking_date)` prevents double-booking.

### `server/src/db/seed.js`

Seeds starter data.

Logic:

1. Check venue count.
2. If the database is empty, insert 5 real Bengaluru venues.
3. For each venue, insert hourly slots from 6 AM to 10 PM.
4. If an older local database has the original fake seed names, update those rows in-place.
5. Ensure every seeded venue has slot rows.

Slot generation:

```text
06:00-07:00
07:00-08:00
...
21:00-22:00
```

There are 16 slots per venue.

Why seed is idempotent:

- It checks if venues already exist.
- Restarting server does not duplicate seed data.

### `server/src/middleware/auth.js`

Simple auth middleware using the SQLite `users` table.

Logic:

1. Read `x-user-id` request header.
2. If missing, return `401`.
3. Query `users` by id.
4. If no row exists, return `401`.
5. Attach user object to `req.user`.
6. Continue to route handler.

Defense point: this keeps auth light as requested, but user identity still comes from persistent backend data.

### `server/src/routes/venues.js`

Venue and slot availability routes.

`GET /venues`:

- Reads all venues.
- Returns JSON array.

`GET /venues/:id/slots`:

- Validates `date`.
- Checks venue exists.
- Queries slots with left join to bookings.
- Returns venue and slot list.

Key query idea:

```sql
LEFT JOIN bookings b
  ON b.slot_id = s.id
 AND b.booking_date = ?
```

This calculates availability for only the selected date.

### `server/src/routes/bookings.js`

Booking create/cancel routes.

`POST /bookings`:

- Requires auth.
- Validates `slot_id` is an integer.
- Validates `booking_date` format.
- Checks slot exists.
- Attempts insert into `bookings`.
- Returns full joined booking data on success.
- Catches unique constraint error and returns `409`.

Important line of thinking:

- We do not first ask "is it available?" and then insert.
- We try the insert and let the database decide.

`DELETE /bookings/:id`:

- Requires auth.
- Finds booking.
- Returns `404` if not found.
- Returns `403` if booking belongs to another user.
- Deletes booking if owner matches.

### `server/src/routes/users.js`

User routes.

`GET /users`:

- No auth required.
- Returns selectable users for the login screen.
- Reads from the SQLite `users` table.

`GET /users/:id/bookings`:

- Requires auth.
- Ensures path user id equals authenticated user id.
- Joins bookings to slots and venues.
- Returns display-ready booking data for the app.

Why join:

- Flutter My Bookings screen needs venue name, sport, address, date, and time.
- Returning display-ready data avoids extra API calls.

### `server/test/booking-concurrency.test.js`

Automated proof for the hardest rule.

Logic:

1. Imports Express app without starting main server.
2. Starts app on a random local port.
3. Picks first slot.
4. Deletes any old test booking for `2099-12-31`.
5. Sends two `POST /bookings` requests at the same time:
   - one as `u1`
   - one as `u2`
6. Asserts status codes are exactly `[201, 409]`.
7. Asserts only one database row exists.
8. Cleans up test booking.

Run:

```bash
cd server
npm run test:concurrency
```

This test is the best proof to show judges before or after the live two-device test.

## Status Code Strategy

- `200 OK`: normal reads and cancellation success.
- `201 Created`: booking created.
- `400 Bad Request`: required fields missing or invalid query date.
- `401 Unauthorized`: missing/invalid `X-User-Id`.
- `403 Forbidden`: user tries to access/cancel another user's data.
- `404 Not Found`: venue, slot, or booking does not exist.
- `409 Conflict`: slot already booked.
- `422 Unprocessable Entity`: date format is wrong.
- `500 Internal Server Error`: unexpected server failure.

## Database Cases to Understand

### Case 1: Slot Is Available

Request:

```json
{ "slot_id": 1, "booking_date": "2026-06-10" }
```

Database has no row for `(slot_id=1, booking_date=2026-06-10)`.

Result:

- Insert succeeds.
- API returns `201`.

### Case 2: Slot Is Already Booked

Database already has row for `(slot_id=1, booking_date=2026-06-10)`.

Result:

- Insert violates unique constraint.
- API catches `errcode === 2067`.
- API returns `409` with `code: "SLOT_TAKEN"`.

### Case 3: Same Slot, Different Date

Existing row:

```text
slot_id=1, booking_date=2026-06-10
```

New request:

```text
slot_id=1, booking_date=2026-06-11
```

Result:

- Insert succeeds.
- Unique constraint allows it because date is different.

### Case 4: Different Slot, Same Date

Existing row:

```text
slot_id=1, booking_date=2026-06-10
```

New request:

```text
slot_id=2, booking_date=2026-06-10
```

Result:

- Insert succeeds.
- Unique constraint allows it because slot is different.

### Case 5: Cancel and Rebook

1. User cancels booking.
2. Row is deleted from `bookings`.
3. Same slot/date becomes available again.
4. Another user can book it.

## Deployment Notes

Root config files:

- `railway.json`: Railway deploy config.
- `render.yaml`: Render deploy config.

Important caveat:

- Free-tier deployments may restart and local SQLite files may not be permanent unless persistent disk is configured.
- For hackathon local demo, local SQLite is safest.
- For real production, use Postgres with the same unique constraint.

## What to Say in Defense

Short architecture answer:

"The backend is Express plus SQLite. I seed real source-backed venues, DB-backed demo users, and hourly slot templates. Bookings are date-specific rows. The no-double-booking guarantee is a unique database constraint on `(slot_id, booking_date)`. The booking endpoint attempts a single insert; if the database rejects it, I return `409 Conflict`. I also added a concurrency test that fires two simultaneous booking requests and proves exactly one succeeds."

Why not app-level locking:

- Locks are easy to get wrong.
- Multiple server processes would break in-memory locks.
- Database constraints remain correct across processes.

Why SQLite is acceptable:

- The task requires local demo and real persistence.
- SQLite is reliable for this scope.
- WAL mode supports good local read/write behavior.
- The same schema idea ports directly to Postgres.

## Likely Live Change Areas

Safe small changes:

- Add a new seeded user in `server/src/db/seed.js`.
- Add a sport field display in `GET /venues`.
- Add a new venue in `seed.js`.
- Change opening hours by editing the seed slot loop.
- Add an endpoint filter such as `/venues?sport=badminton`.
- Add validation to prevent booking past dates.
