const express = require('express');
const { db } = require('../db/schema');
const { auth } = require('../middleware/auth');

const router = express.Router();

router.post('/', auth, (req, res) => {
  const { slot_id, booking_date } = req.body;

  if (!Number.isInteger(slot_id) || !booking_date) {
    return res.status(400).json({ error: 'slot_id and booking_date are required' });
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(booking_date)) {
    return res.status(422).json({ error: 'booking_date must be YYYY-MM-DD' });
  }

  const slot = db.prepare('SELECT * FROM slots WHERE id = ?').get(slot_id);
  if (!slot) return res.status(404).json({ error: 'Slot not found' });

  try {
    const insert = db.prepare(
      'INSERT INTO bookings (slot_id, user_id, booking_date) VALUES (?, ?, ?)'
    );
    const result = insert.run(slot_id, req.user.id, booking_date);

    const booking = db.prepare(`
      SELECT b.id, b.slot_id, b.user_id, b.booking_date, b.created_at,
             s.start_time, s.end_time,
             v.name as venue_name, v.id as venue_id, v.sport, v.address
      FROM bookings b
      JOIN slots s ON s.id = b.slot_id
      JOIN venues v ON v.id = s.venue_id
      WHERE b.id = ?
    `).get(result.lastInsertRowid);

    res.status(201).json({ booking });
  } catch (err) {
    if (err.errcode === 2067) {
      return res.status(409).json({ error: 'Slot already booked', code: 'SLOT_TAKEN' });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.delete('/:id', auth, (req, res) => {
  const booking = db.prepare('SELECT * FROM bookings WHERE id = ?').get(req.params.id);

  if (!booking) return res.status(404).json({ error: 'Booking not found' });
  if (booking.user_id !== req.user.id) {
    return res.status(403).json({ error: 'Not your booking' });
  }

  db.prepare('DELETE FROM bookings WHERE id = ?').run(req.params.id);
  res.json({ message: 'Booking cancelled' });
});

module.exports = router;
