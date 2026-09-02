import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenLife Routine'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Calm daily routines, private by default.'**
  String get appTagline;

  /// No description provided for @preparingYourDay.
  ///
  /// In en, this message translates to:
  /// **'Preparing your day'**
  String get preparingYourDay;

  /// No description provided for @todayTab.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTab;

  /// No description provided for @routinesTab.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routinesTab;

  /// No description provided for @insightsTab.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @createRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create routine'**
  String get createRoutine;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @chooseLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick the language you want to see first. You can change it later in settings.'**
  String get chooseLanguageDesc;

  /// No description provided for @englishLang.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLang;

  /// No description provided for @englishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default app language'**
  String get englishSubtitle;

  /// No description provided for @bahasaLang.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get bahasaLang;

  /// No description provided for @bahasaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bahasa utama untuk pengguna lokal'**
  String get bahasaSubtitle;

  /// No description provided for @bahasaShort.
  ///
  /// In en, this message translates to:
  /// **'Bahasa'**
  String get bahasaShort;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification permission'**
  String get notificationPermissionTitle;

  /// No description provided for @getGentleReminders.
  ///
  /// In en, this message translates to:
  /// **'Get gentle reminders'**
  String get getGentleReminders;

  /// No description provided for @getGentleRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'OpenLife can remind you about routines at the right time, without noisy pressure.'**
  String get getGentleRemindersDesc;

  /// No description provided for @scheduledReminders.
  ///
  /// In en, this message translates to:
  /// **'Scheduled reminders'**
  String get scheduledReminders;

  /// No description provided for @quietAndRespectful.
  ///
  /// In en, this message translates to:
  /// **'Quiet and respectful'**
  String get quietAndRespectful;

  /// No description provided for @privateOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Private on device'**
  String get privateOnDevice;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Build better days'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Desc.
  ///
  /// In en, this message translates to:
  /// **'Design a routine that fits your life. Gentle nudges, not rigid rules.'**
  String get onboardingSlide1Desc;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Never miss what matters'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Desc.
  ///
  /// In en, this message translates to:
  /// **'Receive calm reminders for meals, water, vitamins, and small routines that support your day.'**
  String get onboardingSlide2Desc;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Private by default'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Desc.
  ///
  /// In en, this message translates to:
  /// **'Your routines stay on-device first. No account required to start, and no forced cloud setup.'**
  String get onboardingSlide3Desc;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In en, this message translates to:
  /// **'Start with a template'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Desc.
  ///
  /// In en, this message translates to:
  /// **'Pick a starter template to begin, or add routines yourself one at a time.'**
  String get onboardingSlide4Desc;

  /// No description provided for @chooseStartingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your starting language'**
  String get chooseStartingLanguage;

  /// No description provided for @notificationEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders you control'**
  String get notificationEducationTitle;

  /// No description provided for @notificationEducationMessage.
  ///
  /// In en, this message translates to:
  /// **'You decide which routines send a reminder, and you can turn any of them off at any time.'**
  String get notificationEducationMessage;

  /// No description provided for @privacyPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'No account, no cloud'**
  String get privacyPanelTitle;

  /// No description provided for @privacyPanelMessage.
  ///
  /// In en, this message translates to:
  /// **'Everything you create is stored in a local database on this device. Nothing is uploaded.'**
  String get privacyPanelMessage;

  /// No description provided for @pickStarter.
  ///
  /// In en, this message translates to:
  /// **'Pick a starter'**
  String get pickStarter;

  /// No description provided for @orStartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Or, you can start empty and add routines later from the Routines tab.'**
  String get orStartEmpty;

  /// No description provided for @startEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start empty'**
  String get startEmpty;

  /// No description provided for @templateApplied.
  ///
  /// In en, this message translates to:
  /// **'Template added. You can edit anything later.'**
  String get templateApplied;

  /// No description provided for @onboardingStepCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String onboardingStepCounter(int current, int total);

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// No description provided for @calmDayAhead.
  ///
  /// In en, this message translates to:
  /// **'A calm day ahead. Add a routine whenever you are ready.'**
  String get calmDayAhead;

  /// No description provided for @allFinished.
  ///
  /// In en, this message translates to:
  /// **'You finished all your routines today. Great work.'**
  String get allFinished;

  /// No description provided for @smallProgress.
  ///
  /// In en, this message translates to:
  /// **'Small progress still counts. Take it one step at a time.'**
  String get smallProgress;

  /// No description provided for @dailyProgress.
  ///
  /// In en, this message translates to:
  /// **'Daily Progress'**
  String get dailyProgress;

  /// No description provided for @dailyRoutine.
  ///
  /// In en, this message translates to:
  /// **'Daily routine'**
  String get dailyRoutine;

  /// No description provided for @noRoutinesScheduledForDay.
  ///
  /// In en, this message translates to:
  /// **'No routines scheduled for this day.'**
  String get noRoutinesScheduledForDay;

  /// No description provided for @completedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} routines completed.'**
  String completedOfTotal(int completed, int total);

  /// No description provided for @allDoneBadge.
  ///
  /// In en, this message translates to:
  /// **'ALL DONE'**
  String get allDoneBadge;

  /// No description provided for @stayConsistentBadge.
  ///
  /// In en, this message translates to:
  /// **'STAY CONSISTENT'**
  String get stayConsistentBadge;

  /// No description provided for @allDone.
  ///
  /// In en, this message translates to:
  /// **'All Done!'**
  String get allDone;

  /// No description provided for @allDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'You completed all your routines for today. Great work!'**
  String get allDoneMessage;

  /// No description provided for @nextUp.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextUp;

  /// No description provided for @nothingLeftToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing left for today.'**
  String get nothingLeftToday;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @statusSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get statusSnoozed;

  /// No description provided for @statusDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due Now'**
  String get statusDueNow;

  /// No description provided for @skipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipAction;

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @snoozeAction.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snoozeAction;

  /// No description provided for @snoozedUntil.
  ///
  /// In en, this message translates to:
  /// **'Snoozed until {time}'**
  String snoozedUntil(String time);

  /// No description provided for @todayEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled today'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Add a routine to see your day fill up with calm reminders.'**
  String get todayEmptyDesc;

  /// No description provided for @noRoutinesYet.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get noRoutinesYet;

  /// No description provided for @noRoutinesForDateDesc.
  ///
  /// In en, this message translates to:
  /// **'There is nothing scheduled for this date. Add one or pick another day.'**
  String get noRoutinesForDateDesc;

  /// No description provided for @routinesEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Create your first routine so the app can start guiding your day.'**
  String get routinesEmptyDesc;

  /// No description provided for @routinesListEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Start one small routine today. Your list will update here automatically.'**
  String get routinesListEmptyDesc;

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights will appear here'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete a few routines first, then this screen will show your weekly rhythm.'**
  String get insightsEmptyDesc;

  /// No description provided for @templatesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get templatesEmptyTitle;

  /// No description provided for @templatesEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Templates are ready to help once you start building a routine library.'**
  String get templatesEmptyDesc;

  /// No description provided for @browseRoutines.
  ///
  /// In en, this message translates to:
  /// **'Browse routines'**
  String get browseRoutines;

  /// No description provided for @discoverRoutines.
  ///
  /// In en, this message translates to:
  /// **'Discover Routines'**
  String get discoverRoutines;

  /// No description provided for @addStructured.
  ///
  /// In en, this message translates to:
  /// **'Add structured, calm habits to your day with a single tap.'**
  String get addStructured;

  /// No description provided for @browseTemplates.
  ///
  /// In en, this message translates to:
  /// **'Browse Templates'**
  String get browseTemplates;

  /// No description provided for @yourRoutines.
  ///
  /// In en, this message translates to:
  /// **'Your routines'**
  String get yourRoutines;

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templatesTitle;

  /// No description provided for @addTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add Template'**
  String get addTemplate;

  /// No description provided for @stepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String stepsCount(int count);

  /// No description provided for @templateAdded.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" routines added!'**
  String templateAdded(String title);

  /// No description provided for @newRoutine.
  ///
  /// In en, this message translates to:
  /// **'New Routine'**
  String get newRoutine;

  /// No description provided for @editRoutine.
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get editRoutine;

  /// No description provided for @saveRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save Routine'**
  String get saveRoutine;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @routineName.
  ///
  /// In en, this message translates to:
  /// **'Routine Name'**
  String get routineName;

  /// No description provided for @routineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Morning Yoga'**
  String get routineNameHint;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @iconDefaultForCategory.
  ///
  /// In en, this message translates to:
  /// **'Default for category'**
  String get iconDefaultForCategory;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @repeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatLabel;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Take with food'**
  String get notesHint;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @snoozeDuration.
  ///
  /// In en, this message translates to:
  /// **'Snooze duration'**
  String get snoozeDuration;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String minutesShort(int minutes);

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesLabel(int minutes);

  /// No description provided for @routineNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your routine a name first.'**
  String get routineNameRequired;

  /// No description provided for @repeatDaysRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day to repeat.'**
  String get repeatDaysRequired;

  /// No description provided for @categoryMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get categoryMeal;

  /// No description provided for @categoryWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get categoryWater;

  /// No description provided for @categoryVitamin.
  ///
  /// In en, this message translates to:
  /// **'Vitamin'**
  String get categoryVitamin;

  /// No description provided for @categoryMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get categoryMedicine;

  /// No description provided for @categorySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get categorySleep;

  /// No description provided for @categoryExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get categoryExercise;

  /// No description provided for @categoryBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get categoryBreak;

  /// No description provided for @categoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get categoryCustom;

  /// No description provided for @mealRoutine.
  ///
  /// In en, this message translates to:
  /// **'Meal routine'**
  String get mealRoutine;

  /// No description provided for @waterRoutine.
  ///
  /// In en, this message translates to:
  /// **'Hydration routine'**
  String get waterRoutine;

  /// No description provided for @vitaminRoutine.
  ///
  /// In en, this message translates to:
  /// **'Vitamin routine'**
  String get vitaminRoutine;

  /// No description provided for @medicineRoutine.
  ///
  /// In en, this message translates to:
  /// **'Medicine routine'**
  String get medicineRoutine;

  /// No description provided for @sleepRoutine.
  ///
  /// In en, this message translates to:
  /// **'Sleep routine'**
  String get sleepRoutine;

  /// No description provided for @exerciseRoutine.
  ///
  /// In en, this message translates to:
  /// **'Exercise routine'**
  String get exerciseRoutine;

  /// No description provided for @breakRoutine.
  ///
  /// In en, this message translates to:
  /// **'Break routine'**
  String get breakRoutine;

  /// No description provided for @customRoutine.
  ///
  /// In en, this message translates to:
  /// **'Custom routine'**
  String get customRoutine;

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdayShortSun;

  /// No description provided for @weekdayAbbrMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayAbbrMon;

  /// No description provided for @weekdayAbbrTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayAbbrTue;

  /// No description provided for @weekdayAbbrWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayAbbrWed;

  /// No description provided for @weekdayAbbrThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayAbbrThu;

  /// No description provided for @weekdayAbbrFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayAbbrFri;

  /// No description provided for @weekdayAbbrSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayAbbrSat;

  /// No description provided for @weekdayAbbrSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayAbbrSun;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @noRepeatDays.
  ///
  /// In en, this message translates to:
  /// **'No repeat days'**
  String get noRepeatDays;

  /// No description provided for @routineDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine Detail'**
  String get routineDetailTitle;

  /// No description provided for @routineNotFound.
  ///
  /// In en, this message translates to:
  /// **'Routine not found.'**
  String get routineNotFound;

  /// No description provided for @scheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleLabel;

  /// No description provided for @reminderBehavior.
  ///
  /// In en, this message translates to:
  /// **'Reminder behavior'**
  String get reminderBehavior;

  /// No description provided for @snoozeForMinutes.
  ///
  /// In en, this message translates to:
  /// **'Snooze for {minutes} minutes'**
  String snoozeForMinutes(int minutes);

  /// No description provided for @routineIsActive.
  ///
  /// In en, this message translates to:
  /// **'Routine is active'**
  String get routineIsActive;

  /// No description provided for @routineIsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Routine is disabled'**
  String get routineIsDisabled;

  /// No description provided for @editRoutineAction.
  ///
  /// In en, this message translates to:
  /// **'Edit routine'**
  String get editRoutineAction;

  /// No description provided for @deleteRoutine.
  ///
  /// In en, this message translates to:
  /// **'Delete routine'**
  String get deleteRoutine;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @completedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Completed this week'**
  String get completedThisWeek;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreak;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysLabel(int count);

  /// No description provided for @thisWeeksFlow.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Flow'**
  String get thisWeeksFlow;

  /// No description provided for @focusAreas.
  ///
  /// In en, this message translates to:
  /// **'Focus Areas'**
  String get focusAreas;

  /// No description provided for @insightGreatTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great this week!'**
  String get insightGreatTitle;

  /// No description provided for @insightGreatMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep up the momentum — consistency builds better days.'**
  String get insightGreatMessage;

  /// No description provided for @insightSmallProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Small progress still counts.'**
  String get insightSmallProgressTitle;

  /// No description provided for @insightSmallProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Some routines were missed this week. Try again tomorrow — every step matters.'**
  String get insightSmallProgressMessage;

  /// No description provided for @insightBuildRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your routine rhythm.'**
  String get insightBuildRhythmTitle;

  /// No description provided for @insightBuildRhythmMessage.
  ///
  /// In en, this message translates to:
  /// **'Add routines and start tracking to see your weekly insights here.'**
  String get insightBuildRhythmMessage;

  /// No description provided for @insightNoRoutinesTitle.
  ///
  /// In en, this message translates to:
  /// **'No routines tracked yet.'**
  String get insightNoRoutinesTitle;

  /// No description provided for @insightNoRoutinesMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first routine and start building insights over time.'**
  String get insightNoRoutinesMessage;

  /// No description provided for @sevenDayHistory.
  ///
  /// In en, this message translates to:
  /// **'7-Day History'**
  String get sevenDayHistory;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View 7-day history'**
  String get viewHistory;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No history for the last 7 days yet.'**
  String get historyEmpty;

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyYesterday;

  /// No description provided for @historyDoneCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String historyDoneCount(int done, int total);

  /// No description provided for @mostCompleted.
  ///
  /// In en, this message translates to:
  /// **'Most completed'**
  String get mostCompleted;

  /// No description provided for @mostMissed.
  ///
  /// In en, this message translates to:
  /// **'Most missed'**
  String get mostMissed;

  /// No description provided for @timesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String timesCount(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @privacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySection;

  /// No description provided for @themeSetting.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSetting;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get chooseTheme;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @routineAlerts.
  ///
  /// In en, this message translates to:
  /// **'Routine alerts'**
  String get routineAlerts;

  /// No description provided for @notificationPermissionRequested.
  ///
  /// In en, this message translates to:
  /// **'Notification permission requested.'**
  String get notificationPermissionRequested;

  /// No description provided for @reducedMotionSetting.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reducedMotionSetting;

  /// No description provided for @reducedMotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn off celebration and looping animations.'**
  String get reducedMotionDescription;

  /// No description provided for @exportSetting.
  ///
  /// In en, this message translates to:
  /// **'Export routines'**
  String get exportSetting;

  /// No description provided for @importSetting.
  ///
  /// In en, this message translates to:
  /// **'Import routines'**
  String get importSetting;

  /// No description provided for @resetSetting.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get resetSetting;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get exportJson;

  /// No description provided for @resetDestructive.
  ///
  /// In en, this message translates to:
  /// **'Destructive'**
  String get resetDestructive;

  /// No description provided for @privacyData.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get privacyData;

  /// No description provided for @aboutOpenSourceSetting.
  ///
  /// In en, this message translates to:
  /// **'About open source'**
  String get aboutOpenSourceSetting;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @pasteJsonHint.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON backup here...'**
  String get pasteJsonHint;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @routinesImported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 routine imported.} other{{count} routines imported.}}'**
  String routinesImported(int count);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @resetAllData.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetAllData;

  /// No description provided for @resetWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your routines, schedules, and logs. This action cannot be undone.'**
  String get resetWarning;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @allDataReset.
  ///
  /// In en, this message translates to:
  /// **'All data has been reset.'**
  String get allDataReset;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get privacyTitle;

  /// No description provided for @privacyLocal.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get privacyLocal;

  /// No description provided for @privacyLocalBody.
  ///
  /// In en, this message translates to:
  /// **'OpenLife Routine stores all your routines, schedules, and logs locally on your phone. No data is sent to any server.'**
  String get privacyLocalBody;

  /// No description provided for @privacyNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account required'**
  String get privacyNoAccount;

  /// No description provided for @privacyNoAccountBody.
  ///
  /// In en, this message translates to:
  /// **'You can use all features without creating an account. There is no login, no registration, and no personal information collected.'**
  String get privacyNoAccountBody;

  /// No description provided for @privacyOffline.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get privacyOffline;

  /// No description provided for @privacyOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'All core features work without an internet connection. Reminders are scheduled locally and trigger even when you are offline.'**
  String get privacyOfflineBody;

  /// No description provided for @privacyControl.
  ///
  /// In en, this message translates to:
  /// **'You control your data'**
  String get privacyControl;

  /// No description provided for @privacyControlBody.
  ///
  /// In en, this message translates to:
  /// **'You can export your data as JSON at any time from Settings. You can also import a backup or reset all data from your device.'**
  String get privacyControlBody;

  /// No description provided for @privacyNoTracking.
  ///
  /// In en, this message translates to:
  /// **'No tracking or analytics'**
  String get privacyNoTracking;

  /// No description provided for @privacyNoTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'This app does not use third-party analytics, advertising trackers, or any form of user monitoring. Your routine is yours alone.'**
  String get privacyNoTrackingBody;

  /// No description provided for @privacyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'OpenLife Routine is not a medical app.'**
  String get privacyDisclaimer;

  /// No description provided for @privacyDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'It is a lifestyle and routine reminder app designed to help you build better days. It does not diagnose, treat, or cure any condition.'**
  String get privacyDisclaimerBody;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Open Source'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get aboutOpenSource;

  /// No description provided for @aboutOpenSourceBody.
  ///
  /// In en, this message translates to:
  /// **'OpenLife Routine is free and open-source software. The full source code is available on GitHub under the Apache 2.0 license.'**
  String get aboutOpenSourceBody;

  /// No description provided for @aboutBuiltWith.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter'**
  String get aboutBuiltWith;

  /// No description provided for @aboutBuiltWithBody.
  ///
  /// In en, this message translates to:
  /// **'This app is built with Flutter and Dart, using Clean Architecture, BLoC state management, Drift SQLite, local notifications, and Rive animations.'**
  String get aboutBuiltWithBody;

  /// No description provided for @aboutPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio project'**
  String get aboutPortfolio;

  /// No description provided for @aboutPortfolioBody.
  ///
  /// In en, this message translates to:
  /// **'OpenLife Routine was built as a production-quality open-source portfolio project to demonstrate Flutter engineering, architecture, and product design skills.'**
  String get aboutPortfolioBody;

  /// No description provided for @aboutLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutLicense;

  /// No description provided for @aboutLicenseBody.
  ///
  /// In en, this message translates to:
  /// **'Apache License 2.0 — Free for personal and commercial use. The OpenLife Routine name and logo are reserved for the official project.'**
  String get aboutLicenseBody;

  /// No description provided for @notificationSnoozedTitle.
  ///
  /// In en, this message translates to:
  /// **'Snoozed reminder'**
  String get notificationSnoozedTitle;

  /// iOS action label. iOS registers notification categories once at startup, so the label cannot carry a per-routine snooze duration the way the Android one does.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get notificationSnoozeActionGeneric;

  /// No description provided for @notificationSnoozeAction.
  ///
  /// In en, this message translates to:
  /// **'Snooze {minutes} min'**
  String notificationSnoozeAction(int minutes);

  /// No description provided for @templateMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Routine'**
  String get templateMorningTitle;

  /// No description provided for @templateMorningDesc.
  ///
  /// In en, this message translates to:
  /// **'Start your day with intention and a gentle pace.'**
  String get templateMorningDesc;

  /// No description provided for @templateHydrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration Tracker'**
  String get templateHydrationTitle;

  /// No description provided for @templateHydrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep your water intake consistent throughout the day.'**
  String get templateHydrationDesc;

  /// No description provided for @templateVitaminTitle.
  ///
  /// In en, this message translates to:
  /// **'Vitamin Routine'**
  String get templateVitaminTitle;

  /// No description provided for @templateVitaminDesc.
  ///
  /// In en, this message translates to:
  /// **'Never miss a supplement with timed daily reminders.'**
  String get templateVitaminDesc;

  /// No description provided for @templateSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep Routine'**
  String get templateSleepTitle;

  /// No description provided for @templateSleepDesc.
  ///
  /// In en, this message translates to:
  /// **'Wind down your day with a calming evening rhythm.'**
  String get templateSleepDesc;

  /// No description provided for @templateProgrammerBreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Programmer Break'**
  String get templateProgrammerBreakTitle;

  /// No description provided for @templateProgrammerBreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Eye rest and posture resets to combat screen fatigue.'**
  String get templateProgrammerBreakDesc;

  /// No description provided for @badgePopular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get badgePopular;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// No description provided for @templateRoutineWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Wake Up'**
  String get templateRoutineWakeUp;

  /// No description provided for @templateRoutineDrinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink Water'**
  String get templateRoutineDrinkWater;

  /// No description provided for @templateRoutineBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get templateRoutineBreakfast;

  /// No description provided for @templateRoutineMorningWater.
  ///
  /// In en, this message translates to:
  /// **'Morning Water'**
  String get templateRoutineMorningWater;

  /// No description provided for @templateRoutineMiddayWater.
  ///
  /// In en, this message translates to:
  /// **'Midday Water'**
  String get templateRoutineMiddayWater;

  /// No description provided for @templateRoutineAfternoonWater.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Water'**
  String get templateRoutineAfternoonWater;

  /// No description provided for @templateRoutineEveningWater.
  ///
  /// In en, this message translates to:
  /// **'Evening Water'**
  String get templateRoutineEveningWater;

  /// No description provided for @templateRoutineVitaminD3.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D3'**
  String get templateRoutineVitaminD3;

  /// No description provided for @templateRoutineBComplex.
  ///
  /// In en, this message translates to:
  /// **'B Complex'**
  String get templateRoutineBComplex;

  /// No description provided for @templateRoutineReduceScreenTime.
  ///
  /// In en, this message translates to:
  /// **'Reduce Screen Time'**
  String get templateRoutineReduceScreenTime;

  /// No description provided for @templateRoutinePrepareBed.
  ///
  /// In en, this message translates to:
  /// **'Prepare Bed'**
  String get templateRoutinePrepareBed;

  /// No description provided for @templateRoutineEyeRest.
  ///
  /// In en, this message translates to:
  /// **'Eye Rest'**
  String get templateRoutineEyeRest;

  /// No description provided for @templateRoutineStretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get templateRoutineStretching;

  /// No description provided for @templateRoutinePostureCheck.
  ///
  /// In en, this message translates to:
  /// **'Posture Check'**
  String get templateRoutinePostureCheck;

  /// No description provided for @notificationReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder for {title}'**
  String notificationReminderBody(String title);

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Routine reminders'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminder notifications for daily routines'**
  String get notificationChannelDescription;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Backup copied to the clipboard.'**
  String get copiedToClipboard;

  /// No description provided for @notificationDoneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notificationDoneAction;

  /// No description provided for @routineActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get routineActiveLabel;

  /// No description provided for @routineActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Send reminders for this routine.'**
  String get routineActiveDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
