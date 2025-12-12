const Quiz = require('../models/Quiz');
const Response = require('../models/Response');
const mongoose = require('mongoose');

// Validate individual question
const validateQuestion = (q) => {
  if (!q.questionText || typeof q.questionText !== 'string') {
    return 'questionText required and must be string';
  }
  if (!['MCQ', 'ShortText'].includes(q.answerType)) {
    return 'answerType must be MCQ or ShortText';
  }
  if (q.answerType === 'MCQ') {
    if (!Array.isArray(q.options) || q.options.length < 2) {
      return 'MCQ questions must have options array with at least 2 options';
    }
    for (const opt of q.options) {
      if (!opt.text || typeof opt.text !== 'string') {
        return 'Each option must have text';
      }
    }
  }
  return null;
};

// CRUD Functions
const createQuiz = async (req, res, next) => {
  try {
    const { title, description, questions } = req.body;
    if (!title) return res.status(400).json({ message: 'title is required' });
    if (questions && !Array.isArray(questions)) return res.status(400).json({ message: 'questions must be array' });

    if (questions) {
      for (const q of questions) {
        const err = validateQuestion(q);
        if (err) return res.status(400).json({ message: err });
      }
    }

    const quiz = new Quiz({ title, description, questions });
    await quiz.save();
    res.status(201).json(quiz);
  } catch (err) { next(err); }
};

const listQuizzes = async (req, res, next) => {
  try {
    const quizzes = await Quiz.find({}, 'title description createdAt updatedAt').sort({ createdAt: -1 });
    res.json(quizzes);
  } catch (err) { next(err); }
};

const getQuiz = async (req, res, next) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ message: 'Invalid quiz id' });
    const quiz = await Quiz.findById(id);
    if (!quiz) return res.status(404).json({ message: 'Quiz not found' });
    res.json(quiz);
  } catch (err) { next(err); }
};

const updateQuiz = async (req, res, next) => {
  try {
    const { id } = req.params;
    const update = req.body;
    if (update.questions) {
      for (const q of update.questions) {
        const err = validateQuestion(q);
        if (err) return res.status(400).json({ message: err });
      }
    }
    const quiz = await Quiz.findByIdAndUpdate(id, update, { new: true, runValidators: true });
    if (!quiz) return res.status(404).json({ message: 'Quiz not found' });
    res.json(quiz);
  } catch (err) { next(err); }
};

const deleteQuiz = async (req, res, next) => {
  try {
    const { id } = req.params;
    const quiz = await Quiz.findByIdAndDelete(id);
    if (!quiz) return res.status(404).json({ message: 'Quiz not found' });
    await Response.deleteMany({ quizId: id }); // delete related responses
    res.json({ message: 'Quiz deleted' });
  } catch (err) { next(err); }
};

// ✅ Export all functions as one object
module.exports = {
  createQuiz,
  listQuizzes,
  getQuiz,
  updateQuiz,
  deleteQuiz,
};
