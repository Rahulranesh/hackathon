const express = require('express');
const cors = require('cors');
const { initDb } = require('./src/db/schema');

const venueRoutes = require('./src/routes/venues');
const bookingRoutes = require('./src/routes/bookings');
const userRoutes = require('./src/routes/users');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

initDb();

app.use('/venues', venueRoutes);
app.use('/bookings', bookingRoutes);
app.use('/users', userRoutes);

app.listen(PORT, () => {
  console.log(`QuickSlot server running on http://localhost:${PORT}`);
});
