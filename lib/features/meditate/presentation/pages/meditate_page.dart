import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_preferences.dart';
import 'package:openlife_routine/features/meditate/domain/entities/meditation_practice.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/meditate_bloc.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/meditate_event.dart';
import 'package:openlife_routine/features/meditate/presentation/bloc/meditate_state.dart';
import 'package:openlife_routine/features/meditate/presentation/pages/meditation_library_page.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/anxiety_breath_card.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/feelings_grid.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/meditation_motion.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/quick_start_row.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/recent_meditation_list.dart';
import 'package:openlife_routine/features/meditate/presentation/widgets/todays_pause_card.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_app_bar.dart';

class MeditatePage extends StatelessWidget {
  const MeditatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppDependencies dependencies = AppScope.read(context);

    return BlocProvider<MeditateBloc>(
      create: (BuildContext context) =>
          dependencies.createMeditateBloc()..add(const MeditateStarted()),
      child: const _MeditateView(),
    );
  }
}

class _MeditateView extends StatefulWidget {
  const _MeditateView();

  @override
  State<_MeditateView> createState() => _MeditateViewState();
}

class _MeditateViewState extends State<_MeditateView> {
  AppLifecycleListener? _lifecycleListener;
  Timer? _dayRefresh;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _refresh);
    _dayRefresh = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
    unawaited(MeditationPreferences().event('meditate_home_viewed'));
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    _dayRefresh?.cancel();
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    context.read<MeditateBloc>().add(const MeditateRefreshRequested());
  }

  Future<void> _openAnxietyBreathSetup() async {
    await context.push(OpenLifeRoute.anxietyBreathSetup.path);
    _refresh();
  }

  Future<void> _library([String? category]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MeditationLibraryPage(category: category),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: Column(
        children: <Widget>[
          const OpenLifeAppBar.tab(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: BlocBuilder<MeditateBloc, MeditateState>(
                builder: (BuildContext context, MeditateState state) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageMargin,
                      AppSpacing.sm,
                      AppSpacing.pageMargin,
                      AppSpacing.xl * 2,
                    ),
                    children: <Widget>[
                      Text(
                        l10n.meditateHeaderTitle,
                        style: AppTextStyles.pageTitle.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.meditateHeaderSubtitle,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: context.palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TodaysPauseCard(
                        onStart: () async {
                          await openMeditationPractice(
                            context,
                            MeditationPractice.forHour(DateTime.now().hour),
                          );
                          _refresh();
                        },
                      ),
                      const SizedBox(height: AppSpacing.md + 2),
                      AnxietyBreathCard(
                        completedToday: state.anxietyBreathCompletedToday,
                        targetSessions: state.anxietyBreathTarget,
                        onStartBreathing: _openAnxietyBreathSetup,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FeelingsGrid(
                        onBreatheSelected: () => _library('breathe'),
                        onFeelingSelected: _library,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      QuickStartRow(
                        onDurationSelected: (minutes) => openMeditationPractice(
                          context,
                          MeditationPractice.byId('timer'),
                          minutes: minutes,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: context.palette.surface,
                                foregroundColor: context.palette.primaryInk,
                                side: BorderSide(color: context.palette.border),
                              ),
                              onPressed: _library,
                              icon: const Icon(Icons.spa_outlined),
                              label: Text(
                                medText(
                                  context,
                                  'Explore all',
                                  'Jelajahi semua',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            tooltip: medText(
                              context,
                              'Saved practices',
                              'Latihan tersimpan',
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: context.palette.surface,
                              foregroundColor: context.palette.primaryInk,
                              side: BorderSide(color: context.palette.border),
                              minimumSize: const Size(52, 52),
                              fixedSize: const Size(52, 52),
                            ),
                            onPressed: () => Navigator.of(context).push<void>(
                              MaterialPageRoute(
                                builder: (_) => const MeditationLibraryPage(
                                  savedOnly: true,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.bookmark_border_rounded),
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            tooltip: medText(
                              context,
                              'Mindfulness insights',
                              'Insight meditasi',
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: context.palette.surface,
                              foregroundColor: context.palette.primaryInk,
                              side: BorderSide(color: context.palette.border),
                              minimumSize: const Size(52, 52),
                              fixedSize: const Size(52, 52),
                            ),
                            onPressed: () => Navigator.of(context).push<void>(
                              MaterialPageRoute(
                                builder: (_) => const MeditationHistoryPage(),
                              ),
                            ),
                            icon: const Icon(Icons.bar_chart_rounded),
                          ),
                        ],
                      ),
                      if (state.status == MeditateStatus.failure)
                        ListTile(
                          title: Text(
                            medText(
                              context,
                              'Progress could not load',
                              'Progres belum dimuat',
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh),
                          ),
                        ),
                      if (state.status == MeditateStatus.loading)
                        const LinearProgressIndicator(),
                      const SizedBox(height: AppSpacing.xl),
                      RecentMeditationList(
                        sessions: state.recentSessions,
                        onTapItem: (session) => session.type == 'anxiety_breath'
                            ? _openAnxietyBreathSetup()
                            : openMeditationPractice(
                                context,
                                MeditationPractice.byId(session.type),
                                minutes: session.plannedDurationSec ~/ 60,
                              ),
                        onSeeAll: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => const MeditationHistoryPage(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
