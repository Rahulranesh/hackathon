const { db } = require('../db/schema');

function auth(req, res, next) {
  const userId = req.headers['x-user-id'];
  if (!userId) {
    return res.status(401).json({ error: 'Missing or invalid X-User-Id header' });
  }

  const user = db.prepare('SELECT id, name, phone FROM users WHERE id = ?').get(userId);
  if (!user) {
    return res.status(401).json({ error: 'Missing or invalid X-User-Id header' });
  }

  req.user = user;
  next();
}

module.exports = { auth };
