const assert = require('node:assert/strict');
const { after, before, test } = require('node:test');
const { app } = require('../src/app');
const { db } = require('../src/db/schema');

let server;
let baseUrl;

before(async () => {
  server = app.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve) => server.close(resolve));
});

test('same slot can only be booked once under concurrent requests', async () => {
  const slot = db.prepare('SELECT id FROM slots ORDER BY id LIMIT 1').get();
  const bookingDate = '2099-12-31';

  db.prepare('DELETE FROM bookings WHERE slot_id = ? AND booking_date = ?').run(
    slot.id,
    bookingDate,
  );

  const body = JSON.stringify({ slot_id: slot.id, booking_date: bookingDate });
  const makeRequest = (userId) =>
    fetch(`${baseUrl}/bookings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': userId,
      },
      body,
    });

  const responses = await Promise.all([makeRequest('u1'), makeRequest('u2')]);
  const statuses = responses.map((response) => response.status).sort();

  assert.deepEqual(statuses, [201, 409]);

  const winner = responses.find((response) => response.status === 201);
  const payload = await winner.json();

  assert.equal(payload.booking.slot_id, slot.id);
  assert.equal(payload.booking.booking_date, bookingDate);
  assert.equal(typeof payload.booking.sport, 'string');
  assert.equal(typeof payload.booking.address, 'string');

  const rows = db
    .prepare('SELECT COUNT(*) AS count FROM bookings WHERE slot_id = ? AND booking_date = ?')
    .get(slot.id, bookingDate);

  assert.equal(rows.count, 1);

  db.prepare('DELETE FROM bookings WHERE slot_id = ? AND booking_date = ?').run(
    slot.id,
    bookingDate,
  );
});
