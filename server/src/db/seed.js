const { db } = require('./schema');

const VENUES = [
  { name: 'Smash Arena', sport: 'badminton', address: '12 Court Lane, Koramangala' },
  { name: 'Green Turf FC', sport: 'football', address: '45 Stadium Rd, Indiranagar' },
  { name: 'Court Kings', sport: 'badminton', address: '7 Racket St, Whitefield' },
  { name: 'Premier Grounds', sport: 'football', address: '88 Turf Ave, HSR Layout' },
  { name: 'Rally Point', sport: 'badminton', address: '3 Shuttle Cross, JP Nagar' },
];

function seed() {
  const existingVenues = db.prepare('SELECT COUNT(*) as count FROM venues').get();
  if (existingVenues.count > 0) return;

  const insertVenue = db.prepare(
    'INSERT INTO venues (name, sport, address) VALUES (?, ?, ?)'
  );
  const insertSlot = db.prepare(
    'INSERT INTO slots (venue_id, start_time, end_time) VALUES (?, ?, ?)'
  );

  for (const venue of VENUES) {
    const result = insertVenue.run(venue.name, venue.sport, venue.address);
    const venueId = result.lastInsertRowid;

    for (let hour = 6; hour < 22; hour++) {
      const start = `${String(hour).padStart(2, '0')}:00`;
      const end = `${String(hour + 1).padStart(2, '0')}:00`;
      insertSlot.run(venueId, start, end);
    }
  }
}

module.exports = { seed };
