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

test('venues endpoint returns source-backed venue records', async () => {
  const response = await fetch(`${baseUrl}/venues`);
  const venues = await response.json();

  assert.equal(response.status, 200);
  assert.ok(venues.length >= 5);
  assert.ok(venues.some((venue) => venue.name === 'The Bull Ring'));
  for (const name of ['The Bull Ring', 'Golden Leg', 'The Majesstine Sports']) {
    const venue = venues.find((item) => item.name === name);
    assert.ok(venue);
    assert.ok(venue.source_name);
    assert.ok(venue.source_url);
  }
});

test('slot listing validates date and returns availability fields', async () => {
  const badResponse = await fetch(`${baseUrl}/venues/1/slots?date=10-06-2026`);
  assert.equal(badResponse.status, 400);

  const response = await fetch(`${baseUrl}/venues/1/slots?date=2099-11-11`);
  const payload = await response.json();

  assert.equal(response.status, 200);
  assert.equal(payload.slots.length, 16);
  assert.ok(Object.hasOwn(payload.slots[0], 'is_booked'));
  assert.ok(Object.hasOwn(payload.slots[0], 'booked_by'));
});

test('booking endpoints enforce auth, ownership, and cancellation', async () => {
  const slot = db.prepare('SELECT id FROM slots ORDER BY id LIMIT 1').get();
  const bookingDate = '2099-11-12';
  db.prepare('DELETE FROM bookings WHERE slot_id = ? AND booking_date = ?').run(
    slot.id,
    bookingDate,
  );

  const unauthenticated = await fetch(`${baseUrl}/bookings`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ slot_id: slot.id, booking_date: bookingDate }),
  });
  assert.equal(unauthenticated.status, 401);

  const create = await fetch(`${baseUrl}/bookings`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-User-Id': 'u1',
    },
    body: JSON.stringify({ slot_id: slot.id, booking_date: bookingDate }),
  });
  const payload = await create.json();
  assert.equal(create.status, 201);

  const forbiddenList = await fetch(`${baseUrl}/users/u1/bookings`, {
    headers: { 'X-User-Id': 'u2' },
  });
  assert.equal(forbiddenList.status, 403);

  const forbiddenCancel = await fetch(`${baseUrl}/bookings/${payload.booking.id}`, {
    method: 'DELETE',
    headers: { 'X-User-Id': 'u2' },
  });
  assert.equal(forbiddenCancel.status, 403);

  const cancel = await fetch(`${baseUrl}/bookings/${payload.booking.id}`, {
    method: 'DELETE',
    headers: { 'X-User-Id': 'u1' },
  });
  assert.equal(cancel.status, 200);

  const rows = db
    .prepare('SELECT COUNT(*) AS count FROM bookings WHERE slot_id = ? AND booking_date = ?')
    .get(slot.id, bookingDate);
  assert.equal(rows.count, 0);
});
