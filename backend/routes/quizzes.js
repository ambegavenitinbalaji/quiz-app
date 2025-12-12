const express = require('express');
const router = express.Router();
const quizController = require('../controllers/quizController');
const responseController = require('../controllers/responseController');

// Quiz CRUD
router.post('/', quizController.createQuiz);
router.get('/', quizController.listQuizzes);
router.get('/:id', quizController.getQuiz);
router.put('/:id', quizController.updateQuiz);
router.delete('/:id', quizController.deleteQuiz);

// Responses
router.post('/:id/responses', responseController.submitResponse);
router.get('/:id/responses', responseController.listResponses);

module.exports = router;
