const express = require('express');
const { db } = require('../db/schema');
const { auth } = require('../middleware/auth');

const router = express.Router();

router.get('/', (_req, res) => {
  const users = db.prepare('SELECT id, name, phone FROM users ORDER BY id').all();
  res.json(users);
});

router.get('/:id/bookings', auth, (req, res) => {
  if (req.params.id !== req.user.id) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  const bookings = db.prepare(`
    SELECT b.id, b.slot_id, b.user_id, b.booking_date, b.created_at,
           s.start_time, s.end_time,
           v.id as venue_id, v.name as venue_name, v.sport, v.address
    FROM bookings b
    JOIN slots s ON s.id = b.slot_id
    JOIN venues v ON v.id = s.venue_id
    WHERE b.user_id = ?
    ORDER BY b.booking_date DESC, s.start_time
  `).all(req.params.id);

  res.json(bookings);
});

module.exports = router;
