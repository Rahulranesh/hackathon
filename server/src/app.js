const express = require('express');
const cors = require('cors');
const { initDb } = require('./db/schema');
const { seed } = require('./db/seed');

const venueRoutes = require('./routes/venues');
const bookingRoutes = require('./routes/bookings');
const userRoutes = require('./routes/users');

initDb();
seed();

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.use('/venues', venueRoutes);
app.use('/bookings', bookingRoutes);
app.use('/users', userRoutes);

module.exports = { app };
