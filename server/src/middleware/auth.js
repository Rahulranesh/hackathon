const USERS = {
  'u1': { id: 'u1', name: 'Alice' },
  'u2': { id: 'u2', name: 'Bob' },
  'u3': { id: 'u3', name: 'Charlie' },
};

function auth(req, res, next) {
  const userId = req.headers['x-user-id'];
  if (!userId || !USERS[userId]) {
    return res.status(401).json({ error: 'Missing or invalid X-User-Id header' });
  }
  req.user = USERS[userId];
  next();
}

module.exports = { auth, USERS };
