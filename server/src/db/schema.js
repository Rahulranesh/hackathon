const { DatabaseSync } = require('node:sqlite');
const path = require('path');

const DB_PATH = path.join(__dirname, '../../quickslot.db');
const db = new DatabaseSync(DB_PATH);

db.exec('PRAGMA journal_mode = WAL');
db.exec('PRAGMA foreign_keys = ON');

function initDb() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS venues (
      id        INTEGER PRIMARY KEY AUTOINCREMENT,
      name      TEXT NOT NULL,
      sport     TEXT NOT NULL,
      address   TEXT NOT NULL,
      locality  TEXT,
      rating    REAL,
      review_count INTEGER,
      source_name TEXT,
      source_url TEXT,
      open_time TEXT DEFAULT '06:00',
      close_time TEXT DEFAULT '22:00'
    );

    CREATE TABLE IF NOT EXISTS users (
      id          TEXT PRIMARY KEY,
      name        TEXT NOT NULL,
      phone       TEXT,
      created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS slots (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      venue_id   INTEGER NOT NULL REFERENCES venues(id),
      start_time TEXT NOT NULL,
      end_time   TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS bookings (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      slot_id      INTEGER NOT NULL REFERENCES slots(id),
      user_id      TEXT    NOT NULL REFERENCES users(id),
      booking_date TEXT    NOT NULL,
      created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(slot_id, booking_date)
    );
  `);

  ensureVenueColumn('locality', 'TEXT');
  ensureVenueColumn('rating', 'REAL');
  ensureVenueColumn('review_count', 'INTEGER');
  ensureVenueColumn('source_name', 'TEXT');
  ensureVenueColumn('source_url', 'TEXT');
  ensureVenueColumn('open_time', "TEXT DEFAULT '06:00'");
  ensureVenueColumn('close_time', "TEXT DEFAULT '22:00'");
}

function ensureVenueColumn(name, definition) {
  const columns = db.prepare('PRAGMA table_info(venues)').all();
  if (!columns.some((column) => column.name === name)) {
    db.exec(`ALTER TABLE venues ADD COLUMN ${name} ${definition}`);
  }
}

module.exports = { db, initDb };
