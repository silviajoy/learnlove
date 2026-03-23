import 'package:impariamo_reading_app/features/02_reading/domain/models/session.dart';

abstract class SessionsRepository {
  Future<void> saveSession(Session session);
  Future<List<Session>> getSessionsForChild(String childId);
}
