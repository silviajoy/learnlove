import 'package:impariamo_reading_app/features/02_reading/domain/entities/level_progress.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/session.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/levels_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/sessions_repository.dart';

/// Use-case that finalizes a session: marks end time, computes stars and saves
/// level progress and the session via the provided repository.
class SaveSessionUseCase {
  Future<void> call({required LevelsRepository levelsRepository, required SessionsRepository sessionsRepository, required Session session, required int correctCount, required int total}) async {
    session.end = DateTime.now();

    // compute stars (same rules as SessionBloc)
    int stars = 0;
    if (total > 0) {
      if (correctCount == total) stars = 3;
      else if (correctCount >= 8) stars = 2;
      else if (correctCount >= 7) stars = 1;
      else stars = 0;
    }

    // update level progress
    final lp = await levelsRepository.getLevelProgress(session.childId, session.levelId) ?? LevelProgress(childId: session.childId, levelId: session.levelId);
    lp.lastStars = stars;
    lp.lastCorrectCount = correctCount;
    lp.lastTotal = total;
    lp.updatedAt = DateTime.now();
    lp.bestStars = (lp.bestStars > stars) ? lp.bestStars : stars;
    await levelsRepository.saveLevelProgress(lp);

    // persist session
    await sessionsRepository.saveSession(session);
  }
}
