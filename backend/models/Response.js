const mongoose = require('mongoose');

const AnswerSchema = new mongoose.Schema({
  questionId: { type: mongoose.Schema.Types.ObjectId, required: true },
  answer: { type: mongoose.Schema.Types.Mixed } // string or index/option
}, { _id: false });

const ResponseSchema = new mongoose.Schema({
  quizId: { type: mongoose.Schema.Types.ObjectId, ref: 'Quiz', required: true },
  participantName: { type: String }, // optional
  submittedAt: { type: Date, default: Date.now },
  answers: { type: [AnswerSchema], default: [] }
}, { timestamps: false });

module.exports = mongoose.model('Response', ResponseSchema);
