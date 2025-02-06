const mysql = require('mysql');
const fs = require('fs');
const path = require('path');

// Create MySQL connection
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'NEW_user_db',
});

// Connect to the database
connection.connect((err) => {
  if (err) {
    console.error('Error connecting to the database:', err.stack);
    return;
  }
  console.log('Connected to the database!');
});

// Read the SQL file and execute it
fs.readFile(path.join(__dirname, 'db', 'setup.sql'), 'utf8', (err, sql) => {
  if (err) {
    console.error('Error reading SQL file:', err);
    return;
  }
  
  // Run the SQL queries
  connection.query(sql, (err, results) => {
    if (err) {
      console.error('Error executing SQL:', err);
      return;
    }
    console.log('Database setup complete:', results);
  });
});

// Close the connection
connection.end();
