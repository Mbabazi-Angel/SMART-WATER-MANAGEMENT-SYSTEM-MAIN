const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mysql = require('mysql2'); // Import MySQL library

const app = express();
const PORT = 5000;
const SECRET_KEY = 'your_secret_key'; // Use a secure key for JWT signing

// Create MySQL connection
const db = mysql.createConnection({
  host: 'localhost', // Your MySQL host
  user: 'root', // Your MySQL username
  password: '', // Your MySQL password
  database: 'NEW_user_db', // Your database name
});

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Handle user registration
app.post('/register', async (req, res) => {
  const {
    firstName,
    lastName,
    email,
    password,
    accountType,
    district,
    neighborhood,
    address,
    phoneNumber,
  } = req.body;

  // Validate input
  if (
    !firstName ||
    !lastName ||
    !email ||
    !password ||
    !accountType ||
    !district ||
    !neighborhood ||
    !address ||
    !phoneNumber
  ) {
    return res.status(400).json({ error: "All fields are required" });
  }

  // Check if user already exists
  db.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Database error" });
    }

    if (results.length > 0) {
      return res.status(400).json({ error: "User with this email already exists" });
    }

    try {
      // Hash the password before saving it
      const hashedPassword = await bcrypt.hash(password, 10);

      // Insert user into the database
      db.query(
        'INSERT INTO users (first_name, last_name, email, password, account_type, district, neighborhood, address, phone_number) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          firstName,
          lastName,
          email,
          hashedPassword,
          accountType,
          district,
          neighborhood,
          address,
          phoneNumber,
        ],
        (err, result) => {
          if (err) {
            console.error(err);
            return res.status(500).json({ error: "Failed to register user" });
          }

          res.status(201).json({ message: "User registered successfully" });
        }
      );
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Internal server error" });
    }
  });
});

// Handle user login
app.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email and password are required" });
  }

  // Check if user exists
  db.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Database error" });
    }

    if (results.length === 0) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    const user = results[0];

    // Compare the entered password with the hashed password stored in DB
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    // Generate JWT token
    const token = jwt.sign({ userId: user.id }, SECRET_KEY, { expiresIn: '1h' });

    // Send response with JWT token
    res.status(200).json({ message: "Login successful", token });
  });
});

// Start the server
app.listen(PORT, "172.20.10.3", () => {
  console.log(`Server is running on http://172.20.10.3:${PORT}`);
});


// Endpoint to fetch list of districts
app.get('/districts', (req, res) => {
  // Example list of districts, replace with real data if necessary
  const districts = ['Kampala', 'Mbarara', 'Gulu', 'Entebbe'];
  res.json(districts);
});

// Endpoint to fetch neiaghborhoods based on the selected district
app.get('/neighborhoods', (req, res) => {
  const district = req.query.district;
  let neighborhoods = [];

  // Example: Return neighborhoods based on the selected district
  if (district === 'Kampala') {
    neighborhoods = ['Makerere', 'Kololo', 'Kawempe'];
  } else if (district === 'Mbarara') {
    neighborhoods = ['Nyamitanga', 'Kakoba', 'Buhango'];
  } else if (district === 'Gulu') {
    neighborhoods = ['Layibi', 'Koro', 'Bardege'];
  }

  res.json(neighborhoods);
});


// Endpoint to submit feedback
app.post('/submit-feedback', (req, res) => {
  const { content } = req.body;

  if (!content) {
    return res.status(400).json({ error: "Content is required" });
  }

  // Insert feedback into the database
  db.query('INSERT INTO feedback (content) VALUES (?)', [content], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Failed to submit feedback" });
    }

    res.status(201).json({ message: "Feedback submitted successfully" });
  });
});

// Endpoint to submit leakage report
app.post('/submit-leakage-report', (req, res) => {
  const { description } = req.body;

  if (!description) {
    return res.status(400).json({ error: "Description is required" });
  }

  // Insert leakage report into the database
  db.query('INSERT INTO leakage_reports (description) VALUES (?)', [description], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Failed to submit leakage report" });
    }

    res.status(201).json({ message: "Leakage report submitted successfully" });
  });
});


app.get('/alerts', (req, res) => {
  const alerts = [
    { type: 'water', color: 'yellow', message: 'Expected water shortage in five days', timestamp: '12/20/24' },
    { type: 'water', color: 'red', message: 'Water critically low', timestamp: '12/18/24' },
    { type: 'maintenance', color: 'yellow', message: 'Detected leakage in pipeline', timestamp: '12/17/24' },
    { type: 'water', color: 'green', message: '30% more water consumed this week', timestamp: '12/16/24' },
    { type: 'water', color: 'green', message: 'No shortage expected for two weeks', timestamp: '12/15/24' }
  ];
  res.json(alerts);
});


// Endpoint to fetch user information
app.get('/user-info', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: "Authorization token required" });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    const userId = decoded.userId;

    db.query(
      'SELECT id, first_name, last_name, email, account_type, district, neighborhood, address, phone_number FROM users WHERE id = ?',
      [userId],
      (err, results) => {
        if (err) {
          console.error(err);
          return res.status(500).json({ error: "Database error" });
        }

        if (results.length === 0) {
          return res.status(404).json({ error: "User not found" });
        }

        res.status(200).json(results[0]);
      }
    );
  } catch (error) {
    return res.status(403).json({ error: "Invalid token" });
  }
});


app.put('/update-profile', (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ error: "Authorization token required" });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Verify the token and extract userId
    const decoded = jwt.verify(token, SECRET_KEY);
    const userId = decoded.userId; 

    const {
      first_name,
      last_name,
      email,
      account_type,
      district,
      neighborhood,
      address,
      phone_number,
    } = req.body;

    // Validate at least one field is provided for the update
    if (
      !first_name &&
      !last_name &&
      !email &&
      !account_type &&
      !district &&
      !neighborhood &&
      !address &&
      !phone_number
    ) {
      return res.status(400).json({ error: "At least one field must be provided to update" });
    }

    // Build dynamic SQL query for the update
    let updateFields = [];
    let queryParams = [];

    if (first_name) {
      updateFields.push("first_name = ?");
      queryParams.push(first_name);
    }
    if (last_name) {
      updateFields.push("last_name = ?");
      queryParams.push(last_name);
    }
    if (email) {
      updateFields.push("email = ?");
      queryParams.push(email);
    }
    if (account_type) {
      updateFields.push("account_type = ?");
      queryParams.push(account_type);
    }
    if (district) {
      updateFields.push("district = ?");
      queryParams.push(district);
    }
    if (neighborhood) {
      updateFields.push("neighborhood = ?");
      queryParams.push(neighborhood);
    }
    if (address) {
      updateFields.push("address = ?");
      queryParams.push(address);
    }
    if (phone_number) {
      updateFields.push("phone_number = ?");
      queryParams.push(phone_number);
    }

    // Append userId to query params for WHERE clause
    queryParams.push(userId);

    // Generate the full SQL query dynamically
    const updateQuery = `UPDATE users SET ${updateFields.join(", ")} WHERE id = ?`;

    // Execute the query
    db.query(updateQuery, queryParams, (err, results) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: "Database error" });
      }

      if (results.affectedRows === 0) {
        return res.status(404).json({ error: "User not found" });
      }

      res.status(200).json({ message: "Profile updated successfully" });
    });
  } catch (error) {
    console.error(error);
    return res.status(403).json({ error: "Invalid token" });
  }
});

// Endpoint to receive sensor data
app.post('/sensor-data', (req, res) => {
  const { sensor_id, water_level, water_usage, water_flow, water_pressure } = req.body;

  // Validate required fields
  if (
    !sensor_id ||
    water_level === undefined ||
    water_usage === undefined ||
    water_flow === undefined ||
    water_pressure === undefined
  ) {
    return res.status(400).json({
      error:
        'All fields are required: sensor_id, water_level, water_usage, water_flow, and water_pressure',
    });
  }

  // SQL to insert the received sensor data into the database
  const sql = `INSERT INTO sensor_data (sensor_id, water_level, water_usage, water_flow, water_pressure) VALUES (?, ?, ?, ?, ?)`;
  const values = [sensor_id, water_level, water_usage, water_flow, water_pressure];

  // Query to store the sensor data
  db.query(sql, values, (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to store sensor data' });
    }
    res.status(201).json({ message: 'Sensor data stored successfully' });
  });
});

// Endpoint to get the latest sensor data (water level, usage, flow, pressure)
app.get('/sensor-data', (req, res) => {
  const sql = 'SELECT * FROM sensor_data ORDER BY id DESC LIMIT 1'; // Fetch the latest sensor data
  db.query(sql, (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Database error' });
    }
    if (results.length === 0) {
      return res.status(404).json({ error: 'No sensor data available' });
    }

    // Get the latest sensor data
    const latestData = results[0]; // The most recent record

    // Return the latest sensor data in the response
    res.json({
      sensor_id: latestData.sensor_id || 'Unknown', // Default to 'Unknown' if null
      water_level: latestData.water_level !== null ? latestData.water_level : 0, // Default to 0 if null
      water_usage: latestData.water_usage !== null ? latestData.water_usage : 0, // Default to 0 if null
      water_flow: latestData.water_flow !== null ? latestData.water_flow : 0, // Default to 0 if null
      water_pressure: latestData.water_pressure !== null ? latestData.water_pressure : 0, // Default to 0 if null
    });
  });
});
