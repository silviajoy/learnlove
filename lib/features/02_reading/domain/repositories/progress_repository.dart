import 'package:impariamo_reading_app/features/02_reading/domain/entities/progress_record.dart';

abstract class ProgressRepository {
  Future<void> saveProgressRecord(ProgressRecord record);
  Future<ProgressRecord?> getProgressForChildWord(String childId, String wordId);
  Future<List<ProgressRecord>> getProgressForChild(String childId);
}
