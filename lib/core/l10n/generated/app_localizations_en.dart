// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'The right job on the right day';

  @override
  String get splashChecking => 'Checking the weather forecast…';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDontKnow => 'I don\'t know';

  @override
  String get commonOptional => '(optional)';

  @override
  String get commonLess => 'Fewer days';

  @override
  String get commonMore => 'More days';

  @override
  String get commonRetry => 'Try again';

  @override
  String get routeNotFoundTitle => 'This page does not exist';

  @override
  String get routeNotFoundAction => 'Back to start';

  @override
  String get commonMinutes => 'min';

  @override
  String get commonSquareMeters => 'm²';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String onboardingStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingFinish => 'Create my plan';

  @override
  String get onboardingSkipRest => 'Create the plan now, I\'ll add the rest later';

  @override
  String get onboardingSaveError => 'Could not save. Try again.';

  @override
  String get locationTitle => 'Let\'s get to know your lawn';

  @override
  String get locationBody =>
      'No account needed. All data stays in the app, and your location is only used to get the weather forecast.';

  @override
  String get locationNameLabel => 'Lawn name';

  @override
  String get locationNameHint => 'e.g. Front yard';

  @override
  String get locationLabel => 'Location';

  @override
  String get locationUseMine => 'Use my location';

  @override
  String get locationOr => 'or';

  @override
  String get locationCityHint => 'Enter a town';

  @override
  String get locationCurrent => 'Current location';

  @override
  String get locationTip =>
      'The exact lawn location makes the advice more accurate, because rain in town does not always fall on your garden.';

  @override
  String get locationServiceDisabled => 'Turn on location services on your phone or enter a town.';

  @override
  String get locationPermissionDenied => 'Without location permission, enter the town manually.';

  @override
  String get locationNotFound => 'I couldn\'t find that place.';

  @override
  String get locationNetwork => 'No internet connection. Try again.';

  @override
  String get basicsTitle => 'Basic details';

  @override
  String get basicsBody => 'The age of the lawn decides when you can scarify or aerate it.';

  @override
  String get basicsAreaLabel => 'Area';

  @override
  String get basicsAreaHelper => 'Needed to calculate fertilizer and seed amounts.';

  @override
  String get basicsEstablishedLabel => 'When the lawn was established';

  @override
  String get basicsEstablishedHint => 'Choose month and year';

  @override
  String get basicsEstablishedHelper => 'Month and year are enough.';

  @override
  String basicsLawnAge(int seasons) {
    String _temp0 = intl.Intl.pluralLogic(
      seasons,
      locale: localeName,
      other: 'about $seasons seasons',
      one: 'about 1 season',
      zero: 'first season',
    );
    return 'Month and year are enough. Lawn age: $_temp0.';
  }

  @override
  String get basicsMethodLabel => 'How it was established';

  @override
  String get basicsMethodSeeded => 'From seed';

  @override
  String get basicsMethodSod => 'From sod';

  @override
  String get basicsSunLabel => 'Sunlight';

  @override
  String get basicsSunFull => 'Sun';

  @override
  String get basicsSunPartial => 'Part shade';

  @override
  String get basicsSunShade => 'Shade';

  @override
  String get soilTitle => 'Grass mix and soil';

  @override
  String get soilBody => 'Not sure? Choose “I don\'t know” and fill it in later.';

  @override
  String get soilMixLabel => 'Grass mix';

  @override
  String get soilMixUniversal => 'Universal / recreational';

  @override
  String get soilMixUniversalHint => 'Hard-wearing, for families and pets';

  @override
  String get soilMixOrnamental => 'Ornamental';

  @override
  String get soilMixOrnamentalHint => 'Dense, mown low, demanding';

  @override
  String get soilMixShade => 'For shade';

  @override
  String get soilMixDrought => 'For drought';

  @override
  String get soilMixSport => 'Sports';

  @override
  String get soilTypeLabel => 'Soil type';

  @override
  String get soilTypeSandy => 'Sandy';

  @override
  String get soilTypeMedium => 'Medium';

  @override
  String get soilTypeClay => 'Clay';

  @override
  String get soilPhLabel => 'Soil pH';

  @override
  String get soilPhHint => 'e.g. 6.2 from a test strip';

  @override
  String get soilPhError => 'Enter a value from 3 to 9.';

  @override
  String get careTitle => 'Watering and mowing';

  @override
  String get careWateringLabel => 'How do you water?';

  @override
  String get careWateringAuto => 'Automatic';

  @override
  String get careWateringManual => 'By hand';

  @override
  String get careSectionTime => 'Run time of one zone';

  @override
  String get careSectionHelper =>
      'We\'ll measure how many millimetres of water that is later, with a simple cup test.';

  @override
  String get careManualHelper => 'We\'ll tell you when to water and how much.';

  @override
  String get careMowingLabel => 'Mow every';

  @override
  String get careLastMowedLabel => 'Last mowed';

  @override
  String get careGardenDaysLabel => 'When do you have time for the garden?';

  @override
  String get careGardenDaysHelper => 'We\'ll plan jobs for the best of these days.';

  @override
  String get feedTitle => 'Fertilizing';

  @override
  String get feedBody =>
      'Tell us how you fertilize. We\'ll pick the day when the weather is right.';

  @override
  String get feedIntervalLabel => 'I fertilize every';

  @override
  String get feedWindowLabel => 'Flexible window';

  @override
  String feedWindowRange(int start, int end) {
    return 'day $start–$end';
  }

  @override
  String feedWindowHelper(int interval) {
    return 'If conditions are ideal, we\'ll notify you earlier or later than day $interval.';
  }

  @override
  String get feedLastLabel => 'Last fertilized';

  @override
  String get feedLastHint => 'Choose a date';

  @override
  String get feedLastUnknown => 'I don\'t remember';

  @override
  String get homeBadgeIdeal => 'Ideal day';

  @override
  String homeCycleDay(int day, int interval) {
    return 'day $day of $interval';
  }

  @override
  String homeRainFrom(int hour, String mm) {
    return 'Light rain from $hour:00, about $mm mm, it will water the fertilizer in';
  }

  @override
  String homeRain(String mm) {
    return 'Light rain, about $mm mm, it will water the fertilizer in';
  }

  @override
  String get homeNoRain => 'No rain: water the lawn after fertilizing';

  @override
  String homeSeason(String season) {
    String _temp0 = intl.Intl.selectLogic(season, {
      'spring': 'In spring: nitrogen-rich fertilizer.',
      'summer': 'In summer: smaller doses, don\'t fertilize in heat.',
      'autumn': 'In autumn: potassium-rich fertilizer.',
      'other': 'In winter the lawn rests, fertilizing is paused.',
    });
    return '$_temp0';
  }

  @override
  String get homeDone => 'Done';

  @override
  String homeDoneSnack(int interval) {
    return 'Saved. Next fertilizing in about $interval days.';
  }

  @override
  String get homePostponedSnack => 'Looking for another day in the fertilizing window.';

  @override
  String get homeTodayWork => 'To do today';

  @override
  String get homeNothingToday => 'No garden work today.';

  @override
  String homeSeasonOver(String date) {
    return 'The lawn season is over. The grass is resting, the plan will be back on $date.';
  }

  @override
  String get homeBadgeToday => 'Today';

  @override
  String get homeBadgeNext => 'Coming up';

  @override
  String get homePostponeFertilizing => 'Postpone fertilizing';

  @override
  String get homeDoneGeneric => 'Saved as done.';

  @override
  String get homeMarkDone => 'Mark as done';

  @override
  String get homeNextDays => 'Next days';

  @override
  String get homeCalendar => 'Calendar';

  @override
  String homeRainMm(String mm) {
    return '$mm mm';
  }

  @override
  String homeTemperatureShort(int temp) {
    return '$temp°';
  }

  @override
  String get homeWateringNotNeeded => 'Watering: not needed';

  @override
  String get homeWateringNeeded => 'Watering: needed';

  @override
  String get homeWateringRain => 'Water balance is fine, rain will do the job';

  @override
  String get homeWateringCool => 'It\'s cool, the lawn uses little water';

  @override
  String homeWateringAuto(int minutes) {
    return 'Sprinkler: $minutes min per zone, early in the morning';
  }

  @override
  String homeWateringManual(int litres) {
    return 'Water early in the morning, about $litres l per m²';
  }

  @override
  String get homeLoadError => 'Could not load the weather forecast.';

  @override
  String get homeBadgePinned => 'Pinned';

  @override
  String careKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'fertilizing': 'Fertilizing',
      'mowing': 'Mowing',
      'watering': 'Watering',
      'aeration': 'Aeration',
      'scarification': 'Scarification',
      'overseeding': 'Overseeding',
      'liming': 'Liming',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarAdd => 'Add a job';

  @override
  String get calendarPrevMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarLegendOwn => 'Your job';

  @override
  String get calendarLegendWindow => 'Fertilizing window';

  @override
  String get calendarLegendTentative => 'Tentative date, no forecast';

  @override
  String calendarToday(String date) {
    return 'Today, $date';
  }

  @override
  String get calendarEmptyDay => 'No jobs on this day.';

  @override
  String weatherRainFrom(int temp, int hour) {
    return '$temp°, rain from $hour:00';
  }

  @override
  String weatherRain(int temp, String mm) {
    return '$temp°, $mm mm of rain';
  }

  @override
  String weatherDry(int temp) {
    return '$temp°, dry';
  }

  @override
  String get entryDone => 'Done';

  @override
  String entryTentative(String start, String end) {
    return 'Tentative date · window $start–$end';
  }

  @override
  String get entryPinned => 'Pinned';

  @override
  String entryEvery(String days) {
    return 'Every $days';
  }

  @override
  String get entryBeforeRain => 'In the morning, before it rains';

  @override
  String get entryOwn => 'Your job';

  @override
  String entryMoved(String date) {
    return 'Moved from $date because of the weather';
  }

  @override
  String sheetFromPlan(String days) {
    return 'From your plan, every $days';
  }

  @override
  String get sheetTagTentative => 'Tentative date';

  @override
  String get sheetTagMatched => 'Matched to the weather';

  @override
  String get sheetTagFixed => 'Fixed date';

  @override
  String sheetWindow(String start, String end, int from, int to) {
    return 'Fertilizing window: $start–$end, that is days $from–$to after the previous fertilizing.';
  }

  @override
  String sheetForecastLater(String date) {
    return 'The forecast will cover this window around $date. Then we\'ll pick the best of your days.';
  }

  @override
  String get sheetNextCycle => 'We\'ll set the exact date after the previous fertilizing.';

  @override
  String sheetMowing(String days) {
    return 'Mowing every $days, on your garden days.';
  }

  @override
  String get sheetFlexible => 'We\'ll move the job by 2 days at most if the weather is better.';

  @override
  String get sheetFixed => 'Fixed date, we don\'t move it.';

  @override
  String sheetPin(String date) {
    return 'Pin to $date';
  }

  @override
  String get sheetPinHelper =>
      'We won\'t move a pinned day, but we\'ll warn you about bad weather.';

  @override
  String get sheetUnpin => 'Match to the weather';

  @override
  String get sheetChangeDate => 'Change date';

  @override
  String get sheetSkipCycle => 'Skip this cycle';

  @override
  String get sheetDelete => 'Delete';

  @override
  String get sheetRemove => 'Remove from calendar';

  @override
  String get sheetRemoved => 'Removed from calendar.';

  @override
  String get sheetUndo => 'Undo';

  @override
  String get sheetClose => 'Close';

  @override
  String get addTitle => 'New job';

  @override
  String get addEditTitle => 'Edit job';

  @override
  String get addKind => 'Type';

  @override
  String get addDate => 'Date';

  @override
  String get addFlexLabel => 'When the weather changes';

  @override
  String get addKeepDay => 'Keep this day';

  @override
  String get addFitWeather => 'Match to the weather';

  @override
  String get addFlexHelper => 'We\'ll move the job by 2 days at most and let you know.';

  @override
  String get addNote => 'Note';

  @override
  String get addNoteHint => 'e.g. borrow an aerator from a neighbour';

  @override
  String get addSave => 'Save to calendar';

  @override
  String get addNoForecast =>
      'There is no forecast for this day yet. We\'ll check it closer to the date.';

  @override
  String addGoodWeather(String date, String weather) {
    return '$date: $weather. The weather is good.';
  }

  @override
  String addBadWeather(String date, String weather, String hint) {
    return '$date: $weather. $hint';
  }

  @override
  String addMoveTo(String date, String weather) {
    return 'Move to $date · $weather';
  }

  @override
  String careWeatherHint(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'fertilizing': 'The weather is not good for fertilizing.',
      'mowing': 'Wet grass mows badly.',
      'watering': 'Rain will water the lawn for you.',
      'aeration': 'Wet soil sticks to the aerator tines.',
      'scarification': 'Scarify on a dry lawn.',
      'overseeding': 'Heavy rain or heat will harm the seed.',
      'liming': 'Spread lime without strong wind or heavy rain.',
      'other': 'The weather is not good on this day.',
    });
    return '$_temp0';
  }

  @override
  String get sheetStripPlan => 'plan';

  @override
  String get sheetStripBusy => 'no time';

  @override
  String get sheetTagPinned => 'Pinned';

  @override
  String get weatherOpen => '14-day forecast';

  @override
  String get weatherTitle => 'Weather';

  @override
  String get weatherNow => 'Now';

  @override
  String weatherWind(int speed) {
    return 'Wind $speed km/h';
  }

  @override
  String weatherTodayRange(int max, int min) {
    return 'Today $max° / $min°';
  }

  @override
  String weatherRainChance(int chance) {
    return 'Chance of rain $chance%';
  }

  @override
  String get weatherDays => 'Next 14 days';

  @override
  String get weatherLessCertain => 'Later days: the forecast is less certain';

  @override
  String get weatherToday => 'Today';

  @override
  String get weatherTomorrow => 'Tomorrow';

  @override
  String weatherMinMax(int max, int min) {
    return '$max° / $min°';
  }

  @override
  String get weatherSource => 'Weather data: MET Norway (met.no)';

  @override
  String get dayHourly => 'Hour by hour';

  @override
  String get dayNoForecast => 'No forecast for this day yet.';

  @override
  String get dayPlanned => 'Planned work';

  @override
  String get dayMowingLegend => 'Good time to mow: dry grass, no dew or heat';

  @override
  String dayWindMax(int speed) {
    return 'Wind up to $speed km/h';
  }

  @override
  String get journalTitle => 'Journal';

  @override
  String get journalAdd => 'Add entry';

  @override
  String journalSeason(int year) {
    return '$year season';
  }

  @override
  String get journalSummary => 'Summary';

  @override
  String journalMowings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mowings',
      one: 'mowing',
    );
    return '$_temp0';
  }

  @override
  String journalFertilizings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fertilizings',
      one: 'fertilizing',
    );
    return '$_temp0';
  }

  @override
  String journalWaterings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'waterings',
      one: 'watering',
    );
    return '$_temp0';
  }

  @override
  String get journalFilterAll => 'All';

  @override
  String get journalFilterNotes => 'Notes';

  @override
  String get journalFilterPhotos => 'Photos';

  @override
  String get journalEmpty =>
      'The journal is empty. Entries appear when you mark a job as done or add a note.';

  @override
  String get journalFilterEmpty => 'No entries of this type.';

  @override
  String journalKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'observation': 'Observation',
      'photo': 'Photo',
      'measurement': 'pH measurement',
      'other': 'Job',
    });
    return '$_temp0';
  }

  @override
  String observationTag(String tag) {
    String _temp0 = intl.Intl.selectLogic(tag, {
      'moss': 'Moss',
      'weeds': 'Weeds',
      'yellowPatches': 'Yellow patches',
      'bareSpots': 'Bare spots',
      'grubs': 'Grubs',
      'other': 'Molehill',
    });
    return '$_temp0';
  }

  @override
  String journalDose(String dose, String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {'mlPerSqm': 'ml/m²', 'other': 'g/m²'});
    return '$dose $_temp0';
  }

  @override
  String journalTotal(String amount, String unit, int area) {
    String _temp0 = intl.Intl.selectLogic(unit, {'mlPerSqm': 'l', 'other': 'kg'});
    return '$amount $_temp0 for $area m²';
  }

  @override
  String journalHeight(String cm) {
    return 'Height $cm cm';
  }

  @override
  String journalPh(String value) {
    return 'pH $value';
  }

  @override
  String get journalDetailsMissing => 'Add details: fertilizer and dose';

  @override
  String get journalRainConfirmed => 'Watered in by rain';

  @override
  String journalDoneAt(String time) {
    return 'done at $time';
  }

  @override
  String get journalProduct => 'Fertilizer';

  @override
  String get journalNpk => 'NPK';

  @override
  String get journalDoseLabel => 'Dose';

  @override
  String get journalWholeLawn => 'For the whole lawn';

  @override
  String get journalRainAfter => 'Rain after the job';

  @override
  String get journalRainDays => '3 days';

  @override
  String get journalRainSource => 'According to the weather model for your location.';

  @override
  String get journalRainQuestion => 'Did it rain at your place?';

  @override
  String get journalYes => 'Yes';

  @override
  String get journalNo => 'No';

  @override
  String get journalRainYes => 'You confirmed it rained. The fertilizer was watered in.';

  @override
  String get journalRainNo =>
      'It didn\'t rain at your place. If you fertilized without rain, water the lawn afterwards.';

  @override
  String get journalNote => 'Note';

  @override
  String get journalEdit => 'Edit';

  @override
  String get journalDelete => 'Delete entry';

  @override
  String get journalDeleted => 'Entry deleted.';

  @override
  String get journalNewTitle => 'New entry';

  @override
  String get journalEditTitle => 'Edit entry';

  @override
  String get journalWhatSeen => 'What did you notice?';

  @override
  String get journalDescription => 'Description';

  @override
  String get journalDescriptionHint => 'e.g. moss under the birch, about 2 m²';

  @override
  String get journalPhotos => 'Photos';

  @override
  String get journalCamera => 'Camera';

  @override
  String get journalGallery => 'Gallery';

  @override
  String get journalRemovePhoto => 'Remove photo';

  @override
  String get journalDate => 'Date';

  @override
  String get journalPhValue => 'pH measurement result';

  @override
  String get journalPhHint => 'e.g. 6.2';

  @override
  String get journalProductHint => 'e.g. autumn, potassium-rich';

  @override
  String get journalNpkHint => 'e.g. 5-3-10';

  @override
  String get journalDoseHint => 'e.g. 30';

  @override
  String get journalHeightLabel => 'Mowing height';

  @override
  String get journalMinutesLabel => 'Watering time';

  @override
  String get journalSave => 'Save to journal';

  @override
  String journalSeasonRange(String start, String end, String name) {
    return '$start – $end · $name';
  }

  @override
  String get journalMonths => 'Jobs by month';

  @override
  String get journalLegendMowing => 'mowing';

  @override
  String get journalLegendFertilizing => 'fertilizing';

  @override
  String get journalNitrogen => 'Nitrogen this season';

  @override
  String journalNitrogenValue(String kg) {
    return '$kg kg / 100 m²';
  }

  @override
  String journalNitrogenRange(String min, String max) {
    return 'Rough guide for your mix: $min–$max kg.';
  }

  @override
  String get journalNitrogenMissing =>
      'Add NPK and dose to your fertilizing entries to calculate nitrogen.';

  @override
  String get journalFertilizerUsed => 'Fertilizer';

  @override
  String journalLiquid(String litres) {
    return 'and $litres l of liquid';
  }

  @override
  String get journalRain => 'Rain';

  @override
  String journalRainMm(String mm) {
    return '$mm mm';
  }

  @override
  String get journalObservations => 'Observations to check';

  @override
  String homeWateringCalibrated(int minutes, String mm) {
    return 'Sprinkler: $minutes min per zone, about $mm mm, early in the morning';
  }

  @override
  String journalWateringMm(String mm) {
    return 'and $mm mm from watering';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get notifChannelName => 'Lawn care';

  @override
  String programNoteAverage(String value) {
    return 'average $value';
  }

  @override
  String programNoteSource(String site) {
    return 'Source: $site';
  }

  @override
  String get lawnTitle => 'Lawn';

  @override
  String get lawnsTitle => 'Your lawns';

  @override
  String get lawnsOpen => 'Switch or add a lawn';

  @override
  String get lawnsEditSection => 'Edit the selected lawn';

  @override
  String get lawnsEditData => 'Lawn name and details';

  @override
  String get lawnsAdd => 'Add a new lawn';

  @override
  String get lawnsNotificationsNote => 'Notifications are sent for the selected lawn.';

  @override
  String lawnSubtitle(String place, int area, String age) {
    return '$place · $area m² · $age';
  }

  @override
  String lawnAge(int seasons) {
    String _temp0 = intl.Intl.pluralLogic(
      seasons,
      locale: localeName,
      other: '$seasons seasons',
      one: '1 season',
      zero: 'first season',
    );
    return '$_temp0';
  }

  @override
  String get lawnPh => 'Soil pH';

  @override
  String get lawnLastFertilized => 'Fertilized';

  @override
  String get lawnLastMowed => 'Mowed';

  @override
  String lawnObservations(int count, String tags) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observations to check',
      one: '1 observation to check',
    );
    return '$_temp0: $tags';
  }

  @override
  String get lawnSettings => 'Lawn settings';

  @override
  String lawnSoilSummary(String soil) {
    return '$soil soil';
  }

  @override
  String get lawnData => 'Lawn details';

  @override
  String get lawnCare => 'Care';

  @override
  String get lawnCalibration => 'Sprinkler calibration';

  @override
  String lawnMowingEvery(String days) {
    return 'Mow every $days';
  }

  @override
  String lawnCareSub(String days, String weekdays) {
    return 'Fertilize every $days · $weekdays';
  }

  @override
  String get lawnNotCalibrated => 'Not done';

  @override
  String lawnRate(String rate) {
    return '$rate mm/min';
  }

  @override
  String get lawnAppearance => 'Appearance';

  @override
  String get lawnThemeLight => 'Light';

  @override
  String get lawnThemeDark => 'Dark';

  @override
  String get lawnThemeSystem => 'System';

  @override
  String get lawnSave => 'Save';

  @override
  String get lawnSaved => 'Saved.';

  @override
  String get lawnEstablished => 'Established';

  @override
  String get lawnMix => 'Grass mix';

  @override
  String get lawnSoil => 'Soil';

  @override
  String lawnPhFromJournal(String date) {
    return 'From a journal measurement, $date.';
  }

  @override
  String get lawnHeight => 'Height';

  @override
  String lawnHeightValue(int cm) {
    return '$cm cm';
  }

  @override
  String get lawnGardenDays => 'Garden days';

  @override
  String get lawnWatering => 'Watering';

  @override
  String lawnSectionMm(String mm) {
    return 'About $mm mm per watering.';
  }

  @override
  String get lawnSeason => 'Season';

  @override
  String get lawnSeasonStart => 'Start';

  @override
  String get lawnSeasonEnd => 'End';

  @override
  String get lawnSeasonHelper =>
      'Outside the season we don\'t plan mowing, fertilizing or watering.';

  @override
  String get lawnSeasonInvalid => 'The season must end after it starts.';

  @override
  String get calSubtitle => 'How much water one minute of watering gives';

  @override
  String get calStep1Title => 'Place 4 cups';

  @override
  String get calStep1 => 'Straight, flat-bottomed containers in different spots of one zone.';

  @override
  String calStep2Title(int minutes) {
    return 'Run the zone for $minutes min';
  }

  @override
  String get calStep2 => 'Water as you usually do, without changing the sprinkler settings.';

  @override
  String get calStep3Title => 'Measure the water with a ruler';

  @override
  String get calStep3 => 'Enter the water height in each cup.';

  @override
  String get calTestTime => 'Test time';

  @override
  String calCup(int number) {
    return 'Cup $number';
  }

  @override
  String get calResult => 'Result';

  @override
  String calRate(String rate) {
    return '$rate mm per minute';
  }

  @override
  String calAverage(String mm, int minutes, int target, int needed) {
    return 'Average $mm mm in $minutes min. To apply $target mm, run the zone for $needed min.';
  }

  @override
  String calEven(String mm) {
    return 'Cups differ by $mm mm: water is spread evenly.';
  }

  @override
  String calUneven(String mm) {
    return 'Cups differ by $mm mm: check your sprinklers, part of the lawn gets less water.';
  }

  @override
  String get calMissing => 'Enter the result from at least one cup.';

  @override
  String get calSave => 'Save result';

  @override
  String homeWateringMoves(int minutes, int moves) {
    return 'Hose sprinkler: $minutes min in one spot, move it about $moves times';
  }

  @override
  String homeWateringSpot(int minutes) {
    return 'Hose sprinkler: $minutes min in one spot';
  }

  @override
  String homeWateringHose(String perSqm, String total) {
    return 'Hose: about $perSqm min per m², whole lawn about $total.';
  }

  @override
  String homeWateringInParts(int parts) {
    String _temp0 = intl.Intl.pluralLogic(
      parts,
      locale: localeName,
      other: 'Split it over $parts evenings.',
    );
    return '$_temp0';
  }

  @override
  String homeWateringCan(String litres, String cans, int can) {
    return 'Watering can: $litres l per m², that is $cans cans of $can l. Start with the driest spots.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get manualMethodLabel => 'What do you water with?';

  @override
  String get manualSprinkler => 'Sprinkler';

  @override
  String get manualHose => 'Hose';

  @override
  String get manualCan => 'Watering can';

  @override
  String get lawnMeasurement => 'Watering measurement';

  @override
  String get lawnMethodNone => 'Not selected';

  @override
  String lawnFlow(String flow) {
    return '$flow l/min';
  }

  @override
  String lawnCanValue(int litres) {
    return '$litres l watering can';
  }

  @override
  String get calCoverage => 'Sprinkler coverage';

  @override
  String get calCoverageHelper => 'Area watered from one spot. A circle 6 m across is about 28 m².';

  @override
  String calMoves(int area, int moves) {
    return 'For $area m², move the sprinkler about $moves times.';
  }

  @override
  String get calHoseSubtitle => 'How much water your hose gives per minute';

  @override
  String get calBucketStep1Title => 'Take a bucket of known size';

  @override
  String get calBucketStep1 => '10 l is best. Set the nozzle the way you usually water.';

  @override
  String get calBucketStep2Title => 'Time how long it takes to fill';

  @override
  String get calBucketStep2 =>
      'Turn on the water and use a stopwatch to see how many seconds it takes to fill the bucket.';

  @override
  String get calBucket => 'Bucket size';

  @override
  String calBucketLitres(int litres) {
    return '$litres l';
  }

  @override
  String get calSeconds => 'Fill time';

  @override
  String get calSecondsHint => 'e.g. 50';

  @override
  String calFlow(String flow) {
    return '$flow l per minute';
  }

  @override
  String calHoseResult(int target, String perSqm, int area, String total) {
    return 'To apply $target mm: about $perSqm min per m², whole lawn ($area m²) about $total.';
  }

  @override
  String get calSecondsMissing => 'Enter how many seconds it takes to fill the bucket.';

  @override
  String get calCanTitle => 'Watering with a can';

  @override
  String calCanText(int target, String litres, String cans, int can, int area, int total) {
    return '$target mm of water takes $litres l per m², that is $cans cans of $can l. The whole lawn ($area m²) needs about $total l, so use the can only on the driest spots.';
  }

  @override
  String get journalMinutesSpot => 'Minutes in one spot';

  @override
  String get journalLitresLabel => 'Amount of water';

  @override
  String journalLitres(String litres) {
    return '$litres l of water';
  }

  @override
  String get calHoseByBucket => 'Bucket';

  @override
  String get calHoseByCups => 'Cups';

  @override
  String get calHoseCupsStep1Title => 'Mark out a patch of lawn';

  @override
  String get calHoseCupsStep1 => 'E.g. a 3 × 3 m square. Place 4 cups in it.';

  @override
  String calHoseCupsStep2Title(int minutes) {
    return 'Water it with the hose for $minutes min';
  }

  @override
  String get calHoseCupsStep2 => 'As usual, evenly over the whole patch, without going outside it.';

  @override
  String get calTestArea => 'Patch area';

  @override
  String calHoseCupsFlow(String mm, int minutes, String flow) {
    return 'On average the lawn gets $mm mm in $minutes min, about $flow l per minute.';
  }

  @override
  String get calAreaMissing => 'Enter the patch area and the result from at least one cup.';

  @override
  String get assistantTitle => 'Assistant';

  @override
  String get assistantSubtitle => 'Knows your lawn, weather and journal';

  @override
  String get assistantAskHint => 'Ask about your lawn…';

  @override
  String get assistantFollowHint => 'Ask a follow-up…';

  @override
  String get assistantSend => 'Send';

  @override
  String get assistantAddPhoto => 'Add photo';

  @override
  String assistantQuota(int remaining, int limit) {
    return '$remaining of $limit questions left today';
  }

  @override
  String assistantQuotaCost(int remaining) {
    return 'Uses 1 of your $remaining remaining questions';
  }

  @override
  String get assistantProblems => 'What\'s worrying you?';

  @override
  String lawnProblem(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'yellowPatches': 'Yellow patches',
      'dryGrass': 'Dry grass',
      'moss': 'Moss',
      'weeds': 'Weeds',
      'bareSpots': 'Bare spots',
      'fungus': 'Fungus, mould',
      'molehills': 'Molehills',
      'other': 'Grubs',
    });
    return '$_temp0';
  }

  @override
  String get assistantQuick => 'Quick answers';

  @override
  String get assistantOffline => 'offline';

  @override
  String get assistantOfflineAnswer => 'Offline answer, no limit';

  @override
  String get quickWeek => 'What should I do this week?';

  @override
  String get quickScarify => 'When can I scarify?';

  @override
  String get quickWinter => 'How do I prepare the lawn for winter?';

  @override
  String get quickWeekNone => 'No work is planned for the next 7 days.';

  @override
  String get quickWeekIntro => 'Plan for the next 7 days:';

  @override
  String get quickScarifyNow =>
      'Yes, now is a good time. Scarify a dry, freshly mown lawn and reseed bare spots right away.';

  @override
  String get quickScarifyLater =>
      'Not now. Scarifying wounds the turf, so the grass must regrow quickly: spring or late summer is best.';

  @override
  String quickScarifyNext(String date) {
    return 'Next good date: from $date.';
  }

  @override
  String get quickScarifyNowPreview => 'Now is a good time';

  @override
  String quickScarifyLaterPreview(String date) {
    return 'From $date';
  }

  @override
  String get quickWinterText =>
      '1. Last mow to about 5 cm, when the grass stops growing.\n2. By the end of October apply a potassium-rich autumn fertilizer.\n3. Rake the leaves: don\'t leave them over winter.\n4. Don\'t walk on frozen grass.';

  @override
  String get quickWinterPreview => '4 steps before winter';

  @override
  String get diagnoseSubtitle => 'Diagnosis from a photo';

  @override
  String get diagnosePhotos => 'Photos';

  @override
  String get diagnosePhotosHint => 'Two are best: the whole patch and a close-up.';

  @override
  String get diagnoseDescribe => 'Describe what you see';

  @override
  String get diagnoseDescribeHint => 'e.g. irregular patches, grass pulls up easily';

  @override
  String get diagnoseSince => 'Since when?';

  @override
  String diagnoseSinceOption(String since) {
    String _temp0 = intl.Intl.selectLogic(since, {
      'days': 'A few days',
      'weeks': '1–2 weeks',
      'month': 'Over a month',
      'other': 'I don\'t know',
    });
    return '$_temp0';
  }

  @override
  String get diagnoseContextTitle => 'The assistant will also get';

  @override
  String diagnoseContext(int area, String mix) {
    return 'Lawn details ($area m², $mix), rainfall for 14 days, the forecast and recent journal entries.';
  }

  @override
  String get diagnoseButton => 'Diagnose';

  @override
  String get diagnoseWorking => 'Analysing…';

  @override
  String get resultTitle => 'Diagnosis result';

  @override
  String get resultMost => 'Most likely';

  @override
  String resultUrgency(String urgency) {
    String _temp0 = intl.Intl.selectLogic(urgency, {
      'actNow': 'act now',
      'soon': 'in the coming weeks',
      'other': 'not urgent',
    });
    return '$_temp0';
  }

  @override
  String resultLikelihood(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'high': 'high',
      'medium': 'medium',
      'other': 'low',
    });
    return '$_temp0';
  }

  @override
  String get resultCheck => 'How to check';

  @override
  String get resultActions => 'Suggested jobs';

  @override
  String get assistantToCalendar => 'To calendar';

  @override
  String get assistantAddedToCalendar => 'Added to calendar.';

  @override
  String get assistantSaveJournal => 'Save to journal';

  @override
  String get assistantSavedJournal => 'Saved to journal.';

  @override
  String get assistantReport => 'Report answer';

  @override
  String get assistantAiNote =>
      'AI answers can be wrong. For plant protection products follow the product label.';

  @override
  String get reportTitle => 'What\'s wrong with this answer?';

  @override
  String reportReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'wrong': 'Wrong',
      'offensive': 'Offensive',
      'dangerous': 'Dangerous',
      'other': 'Other reason',
    });
    return '$_temp0';
  }

  @override
  String get reportNote => 'Comment';

  @override
  String get reportSend => 'Send report';

  @override
  String get reportSent => 'Thank you, we\'ll check this answer.';

  @override
  String assistantError(String error) {
    String _temp0 = intl.Intl.selectLogic(error, {
      'quotaExceeded': 'You\'ve used today\'s questions. The limit resets tomorrow.',
      'offline': 'No internet connection.',
      'busy': 'The assistant is busy. Try again in a moment.',
      'badImage': 'Could not send the photo. Try another one.',
      'other': 'Could not get an answer. Try again.',
    });
    return '$_temp0';
  }

  @override
  String get assistantUnavailable =>
      'The AI assistant is not available in this version of the app. Quick answers work offline.';

  @override
  String get assistantPrivacyTitle => 'Before you ask';

  @override
  String get assistantPrivacy =>
      'Questions, selected photos and lawn details are sent through our server to Google Gemini. Under the free terms Google may use them to improve its services. Don\'t include photos of people.';

  @override
  String get assistantPrivacyAccept => 'I understand';

  @override
  String get navToday => 'Today';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navJournal => 'Journal';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navLawn => 'Lawn';

  @override
  String guideTopicTitle(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification': 'Scarification',
      'aeration': 'Aeration',
      'raking': 'Raking',
      'overseeding': 'Overseeding',
      'sanding': 'Sanding',
      'liming': 'Liming',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicSummary(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification': 'Removes thatch and moss, lets the turf breathe',
      'aeration': 'Loosens compacted soil so water and fertilizer reach the roots',
      'raking': 'Gently removes dead grass, leaves and thin thatch',
      'overseeding': 'Thickens the lawn and fills bare spots',
      'sanding': 'Loosens heavy soil and levels the surface',
      'liming': 'Reduces soil acidity when pH drops too low',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicWhen(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification': 'April–May, optionally late August–September',
      'aeration': 'April–May or September',
      'raking': 'March–April and in autumn, with leaves',
      'overseeding': 'Late August–September, April–May',
      'sanding': 'Right after aeration, in spring or September',
      'liming': 'October–November, when pH is below 5.5',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicWhenText(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification':
          'When the grass is growing strongly and the soil is at least 10°C. Usually after the 2nd or 3rd spring mow. Not in heat and not on wet soil.',
      'aeration':
          'When the grass is growing and will quickly cover the holes. The soil should be moist but not wet: tines go in easily and don\'t smear it.',
      'raking':
          'In spring, once the lawn dries after winter, and in autumn when leaves fall. It is gentler than scarifying, so you can do it more often.',
      'overseeding':
          'Best from late August to mid-September: the soil is warm and dew keeps it moist. In spring, once the soil is at least 8–10°C.',
      'sanding':
          'Best right after aeration or scarification, while the holes are open. The lawn and sand must be dry.',
      'liming':
          'In autumn, after the last fertilizing, or in early spring. Only when a test shows acidic soil: grass grows best at pH 5.5–7.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicSigns(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification':
          'There is a springy layer of thatch over 1 cm under the blades\nMoss grows between the grass\nThe lawn responds poorly to fertilizer and water',
      'aeration':
          'Water stands on the lawn long after rain\nThe soil is hard, a screwdriver barely goes in\nGrass thins on paths and play areas',
      'raking':
          'After winter the grass is matted and dry\nLeaves and clippings lie on the lawn\nThe thatch is thin, under 1 cm',
      'overseeding':
          'The lawn is thinning and soil shows\nWinter or scarifying left bare patches\nWeeds grow in the gaps',
      'sanding':
          'The soil is heavy clay and compacted\nWater stands long after rain\nThe lawn has small bumps',
      'liming':
          'A pH test showed less than 5.5\nMoss is spreading in the lawn\nThe grass responds poorly to fertilizer',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicSteps(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification':
          'Mow low: To 3–4 cm, a day or two before. The lawn must be dry.\nSet the blades shallow: They should cut 2–3 mm into the soil. Deeper damages the roots.\nGo along, then across: At a steady pace, without stopping in one place.\nRake up the thatch: There can be surprisingly much. The lawn looks worse for 2 weeks, that\'s normal.\nReseed and fertilize: Reseed bare spots right away, then apply spring fertilizer.\nWater: Regularly for 2–3 weeks if it doesn\'t rain.',
      'aeration':
          'Mow the lawn: To the usual height, a day before.\nWater if dry: The day before, so the soil softens.\nPierce the soil: With a hollow-tine aerator to 6–10 cm, about every 10 cm.\nLeave the cores: They dry in 1–2 days, then break them up with a rake.\nFill the holes with sand: Sanding right after aeration works best.\nFertilize and water: Nutrients go straight to the roots.',
      'raking':
          'Wait until the lawn dries: Wet turf is easily pulled out with the roots.\nRake with a fan rake: Firmly but shallow, in two directions.\nCollect the debris: Put leaves and dead grass on the compost.\nReseed gaps: Reseed winter bare spots when the soil is 8–10°C.',
      'overseeding':
          'Prepare the soil: Rake or scarify the lawn and loosen bare spots.\nSow the seed: 15–20 g/m², on bare spots 25–35 g/m². Sow in two directions.\nCover lightly: About 0.5 cm of soil or sand, then roll gently.\nWater daily: Gently, a little at a time, for 2–3 weeks until the grass comes up.\nFirst mow: When the young grass is 8–10 cm, cut it to 5–6 cm.',
      'sanding':
          'Aerate first: The sand should fall into the tine holes.\nSpread the sand: 3–5 l/m², a layer of 3–5 mm. Washed sand, 0–2 mm grain.\nSpread and brush in: With the back of a rake or a brush until the sand disappears into the turf.\nWater: Water rinses the remaining sand off the blades.',
      'liming':
          'Measure pH: With a meter or strips, in several places.\nChoose the dose: Calcium carbonate or dolomite lime, usually 10–20 kg per 100 m². The label gives the exact dose.\nSpread evenly: With a spreader, in calm weather, in two directions.\nWater or wait for rain: The lime has to get into the soil.\nCheck pH after a year: Don\'t lime every season without testing.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicTools(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification': 'Scarifier\nRake\nOverseeding seed\nSpring fertilizer',
      'aeration': 'Hollow-tine aerator\nRake\nWashed sand',
      'raking': 'Fan rake\nPowered lawn rake (optional)\nBags or compost bin',
      'overseeding': 'Seed of the same mix\nRake\nSoil or sand for covering\nRoller (optional)',
      'sanding': 'Washed sand 0–2 mm\nRake or brush\nWheelbarrow and shovel',
      'liming': 'pH meter or test strips\nCalcium carbonate or dolomite lime\nSpreader',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicAvoid(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification':
          'A lawn younger than 2 years from seed or 1 year from sod. Scarifying in heat, drought or on wet soil. More than 1–2 times a year.',
      'aeration':
          'A lawn less than a year old. Aerating dry, hard soil or during drought. Solid tines on heavy soil only compact it. On clay 1–2 times a year is enough, on sand even less.',
      'raking':
          'Raking a wet or frozen lawn. Leaves left over winter: the grass under them rots and gets diseases.',
      'overseeding':
          'Sowing in heat, drought or into cold soil. Walking on fresh seed. Weed killers for 6–8 weeks before and after sowing.',
      'sanding':
          'Builder\'s sand with clay and fine dusty sand. A layer over 5 mm at once: the grass will suffocate. On sandy soil sanding is usually not needed.',
      'liming':
          'Lime together with nitrogen fertilizer: leave 3–4 weeks between them. Quicklime, which burns grass. Liming without a pH test.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideMonthTitle(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Winter: the lawn rests',
      'feb': 'Getting ready for the season',
      'mar': 'Raking and first feed',
      'apr': 'Scarification and aeration',
      'may': 'Overseeding and regular mowing',
      'jun': 'Mowing and watering',
      'jul': 'Heat: mow higher',
      'aug': 'Overseeding late in the month',
      'sep': 'Aeration, sanding, overseeding',
      'oct': 'Liming and last mowing',
      'nov': 'Raking leaves',
      'dec': 'Winter: the lawn rests',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideMonthText(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Don\'t walk on frozen grass and plan your spring jobs.',
      'feb': 'Sharpen the mower blades and check your equipment before spring.',
      'mar':
          'Once the lawn dries, rake out thatch and leaves. Apply a starter fertilizer late in the month.',
      'apr': 'Grass starts growing. It\'s the best time for treatments and reseeding bare spots.',
      'may': 'Last chance for spring scarification. Mow every 4–7 days.',
      'jun': 'Water less often but more deeply, preferably in the morning.',
      'jul': 'Raise the mower by 1 cm and don\'t apply nitrogen in heat.',
      'aug': 'When the heat passes, the best time for overseeding begins.',
      'sep': 'Warm soil and dew help the lawn recover quickly after treatments.',
      'oct': 'Autumn is a good time to reduce soil acidity before winter.',
      'nov': 'Don\'t leave leaves over winter. Last mow to about 5 cm.',
      'dec': 'Don\'t walk on frozen grass and don\'t pile salty snow on it.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get guideTitle => 'Guide';

  @override
  String get guideCare => 'Treatments';

  @override
  String get guideCareSub => 'Scarification, aeration, overseeding and more';

  @override
  String get guideCarePageSub => 'When and how to do them';

  @override
  String get guideFertilizing => 'Fertilizing';

  @override
  String get guideFertilizingSub => 'Fertilizer types and NPK';

  @override
  String get guideFertilizingPageSub => 'Which fertilizers, when and what composition';

  @override
  String get guideMowing => 'Mowing';

  @override
  String get guideMowingSub => 'Height, rhythm and the 1/3 rule';

  @override
  String get guideMowingPageSub => 'Height, rhythm and good habits';

  @override
  String get guideMixes => 'Grass mixes';

  @override
  String get guideMixesSub => 'Choosing a mix and mowing height';

  @override
  String get guideMixesPageSub => 'How to choose and how high to mow';

  @override
  String get guideNowGood => 'Good time now';

  @override
  String get guideLater => 'Later this season';

  @override
  String get guideNextSeason => 'Next season';

  @override
  String get guideNowBadge => 'Now';

  @override
  String get guideOrderTip =>
      'Spring order: scarification, aeration, sanding, overseeding, fertilizing. Each step prepares the lawn for the next.';

  @override
  String get guideWhen => 'When';

  @override
  String get guideBest => 'best';

  @override
  String get guidePossible => 'possible';

  @override
  String get guideNowLegend => 'now';

  @override
  String get guideSignsTitle => 'Does your lawn need it?';

  @override
  String get guideStepsTitle => 'How to do it';

  @override
  String get guideToolsTitle => 'What you need';

  @override
  String get guideAvoidTitle => 'What to avoid';

  @override
  String get guidePlanNow => 'Plan this job';

  @override
  String get guideAsk => 'Ask the assistant';

  @override
  String get guideYoursMix => 'Yours';

  @override
  String get guideNpkTitle => 'What N-P-K means';

  @override
  String get guideNpkIntro =>
      'The numbers on the bag are percentages of nutrients. 20-5-8 means 20% nitrogen, 5% phosphorus and 8% potassium.';

  @override
  String get guideNitrogen => 'Nitrogen';

  @override
  String get guideNitrogenText => 'Growth and green colour';

  @override
  String get guidePhosphorus => 'Phosphorus';

  @override
  String get guidePhosphorusText => 'Roots, important when starting a lawn';

  @override
  String get guidePotassium => 'Potassium';

  @override
  String get guidePotassiumText => 'Resistance to frost, drought and disease';

  @override
  String get guideMicro =>
      'Magnesium (Mg) deepens the colour, and iron (Fe) gives an intense green and limits moss.';

  @override
  String get guideFertSeasonsTitle => 'Fertilizer for each season';

  @override
  String get guideColSeason => 'Season';

  @override
  String get guideColNpk => 'N-P-K';

  @override
  String get guideColWhy => 'Why';

  @override
  String get guideFertSeason1 => 'March–April';

  @override
  String get guideFertSeason1Why => 'Start of growth after winter';

  @override
  String get guideFertSeason2 => 'May–June';

  @override
  String get guideFertSeason2Why => 'Dense, even turf';

  @override
  String get guideFertSeason3 => 'July–August';

  @override
  String get guideFertSeason3Why => 'Less nitrogen, heat resistance';

  @override
  String get guideFertSeason4 => 'September–October';

  @override
  String get guideFertSeason4Why => 'Roots and overwintering, lots of potassium';

  @override
  String get guideFertTypesTitle => 'Fertilizer types';

  @override
  String get guideColType => 'Type';

  @override
  String get guideColWorks => 'Lasts';

  @override
  String get guideColEvery => 'How often';

  @override
  String get guideFertSlow => 'Slow-release granules';

  @override
  String get guideFertFast => 'Fast granules';

  @override
  String get guideFertLiquid => 'Liquid';

  @override
  String get guideFertOrganic => 'Organic';

  @override
  String get guideFertSlowWorks => '2–3 months';

  @override
  String get guideFertSlowEvery => '8–12 weeks';

  @override
  String get guideFertFastWorks => '4–6 weeks';

  @override
  String get guideFertFastEvery => '4–6 weeks';

  @override
  String get guideFertLiquidWorks => '1–2 weeks';

  @override
  String get guideFertLiquidEvery => '2–3 weeks';

  @override
  String get guideFertOrganicWorks => '2–3 months';

  @override
  String get guideFertOrganicEvery => '2–3 times a season';

  @override
  String get guideFertHowTitle => 'How to fertilize';

  @override
  String get guideFertHow =>
      'On dry grass, ideally before light rain. Otherwise water it.\nWith a spreader, in two crosswise passes at half the dose.\nNot in heat above 25°C and not before heavy rain.\nNo nitrogen from October, only autumn fertilizer.';

  @override
  String get guideFertNote =>
      'The N-P-K ratios in the table are examples. Always take the dose per m² from the fertilizer label.';

  @override
  String get guideMowRuleLabel => 'The 1/3 rule';

  @override
  String get guideMowRuleTitle => 'Cut off no more than one third of the height';

  @override
  String get guideMowRhythmTitle => 'Rhythm through the season';

  @override
  String get guideColHeight => 'Height';

  @override
  String get guideMowSeason1 => 'April';

  @override
  String get guideMowSeason1Every => 'When it is about 8 cm';

  @override
  String get guideMowSeason1Height => 'First cut only 1–2 cm';

  @override
  String get guideMowSeason2 => 'May–June';

  @override
  String get guideMowSeason2Every => 'Every 4–7 days';

  @override
  String get guideMowSeason2Height => 'Target';

  @override
  String get guideMowSeason3 => 'July–August';

  @override
  String get guideMowSeason3Every => 'Every 7–10 days';

  @override
  String get guideMowSeason3Height => '1 cm higher in heat';

  @override
  String get guideMowSeason4 => 'September–November';

  @override
  String get guideMowSeason4Every => 'Every 7–14 days until growth stops';

  @override
  String get guideMowSeason4Height => 'Last cut to about 5 cm';

  @override
  String get guideMowHabitsTitle => 'Good habits';

  @override
  String get guideMowHabits =>
      'Sharp blades. Blunt ones tear the grass and the tips turn brown.\nOnly dry grass, no morning dew and not in the hottest hours.\nChange mowing direction so the grass doesn\'t lean one way.\nMulching returns nitrogen to the lawn, but only if you mow dry grass regularly.';

  @override
  String get guideMowToday => 'When to mow today?';

  @override
  String get guideMowTodaySub => 'Good hours have a green frame in the day forecast';

  @override
  String get guideMixHowTitle => 'How to choose';

  @override
  String get guideMixListTitle => 'Mixes and mowing height';

  @override
  String get guideMixWhenUniversal => 'Sun, children, a dog';

  @override
  String get guideMixWhenOrnamental => 'Showcase lawn, little foot traffic';

  @override
  String get guideMixWhenShade => 'Under trees, 3–4 h of sun';

  @override
  String get guideMixWhenDrought => 'Sand, infrequent watering';

  @override
  String guideMixShort(String mix) {
    String _temp0 = intl.Intl.selectLogic(mix, {
      'universal': 'Universal',
      'ornamental': 'Ornamental',
      'shade': 'Shade',
      'drought': 'Drought',
      'sport': 'Sports',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideMixText(String mix) {
    String _temp0 = intl.Intl.selectLogic(mix, {
      'universal': 'Hard-wearing, for families and pets',
      'ornamental': 'Dense and low, mow even every 3–5 days',
      'shade': 'Mown higher to catch more light',
      'drought': 'Deep roots, tall grass protects the soil',
      'sport': 'Recovers fastest after heavy use',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideMixSpecies(String mix) {
    String _temp0 = intl.Intl.selectLogic(mix, {
      'universal': 'Perennial ryegrass, red fescue, Kentucky bluegrass',
      'ornamental': 'Red fescue, common bent, Kentucky bluegrass',
      'shade': 'Red fescue, wood meadow grass, tufted hair grass',
      'drought': 'Tall fescue, sheep\'s fescue, red fescue',
      'sport': 'Perennial ryegrass, Kentucky bluegrass',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get guideSeedsTitle => 'How much seed?';

  @override
  String get guideSeedsText =>
      'New lawn 25–35 g/m², overseeding 15–20 g/m². For overseeding choose the same mix as the lawn.';

  @override
  String get guideCm => 'cm';

  @override
  String guideNowInSeason(String month) {
    return 'In season now · $month';
  }

  @override
  String guidePlanOn(String month) {
    return 'Plan for $month';
  }

  @override
  String guideAskQuestion(String topic) {
    return 'Does my lawn need this treatment now: $topic? When is the best time to do it?';
  }

  @override
  String guideMowRuleText(String height, String max) {
    return 'Keep it at $height cm and mow when the grass is about $max cm.';
  }

  @override
  String get quickScarifyYoung =>
      'Not yet. Your lawn is too young: scarify no earlier than 2 years after seeding or a year after laying sod.';

  @override
  String guideTooYoung(String date) {
    return 'Your lawn is still too young for this treatment. It will be safe from: $date.';
  }

  @override
  String get guideTooYoungTitle => 'Lawn too young';

  @override
  String addTooYoung(String kind, String date) {
    return 'The lawn is too young for “$kind”. The turf must root well first: it will be safe from $date.';
  }

  @override
  String addMoveToReady(String date) {
    return 'Move to $date';
  }

  @override
  String get noticeFrostTitle => 'Frost warning';

  @override
  String noticeFrostBody(String day, int temp) {
    return '$day down to $temp°C. Hold off fertilizing and turn off automatic watering.';
  }

  @override
  String get noticeHeatTitle => 'Heat';

  @override
  String noticeHeatBody(String day, int temp) {
    return '$day up to $temp°C. Water in the morning and don\'t mow.';
  }

  @override
  String get noticeDownpourTitle => 'Heavy rain';

  @override
  String noticeDownpourBody(String day, String mm) {
    return '$day about $mm mm of rain. Don\'t fertilize before it.';
  }

  @override
  String noticeMovedTitle(String day) {
    return 'Fertilizing moved to $day';
  }

  @override
  String get noticeMovedBody => 'We picked a better day in the fertilizing window.';

  @override
  String noticeStaleTitle(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return 'Forecast from $_temp0 ago';
  }

  @override
  String get noticeStaleBody => 'Advice may be less accurate. We\'ll refresh when you\'re online.';

  @override
  String get noticeToday => 'Today';

  @override
  String get noticeTomorrow => 'Tomorrow';

  @override
  String get notifFertilizeIdealTitle => 'Ideal day for fertilizing';

  @override
  String get notifFertilizeTitle => 'Fertilizing today';

  @override
  String notifFertilizeBody(int cycleDay, int interval) {
    return 'Day $cycleDay of $interval. Check the forecast before spreading fertilizer.';
  }

  @override
  String get notifFertilizeFallbackBody => 'Open the plan to see the details.';

  @override
  String get notifProgramTitle => 'Fertilizing program step today';

  @override
  String notifProgramRain(int mm) {
    return 'Rain forecast: $mm mm. Consider moving the date so the fertilizer doesn\'t wash out.';
  }

  @override
  String get notifMowingTitle => 'Time to mow';

  @override
  String get notifMowingBody => 'The grass is ready for mowing. Check the cutting height.';

  @override
  String get notifWateringTitle => 'Watering';

  @override
  String get notifWateringBody => 'No rain today, the lawn needs water.';

  @override
  String get notifTaskTitle => 'Planned job';

  @override
  String get notifTaskBody => 'You have a job in the calendar today.';

  @override
  String get notifSettingsTitle => 'Notifications';

  @override
  String get notifSettingsIntro =>
      'At most one a day. The exception is a weather warning the day before. Quiet hours from 21:00 to 7:00.';

  @override
  String get notifSettingsEnable => 'Turn on notifications';

  @override
  String get notifSettingsDenied => 'Allow notifications in your phone settings.';

  @override
  String get notifSettingsHour => 'Morning time';

  @override
  String notifSettingsHourValue(int hour) {
    return '$hour:00';
  }

  @override
  String get notifSettingsFertilizing => 'Fertilizing';

  @override
  String get notifSettingsWatering => 'Watering';

  @override
  String get notifSettingsCare => 'Mowing and treatments';

  @override
  String get notifSettingsWarnings => 'Weather warnings';

  @override
  String get notifSettingsOff => 'Off';

  @override
  String notifSettingsOn(int hour) {
    return 'On from $hour:00';
  }

  @override
  String get notifPlanChangedTitle => 'Plan changed';

  @override
  String notifPlanChangedBody(String date) {
    return 'Fertilizing moved to $date.';
  }

  @override
  String get homeOffSeasonTitle => 'The lawn is resting';

  @override
  String homeDoneNextWindow(String range) {
    return 'Saved to journal. Next window: $range.';
  }

  @override
  String get notifSeasonTitle => 'The season is starting';

  @override
  String get notifSeasonBody => 'The work plan for the new season is ready.';

  @override
  String get programsTitle => 'Fertilizing programs';

  @override
  String get programsOff => 'Off';

  @override
  String get programsIntro =>
      'Ready-made schedules from fertilizer makers. When turned on, treatments go to the calendar with the product and dose for your area. They replace the standard fertilizing plan.';

  @override
  String get programsActive => 'Active';

  @override
  String get programsEnable => 'Turn on program';

  @override
  String get programsDisable => 'Turn off program';

  @override
  String get programsEnabled => 'Program turned on. The treatments are in the calendar.';

  @override
  String get programsDisabled => 'Program turned off. The standard fertilizing plan is back.';

  @override
  String programsSource(String brand, String site) {
    return 'Source: $brand ($site). Programs and doses are examples, always check the product label.';
  }

  @override
  String programsWindow(String from, String to) {
    return '$from–$to';
  }

  @override
  String programsDose(String dose) {
    return '$dose g/m²';
  }

  @override
  String get programsFixedNote =>
      'Program dates are fixed. The weather doesn\'t move them, it only warns you.';

  @override
  String get programsCustomTitle => 'Your plans';

  @override
  String get programsCreate => 'Create your own plan';

  @override
  String get programsEdit => 'Edit';

  @override
  String get programsDelete => 'Delete';

  @override
  String get programsDeleted => 'Plan deleted.';

  @override
  String customSummary(String product, int dose, String days) {
    return '$product, $dose g/m², every $days';
  }

  @override
  String get customFormTitle => 'Your own fertilizing plan';

  @override
  String get customName => 'Plan name';

  @override
  String get customProduct => 'Fertilizer name';

  @override
  String get customDose => 'Dose (g/m²)';

  @override
  String get customInterval => 'Every how many days';

  @override
  String get customStart => 'First fertilizing';

  @override
  String get customSave => 'Save plan';

  @override
  String get customInvalid => 'Enter the fertilizer name, dose and interval in days.';

  @override
  String programsControlsDates(String name) {
    return 'Fertilizing dates are set by the program: $name. The interval between treatments is not used now.';
  }

  @override
  String get backupTitle => 'Your data';

  @override
  String get backupExport => 'Export data';

  @override
  String get backupExportSub =>
      'A file with your lawns, journal and photos. It also contains your lawn location.';

  @override
  String get backupImport => 'Import data';

  @override
  String get backupImportSub => 'Restore data from a previously saved file.';

  @override
  String get backupRestoreFromFile => 'Restore data from a file';

  @override
  String get backupImportTitle => 'Restore data?';

  @override
  String get backupReplaceWarning =>
      'The lawns, plans, journal and photos currently on this phone will be replaced. This cannot be undone.';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupExported => 'Backup saved.';

  @override
  String get backupImported => 'Your data has been restored.';

  @override
  String get backupExportFailed => 'Could not save the backup.';

  @override
  String get backupImportFailed => 'Could not restore the data.';

  @override
  String get backupInvalidFile => 'This is not a valid Lawnly backup, or the file is damaged.';

  @override
  String get backupNewerVersion =>
      'This backup comes from a newer version of Lawnly. Update the app.';

  @override
  String get backupNothingToExport => 'There is no data to save yet.';

  @override
  String backupSummary(String date, int lawns, int photos) {
    return 'Backup from $date. Lawns: $lawns, photos: $photos.';
  }

  @override
  String get backupCancel => 'Cancel';
}
