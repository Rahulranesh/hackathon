const { db } = require('./schema');

const USERS = [
  { id: 'u1', name: 'Alice Kumar', phone: '+91-90000-00001' },
  { id: 'u2', name: 'Bob Mathew', phone: '+91-90000-00002' },
  { id: 'u3', name: 'Charlie Rao', phone: '+91-90000-00003' },
];

const VENUES = [
  {
    legacyName: 'Smash Arena',
    name: 'Krishna Premier Badminton Arena',
    sport: 'badminton',
    address: 'Guava Garden, No.21, 1st Cross Rd, 5th Block, Koramangala, Bengaluru',
    locality: 'Koramangala',
    rating: null,
    reviewCount: null,
    sourceName: 'Playo',
    sourceUrl:
      'https://playo.co/venues/near-st-johns-medical-college-hospital-bengaluru/krishna-premier-badminton-arena-koramangala-near-st-johns-medical-college-hospital-bengaluru',
    openTime: '06:00',
    closeTime: '22:00',
  },
  {
    legacyName: 'Green Turf FC',
    name: 'The Bull Ring',
    sport: 'football',
    address:
      'No 36, Old Madras Road, next to BMTC 6th Depot, Swami Vivekananda Rd, Indiranagar, Bengaluru - 560038',
    locality: 'Indiranagar',
    rating: null,
    reviewCount: null,
    sourceName: 'KheloMore',
    sourceUrl: 'https://www.khelomore.com/sports-venues/bengaluru/the-bull-ring-indiranagar/374',
    openTime: '06:00',
    closeTime: '22:00',
  },
  {
    legacyName: 'Court Kings',
    name: 'Elite Badminton Arena',
    sport: 'badminton',
    address:
      '7A, 4th C Main Road, Dr. Vivekananda Layout, Santrupthi Nagar, JP Nagar 7th Phase, Arekere, Bengaluru',
    locality: 'JP Nagar 7th Phase',
    rating: null,
    reviewCount: null,
    sourceName: 'Playo',
    sourceUrl:
      'https://playo.co/venues/jp-nagar-7th-phase-bengaluru/elite-badminton-arena-jp-nagar-7th-phase-bengaluru',
    openTime: '06:00',
    closeTime: '22:00',
  },
  {
    legacyName: 'Premier Grounds',
    name: 'Golden Leg',
    sport: 'football',
    address: 'No. 1, Service Road, Near Green View Hospital, Jakkasandra Extension, Bengaluru',
    locality: 'Koramangala',
    rating: 4.3,
    reviewCount: 169,
    sourceName: 'Playo',
    sourceUrl: 'https://playo.co/venues/koramangala-bengaluru/golden-leg-koramangala-bengaluru',
    openTime: '06:00',
    closeTime: '22:00',
  },
  {
    legacyName: 'Rally Point',
    name: 'The Majesstine Sports',
    sport: 'badminton',
    address: '383/1-10, 5th Cross, Garebhavipalya, Opp HSR Trinity Apartments, Bengaluru - 560068',
    locality: 'HSR Layout',
    rating: null,
    reviewCount: null,
    sourceName: 'Majesstine Sports',
    sourceUrl: 'https://www.majesstinesports.com/',
    openTime: '06:00',
    closeTime: '22:00',
  },
];

function seed() {
  seedUsers();

  const existingVenues = db.prepare('SELECT COUNT(*) as count FROM venues').get();

  if (existingVenues.count === 0) {
    for (const venue of VENUES) {
      const venueId = insertVenue(venue);
      seedSlotsForVenue(venueId);
    }
    return;
  }

  for (const venue of VENUES) {
    const current = db
      .prepare('SELECT id FROM venues WHERE name IN (?, ?) LIMIT 1')
      .get(venue.name, venue.legacyName);

    if (current) {
      updateVenue(current.id, venue);
      ensureSlotsForVenue(current.id);
    } else {
      const venueId = insertVenue(venue);
      seedSlotsForVenue(venueId);
    }
  }
}

function seedUsers() {
  const upsertUser = db.prepare(
    `INSERT INTO users (id, name, phone)
     VALUES (?, ?, ?)
     ON CONFLICT(id) DO UPDATE SET
       name = excluded.name,
       phone = excluded.phone`,
  );

  for (const user of USERS) {
    upsertUser.run(user.id, user.name, user.phone);
  }
}

function insertVenue(venue) {
  const result = db
    .prepare(
      `INSERT INTO venues (
        name, sport, address, locality, rating, review_count,
        source_name, source_url, open_time, close_time
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    )
    .run(
      venue.name,
      venue.sport,
      venue.address,
      venue.locality,
      venue.rating,
      venue.reviewCount,
      venue.sourceName,
      venue.sourceUrl,
      venue.openTime,
      venue.closeTime,
    );

  return result.lastInsertRowid;
}

function updateVenue(venueId, venue) {
  db.prepare(
    `UPDATE venues
       SET name = ?, sport = ?, address = ?, locality = ?, rating = ?,
           review_count = ?, source_name = ?, source_url = ?,
           open_time = ?, close_time = ?
     WHERE id = ?`,
  ).run(
    venue.name,
    venue.sport,
    venue.address,
    venue.locality,
    venue.rating,
    venue.reviewCount,
    venue.sourceName,
    venue.sourceUrl,
    venue.openTime,
    venue.closeTime,
    venueId,
  );
}

function ensureSlotsForVenue(venueId) {
  const count = db.prepare('SELECT COUNT(*) as count FROM slots WHERE venue_id = ?').get(venueId);
  if (count.count === 0) {
    seedSlotsForVenue(venueId);
  }
}

function seedSlotsForVenue(venueId) {
  const insertSlot = db.prepare(
    'INSERT INTO slots (venue_id, start_time, end_time) VALUES (?, ?, ?)',
  );

  for (let hour = 6; hour < 22; hour++) {
    const start = `${String(hour).padStart(2, '0')}:00`;
    const end = `${String(hour + 1).padStart(2, '0')}:00`;
    insertSlot.run(venueId, start, end);
  }
}

module.exports = { seed, VENUES, USERS };
