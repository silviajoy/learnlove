import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';

import 'package:impariamo_reading_app/features/02_reading/domain/entities/level_progress.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/levels_repository.dart';
 

class LevelsOverviewScreen extends StatefulWidget {
  const LevelsOverviewScreen({super.key, required this.childId});
  final String childId;

  @override
  State<LevelsOverviewScreen> createState() => _LevelsOverviewScreenState();
}

class _LevelsOverviewScreenState extends State<LevelsOverviewScreen> {
  List<Map<String, dynamic>> _levels = [];
  final Map<String, LevelProgress?> _progressMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final indexStr = await rootBundle.loadString('assets/configs/levels_index.json');
      final files = (json.decode(indexStr) as List<dynamic>).cast<String>();
      final repo = RepositoryProvider.of<LevelsRepository>(context);

      final List<Map<String, dynamic>> levels = [];
      for (final cfgFile in files) {
        try {
          final cfgStr = await rootBundle.loadString('assets/configs/$cfgFile');
          final cfg = json.decode(cfgStr) as Map<String, dynamic>;
          levels.add(cfg);
          final lp = await repo.getLevelProgress(widget.childId, cfg['id'] as String);
          _progressMap[cfg['id'] as String] = lp;
        } catch (_) {
          // ignore malformed
        }
      }

      setState(() {
        _levels = levels;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(title: const Text('Livelli')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: _levels.length,
          itemBuilder: (context, index) {
            final cfg = _levels[index];
            final lp = _progressMap[cfg['id'] as String];
            final best = lp?.bestStars ?? 0;
            final last = lp?.lastStars ?? 0;
            final lastCorrect = lp?.lastCorrectCount ?? 0;
            final lastTotal = lp?.lastTotal ?? 0;
            final percent = (lastTotal > 0) ? (lastCorrect / lastTotal) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(radius: 28, backgroundColor: Colors.amber[200], child: Text('${cfg['order'] ?? (index+1)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  title: Text(cfg['name'] ?? 'Livello', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: percent, minHeight: 8),
                      const SizedBox(height: 6),
                      Text(lastTotal > 0 ? 'Ultima: $lastCorrect/$lastTotal • Stelle: $last' : 'Non giocato ancora'),
                    ],
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0), child: Icon(i < best ? Icons.star : Icons.star_border, color: Colors.amber, size: 18)))),
                  onTap: () {
                    GoRouter.of(context).pushNamed(AppRoutes.session, params: {'childId': widget.childId, 'levelId': cfg['id'] as String});
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
