// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OpenLife Routine';

  @override
  String get appTagline => 'Calm daily routines, private by default.';

  @override
  String get preparingYourDay => 'Preparing your day';

  @override
  String get todayTab => 'Today';

  @override
  String get routinesTab => 'Routines';

  @override
  String get meditateTab => 'Meditate';

  @override
  String get insightsTab => 'Insights';

  @override
  String get settingsTab => 'Settings';

  @override
  String get continueButton => 'Continue';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skipButton => 'Skip';

  @override
  String get backButton => 'Back';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get closeAction => 'Close';

  @override
  String get createRoutine => 'Create routine';

  @override
  String get chooseYourLanguage => 'Choose your language';

  @override
  String get chooseLanguageDesc =>
      'Pick the language you want to see first. You can change it later in settings.';

  @override
  String get englishLang => 'English';

  @override
  String get englishSubtitle => 'Default app language';

  @override
  String get bahasaLang => 'Bahasa Indonesia';

  @override
  String get bahasaSubtitle => 'Bahasa utama untuk pengguna lokal';

  @override
  String get bahasaShort => 'Bahasa';

  @override
  String get notificationPermissionTitle => 'Notification permission';

  @override
  String get getGentleReminders => 'Get gentle reminders';

  @override
  String get getGentleRemindersDesc =>
      'OpenLife can remind you about routines at the right time, without noisy pressure.';

  @override
  String get scheduledReminders => 'Scheduled reminders';

  @override
  String get quietAndRespectful => 'Quiet and respectful';

  @override
  String get privateOnDevice => 'Private on device';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get notNow => 'Not now';

  @override
  String get onboardingSlide1Title => 'Build better days';

  @override
  String get onboardingSlide1Desc =>
      'Design a routine that fits your life. Gentle nudges, not rigid rules.';

  @override
  String get onboardingSlide2Title => 'Never miss what matters';

  @override
  String get onboardingSlide2Desc =>
      'Receive calm reminders for meals, water, vitamins, and small routines that support your day.';

  @override
  String get onboardingSlide3Title => 'Private by default';

  @override
  String get onboardingSlide3Desc =>
      'Your routines stay on-device first. No account required to start, and no forced cloud setup.';

  @override
  String get onboardingSlide4Title => 'Start with a template';

  @override
  String get onboardingSlide4Desc =>
      'Pick a starter template to begin, or add routines yourself one at a time.';

  @override
  String get chooseStartingLanguage => 'Choose your starting language';

  @override
  String get notificationEducationTitle => 'Reminders you control';

  @override
  String get notificationEducationMessage =>
      'You decide which routines send a reminder, and you can turn any of them off at any time.';

  @override
  String get privacyPanelTitle => 'No account, no cloud';

  @override
  String get privacyPanelMessage =>
      'Everything you create is stored in a local database on this device. Nothing is uploaded.';

  @override
  String get pickStarter => 'Pick a starter';

  @override
  String get orStartEmpty =>
      'Or, you can start empty and add routines later from the Routines tab.';

  @override
  String get startEmpty => 'Start empty';

  @override
  String get templateApplied => 'Template added. You can edit anything later.';

  @override
  String onboardingStepCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String get calmDayAhead =>
      'A calm day ahead. Add a routine whenever you are ready.';

  @override
  String get allFinished => 'You finished all your routines today. Great work.';

  @override
  String get smallProgress =>
      'Small progress still counts. Take it one step at a time.';

  @override
  String get dailyProgress => 'Daily Progress';

  @override
  String get dailyRoutine => 'Daily routine';

  @override
  String get noRoutinesScheduledForDay => 'No routines scheduled for this day.';

  @override
  String completedOfTotal(int completed, int total) {
    return '$completed of $total routines completed.';
  }

  @override
  String get allDoneBadge => 'ALL DONE';

  @override
  String get stayConsistentBadge => 'STAY CONSISTENT';

  @override
  String get allDone => 'All Done!';

  @override
  String get allDoneMessage =>
      'You completed all your routines for today. Great work!';

  @override
  String get nextUp => 'Next';

  @override
  String get nothingLeftToday => 'Nothing left for today.';

  @override
  String get statusDone => 'Done';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusMissed => 'Missed';

  @override
  String get statusSnoozed => 'Snoozed';

  @override
  String get statusDueNow => 'Due Now';

  @override
  String get skipAction => 'Skip';

  @override
  String get undoAction => 'Undo';

  @override
  String get snoozeAction => 'Snooze';

  @override
  String snoozedUntil(String time) {
    return 'Snoozed until $time';
  }

  @override
  String get todayEmptyTitle => 'Nothing scheduled today';

  @override
  String get todayEmptyDesc =>
      'Add a routine to see your day fill up with calm reminders.';

  @override
  String get noRoutinesYet => 'No routines yet';

  @override
  String get noRoutinesForDateDesc =>
      'There is nothing scheduled for this date. Add one or pick another day.';

  @override
  String get routinesEmptyDesc =>
      'Create your first routine so the app can start guiding your day.';

  @override
  String get routinesListEmptyDesc =>
      'Start one small routine today. Your list will update here automatically.';

  @override
  String get insightsEmptyTitle => 'Insights will appear here';

  @override
  String get insightsEmptyDesc =>
      'Complete a few routines first, then this screen will show your weekly rhythm.';

  @override
  String get templatesEmptyTitle => 'No templates yet';

  @override
  String get templatesEmptyDesc =>
      'Templates are ready to help once you start building a routine library.';

  @override
  String get browseRoutines => 'Browse routines';

  @override
  String get discoverRoutines => 'Discover Routines';

  @override
  String get addStructured =>
      'Add structured, calm habits to your day with a single tap.';

  @override
  String get browseTemplates => 'Browse templates';

  @override
  String get yourRoutines => 'Your routines';

  @override
  String get templatesTitle => 'Templates';

  @override
  String get addTemplate => 'Add Template';

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String templateAdded(String title) {
    return '\"$title\" routines added!';
  }

  @override
  String get newRoutine => 'New Routine';

  @override
  String get editRoutine => 'Edit Routine';

  @override
  String get saveRoutine => 'Save Routine';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get routineName => 'Routine Name';

  @override
  String get routineNameHint => 'e.g., Morning Yoga';

  @override
  String get categoryLabel => 'Category';

  @override
  String get iconLabel => 'Icon';

  @override
  String get iconDefaultForCategory => 'Default for category';

  @override
  String get timeLabel => 'Time';

  @override
  String get repeatLabel => 'Repeat';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get notesHint => 'e.g., Take with food';

  @override
  String get notesLabel => 'Notes';

  @override
  String get snoozeDuration => 'Snooze duration';

  @override
  String minutesShort(int minutes) {
    return '${minutes}m';
  }

  @override
  String minutesLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String get routineNameRequired => 'Give your routine a name first.';

  @override
  String get repeatDaysRequired => 'Pick at least one day to repeat.';

  @override
  String get categoryMeal => 'Meal';

  @override
  String get categoryWater => 'Water';

  @override
  String get categoryVitamin => 'Vitamin';

  @override
  String get categoryMedicine => 'Medicine';

  @override
  String get categorySleep => 'Sleep';

  @override
  String get categoryExercise => 'Exercise';

  @override
  String get categoryBreak => 'Break';

  @override
  String get categoryCustom => 'Custom';

  @override
  String get mealRoutine => 'Meal routine';

  @override
  String get waterRoutine => 'Hydration routine';

  @override
  String get vitaminRoutine => 'Vitamin routine';

  @override
  String get medicineRoutine => 'Medicine routine';

  @override
  String get sleepRoutine => 'Sleep routine';

  @override
  String get exerciseRoutine => 'Exercise routine';

  @override
  String get breakRoutine => 'Break routine';

  @override
  String get customRoutine => 'Custom routine';

  @override
  String get weekdayShortMon => 'M';

  @override
  String get weekdayShortTue => 'T';

  @override
  String get weekdayShortWed => 'W';

  @override
  String get weekdayShortThu => 'T';

  @override
  String get weekdayShortFri => 'F';

  @override
  String get weekdayShortSat => 'S';

  @override
  String get weekdayShortSun => 'S';

  @override
  String get weekdayAbbrMon => 'Mon';

  @override
  String get weekdayAbbrTue => 'Tue';

  @override
  String get weekdayAbbrWed => 'Wed';

  @override
  String get weekdayAbbrThu => 'Thu';

  @override
  String get weekdayAbbrFri => 'Fri';

  @override
  String get weekdayAbbrSat => 'Sat';

  @override
  String get weekdayAbbrSun => 'Sun';

  @override
  String get everyDay => 'Every day';

  @override
  String get noRepeatDays => 'No repeat days';

  @override
  String get routineDetailTitle => 'Routine Detail';

  @override
  String get routineNotFound => 'Routine not found.';

  @override
  String get scheduleLabel => 'Schedule';

  @override
  String get reminderBehavior => 'Reminder behavior';

  @override
  String snoozeForMinutes(int minutes) {
    return 'Snooze for $minutes minutes';
  }

  @override
  String get routineIsActive => 'Routine is active';

  @override
  String get routineIsDisabled => 'Routine is disabled';

  @override
  String get editRoutineAction => 'Edit routine';

  @override
  String get deleteRoutine => 'Delete routine';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get completedThisWeek => 'Completed this week';

  @override
  String get bestStreak => 'Best streak';

  @override
  String daysLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get thisWeeksFlow => 'This Week\'s Flow';

  @override
  String get focusAreas => 'Focus Areas';

  @override
  String get insightGreatTitle => 'You\'re doing great this week!';

  @override
  String get insightGreatMessage =>
      'Keep up the momentum — consistency builds better days.';

  @override
  String get insightSmallProgressTitle => 'Small progress still counts.';

  @override
  String get insightSmallProgressMessage =>
      'Some routines were missed this week. Try again tomorrow — every step matters.';

  @override
  String get insightBuildRhythmTitle => 'Build your routine rhythm.';

  @override
  String get insightBuildRhythmMessage =>
      'Add routines and start tracking to see your weekly insights here.';

  @override
  String get insightNoRoutinesTitle => 'No routines tracked yet.';

  @override
  String get insightNoRoutinesMessage =>
      'Create your first routine and start building insights over time.';

  @override
  String get sevenDayHistory => '7-Day History';

  @override
  String get viewHistory => 'View 7-day history';

  @override
  String get historyEmpty => 'No history for the last 7 days yet.';

  @override
  String get historyToday => 'Today';

  @override
  String get historyYesterday => 'Yesterday';

  @override
  String historyDoneCount(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get mostCompleted => 'Most completed';

  @override
  String get mostMissed => 'Most missed';

  @override
  String timesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get dataSection => 'Data';

  @override
  String get privacySection => 'Privacy';

  @override
  String get themeSetting => 'Theme';

  @override
  String get languageSetting => 'Language';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get chooseTheme => 'Choose theme';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get routineAlerts => 'Routine alerts';

  @override
  String get notificationPermissionRequested =>
      'Notification permission requested.';

  @override
  String get reducedMotionSetting => 'Reduce motion';

  @override
  String get reducedMotionDescription =>
      'Turn off celebration and looping animations.';

  @override
  String get exportSetting => 'Export routines';

  @override
  String get importSetting => 'Import routines';

  @override
  String get resetSetting => 'Reset all data';

  @override
  String get exportJson => 'JSON';

  @override
  String get resetDestructive => 'Destructive';

  @override
  String get privacyData => 'Privacy & data';

  @override
  String get aboutOpenSourceSetting => 'About open source';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get pasteJsonHint => 'Paste JSON backup here...';

  @override
  String get importAction => 'Import';

  @override
  String routinesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routines imported.',
      one: '1 routine imported.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get resetAllData => 'Reset All Data';

  @override
  String get resetWarning =>
      'This will permanently delete all your routines, schedules, and logs. This action cannot be undone.';

  @override
  String get resetButton => 'Reset';

  @override
  String get allDataReset => 'All data has been reset.';

  @override
  String get privacyTitle => 'Privacy & Data';

  @override
  String get privacyLocal => 'Your data stays on your device';

  @override
  String get privacyLocalBody =>
      'OpenLife Routine stores all your routines, schedules, and logs locally on your phone. No data is sent to any server.';

  @override
  String get privacyNoAccount => 'No account required';

  @override
  String get privacyNoAccountBody =>
      'You can use all features without creating an account. There is no login, no registration, and no personal information collected.';

  @override
  String get privacyOffline => 'Works offline';

  @override
  String get privacyOfflineBody =>
      'All core features work without an internet connection. Reminders are scheduled locally and trigger even when you are offline.';

  @override
  String get privacyControl => 'You control your data';

  @override
  String get privacyControlBody =>
      'You can export your data as JSON at any time from Settings. You can also import a backup or reset all data from your device.';

  @override
  String get privacyNoTracking => 'No tracking or analytics';

  @override
  String get privacyNoTrackingBody =>
      'This app does not use third-party analytics, advertising trackers, or any form of user monitoring. Your routine is yours alone.';

  @override
  String get privacyDisclaimer => 'OpenLife Routine is not a medical app.';

  @override
  String get privacyDisclaimerBody =>
      'It is a lifestyle and routine reminder app designed to help you build better days. It does not diagnose, treat, or cure any condition.';

  @override
  String get aboutTitle => 'About Open Source';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutOpenSource => 'Open source';

  @override
  String get aboutOpenSourceBody =>
      'OpenLife Routine is free and open-source software. The full source code is available on GitHub under the Apache 2.0 license.';

  @override
  String get aboutBuiltWith => 'Built with Flutter';

  @override
  String get aboutBuiltWithBody =>
      'This app is built with Flutter and Dart, using Clean Architecture, BLoC state management, Drift SQLite, and local notifications.';

  @override
  String get aboutPortfolio => 'Portfolio project';

  @override
  String get aboutPortfolioBody =>
      'OpenLife Routine was built as a production-quality open-source portfolio project to demonstrate Flutter engineering, architecture, and product design skills.';

  @override
  String get aboutLicense => 'License';

  @override
  String get aboutLicenseBody =>
      'Apache License 2.0 — Free for personal and commercial use. The OpenLife Routine name and logo are reserved for the official project.';

  @override
  String get notificationSnoozedTitle => 'Snoozed reminder';

  @override
  String get notificationSnoozeActionGeneric => 'Snooze';

  @override
  String notificationSnoozeAction(int minutes) {
    return 'Snooze $minutes min';
  }

  @override
  String get templateMorningTitle => 'Morning Routine';

  @override
  String get templateMorningDesc =>
      'Start your day with intention and a gentle pace.';

  @override
  String get templateHydrationTitle => 'Hydration Tracker';

  @override
  String get templateHydrationDesc =>
      'Keep your water intake consistent throughout the day.';

  @override
  String get templateMedicineTitle => 'Medication Schedule';

  @override
  String get templateMedicineDesc =>
      'Doses at the hours a prescription actually calls for.';

  @override
  String get templateRoutineMedicineWithMeals => 'With meals';

  @override
  String get templateRoutineMedicineBeforeBed => 'Before bed';

  @override
  String timesPerDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times a day',
      one: 'Once a day',
    );
    return '$_temp0';
  }

  @override
  String get timesPerDayLabel => 'Times a day';

  @override
  String reminderTimeNumber(int number) {
    return 'Time $number';
  }

  @override
  String get duplicateTimesError => 'Two reminders cannot be at the same time.';

  @override
  String get testReminderTitle => 'Test reminder';

  @override
  String get testReminderBody =>
      'If you can see this, reminders can reach you.';

  @override
  String get sendTestReminder => 'Send a test reminder';

  @override
  String get testReminderSent =>
      'Sent. If nothing appeared, notifications are blocked.';

  @override
  String get templateVitaminTitle => 'Vitamin Routine';

  @override
  String get templateVitaminDesc =>
      'Never miss a supplement with timed daily reminders.';

  @override
  String get templateSleepTitle => 'Sleep Routine';

  @override
  String get templateSleepDesc =>
      'Wind down your day with a calming evening rhythm.';

  @override
  String get templateProgrammerBreakTitle => 'Programmer Break';

  @override
  String get templateProgrammerBreakDesc =>
      'Eye rest and posture resets to combat screen fatigue.';

  @override
  String get badgePopular => 'POPULAR';

  @override
  String get badgeNew => 'NEW';

  @override
  String get templateRoutineWakeUp => 'Wake Up';

  @override
  String get templateRoutineDrinkWater => 'Drink Water';

  @override
  String get templateRoutineBreakfast => 'Breakfast';

  @override
  String get templateRoutineMorningWater => 'Morning Water';

  @override
  String get templateRoutineMiddayWater => 'Midday Water';

  @override
  String get templateRoutineAfternoonWater => 'Afternoon Water';

  @override
  String get templateRoutineEveningWater => 'Evening Water';

  @override
  String get templateRoutineVitaminD3 => 'Vitamin D3';

  @override
  String get templateRoutineBComplex => 'B Complex';

  @override
  String get templateRoutineReduceScreenTime => 'Reduce Screen Time';

  @override
  String get templateRoutinePrepareBed => 'Prepare Bed';

  @override
  String get templateRoutineEyeRest => 'Eye Rest';

  @override
  String get templateRoutineStretching => 'Stretching';

  @override
  String get templateRoutinePostureCheck => 'Posture Check';

  @override
  String notificationReminderBody(String title) {
    return 'Reminder for $title';
  }

  @override
  String get notificationChannelName => 'Routine reminders';

  @override
  String get notificationChannelDescription =>
      'Reminder notifications for daily routines';

  @override
  String get copyAction => 'Copy';

  @override
  String get copiedToClipboard => 'Backup copied to the clipboard.';

  @override
  String get notificationDoneAction => 'Done';

  @override
  String get routineActiveLabel => 'Active';

  @override
  String get routineActiveDescription => 'Send reminders for this routine.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get upcomingReminders => 'Upcoming reminders';

  @override
  String get upcomingRemindersDesc =>
      'The next reminders your routines will send.';

  @override
  String get noUpcomingReminders => 'No reminders scheduled';

  @override
  String get noUpcomingRemindersDesc =>
      'Add a routine, or turn one back on, and its reminders will appear here.';

  @override
  String get manageAlerts => 'Manage reminder alerts';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLocalOnly => 'No account needed';

  @override
  String get profileLocalOnlyDesc =>
      'OpenLife Routine has no sign-in. Everything you see here is stored on this device only.';

  @override
  String get yourActivity => 'Your activity';

  @override
  String get activeRoutinesStat => 'Active routines';

  @override
  String get currentStreakStat => 'Current streak';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get doneLabel => 'done';

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
    );
    return '$_temp0';
  }

  @override
  String get lastSevenDays => 'Last 7 days';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String routinesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
    );
    return '$_temp0';
  }

  @override
  String markDoneAction(String title) {
    return 'Mark $title as done';
  }

  @override
  String markNotDoneAction(String title) {
    return 'Mark $title as not done';
  }

  @override
  String get startFromTemplate => 'Start from a template';

  @override
  String get startFromTemplateDesc =>
      'Calm, ready-made habits you can adjust after adding.';

  @override
  String get daysSuffix => 'days';

  @override
  String get completionLabel => 'Completion';

  @override
  String get aboutSection => 'About';

  @override
  String get openSourceSetting => 'Open source';

  @override
  String get tomorrowLabel => 'Tomorrow';

  @override
  String get laterLabel => 'Later';

  @override
  String inMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count minutes',
      one: 'In 1 minute',
    );
    return '$_temp0';
  }

  @override
  String get alertsAllowed => 'Allowed';

  @override
  String get alertsBlocked => 'Blocked';

  @override
  String get reminderHealthTitle => 'Reminder health';

  @override
  String get reminderHealthAllGood => 'Your reminders will arrive on time.';

  @override
  String reminderHealthProblems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things are stopping your reminders',
      one: '1 thing is stopping your reminders',
    );
    return '$_temp0';
  }

  @override
  String get checkNotifications => 'Notifications';

  @override
  String get checkNotificationsOk => 'OpenLife can show reminders.';

  @override
  String get checkNotificationsBad => 'Reminders cannot be shown at all.';

  @override
  String get checkExactAlarms => 'Exact timing';

  @override
  String get checkExactAlarmsOk => 'Reminders fire at the minute you set.';

  @override
  String get checkExactAlarmsBad => 'Reminders may arrive up to an hour late.';

  @override
  String get checkBattery => 'Background activity';

  @override
  String get checkBatteryOk => 'OpenLife is exempt from battery optimisation.';

  @override
  String get checkBatteryBad =>
      'The system may stop reminders to save battery.';

  @override
  String get fixIt => 'Fix this';

  @override
  String get vendorWarningTitle => 'One more setting on this phone';

  @override
  String get vendorWarningBody =>
      'This phone stops background apps far more aggressively than stock Android, and the settings that control it cannot be read or requested by any app. Three things to change:';

  @override
  String get vendorStepAutostart =>
      'Allow autostart, so reminders survive closing the app';

  @override
  String get vendorStepBattery => 'Set battery usage to no restrictions';

  @override
  String get vendorStepLock =>
      'Lock the app in Recents, so clearing apps does not stop it';

  @override
  String get openAutostartSettings => 'Open autostart settings';

  @override
  String get openAppSettings => 'Open app settings';

  @override
  String get reminderHealthSetting => 'Reminder health';

  @override
  String get meditateHeaderTitle => 'Meditate';

  @override
  String get meditateHeaderSubtitle => 'A little space for yourself.';

  @override
  String get categoryAnxietyBreath => 'Anxiety Breath';

  @override
  String get anxietyBreathRoutine => 'Anxiety Breath routine';

  @override
  String get anxietyBreathTitle => 'Anxiety Breath';

  @override
  String get anxietyBreathTagline => 'Slow the breath, one cycle at a time.';

  @override
  String get anxietyBreathDuration => '7 min · Guided breathing';

  @override
  String get anxietyBreathSubtitle => 'Slow, steady breaths to feel calmer.';

  @override
  String get anxietyBreathSetupTitle => 'Choose your exhale';

  @override
  String get anxietyBreathSetupDesc =>
      'Inhale stays at 3 seconds. Choose the exhale pace that feels comfortable today.';

  @override
  String get startBreathingAction => 'Start breathing';

  @override
  String get todaysPause => 'TODAY\'S PAUSE';

  @override
  String get morningReset => 'Morning Reset';

  @override
  String get morningResetDesc => 'Clear your mind gently.';

  @override
  String get middayPause => 'Midday Pause';

  @override
  String get middayPauseDesc => 'Step back and breathe.';

  @override
  String get eveningUnwind => 'Evening Unwind';

  @override
  String get eveningUnwindDesc => 'Let go of the day\'s tension.';

  @override
  String get prepareForSleep => 'Prepare for Sleep';

  @override
  String get prepareForSleepDesc => 'Settle your mind for rest.';

  @override
  String get howDoYouWantToFeel => 'How do you want to feel?';

  @override
  String get feelCalm => 'Calm';

  @override
  String get feelFocus => 'Focus';

  @override
  String get feelReset => 'Reset';

  @override
  String get feelSleep => 'Sleep';

  @override
  String get feelBreathe => 'Breathe';

  @override
  String get feelStressRelief => 'Stress relief';

  @override
  String get quickStart => 'Quick Start';

  @override
  String get recentLabel => 'Recent';

  @override
  String get seeAll => 'See all';

  @override
  String get inhaleLabel => 'Inhale';

  @override
  String get exhaleLabel => 'Exhale';

  @override
  String get fixedBadge => 'Fixed';

  @override
  String secUnit(int seconds) {
    return '$seconds sec';
  }

  @override
  String get sessionLabel => 'Session';

  @override
  String get sevenMinutes => '7 minutes';

  @override
  String get comfortSafetyNote =>
      'Choose only a pace that feels comfortable. Return to normal breathing if you feel dizzy or uncomfortable.';

  @override
  String get canEndSessionAnytime => 'You can end the session at any time.';

  @override
  String timeLeft(String time) {
    return '$time left';
  }

  @override
  String secExhaleSelected(int seconds) {
    return '$seconds sec exhale selected';
  }

  @override
  String get pauseAction => 'Pause';

  @override
  String get resumeAction => 'Resume';

  @override
  String get endSessionAction => 'End session';

  @override
  String get endSessionDialogTitle => 'End this session?';

  @override
  String get endSessionDialogMessage =>
      'Your current reminder will stay incomplete.';

  @override
  String get keepBreathingAction => 'Keep breathing';

  @override
  String get sessionCompleteTitle => 'Session complete';

  @override
  String get sessionCompleteSubtitle =>
      'You gave yourself 7 minutes to slow down.';

  @override
  String sessionsCompleteToday(int completed, int total) {
    return '$completed of $total today';
  }

  @override
  String sessionsCompleteTodayFull(int completed, int total) {
    return '$completed of $total sessions complete today';
  }

  @override
  String get allSessionsCompleteToday => 'Today\'s 5 sessions are complete';

  @override
  String get howDoYouFeel => 'How do you feel?';

  @override
  String get moodCalmer => 'Calmer';

  @override
  String get moodSame => 'Same';

  @override
  String get moodUncomfortable => 'Uncomfortable';

  @override
  String get doneAction => 'Done';

  @override
  String get settleOutroLabel => 'SETTLE';

  @override
  String get settleOutroSubtext => 'Let your breath return naturally.';

  @override
  String get inhaleGentlySubtext => 'Inhale gently';

  @override
  String get slowExhaleSubtext => 'Slow exhale';

  @override
  String get actionTypeGuidedBreathing => 'Guided breathing';

  @override
  String get fiveTimesADay => '5 times a day';

  @override
  String get exhaleSelectionNotice =>
      'You will choose 7, 12, or 21 seconds before each session.';

  @override
  String get threeMinutes => '3 min';

  @override
  String get fiveMinutes => '5 min';

  @override
  String get tenMinutes => '10 min';

  @override
  String get fifteenMinutes => '15 min';

  @override
  String get eveningCalmSample => 'Evening Calm';

  @override
  String get meditationSample => '5 min · Meditation';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get reminderCloseWarning =>
      'Some reminders are less than 30 minutes apart. You can keep these times or spread them out.';
}
