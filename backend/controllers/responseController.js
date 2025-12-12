const Response = require('../models/Response');
const Quiz = require('../models/Quiz');
const mongoose = require('mongoose');

const submitResponse = async (req, res, next) => {
  try {
    const { id: quizId } = req.params;
    if (!mongoose.isValidObjectId(quizId)) return res.status(400).json({ message: 'Invalid quiz id' });
    const quiz = await Quiz.findById(quizId);
    if (!quiz) return res.status(404).json({ message: 'Quiz not found' });

    const { participantName, answers } = req.body;
    if (!Array.isArray(answers)) return res.status(400).json({ message: 'answers must be an array' });

    // ensure required questions answered and MCQ validity
    for (const q of quiz.questions) {
      if (q.required) {
        const found = answers.find(a => String(a.questionId) === String(q._id));
        if (!found || found.answer === undefined || found.answer === null || found.answer === '') {
          return res.status(400).json({ message: `Required question "${q.questionText}" not answered` });
        }
      }
    }

    // Validate MCQ options (if provided answer for MCQ must match an option text or index)
    for (const ans of answers) {
      const q = quiz.questions.id(ans.questionId);
      if (!q) return res.status(400).json({ message: `questionId ${ans.questionId} not found in quiz` });
      if (q.answerType === 'MCQ') {
        // Accept either option index (number) or option text (string)
        const okIndex = typeof ans.answer === 'number' && ans.answer >= 0 && ans.answer < q.options.length;
        const okText = typeof ans.answer === 'string' && q.options.some(opt => opt.text === ans.answer);
        if (!okIndex && !okText) {
          return res.status(400).json({ message: `Invalid MCQ answer for question "${q.questionText}"` });
        }
      } else {
        // ShortText must be string
        if (q.answerType === 'ShortText' && typeof ans.answer !== 'string') {
          return res.status(400).json({ message: `ShortText answer must be string for "${q.questionText}"` });
        }
      }
    }

    const response = new Response({ quizId, participantName, answers });
    await response.save();
    res.status(201).json({ message: 'Response submitted', id: response._id });
  } catch (err) { next(err); }
};

const listResponses = async (req, res, next) => {
  try {
    const { id: quizId } = req.params;
    if (!mongoose.isValidObjectId(quizId)) return res.status(400).json({ message: 'Invalid quiz id' });
    const responses = await Response.find({ quizId }).sort({ submittedAt: -1 });
    res.json(responses);
  } catch (err) { next(err); }
};

module.exports = { submitResponse, listResponses };