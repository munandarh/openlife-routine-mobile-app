import 'package:flutter/material.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_practice.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_session.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/meditation_motion.dart';

class RecentMeditationList extends StatelessWidget {
  const RecentMeditationList({
    required this.sessions,
    this.onTapItem,
    this.onSeeAll,
    super.key,
  });
  final List<MeditationSession> sessions;
  final ValueChanged<MeditationSession>? onTapItem;
  final VoidCallback? onSeeAll;
  @override
  Widget build(BuildContext context) {
    final completed = sessions
        .where((s) => s.status == 'completed')
        .take(3)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.recentLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(onPressed: onSeeAll, child: Text(context.l10n.seeAll)),
          ],
        ),
        if (completed.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.palette.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(Icons.spa_outlined, color: context.palette.primaryInk),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    medText(
                      context,
                      'Your moments of calm will appear here. Begin whenever you are ready.',
                      'Momen tenangmu akan tampil di sini. Mulai kapan pun kamu siap.',
                    ),
                    style: TextStyle(color: context.palette.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        for (final session in completed)
          Card(
            child: ListTile(
              minVerticalPadding: 14,
              leading: Icon(
                session.type == 'anxiety_breath'
                    ? Icons.air_rounded
                    : meditationIcon(
                        MeditationPractice.byId(session.type).category,
                      ),
              ),
              title: Text(
                session.type == 'anxiety_breath'
                    ? context.l10n.anxietyBreathTitle
                    : MeditationPractice.byId(
                        session.type,
                      ).title(meditationIndonesian(context)),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${session.actualDurationSec ~/ 60} ${medText(context, 'min', 'mnt')} · ${MaterialLocalizations.of(context).formatShortDate(session.startedAt.toLocal())}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onTapItem?.call(session),
            ),
          ),
      ],
    );
  }
}
