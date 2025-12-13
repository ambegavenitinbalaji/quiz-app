const mongoose = require('mongoose');
const connectDB = require('../config/db');
const Quiz = require('../models/Quiz');

const run = async () => {
  await connectDB();
  await Quiz.deleteMany({});
  const sample = new Quiz({
    title: 'Sample Trivia',
    description: 'A small sample quiz',
    questions: [
      {
        questionText: 'What is the capital of India?',
        answerType: 'MCQ',
        options: [{ text: 'Mumbai' }, { text: 'New Delhi' }, { text: 'Bengaluru' }],
        required: true
      },
      {
        questionText: 'Name your favorite fruit',
        answerType: 'ShortText',
        required: false
      }
    ]
  });
  await sample.save();
  console.log('Seed created:', sample._id);
  process.exit(0);
};

run().catch(err => { console.error(err); process.exit(1); });
