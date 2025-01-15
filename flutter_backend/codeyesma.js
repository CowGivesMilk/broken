const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors());

// MySQL Connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '1234',
  database: 'user_auth',
});

db.connect(err => {
  if (err) throw err;
  console.log('Connected to MySQL');
});

// Sign Up Endpoint
app.post('/signup', (req, res) => {
  const { name, email, password } = req.body;
  const query = 'INSERT INTO users (name, email, password) VALUES (?, ?, ?)';
  db.query(query, [name, email, password], (err) => {
    if (err) return res.status(500).json({ error: 'Sign Up Failed' });
    res.json({ message: 'Sign Up Successful' });
  });
});

// Login Endpoint
app.post('/login', (req, res) => {
  const { email, password } = req.body;
  const query = 'SELECT * FROM users WHERE email = ? AND password = ?';
  db.query(query, [email, password], (err, results) => {
    if (err || results.length === 0) {
      return res.status(401).json({ error: 'Invalid Credentials' });
    }
    res.json({ username: results[0].name });
  });
});

// Start Server
app.listen(3000, () => console.log('Server running on port 3000'));
