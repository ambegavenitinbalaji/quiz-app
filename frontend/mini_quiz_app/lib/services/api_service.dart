import 'package:dio/dio.dart';
import '../models/quiz.dart';

class ApiService {
  final Dio dio;

  ApiService({String baseUrl = 'http://192.168.1.2:4000/api'}) : dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<List<Quiz>> fetchQuizzes() async {
    final res = await dio.get('/quizzes');
    return (res.data as List).map((e) => Quiz.fromJson(e)).toList();
  }

  Future<Quiz> getQuiz(String id) async {
    final res = await dio.get('/quizzes/$id');
    return Quiz.fromJson(res.data);
  }

  Future<Quiz> createQuiz(Quiz q) async {
    final res = await dio.post('/quizzes', data: q.toJson());
    return Quiz.fromJson(res.data);
  }

  Future<Quiz> updateQuiz(String id, Map<String, dynamic> body) async {
    final res = await dio.put('/quizzes/$id', data: body);
    return Quiz.fromJson(res.data);
  }

  Future<void> deleteQuiz(String id) async {
    await dio.delete('/quizzes/$id');
  }

  Future<void> submitResponse(String quizId, Map<String, dynamic> body) async {
    await dio.post('/quizzes/$quizId/responses', data: body);
  }

  Future<List<dynamic>> fetchResponses(String quizId) async {
    final res = await dio.get('/quizzes/$quizId/responses');
    return res.data as List<dynamic>;
  }
}
