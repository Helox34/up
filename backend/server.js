// backend/server.js
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// DB init
const DB_PATH = path.join(__dirname, 'db.sqlite');
const dbExists = fs.existsSync(DB_PATH);
const db = new sqlite3.Database(DB_PATH);

const initSql = fs.readFileSync(path.join(__dirname, 'migrations', 'init.sql'), 'utf8');

db.serialize(() => {
  db.exec(initSql, (err) => {
    if (err) {
      console.error('Error initializing DB', err);
    } else {
      console.log('DB initialized');
      // seed sample product
      db.get('SELECT COUNT(*) as cnt FROM products', (e, row) => {
        if (!row || row.cnt === 0) {
          const stmt = db.prepare('INSERT INTO products (id,name,description,price) VALUES (?,?,?,?)');
          stmt.run(uuidv4(), 'Koszulka WK', 'Koszulka treningowa w tłoczonym logo WK', 79.99);
          stmt.run(uuidv4(), 'Shaker WK', 'Shaker 700ml', 29.90);
          stmt.finalize();
        }
      });
    }
  });
});

// Routes
app.get('/', (req, res) => res.json({ status: 'ok', version: '1.0' }));

// Posts route
app.post('/posts', (req, res) => {
  const { author = 'anon', content } = req.body;
  if (!content) return res.status(400).json({ error: 'content required' });
  const id = uuidv4();
  const created_at = Date.now();
  db.run('INSERT INTO posts (id,author,content,created_at) VALUES (?,?,?,?)',
    [id, author, content, created_at], function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ id, author, content, imageUrl, created_at });
    });
});

app.get('/posts', (req, res) => {
  db.all('SELECT * FROM posts ORDER BY created_at DESC LIMIT 100', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Products
app.get('/products', (req, res) => {
  db.all('SELECT * FROM products', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Challenges
app.get('/challenges', (req, res) => {
  db.all('SELECT * FROM challenges', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Achievements (demo: list)
app.get('/achievements', (req, res) => {
  db.all('SELECT * FROM achievements ORDER BY awarded_at DESC', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Backend running on http://localhost:${PORT}`);
});
