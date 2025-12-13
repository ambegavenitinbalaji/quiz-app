require("dotenv").config();

const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const bodyParser = require('body-parser');
const connectDB = require('./config/db');
const quizzesRoute = require('./routes/quizzes');
const errorHandler = require('./middlewares/errorHandler');

console.log("🔥 server.js loaded…");

const app = express();
connectDB();

app.use(cors());
app.use(morgan('dev'));
app.use(bodyParser.json({ limit: '1mb' }));

app.use('/api/quizzes', quizzesRoute);

app.get('/', (req, res) => res.send('Mini Quiz API'));

app.use(errorHandler);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
    console.log(`\n🚀 Server is running!`);
    console.log(`📌 Port: ${PORT}`);
    console.log(`🌐 URL: http://localhost:${PORT}\n`);
});
