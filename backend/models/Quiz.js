const mongoose = require('mongoose');

const OptionSchema = new mongoose.Schema({
  text: { type: String, required: true }
}, { _id: false });

const QuestionSchema = new mongoose.Schema({
  questionText: { type: String, required: true },
  answerType: { type: String, enum: ['MCQ', 'ShortText'], required: true },
  options: { type: [OptionSchema], default: undefined }, // only for MCQ
  required: { type: Boolean, default: false }
}, { _id: true, timestamps: false });

const QuizSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  questions: { type: [QuestionSchema], default: [] }
}, { timestamps: true });

module.exports = mongoose.model('Quiz', QuizSchema);
