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
      address   TEXT NOT NULL
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
      user_id      TEXT    NOT NULL,
      booking_date TEXT    NOT NULL,
      created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(slot_id, booking_date)
    );
  `);
}

module.exports = { db, initDb };
