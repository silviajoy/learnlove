import '../models/session.dart';

abstract class SessionsRepository {
  Future<void> saveSession(Session session);
  Future<List<Session>> getSessionsForChild(String childId);
}
