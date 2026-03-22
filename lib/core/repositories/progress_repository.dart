import '../models/progress_record.dart';

abstract class ProgressRepository {
  Future<void> saveProgressRecord(ProgressRecord record);
  Future<ProgressRecord?> getProgressForChildWord(String childId, String wordId);
  Future<List<ProgressRecord>> getProgressForChild(String childId);
}
