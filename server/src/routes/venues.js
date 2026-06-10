const express = require('express');
const { db } = require('../db/schema');

const router = express.Router();

router.get('/', (req, res) => {
  const venues = db.prepare('SELECT * FROM venues').all();
  res.json(venues);
});

router.get('/:id/slots', (req, res) => {
  const { id } = req.params;
  const { date } = req.query;

  if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    return res.status(400).json({ error: 'date query param required (YYYY-MM-DD)' });
  }

  const venue = db.prepare('SELECT * FROM venues WHERE id = ?').get(id);
  if (!venue) return res.status(404).json({ error: 'Venue not found' });

  const slots = db.prepare(`
    SELECT
      s.id,
      s.venue_id,
      s.start_time,
      s.end_time,
      CASE WHEN b.id IS NOT NULL THEN 1 ELSE 0 END AS is_booked,
      b.user_id AS booked_by
    FROM slots s
    LEFT JOIN bookings b ON b.slot_id = s.id AND b.booking_date = ?
    WHERE s.venue_id = ?
    ORDER BY s.start_time
  `).all(date, id);

  res.json({ venue, slots });
});

module.exports = router;
