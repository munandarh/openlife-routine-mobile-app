import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_preferences.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_practice.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/breathing_player_page.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/meditation_motion.dart';

Future<void> openMeditationPractice(
  BuildContext context,
  MeditationPractice practice, {
  int? minutes,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) => MeditationSetupPage(practice: practice, minutes: minutes),
  ),
);

class MeditationSetupPage extends StatefulWidget {
  const MeditationSetupPage({required this.practice, this.minutes, super.key});
  final MeditationPractice practice;
  final int? minutes;
  @override
  State<MeditationSetupPage> createState() => _MeditationSetupPageState();
}

class _MeditationSetupPageState extends State<MeditationSetupPage> {
  late int _minutes = widget.minutes ?? widget.practice.minutes;
  @override
  Widget build(BuildContext context) {
    final p = widget.practice;
    final color = meditationColor(p.category);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(medText(context, 'Your practice', 'Latihanmu')),
      ),
      body: MeditationEntrance(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: SizedBox(
                height: 240,
                child: MeditationLandscape(
                  color: color,
                  child: Center(
                    child: Icon(
                      meditationIcon(p.category),
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              p.title(meditationIndonesian(context)),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              p.description(meditationIndonesian(context)),
              style: TextStyle(
                fontSize: 16,
                color: context.palette.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              medText(context, 'Make a little space', 'Luangkan sedikit waktu'),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final minutes in [3, 5, 10, 15])
                  ChoiceChip(
                    label: Text('$minutes ${medText(context, 'min', 'mnt')}'),
                    selected: _minutes == minutes,
                    onSelected: (_) => setState(() => _minutes = minutes),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.headphones_rounded, color: color),
              title: Text(
                medText(
                  context,
                  'Music & gentle guidance',
                  'Musik & panduan lembut',
                ),
              ),
              subtitle: Text(
                medText(
                  context,
                  'Original ambient music with on-screen prompts. Available offline.',
                  'Musik ambient orisinal dengan panduan teks. Tersedia offline.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              p.guidance(0, meditationIndonesian(context)),
              style: TextStyle(
                height: 1.6,
                color: context.palette.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => BreathingPlayerPage(
                    exhaleSeconds: 7,
                    practice: p,
                    durationMinutes: _minutes,
                  ),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(medText(context, 'Begin practice', 'Mulai latihan')),
            ),
            const SizedBox(height: 12),
            Text(
              medText(
                context,
                'No perfect way to do this. You can pause or stop anytime.',
                'Tidak perlu sempurna. Kamu dapat menjeda atau berhenti kapan saja.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MeditationLibraryPage extends StatefulWidget {
  const MeditationLibraryPage({
    this.category,
    this.savedOnly = false,
    super.key,
  });
  final String? category;
  final bool savedOnly;
  @override
  State<MeditationLibraryPage> createState() => _MeditationLibraryPageState();
}

class _MeditationLibraryPageState extends State<MeditationLibraryPage> {
  final _preferences = MeditationPreferences();
  Set<String> _favorites = {};
  bool _loaded = false, _error = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ids = await _preferences.favorites();
      if (mounted) {
        setState(() {
          _favorites = ids;
          _loaded = true;
          _error = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loaded = true;
          _error = true;
        });
      }
    }
  }

  Future<void> _favorite(String id) async {
    final next = {..._favorites};
    if (!next.add(id)) next.remove(id);
    try {
      await _preferences.saveFavorites(next);
      if (mounted) setState(() => _favorites = next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              medText(
                context,
                'Could not save. Please try again.',
                'Belum tersimpan. Silakan coba lagi.',
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final practices = MeditationPractice.all
        .where(
          (p) =>
              (widget.category == null || p.category == widget.category) &&
              (!widget.savedOnly || _favorites.contains(p.id)),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          widget.savedOnly
              ? medText(context, 'Saved practices', 'Latihan tersimpan')
              : medText(context, 'Find your moment', 'Temukan jedamu'),
        ),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (_error)
                  ListTile(
                    title: Text(
                      medText(
                        context,
                        'Saved practices could not load',
                        'Latihan tersimpan belum dimuat',
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                if (!widget.savedOnly &&
                    (widget.category == 'breathe' || widget.category == null))
                  Card(
                    child: ListTile(
                      minVerticalPadding: 20,
                      leading: const Icon(Icons.air_rounded),
                      title: const Text('Anxiety Breath'),
                      subtitle: Text(
                        medText(
                          context,
                          '7 min · 3-second inhale, your choice of exhale',
                          '7 mnt · Tarik 3 detik, pilih durasi hembusan',
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          context.push(OpenLifeRoute.anxietyBreathSetup.path),
                    ),
                  ),
                if (practices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: Column(
                      children: [
                        const Icon(Icons.bookmark_border_rounded, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          medText(
                            context,
                            'A space for your favorites',
                            'Ruang untuk favoritmu',
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          medText(
                            context,
                            'Tap the bookmark on a practice to keep it here.',
                            'Ketuk penanda pada latihan untuk menyimpannya di sini.',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                for (final p in practices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: MeditationEntrance(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => openMeditationPractice(context, p),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 125,
                                child: MeditationLandscape(
                                  color: meditationColor(p.category),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      tooltip: medText(
                                        context,
                                        'Save practice',
                                        'Simpan latihan',
                                      ),
                                      isSelected: _favorites.contains(p.id),
                                      onPressed: () => _favorite(p.id),
                                      icon: Icon(
                                        _favorites.contains(p.id)
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.title(
                                              meditationIndonesian(context),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            p.description(
                                              meditationIndonesian(context),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            '${p.minutes} ${medText(context, 'min · Music & guidance', 'mnt · Musik & panduan')}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  context.palette.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_rounded),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class MeditationHistoryPage extends StatelessWidget {
  const MeditationHistoryPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      title: Text(medText(context, 'Your mindful moments', 'Momen tenangmu')),
    ),
    body: FutureBuilder<List<MeditationSession>>(
      future: AppScope.read(context).meditationRepository.getSessions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              medText(
                context,
                'History could not load. Please reopen to retry.',
                'Riwayat belum dimuat. Buka kembali untuk mencoba lagi.',
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snapshot.data!
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final now = DateTime.now();
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        final week = sessions.where(
          (s) =>
              s.status == 'completed' &&
              !(s.completedAt ?? s.startedAt).toLocal().isBefore(start),
        );
        final seconds = week.fold<int>(
          0,
          (sum, s) => sum + s.actualDurationSec,
        );
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              medText(context, 'This week', 'Minggu ini'),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              '${seconds ~/ 60} ${medText(context, 'mindful minutes', 'menit meditasi')} · ${week.length} ${medText(context, 'sessions', 'sesi')}',
            ),
            const SizedBox(height: 20),
            Semantics(
              label: medText(
                context,
                'Mindful minutes over the last seven days',
                'Menit meditasi tujuh hari terakhir',
              ),
              child: SizedBox(
                height: 135,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var day = 0; day < 7; day++)
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final date = start.add(Duration(days: day));
                            final minutes =
                                week
                                    .where((s) {
                                      final at = (s.completedAt ?? s.startedAt)
                                          .toLocal();
                                      return at.year == date.year &&
                                          at.month == date.month &&
                                          at.day == date.day;
                                    })
                                    .fold<int>(
                                      0,
                                      (sum, s) => sum + s.actualDurationSec,
                                    ) /
                                60;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${minutes.round()}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration: meditationReducedMotion(context)
                                      ? Duration.zero
                                      : const Duration(milliseconds: 450),
                                  width: 20,
                                  height:
                                      6 +
                                      (minutes / (seconds / 60 + 1) * 85).clamp(
                                        0,
                                        85,
                                      ),
                                  decoration: BoxDecoration(
                                    color: context.palette.primaryInk
                                        .withValues(alpha: day == 6 ? 1 : .45),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${date.day}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  medText(
                    context,
                    'Your first quiet moment starts here. Completed practices will appear in your history.',
                    'Mulai momen tenang pertamamu. Latihan yang selesai akan tampil di riwayat.',
                  ),
                ),
              ),
            for (final session in sessions)
              Card(
                child: ListTile(
                  minVerticalPadding: 16,
                  leading: Icon(
                    meditationIcon(
                      session.type == 'anxiety_breath'
                          ? 'breathe'
                          : MeditationPractice.byId(session.type).category,
                    ),
                  ),
                  title: Text(
                    session.type == 'anxiety_breath'
                        ? 'Anxiety Breath'
                        : MeditationPractice.byId(
                            session.type,
                          ).title(meditationIndonesian(context)),
                  ),
                  subtitle: Text(
                    '${session.actualDurationSec ~/ 60} ${medText(context, 'min', 'mnt')} · ${session.status == 'completed' ? medText(context, 'Complete', 'Selesai') : medText(context, 'Ended early', 'Berakhir lebih awal')}\n${MaterialLocalizations.of(context).formatMediumDate(session.startedAt.toLocal())}${session.mood == null ? '' : ' · ${session.mood}'}',
                  ),
                  trailing: const Icon(Icons.replay_rounded),
                  onTap: () => session.type == 'anxiety_breath'
                      ? context.push(OpenLifeRoute.anxietyBreathSetup.path)
                      : openMeditationPractice(
                          context,
                          MeditationPractice.byId(session.type),
                          minutes: session.plannedDurationSec ~/ 60,
                        ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
