import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
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
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('pl')];

  /// No description provided for @appTagline.
  ///
  /// In pl, this message translates to:
  /// **'Właściwy zabieg we właściwym dniu'**
  String get appTagline;

  /// No description provided for @splashChecking.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdzam prognozę pogody…'**
  String get splashChecking;

  /// No description provided for @commonNext.
  ///
  /// In pl, this message translates to:
  /// **'Dalej'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In pl, this message translates to:
  /// **'Wstecz'**
  String get commonBack;

  /// No description provided for @commonDontKnow.
  ///
  /// In pl, this message translates to:
  /// **'Nie wiem'**
  String get commonDontKnow;

  /// No description provided for @commonOptional.
  ///
  /// In pl, this message translates to:
  /// **'(opcjonalnie)'**
  String get commonOptional;

  /// No description provided for @commonLess.
  ///
  /// In pl, this message translates to:
  /// **'Mniej dni'**
  String get commonLess;

  /// No description provided for @commonMore.
  ///
  /// In pl, this message translates to:
  /// **'Więcej dni'**
  String get commonMore;

  /// No description provided for @commonRetry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get commonRetry;

  /// No description provided for @routeNotFoundTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie ma takiej strony'**
  String get routeNotFoundTitle;

  /// No description provided for @routeNotFoundAction.
  ///
  /// In pl, this message translates to:
  /// **'Wróć na start'**
  String get routeNotFoundAction;

  /// No description provided for @commonMinutes.
  ///
  /// In pl, this message translates to:
  /// **'min'**
  String get commonMinutes;

  /// No description provided for @commonSquareMeters.
  ///
  /// In pl, this message translates to:
  /// **'m²'**
  String get commonSquareMeters;

  /// No description provided for @daysCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =1{1 dzień} other{{count} dni}}'**
  String daysCount(int count);

  /// No description provided for @weekdayShort.
  ///
  /// In pl, this message translates to:
  /// **'{day, select, mon{Pn} tue{Wt} wed{Śr} thu{Cz} fri{Pt} sat{Sb} sun{Nd} other{}}'**
  String weekdayShort(String day);

  /// No description provided for @onboardingStep.
  ///
  /// In pl, this message translates to:
  /// **'Krok {step} z {total}'**
  String onboardingStep(int step, int total);

  /// No description provided for @onboardingFinish.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz mój plan'**
  String get onboardingFinish;

  /// No description provided for @onboardingSkipRest.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz plan teraz, resztę uzupełnię później'**
  String get onboardingSkipRest;

  /// No description provided for @onboardingSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać. Spróbuj ponownie.'**
  String get onboardingSaveError;

  /// No description provided for @locationTitle.
  ///
  /// In pl, this message translates to:
  /// **'Poznajmy Twój trawnik'**
  String get locationTitle;

  /// No description provided for @locationBody.
  ///
  /// In pl, this message translates to:
  /// **'Bez zakładania konta. Wszystkie dane zostają w aplikacji, a lokalizacja służy tylko do pobierania prognozy pogody.'**
  String get locationBody;

  /// No description provided for @locationNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa trawnika'**
  String get locationNameLabel;

  /// No description provided for @locationNameHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Przed domem'**
  String get locationNameHint;

  /// No description provided for @locationLabel.
  ///
  /// In pl, this message translates to:
  /// **'Lokalizacja'**
  String get locationLabel;

  /// No description provided for @locationUseMine.
  ///
  /// In pl, this message translates to:
  /// **'Użyj mojej lokalizacji'**
  String get locationUseMine;

  /// No description provided for @locationOr.
  ///
  /// In pl, this message translates to:
  /// **'lub'**
  String get locationOr;

  /// No description provided for @locationCityHint.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz miejscowość'**
  String get locationCityHint;

  /// No description provided for @locationCurrent.
  ///
  /// In pl, this message translates to:
  /// **'Bieżąca lokalizacja'**
  String get locationCurrent;

  /// No description provided for @locationTip.
  ///
  /// In pl, this message translates to:
  /// **'Dokładna lokalizacja trawnika poprawia trafność rad, bo deszcz w mieście nie zawsze pada nad Twoim ogrodem.'**
  String get locationTip;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In pl, this message translates to:
  /// **'Włącz usługi lokalizacji w telefonie albo wpisz miejscowość.'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In pl, this message translates to:
  /// **'Bez zgody na lokalizację wpisz miejscowość ręcznie.'**
  String get locationPermissionDenied;

  /// No description provided for @locationNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie znalazłem takiej miejscowości.'**
  String get locationNotFound;

  /// No description provided for @locationNetwork.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z internetem. Spróbuj ponownie.'**
  String get locationNetwork;

  /// No description provided for @basicsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podstawowe dane'**
  String get basicsTitle;

  /// No description provided for @basicsBody.
  ///
  /// In pl, this message translates to:
  /// **'Wiek trawnika decyduje, kiedy można robić wertykulację czy aerację.'**
  String get basicsBody;

  /// No description provided for @basicsAreaLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powierzchnia'**
  String get basicsAreaLabel;

  /// No description provided for @basicsAreaHelper.
  ///
  /// In pl, this message translates to:
  /// **'Potrzebne do wyliczenia dawki nawozu i nasion.'**
  String get basicsAreaHelper;

  /// No description provided for @basicsEstablishedLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data założenia trawnika'**
  String get basicsEstablishedLabel;

  /// No description provided for @basicsEstablishedHint.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz miesiąc i rok'**
  String get basicsEstablishedHint;

  /// No description provided for @basicsEstablishedHelper.
  ///
  /// In pl, this message translates to:
  /// **'Wystarczy miesiąc i rok.'**
  String get basicsEstablishedHelper;

  /// No description provided for @basicsLawnAge.
  ///
  /// In pl, this message translates to:
  /// **'Wystarczy miesiąc i rok. Wiek trawnika: {seasons, plural, =0{pierwszy sezon} =1{ok. 1 sezon} few{ok. {seasons} sezony} other{ok. {seasons} sezonów}}.'**
  String basicsLawnAge(int seasons);

  /// No description provided for @basicsMethodLabel.
  ///
  /// In pl, this message translates to:
  /// **'Sposób założenia'**
  String get basicsMethodLabel;

  /// No description provided for @basicsMethodSeeded.
  ///
  /// In pl, this message translates to:
  /// **'Z siewu'**
  String get basicsMethodSeeded;

  /// No description provided for @basicsMethodSod.
  ///
  /// In pl, this message translates to:
  /// **'Z rolki'**
  String get basicsMethodSod;

  /// No description provided for @basicsSunLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nasłonecznienie'**
  String get basicsSunLabel;

  /// No description provided for @basicsSunFull.
  ///
  /// In pl, this message translates to:
  /// **'Słońce'**
  String get basicsSunFull;

  /// No description provided for @basicsSunPartial.
  ///
  /// In pl, this message translates to:
  /// **'Półcień'**
  String get basicsSunPartial;

  /// No description provided for @basicsSunShade.
  ///
  /// In pl, this message translates to:
  /// **'Cień'**
  String get basicsSunShade;

  /// No description provided for @soilTitle.
  ///
  /// In pl, this message translates to:
  /// **'Mieszanka i gleba'**
  String get soilTitle;

  /// No description provided for @soilBody.
  ///
  /// In pl, this message translates to:
  /// **'Nie wiesz? Wybierz „nie wiem”, uzupełnisz później.'**
  String get soilBody;

  /// No description provided for @soilMixLabel.
  ///
  /// In pl, this message translates to:
  /// **'Mieszanka traw'**
  String get soilMixLabel;

  /// No description provided for @soilMixUniversal.
  ///
  /// In pl, this message translates to:
  /// **'Uniwersalna / rekreacyjna'**
  String get soilMixUniversal;

  /// No description provided for @soilMixUniversalHint.
  ///
  /// In pl, this message translates to:
  /// **'Odporna na deptanie, dla rodzin i zwierząt'**
  String get soilMixUniversalHint;

  /// No description provided for @soilMixOrnamental.
  ///
  /// In pl, this message translates to:
  /// **'Ozdobna / parterowa'**
  String get soilMixOrnamental;

  /// No description provided for @soilMixOrnamentalHint.
  ///
  /// In pl, this message translates to:
  /// **'Gęsta, niskie koszenie, wymagająca'**
  String get soilMixOrnamentalHint;

  /// No description provided for @soilMixShade.
  ///
  /// In pl, this message translates to:
  /// **'Do cienia'**
  String get soilMixShade;

  /// No description provided for @soilMixDrought.
  ///
  /// In pl, this message translates to:
  /// **'Na suszę'**
  String get soilMixDrought;

  /// No description provided for @soilMixSport.
  ///
  /// In pl, this message translates to:
  /// **'Sportowa'**
  String get soilMixSport;

  /// No description provided for @soilTypeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj gleby'**
  String get soilTypeLabel;

  /// No description provided for @soilTypeSandy.
  ///
  /// In pl, this message translates to:
  /// **'Piaszczysta'**
  String get soilTypeSandy;

  /// No description provided for @soilTypeMedium.
  ///
  /// In pl, this message translates to:
  /// **'Średnia'**
  String get soilTypeMedium;

  /// No description provided for @soilTypeClay.
  ///
  /// In pl, this message translates to:
  /// **'Gliniasta'**
  String get soilTypeClay;

  /// No description provided for @soilPhLabel.
  ///
  /// In pl, this message translates to:
  /// **'pH gleby'**
  String get soilPhLabel;

  /// No description provided for @soilPhHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 6,2 z testu paskowego'**
  String get soilPhHint;

  /// No description provided for @soilPhError.
  ///
  /// In pl, this message translates to:
  /// **'Podaj wartość od 3 do 9.'**
  String get soilPhError;

  /// No description provided for @careTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podlewanie i koszenie'**
  String get careTitle;

  /// No description provided for @careWateringLabel.
  ///
  /// In pl, this message translates to:
  /// **'Jak podlewasz?'**
  String get careWateringLabel;

  /// No description provided for @careWateringAuto.
  ///
  /// In pl, this message translates to:
  /// **'Automatycznie'**
  String get careWateringAuto;

  /// No description provided for @careWateringManual.
  ///
  /// In pl, this message translates to:
  /// **'Ręcznie'**
  String get careWateringManual;

  /// No description provided for @careSectionTime.
  ///
  /// In pl, this message translates to:
  /// **'Czas pracy jednej sekcji'**
  String get careSectionTime;

  /// No description provided for @careSectionHelper.
  ///
  /// In pl, this message translates to:
  /// **'Ile to milimetrów wody, zmierzymy później prostym testem z kubeczkiem.'**
  String get careSectionHelper;

  /// No description provided for @careManualHelper.
  ///
  /// In pl, this message translates to:
  /// **'Podpowiemy, kiedy podlać i ile wody dać.'**
  String get careManualHelper;

  /// No description provided for @careMowingLabel.
  ///
  /// In pl, this message translates to:
  /// **'Koszenie co'**
  String get careMowingLabel;

  /// No description provided for @careLastMowedLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie koszenie'**
  String get careLastMowedLabel;

  /// No description provided for @careGardenDaysLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kiedy masz czas na ogród?'**
  String get careGardenDaysLabel;

  /// No description provided for @careGardenDaysHelper.
  ///
  /// In pl, this message translates to:
  /// **'Zabiegi zaplanujemy na najlepszy z tych dni.'**
  String get careGardenDaysHelper;

  /// No description provided for @feedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nawożenie'**
  String get feedTitle;

  /// No description provided for @feedBody.
  ///
  /// In pl, this message translates to:
  /// **'Podaj, jak nawozisz. Dzień wybierzemy sami, gdy pogoda będzie sprzyjać.'**
  String get feedBody;

  /// No description provided for @feedIntervalLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nawożę co'**
  String get feedIntervalLabel;

  /// No description provided for @feedWindowLabel.
  ///
  /// In pl, this message translates to:
  /// **'Elastyczne okno'**
  String get feedWindowLabel;

  /// No description provided for @feedWindowRange.
  ///
  /// In pl, this message translates to:
  /// **'{start}–{end} dzień'**
  String feedWindowRange(int start, int end);

  /// No description provided for @feedWindowHelper.
  ///
  /// In pl, this message translates to:
  /// **'Jeśli warunki będą idealne, powiadomimy Cię wcześniej lub później niż {interval}. dnia.'**
  String feedWindowHelper(int interval);

  /// No description provided for @feedLastLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie nawożenie'**
  String get feedLastLabel;

  /// No description provided for @feedLastHint.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę'**
  String get feedLastHint;

  /// No description provided for @feedLastUnknown.
  ///
  /// In pl, this message translates to:
  /// **'Nie pamiętam'**
  String get feedLastUnknown;

  /// No description provided for @homeBadgeIdeal.
  ///
  /// In pl, this message translates to:
  /// **'Idealny dzień'**
  String get homeBadgeIdeal;

  /// No description provided for @homeCycleDay.
  ///
  /// In pl, this message translates to:
  /// **'dzień {day} z {interval}'**
  String homeCycleDay(int day, int interval);

  /// No description provided for @homeRainFrom.
  ///
  /// In pl, this message translates to:
  /// **'Od {hour}:00 lekki deszcz, ok. {mm} mm, wmyje nawóz'**
  String homeRainFrom(int hour, String mm);

  /// No description provided for @homeRain.
  ///
  /// In pl, this message translates to:
  /// **'Lekki deszcz, ok. {mm} mm, wmyje nawóz'**
  String homeRain(String mm);

  /// No description provided for @homeNoRain.
  ///
  /// In pl, this message translates to:
  /// **'Bez deszczu: podlej trawnik po nawożeniu'**
  String get homeNoRain;

  /// No description provided for @homeSeason.
  ///
  /// In pl, this message translates to:
  /// **'{season, select, spring{Wiosną: nawóz z przewagą azotu.} summer{Latem: mniejsze dawki, nie nawoź w upał.} autumn{Jesienią: nawóz z przewagą potasu.} other{Zimą trawnik odpoczywa, nawożenie wstrzymane.}}'**
  String homeSeason(String season);

  /// No description provided for @homeDone.
  ///
  /// In pl, this message translates to:
  /// **'Zrobione'**
  String get homeDone;

  /// No description provided for @homeDoneSnack.
  ///
  /// In pl, this message translates to:
  /// **'Zapisane. Następne nawożenie za ok. {interval} dni.'**
  String homeDoneSnack(int interval);

  /// No description provided for @homePostponedSnack.
  ///
  /// In pl, this message translates to:
  /// **'Szukam innego dnia w oknie nawożenia.'**
  String get homePostponedSnack;

  /// No description provided for @homeTodayWork.
  ///
  /// In pl, this message translates to:
  /// **'Dziś do zrobienia'**
  String get homeTodayWork;

  /// No description provided for @homeNothingToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś nie ma prac w ogrodzie.'**
  String get homeNothingToday;

  /// No description provided for @homeSeasonOver.
  ///
  /// In pl, this message translates to:
  /// **'Sezon na trawniku zakończony. Trawa odpoczywa, plan prac wróci {date}.'**
  String homeSeasonOver(String date);

  /// No description provided for @homeBadgeToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś'**
  String get homeBadgeToday;

  /// No description provided for @homeBadgeNext.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższe prace'**
  String get homeBadgeNext;

  /// No description provided for @homePostponeFertilizing.
  ///
  /// In pl, this message translates to:
  /// **'Przesuń nawożenie'**
  String get homePostponeFertilizing;

  /// No description provided for @homeDoneGeneric.
  ///
  /// In pl, this message translates to:
  /// **'Zapisane jako zrobione.'**
  String get homeDoneGeneric;

  /// No description provided for @homeMarkDone.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako zrobione'**
  String get homeMarkDone;

  /// No description provided for @homeNextDays.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższe dni'**
  String get homeNextDays;

  /// No description provided for @homeCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get homeCalendar;

  /// No description provided for @homeRainMm.
  ///
  /// In pl, this message translates to:
  /// **'{mm} mm'**
  String homeRainMm(String mm);

  /// No description provided for @homeTemperatureShort.
  ///
  /// In pl, this message translates to:
  /// **'{temp}°'**
  String homeTemperatureShort(int temp);

  /// No description provided for @homeWateringNotNeeded.
  ///
  /// In pl, this message translates to:
  /// **'Podlewanie: niepotrzebne'**
  String get homeWateringNotNeeded;

  /// No description provided for @homeWateringNeeded.
  ///
  /// In pl, this message translates to:
  /// **'Podlewanie: potrzebne'**
  String get homeWateringNeeded;

  /// No description provided for @homeWateringRain.
  ///
  /// In pl, this message translates to:
  /// **'Bilans wody w normie, deszcz zrobi swoje'**
  String get homeWateringRain;

  /// No description provided for @homeWateringCool.
  ///
  /// In pl, this message translates to:
  /// **'Chłodno, trawnik zużywa mało wody'**
  String get homeWateringCool;

  /// No description provided for @homeWateringAuto.
  ///
  /// In pl, this message translates to:
  /// **'Zraszacz: {minutes} min na sekcję, wcześnie rano'**
  String homeWateringAuto(int minutes);

  /// No description provided for @homeWateringManual.
  ///
  /// In pl, this message translates to:
  /// **'Podlej wcześnie rano, ok. {litres} l wody na każdy m²'**
  String homeWateringManual(int litres);

  /// No description provided for @homeLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać prognozy pogody.'**
  String get homeLoadError;

  /// No description provided for @homeBadgePinned.
  ///
  /// In pl, this message translates to:
  /// **'Przypięte'**
  String get homeBadgePinned;

  /// No description provided for @careKind.
  ///
  /// In pl, this message translates to:
  /// **'{kind, select, fertilizing{Nawożenie} mowing{Koszenie} watering{Podlewanie} aeration{Aeracja} scarification{Wertykulacja} overseeding{Dosiewanie} liming{Wapnowanie} other{Inny}}'**
  String careKind(String kind);

  /// No description provided for @calendarTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get calendarTitle;

  /// No description provided for @calendarAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zabieg'**
  String get calendarAdd;

  /// No description provided for @calendarPrevMonth.
  ///
  /// In pl, this message translates to:
  /// **'Poprzedni miesiąc'**
  String get calendarPrevMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In pl, this message translates to:
  /// **'Następny miesiąc'**
  String get calendarNextMonth;

  /// No description provided for @calendarLegendOwn.
  ///
  /// In pl, this message translates to:
  /// **'Twój zabieg'**
  String get calendarLegendOwn;

  /// No description provided for @calendarLegendWindow.
  ///
  /// In pl, this message translates to:
  /// **'Okno nawożenia'**
  String get calendarLegendWindow;

  /// No description provided for @calendarLegendTentative.
  ///
  /// In pl, this message translates to:
  /// **'Termin wstępny, bez prognozy'**
  String get calendarLegendTentative;

  /// No description provided for @calendarToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś, {date}'**
  String calendarToday(String date);

  /// No description provided for @calendarEmptyDay.
  ///
  /// In pl, this message translates to:
  /// **'Brak zabiegów tego dnia.'**
  String get calendarEmptyDay;

  /// No description provided for @weatherRainFrom.
  ///
  /// In pl, this message translates to:
  /// **'{temp}°, deszcz od {hour}:00'**
  String weatherRainFrom(int temp, int hour);

  /// No description provided for @weatherRain.
  ///
  /// In pl, this message translates to:
  /// **'{temp}°, {mm} mm deszczu'**
  String weatherRain(int temp, String mm);

  /// No description provided for @weatherDry.
  ///
  /// In pl, this message translates to:
  /// **'{temp}°, sucho'**
  String weatherDry(int temp);

  /// No description provided for @entryDone.
  ///
  /// In pl, this message translates to:
  /// **'Zrobione'**
  String get entryDone;

  /// No description provided for @entryTentative.
  ///
  /// In pl, this message translates to:
  /// **'Termin wstępny · okno {start}–{end}'**
  String entryTentative(String start, String end);

  /// No description provided for @entryPinned.
  ///
  /// In pl, this message translates to:
  /// **'Przypięte'**
  String get entryPinned;

  /// No description provided for @entryEvery.
  ///
  /// In pl, this message translates to:
  /// **'Co {days}'**
  String entryEvery(String days);

  /// No description provided for @entryBeforeRain.
  ///
  /// In pl, this message translates to:
  /// **'Rano, zanim zacznie padać'**
  String get entryBeforeRain;

  /// No description provided for @entryOwn.
  ///
  /// In pl, this message translates to:
  /// **'Twój zabieg'**
  String get entryOwn;

  /// No description provided for @entryMoved.
  ///
  /// In pl, this message translates to:
  /// **'Przesunięte z {date} przez pogodę'**
  String entryMoved(String date);

  /// No description provided for @sheetFromPlan.
  ///
  /// In pl, this message translates to:
  /// **'Z Twojego planu, co {days}'**
  String sheetFromPlan(String days);

  /// No description provided for @sheetTagTentative.
  ///
  /// In pl, this message translates to:
  /// **'Termin wstępny'**
  String get sheetTagTentative;

  /// No description provided for @sheetTagMatched.
  ///
  /// In pl, this message translates to:
  /// **'Dopasowane do pogody'**
  String get sheetTagMatched;

  /// No description provided for @sheetTagFixed.
  ///
  /// In pl, this message translates to:
  /// **'Stały termin'**
  String get sheetTagFixed;

  /// No description provided for @sheetWindow.
  ///
  /// In pl, this message translates to:
  /// **'Okno nawożenia: {start}–{end}, czyli {from}.–{to}. dzień od poprzedniego nawożenia.'**
  String sheetWindow(String start, String end, int from, int to);

  /// No description provided for @sheetForecastLater.
  ///
  /// In pl, this message translates to:
  /// **'Prognoza obejmie to okno ok. {date}. Wtedy wybierzemy najlepszy z Twoich dni.'**
  String sheetForecastLater(String date);

  /// No description provided for @sheetNextCycle.
  ///
  /// In pl, this message translates to:
  /// **'Dokładny termin ustalimy po poprzednim nawożeniu.'**
  String get sheetNextCycle;

  /// No description provided for @sheetMowing.
  ///
  /// In pl, this message translates to:
  /// **'Koszenie co {days}, w Twoje dni na ogród.'**
  String sheetMowing(String days);

  /// No description provided for @sheetFlexible.
  ///
  /// In pl, this message translates to:
  /// **'Przesuniemy zabieg najwyżej o 2 dni, jeśli pogoda będzie lepsza.'**
  String get sheetFlexible;

  /// No description provided for @sheetFixed.
  ///
  /// In pl, this message translates to:
  /// **'Stały termin, nie przesuwamy go.'**
  String get sheetFixed;

  /// No description provided for @sheetPin.
  ///
  /// In pl, this message translates to:
  /// **'Przypnij do {date}'**
  String sheetPin(String date);

  /// No description provided for @sheetPinHelper.
  ///
  /// In pl, this message translates to:
  /// **'Przypiętego dnia nie przesuniemy, ale ostrzeżemy przed złą pogodą.'**
  String get sheetPinHelper;

  /// No description provided for @sheetUnpin.
  ///
  /// In pl, this message translates to:
  /// **'Dopasuj do pogody'**
  String get sheetUnpin;

  /// No description provided for @sheetChangeDate.
  ///
  /// In pl, this message translates to:
  /// **'Zmień termin'**
  String get sheetChangeDate;

  /// No description provided for @sheetSkipCycle.
  ///
  /// In pl, this message translates to:
  /// **'Pomiń ten cykl'**
  String get sheetSkipCycle;

  /// No description provided for @sheetDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get sheetDelete;

  /// No description provided for @sheetRemove.
  ///
  /// In pl, this message translates to:
  /// **'Usuń z kalendarza'**
  String get sheetRemove;

  /// No description provided for @sheetRemoved.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto z kalendarza.'**
  String get sheetRemoved;

  /// No description provided for @sheetUndo.
  ///
  /// In pl, this message translates to:
  /// **'Cofnij'**
  String get sheetUndo;

  /// No description provided for @sheetClose.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get sheetClose;

  /// No description provided for @addTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy zabieg'**
  String get addTitle;

  /// No description provided for @addEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zmień zabieg'**
  String get addEditTitle;

  /// No description provided for @addKind.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj'**
  String get addKind;

  /// No description provided for @addDate.
  ///
  /// In pl, this message translates to:
  /// **'Termin'**
  String get addDate;

  /// No description provided for @addFlexLabel.
  ///
  /// In pl, this message translates to:
  /// **'Gdy pogoda się zmieni'**
  String get addFlexLabel;

  /// No description provided for @addKeepDay.
  ///
  /// In pl, this message translates to:
  /// **'Trzymaj ten dzień'**
  String get addKeepDay;

  /// No description provided for @addFitWeather.
  ///
  /// In pl, this message translates to:
  /// **'Dopasuj do pogody'**
  String get addFitWeather;

  /// No description provided for @addFlexHelper.
  ///
  /// In pl, this message translates to:
  /// **'Przesuniemy zabieg najwyżej o 2 dni i damy Ci znać.'**
  String get addFlexHelper;

  /// No description provided for @addNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get addNote;

  /// No description provided for @addNoteHint.
  ///
  /// In pl, this message translates to:
  /// **'np. pożyczyć aerator od sąsiada'**
  String get addNoteHint;

  /// No description provided for @addSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz w kalendarzu'**
  String get addSave;

  /// No description provided for @addNoForecast.
  ///
  /// In pl, this message translates to:
  /// **'Prognozy na ten dzień jeszcze nie ma. Sprawdzimy ją bliżej terminu.'**
  String get addNoForecast;

  /// No description provided for @addGoodWeather.
  ///
  /// In pl, this message translates to:
  /// **'{date}: {weather}. Pogoda sprzyja.'**
  String addGoodWeather(String date, String weather);

  /// No description provided for @addBadWeather.
  ///
  /// In pl, this message translates to:
  /// **'{date}: {weather}. {hint}'**
  String addBadWeather(String date, String weather, String hint);

  /// No description provided for @addMoveTo.
  ///
  /// In pl, this message translates to:
  /// **'Przenieś na {date} · {weather}'**
  String addMoveTo(String date, String weather);

  /// No description provided for @careWeatherHint.
  ///
  /// In pl, this message translates to:
  /// **'{kind, select, fertilizing{Pogoda nie sprzyja nawożeniu.} mowing{Mokra trawa źle się kosi.} watering{Deszcz podleje trawnik za Ciebie.} aeration{Mokra gleba oblepia kolce aeratora.} scarification{Wertykulację rób na suchym trawniku.} overseeding{Ulewa albo upał zaszkodzą nasionom.} liming{Wapno rozsiewaj bez silnego wiatru i ulewy.} other{Pogoda tego dnia nie sprzyja.}}'**
  String careWeatherHint(String kind);

  /// No description provided for @sheetStripPlan.
  ///
  /// In pl, this message translates to:
  /// **'plan'**
  String get sheetStripPlan;

  /// No description provided for @sheetStripBusy.
  ///
  /// In pl, this message translates to:
  /// **'bez czasu'**
  String get sheetStripBusy;

  /// No description provided for @sheetTagPinned.
  ///
  /// In pl, this message translates to:
  /// **'Przypięte'**
  String get sheetTagPinned;

  /// No description provided for @weatherOpen.
  ///
  /// In pl, this message translates to:
  /// **'Prognoza na 14 dni'**
  String get weatherOpen;

  /// No description provided for @weatherTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pogoda'**
  String get weatherTitle;

  /// No description provided for @weatherNow.
  ///
  /// In pl, this message translates to:
  /// **'Teraz'**
  String get weatherNow;

  /// No description provided for @weatherWind.
  ///
  /// In pl, this message translates to:
  /// **'Wiatr {speed} km/h'**
  String weatherWind(int speed);

  /// No description provided for @weatherTodayRange.
  ///
  /// In pl, this message translates to:
  /// **'Dziś {max}° / {min}°'**
  String weatherTodayRange(int max, int min);

  /// No description provided for @weatherRainChance.
  ///
  /// In pl, this message translates to:
  /// **'Szansa opadu {chance}%'**
  String weatherRainChance(int chance);

  /// No description provided for @weatherDays.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższe 14 dni'**
  String get weatherDays;

  /// No description provided for @weatherLessCertain.
  ///
  /// In pl, this message translates to:
  /// **'Dalsze dni: prognoza mniej pewna'**
  String get weatherLessCertain;

  /// No description provided for @weatherToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś'**
  String get weatherToday;

  /// No description provided for @weatherTomorrow.
  ///
  /// In pl, this message translates to:
  /// **'Jutro'**
  String get weatherTomorrow;

  /// No description provided for @weatherMinMax.
  ///
  /// In pl, this message translates to:
  /// **'{max}° / {min}°'**
  String weatherMinMax(int max, int min);

  /// No description provided for @weatherSource.
  ///
  /// In pl, this message translates to:
  /// **'Dane pogodowe: MET Norway (met.no)'**
  String get weatherSource;

  /// No description provided for @dayHourly.
  ///
  /// In pl, this message translates to:
  /// **'Godzina po godzinie'**
  String get dayHourly;

  /// No description provided for @dayNoForecast.
  ///
  /// In pl, this message translates to:
  /// **'Prognoza na ten dzień jeszcze niedostępna.'**
  String get dayNoForecast;

  /// No description provided for @dayPlanned.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanowane prace'**
  String get dayPlanned;

  /// No description provided for @dayMowingLegend.
  ///
  /// In pl, this message translates to:
  /// **'Dobra pora na koszenie: sucha trawa, bez rosy i upału'**
  String get dayMowingLegend;

  /// No description provided for @dayWindMax.
  ///
  /// In pl, this message translates to:
  /// **'Wiatr do {speed} km/h'**
  String dayWindMax(int speed);

  /// No description provided for @journalTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik'**
  String get journalTitle;

  /// No description provided for @journalAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wpis'**
  String get journalAdd;

  /// No description provided for @journalSeason.
  ///
  /// In pl, this message translates to:
  /// **'Sezon {year}'**
  String journalSeason(int year);

  /// No description provided for @journalSummary.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie'**
  String get journalSummary;

  /// No description provided for @journalMowings.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{koszenie} few{koszenia} many{koszeń} other{koszeń}}'**
  String journalMowings(int count);

  /// No description provided for @journalFertilizings.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{nawożenie} few{nawożenia} many{nawożeń} other{nawożeń}}'**
  String journalFertilizings(int count);

  /// No description provided for @journalWaterings.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{podlewanie} few{podlewania} many{podlewań} other{podlewań}}'**
  String journalWaterings(int count);

  /// No description provided for @journalFilterAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko'**
  String get journalFilterAll;

  /// No description provided for @journalFilterNotes.
  ///
  /// In pl, this message translates to:
  /// **'Notatki'**
  String get journalFilterNotes;

  /// No description provided for @journalFilterPhotos.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia'**
  String get journalFilterPhotos;

  /// No description provided for @journalEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik jest pusty. Wpisy pojawią się, gdy oznaczysz zabieg jako zrobiony albo dodasz notatkę.'**
  String get journalEmpty;

  /// No description provided for @journalFilterEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak wpisów tego rodzaju.'**
  String get journalFilterEmpty;

  /// No description provided for @journalKind.
  ///
  /// In pl, this message translates to:
  /// **'{kind, select, observation{Obserwacja} photo{Zdjęcie} measurement{Pomiar pH} other{Zabieg}}'**
  String journalKind(String kind);

  /// No description provided for @observationTag.
  ///
  /// In pl, this message translates to:
  /// **'{tag, select, moss{Mech} weeds{Chwasty} yellowPatches{Żółte plamy} bareSpots{Łyse miejsca} grubs{Pędraki} other{Kretowisko}}'**
  String observationTag(String tag);

  /// No description provided for @journalDose.
  ///
  /// In pl, this message translates to:
  /// **'{dose} {unit, select, mlPerSqm{ml/m²} other{g/m²}}'**
  String journalDose(String dose, String unit);

  /// No description provided for @journalTotal.
  ///
  /// In pl, this message translates to:
  /// **'{amount} {unit, select, mlPerSqm{l} other{kg}} na {area} m²'**
  String journalTotal(String amount, String unit, int area);

  /// No description provided for @journalHeight.
  ///
  /// In pl, this message translates to:
  /// **'Wysokość {cm} cm'**
  String journalHeight(String cm);

  /// No description provided for @journalPh.
  ///
  /// In pl, this message translates to:
  /// **'pH {value}'**
  String journalPh(String value);

  /// No description provided for @journalDetailsMissing.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj szczegóły: nawóz i dawkę'**
  String get journalDetailsMissing;

  /// No description provided for @journalRainConfirmed.
  ///
  /// In pl, this message translates to:
  /// **'Wmyte deszczem'**
  String get journalRainConfirmed;

  /// No description provided for @journalDoneAt.
  ///
  /// In pl, this message translates to:
  /// **'zrobione o {time}'**
  String journalDoneAt(String time);

  /// No description provided for @journalProduct.
  ///
  /// In pl, this message translates to:
  /// **'Nawóz'**
  String get journalProduct;

  /// No description provided for @journalNpk.
  ///
  /// In pl, this message translates to:
  /// **'NPK'**
  String get journalNpk;

  /// No description provided for @journalDoseLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dawka'**
  String get journalDoseLabel;

  /// No description provided for @journalWholeLawn.
  ///
  /// In pl, this message translates to:
  /// **'Na cały trawnik'**
  String get journalWholeLawn;

  /// No description provided for @journalRainAfter.
  ///
  /// In pl, this message translates to:
  /// **'Opady po zabiegu'**
  String get journalRainAfter;

  /// No description provided for @journalRainDays.
  ///
  /// In pl, this message translates to:
  /// **'3 dni'**
  String get journalRainDays;

  /// No description provided for @journalRainSource.
  ///
  /// In pl, this message translates to:
  /// **'Według modelu pogody dla Twojej lokalizacji.'**
  String get journalRainSource;

  /// No description provided for @journalRainQuestion.
  ///
  /// In pl, this message translates to:
  /// **'Czy u Ciebie padało?'**
  String get journalRainQuestion;

  /// No description provided for @journalYes.
  ///
  /// In pl, this message translates to:
  /// **'Tak'**
  String get journalYes;

  /// No description provided for @journalNo.
  ///
  /// In pl, this message translates to:
  /// **'Nie'**
  String get journalNo;

  /// No description provided for @journalRainYes.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdziłeś, że u Ciebie padało. Nawóz został wmyty.'**
  String get journalRainYes;

  /// No description provided for @journalRainNo.
  ///
  /// In pl, this message translates to:
  /// **'U Ciebie nie padało. Przy nawożeniu bez deszczu podlej potem trawnik.'**
  String get journalRainNo;

  /// No description provided for @journalNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get journalNote;

  /// No description provided for @journalEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get journalEdit;

  /// No description provided for @journalDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wpis'**
  String get journalDelete;

  /// No description provided for @journalDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Wpis usunięty.'**
  String get journalDeleted;

  /// No description provided for @journalNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy wpis'**
  String get journalNewTitle;

  /// No description provided for @journalEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj wpis'**
  String get journalEditTitle;

  /// No description provided for @journalWhatSeen.
  ///
  /// In pl, this message translates to:
  /// **'Co zauważyłeś?'**
  String get journalWhatSeen;

  /// No description provided for @journalDescription.
  ///
  /// In pl, this message translates to:
  /// **'Opis'**
  String get journalDescription;

  /// No description provided for @journalDescriptionHint.
  ///
  /// In pl, this message translates to:
  /// **'np. mech pod brzozą, ok. 2 m²'**
  String get journalDescriptionHint;

  /// No description provided for @journalPhotos.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia'**
  String get journalPhotos;

  /// No description provided for @journalCamera.
  ///
  /// In pl, this message translates to:
  /// **'Aparat'**
  String get journalCamera;

  /// No description provided for @journalGallery.
  ///
  /// In pl, this message translates to:
  /// **'Galeria'**
  String get journalGallery;

  /// No description provided for @journalRemovePhoto.
  ///
  /// In pl, this message translates to:
  /// **'Usuń zdjęcie'**
  String get journalRemovePhoto;

  /// No description provided for @journalDate.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get journalDate;

  /// No description provided for @journalPhValue.
  ///
  /// In pl, this message translates to:
  /// **'Wynik pomiaru pH'**
  String get journalPhValue;

  /// No description provided for @journalPhHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 6,2'**
  String get journalPhHint;

  /// No description provided for @journalProductHint.
  ///
  /// In pl, this message translates to:
  /// **'np. jesienny z potasem'**
  String get journalProductHint;

  /// No description provided for @journalNpkHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 5-3-10'**
  String get journalNpkHint;

  /// No description provided for @journalDoseHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 30'**
  String get journalDoseHint;

  /// No description provided for @journalHeightLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wysokość koszenia'**
  String get journalHeightLabel;

  /// No description provided for @journalMinutesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Czas podlewania'**
  String get journalMinutesLabel;

  /// No description provided for @journalSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz w dzienniku'**
  String get journalSave;

  /// No description provided for @journalSeasonRange.
  ///
  /// In pl, this message translates to:
  /// **'{start} – {end} · {name}'**
  String journalSeasonRange(String start, String end, String name);

  /// No description provided for @journalMonths.
  ///
  /// In pl, this message translates to:
  /// **'Zabiegi w miesiącach'**
  String get journalMonths;

  /// No description provided for @journalLegendMowing.
  ///
  /// In pl, this message translates to:
  /// **'koszenie'**
  String get journalLegendMowing;

  /// No description provided for @journalLegendFertilizing.
  ///
  /// In pl, this message translates to:
  /// **'nawożenie'**
  String get journalLegendFertilizing;

  /// No description provided for @journalNitrogen.
  ///
  /// In pl, this message translates to:
  /// **'Azot w sezonie'**
  String get journalNitrogen;

  /// No description provided for @journalNitrogenValue.
  ///
  /// In pl, this message translates to:
  /// **'{kg} kg / 100 m²'**
  String journalNitrogenValue(String kg);

  /// No description provided for @journalNitrogenRange.
  ///
  /// In pl, this message translates to:
  /// **'Orientacyjnie dla Twojej mieszanki: {min}–{max} kg.'**
  String journalNitrogenRange(String min, String max);

  /// No description provided for @journalNitrogenMissing.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij skład NPK i dawkę przy nawożeniach, żeby policzyć azot.'**
  String get journalNitrogenMissing;

  /// No description provided for @journalFertilizerUsed.
  ///
  /// In pl, this message translates to:
  /// **'Nawóz'**
  String get journalFertilizerUsed;

  /// No description provided for @journalLiquid.
  ///
  /// In pl, this message translates to:
  /// **'i {litres} l płynnego'**
  String journalLiquid(String litres);

  /// No description provided for @journalRain.
  ///
  /// In pl, this message translates to:
  /// **'Deszcz'**
  String get journalRain;

  /// No description provided for @journalRainMm.
  ///
  /// In pl, this message translates to:
  /// **'{mm} mm'**
  String journalRainMm(String mm);

  /// No description provided for @journalObservations.
  ///
  /// In pl, this message translates to:
  /// **'Obserwacje do sprawdzenia'**
  String get journalObservations;

  /// No description provided for @homeWateringCalibrated.
  ///
  /// In pl, this message translates to:
  /// **'Zraszacz: {minutes} min na sekcję, ok. {mm} mm, wcześnie rano'**
  String homeWateringCalibrated(int minutes, String mm);

  /// No description provided for @journalWateringMm.
  ///
  /// In pl, this message translates to:
  /// **'i {mm} mm z podlewania'**
  String journalWateringMm(String mm);

  /// No description provided for @languageTitle.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In pl, this message translates to:
  /// **'Systemowy'**
  String get languageSystem;

  /// No description provided for @notifChannelName.
  ///
  /// In pl, this message translates to:
  /// **'Pielęgnacja trawnika'**
  String get notifChannelName;

  /// No description provided for @programNoteAverage.
  ///
  /// In pl, this message translates to:
  /// **'średnio {value}'**
  String programNoteAverage(String value);

  /// No description provided for @programNoteSource.
  ///
  /// In pl, this message translates to:
  /// **'Źródło: {site}'**
  String programNoteSource(String site);

  /// No description provided for @lawnTitle.
  ///
  /// In pl, this message translates to:
  /// **'Trawnik'**
  String get lawnTitle;

  /// No description provided for @lawnsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Twoje trawniki'**
  String get lawnsTitle;

  /// No description provided for @lawnsOpen.
  ///
  /// In pl, this message translates to:
  /// **'Zmień lub dodaj trawnik'**
  String get lawnsOpen;

  /// No description provided for @lawnsEditSection.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj wybrany trawnik'**
  String get lawnsEditSection;

  /// No description provided for @lawnsEditData.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa i dane trawnika'**
  String get lawnsEditData;

  /// No description provided for @lawnsAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj nowy trawnik'**
  String get lawnsAdd;

  /// No description provided for @lawnsNotificationsNote.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia przychodzą dla wybranego trawnika.'**
  String get lawnsNotificationsNote;

  /// No description provided for @lawnSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'{place} · {area} m² · {age}'**
  String lawnSubtitle(String place, int area, String age);

  /// No description provided for @lawnAge.
  ///
  /// In pl, this message translates to:
  /// **'{seasons, plural, =0{pierwszy sezon} =1{1 sezon} few{{seasons} sezony} other{{seasons} sezonów}}'**
  String lawnAge(int seasons);

  /// No description provided for @lawnPh.
  ///
  /// In pl, this message translates to:
  /// **'pH gleby'**
  String get lawnPh;

  /// No description provided for @lawnLastFertilized.
  ///
  /// In pl, this message translates to:
  /// **'Nawożenie'**
  String get lawnLastFertilized;

  /// No description provided for @lawnLastMowed.
  ///
  /// In pl, this message translates to:
  /// **'Koszenie'**
  String get lawnLastMowed;

  /// No description provided for @lawnObservations.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =1{1 obserwacja do sprawdzenia} few{{count} obserwacje do sprawdzenia} other{{count} obserwacji do sprawdzenia}}: {tags}'**
  String lawnObservations(int count, String tags);

  /// No description provided for @lawnSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia trawnika'**
  String get lawnSettings;

  /// No description provided for @lawnSoilSummary.
  ///
  /// In pl, this message translates to:
  /// **'gleba {soil}'**
  String lawnSoilSummary(String soil);

  /// No description provided for @lawnData.
  ///
  /// In pl, this message translates to:
  /// **'Dane trawnika'**
  String get lawnData;

  /// No description provided for @lawnCare.
  ///
  /// In pl, this message translates to:
  /// **'Pielęgnacja'**
  String get lawnCare;

  /// No description provided for @lawnCalibration.
  ///
  /// In pl, this message translates to:
  /// **'Kalibracja zraszacza'**
  String get lawnCalibration;

  /// No description provided for @lawnMowingEvery.
  ///
  /// In pl, this message translates to:
  /// **'Koszenie co {days}'**
  String lawnMowingEvery(String days);

  /// No description provided for @lawnCareSub.
  ///
  /// In pl, this message translates to:
  /// **'Nawożenie co {days} · {weekdays}'**
  String lawnCareSub(String days, String weekdays);

  /// No description provided for @lawnNotCalibrated.
  ///
  /// In pl, this message translates to:
  /// **'Nie wykonano'**
  String get lawnNotCalibrated;

  /// No description provided for @lawnRate.
  ///
  /// In pl, this message translates to:
  /// **'{rate} mm/min'**
  String lawnRate(String rate);

  /// No description provided for @lawnAppearance.
  ///
  /// In pl, this message translates to:
  /// **'Wygląd'**
  String get lawnAppearance;

  /// No description provided for @lawnThemeLight.
  ///
  /// In pl, this message translates to:
  /// **'Jasny'**
  String get lawnThemeLight;

  /// No description provided for @lawnThemeDark.
  ///
  /// In pl, this message translates to:
  /// **'Ciemny'**
  String get lawnThemeDark;

  /// No description provided for @lawnThemeSystem.
  ///
  /// In pl, this message translates to:
  /// **'Systemowy'**
  String get lawnThemeSystem;

  /// No description provided for @lawnSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get lawnSave;

  /// No description provided for @lawnSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano.'**
  String get lawnSaved;

  /// No description provided for @lawnEstablished.
  ///
  /// In pl, this message translates to:
  /// **'Założony'**
  String get lawnEstablished;

  /// No description provided for @lawnMix.
  ///
  /// In pl, this message translates to:
  /// **'Mieszanka'**
  String get lawnMix;

  /// No description provided for @lawnSoil.
  ///
  /// In pl, this message translates to:
  /// **'Gleba'**
  String get lawnSoil;

  /// No description provided for @lawnPhFromJournal.
  ///
  /// In pl, this message translates to:
  /// **'Z pomiaru w dzienniku, {date}.'**
  String lawnPhFromJournal(String date);

  /// No description provided for @lawnHeight.
  ///
  /// In pl, this message translates to:
  /// **'Wysokość'**
  String get lawnHeight;

  /// No description provided for @lawnHeightValue.
  ///
  /// In pl, this message translates to:
  /// **'{cm} cm'**
  String lawnHeightValue(int cm);

  /// No description provided for @lawnGardenDays.
  ///
  /// In pl, this message translates to:
  /// **'Dni na ogród'**
  String get lawnGardenDays;

  /// No description provided for @lawnWatering.
  ///
  /// In pl, this message translates to:
  /// **'Podlewanie'**
  String get lawnWatering;

  /// No description provided for @lawnSectionMm.
  ///
  /// In pl, this message translates to:
  /// **'Ok. {mm} mm na jedno podlewanie.'**
  String lawnSectionMm(String mm);

  /// No description provided for @lawnSeason.
  ///
  /// In pl, this message translates to:
  /// **'Sezon'**
  String get lawnSeason;

  /// No description provided for @lawnSeasonStart.
  ///
  /// In pl, this message translates to:
  /// **'Początek'**
  String get lawnSeasonStart;

  /// No description provided for @lawnSeasonEnd.
  ///
  /// In pl, this message translates to:
  /// **'Koniec'**
  String get lawnSeasonEnd;

  /// No description provided for @lawnSeasonHelper.
  ///
  /// In pl, this message translates to:
  /// **'Poza sezonem nie planujemy koszenia, nawożenia ani podlewania.'**
  String get lawnSeasonHelper;

  /// No description provided for @lawnSeasonInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Koniec sezonu musi być po jego początku.'**
  String get lawnSeasonInvalid;

  /// No description provided for @calSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Ile wody daje minuta podlewania'**
  String get calSubtitle;

  /// No description provided for @calStep1Title.
  ///
  /// In pl, this message translates to:
  /// **'Rozstaw 4 kubki'**
  String get calStep1Title;

  /// No description provided for @calStep1.
  ///
  /// In pl, this message translates to:
  /// **'Proste naczynia o płaskim dnie, w różnych miejscach jednej sekcji.'**
  String get calStep1;

  /// No description provided for @calStep2Title.
  ///
  /// In pl, this message translates to:
  /// **'Włącz sekcję na {minutes} min'**
  String calStep2Title(int minutes);

  /// No description provided for @calStep2.
  ///
  /// In pl, this message translates to:
  /// **'Tak jak zwykle podlewasz, bez zmiany ustawień zraszaczy.'**
  String get calStep2;

  /// No description provided for @calStep3Title.
  ///
  /// In pl, this message translates to:
  /// **'Zmierz wodę linijką'**
  String get calStep3Title;

  /// No description provided for @calStep3.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz wysokość wody w każdym kubku.'**
  String get calStep3;

  /// No description provided for @calTestTime.
  ///
  /// In pl, this message translates to:
  /// **'Czas testu'**
  String get calTestTime;

  /// No description provided for @calCup.
  ///
  /// In pl, this message translates to:
  /// **'Kubek {number}'**
  String calCup(int number);

  /// No description provided for @calResult.
  ///
  /// In pl, this message translates to:
  /// **'Wynik'**
  String get calResult;

  /// No description provided for @calRate.
  ///
  /// In pl, this message translates to:
  /// **'{rate} mm na minutę'**
  String calRate(String rate);

  /// No description provided for @calAverage.
  ///
  /// In pl, this message translates to:
  /// **'Średnio {mm} mm w {minutes} min. Żeby podlać {target} mm, włącz sekcję na {needed} min.'**
  String calAverage(String mm, int minutes, int target, int needed);

  /// No description provided for @calEven.
  ///
  /// In pl, this message translates to:
  /// **'Kubki różnią się o {mm} mm: rozkład wody jest równy.'**
  String calEven(String mm);

  /// No description provided for @calUneven.
  ///
  /// In pl, this message translates to:
  /// **'Kubki różnią się o {mm} mm: sprawdź zraszacze, część trawnika dostaje mniej wody.'**
  String calUneven(String mm);

  /// No description provided for @calMissing.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz wynik z co najmniej jednego kubka.'**
  String get calMissing;

  /// No description provided for @calSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz wynik'**
  String get calSave;

  /// No description provided for @homeWateringMoves.
  ///
  /// In pl, this message translates to:
  /// **'Zraszacz na wężu: {minutes} min w jednym miejscu, przestaw ok. {moves} razy'**
  String homeWateringMoves(int minutes, int moves);

  /// No description provided for @homeWateringSpot.
  ///
  /// In pl, this message translates to:
  /// **'Zraszacz na wężu: {minutes} min w jednym miejscu'**
  String homeWateringSpot(int minutes);

  /// No description provided for @homeWateringHose.
  ///
  /// In pl, this message translates to:
  /// **'Wąż: ok. {perSqm} min na m², cały trawnik ok. {total}.'**
  String homeWateringHose(String perSqm, String total);

  /// No description provided for @homeWateringInParts.
  ///
  /// In pl, this message translates to:
  /// **'{parts, plural, few{Podziel na {parts} wieczory.} many{Podziel na {parts} wieczorów.} other{Podziel na {parts} wieczory.}}'**
  String homeWateringInParts(int parts);

  /// No description provided for @homeWateringCan.
  ///
  /// In pl, this message translates to:
  /// **'Konewka: {litres} l na m², czyli {cans} konewki {can} l. Zacznij od najsuchszych miejsc.'**
  String homeWateringCan(String litres, String cans, int can);

  /// No description provided for @durationMinutes.
  ///
  /// In pl, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In pl, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In pl, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @manualMethodLabel.
  ///
  /// In pl, this message translates to:
  /// **'Czym podlewasz?'**
  String get manualMethodLabel;

  /// No description provided for @manualSprinkler.
  ///
  /// In pl, this message translates to:
  /// **'Zraszacz'**
  String get manualSprinkler;

  /// No description provided for @manualHose.
  ///
  /// In pl, this message translates to:
  /// **'Wąż'**
  String get manualHose;

  /// No description provided for @manualCan.
  ///
  /// In pl, this message translates to:
  /// **'Konewka'**
  String get manualCan;

  /// No description provided for @lawnMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Pomiar podlewania'**
  String get lawnMeasurement;

  /// No description provided for @lawnMethodNone.
  ///
  /// In pl, this message translates to:
  /// **'Nie wybrano'**
  String get lawnMethodNone;

  /// No description provided for @lawnFlow.
  ///
  /// In pl, this message translates to:
  /// **'{flow} l/min'**
  String lawnFlow(String flow);

  /// No description provided for @lawnCanValue.
  ///
  /// In pl, this message translates to:
  /// **'Konewka {litres} l'**
  String lawnCanValue(int litres);

  /// No description provided for @calCoverage.
  ///
  /// In pl, this message translates to:
  /// **'Zasięg zraszacza'**
  String get calCoverage;

  /// No description provided for @calCoverageHelper.
  ///
  /// In pl, this message translates to:
  /// **'Powierzchnia podlewana z jednego miejsca. Koło o średnicy 6 m to ok. 28 m².'**
  String get calCoverageHelper;

  /// No description provided for @calMoves.
  ///
  /// In pl, this message translates to:
  /// **'Przy {area} m² przestawiaj zraszacz ok. {moves} razy.'**
  String calMoves(int area, int moves);

  /// No description provided for @calHoseSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Ile wody daje wąż w minutę'**
  String get calHoseSubtitle;

  /// No description provided for @calBucketStep1Title.
  ///
  /// In pl, this message translates to:
  /// **'Weź wiadro o znanej pojemności'**
  String get calBucketStep1Title;

  /// No description provided for @calBucketStep1.
  ///
  /// In pl, this message translates to:
  /// **'Najlepiej 10 l. Ustaw pistolet tak, jak zwykle podlewasz.'**
  String get calBucketStep1;

  /// No description provided for @calBucketStep2Title.
  ///
  /// In pl, this message translates to:
  /// **'Zmierz czas napełniania'**
  String get calBucketStep2Title;

  /// No description provided for @calBucketStep2.
  ///
  /// In pl, this message translates to:
  /// **'Odkręć wodę i stoperem zmierz, po ilu sekundach wiadro jest pełne.'**
  String get calBucketStep2;

  /// No description provided for @calBucket.
  ///
  /// In pl, this message translates to:
  /// **'Pojemność wiadra'**
  String get calBucket;

  /// No description provided for @calBucketLitres.
  ///
  /// In pl, this message translates to:
  /// **'{litres} l'**
  String calBucketLitres(int litres);

  /// No description provided for @calSeconds.
  ///
  /// In pl, this message translates to:
  /// **'Czas napełniania'**
  String get calSeconds;

  /// No description provided for @calSecondsHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 50'**
  String get calSecondsHint;

  /// No description provided for @calFlow.
  ///
  /// In pl, this message translates to:
  /// **'{flow} l na minutę'**
  String calFlow(String flow);

  /// No description provided for @calHoseResult.
  ///
  /// In pl, this message translates to:
  /// **'Żeby podlać {target} mm: ok. {perSqm} min na każdy m², cały trawnik ({area} m²) ok. {total}.'**
  String calHoseResult(int target, String perSqm, int area, String total);

  /// No description provided for @calSecondsMissing.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz, po ilu sekundach wiadro jest pełne.'**
  String get calSecondsMissing;

  /// No description provided for @calCanTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podlewanie konewką'**
  String get calCanTitle;

  /// No description provided for @calCanText.
  ///
  /// In pl, this message translates to:
  /// **'Na {target} mm wody potrzeba {litres} l na każdy m², czyli {cans} konewki {can} l. Cały trawnik ({area} m²) to ok. {total} l, dlatego konewką podlewaj tylko najbardziej suche miejsca.'**
  String calCanText(int target, String litres, String cans, int can, int area, int total);

  /// No description provided for @journalMinutesSpot.
  ///
  /// In pl, this message translates to:
  /// **'Minut w jednym miejscu'**
  String get journalMinutesSpot;

  /// No description provided for @journalLitresLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ilość wody'**
  String get journalLitresLabel;

  /// No description provided for @journalLitres.
  ///
  /// In pl, this message translates to:
  /// **'{litres} l wody'**
  String journalLitres(String litres);

  /// No description provided for @calHoseByBucket.
  ///
  /// In pl, this message translates to:
  /// **'Wiadro'**
  String get calHoseByBucket;

  /// No description provided for @calHoseByCups.
  ///
  /// In pl, this message translates to:
  /// **'Kubki'**
  String get calHoseByCups;

  /// No description provided for @calHoseCupsStep1Title.
  ///
  /// In pl, this message translates to:
  /// **'Wyznacz kawałek trawnika'**
  String get calHoseCupsStep1Title;

  /// No description provided for @calHoseCupsStep1.
  ///
  /// In pl, this message translates to:
  /// **'Np. kwadrat 3 × 3 m. Rozstaw w nim 4 kubki.'**
  String get calHoseCupsStep1;

  /// No description provided for @calHoseCupsStep2Title.
  ///
  /// In pl, this message translates to:
  /// **'Podlewaj go wężem przez {minutes} min'**
  String calHoseCupsStep2Title(int minutes);

  /// No description provided for @calHoseCupsStep2.
  ///
  /// In pl, this message translates to:
  /// **'Tak jak zwykle, równo po całym kawałku, bez wychodzenia poza niego.'**
  String get calHoseCupsStep2;

  /// No description provided for @calTestArea.
  ///
  /// In pl, this message translates to:
  /// **'Powierzchnia kawałka'**
  String get calTestArea;

  /// No description provided for @calHoseCupsFlow.
  ///
  /// In pl, this message translates to:
  /// **'Na trawnik trafia średnio {mm} mm w {minutes} min, czyli ok. {flow} l na minutę.'**
  String calHoseCupsFlow(String mm, int minutes, String flow);

  /// No description provided for @calAreaMissing.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz powierzchnię kawałka i wynik z co najmniej jednego kubka.'**
  String get calAreaMissing;

  /// No description provided for @assistantTitle.
  ///
  /// In pl, this message translates to:
  /// **'Asystent'**
  String get assistantTitle;

  /// No description provided for @assistantSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zna Twój trawnik, pogodę i dziennik'**
  String get assistantSubtitle;

  /// No description provided for @assistantAskHint.
  ///
  /// In pl, this message translates to:
  /// **'Zapytaj o swój trawnik…'**
  String get assistantAskHint;

  /// No description provided for @assistantFollowHint.
  ///
  /// In pl, this message translates to:
  /// **'Dopytaj…'**
  String get assistantFollowHint;

  /// No description provided for @assistantSend.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij'**
  String get assistantSend;

  /// No description provided for @assistantAddPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie'**
  String get assistantAddPhoto;

  /// No description provided for @assistantQuota.
  ///
  /// In pl, this message translates to:
  /// **'Zostało {remaining} z {limit} pytań na dziś'**
  String assistantQuota(int remaining, int limit);

  /// No description provided for @assistantQuotaCost.
  ///
  /// In pl, this message translates to:
  /// **'Zużyje 1 z {remaining} pozostałych pytań'**
  String assistantQuotaCost(int remaining);

  /// No description provided for @assistantProblems.
  ///
  /// In pl, this message translates to:
  /// **'Co Cię niepokoi?'**
  String get assistantProblems;

  /// No description provided for @lawnProblem.
  ///
  /// In pl, this message translates to:
  /// **'{problem, select, yellowPatches{Żółte plamy} dryGrass{Sucha trawa} moss{Mech} weeds{Chwasty} bareSpots{Łyse miejsca} fungus{Grzyby, pleśń} molehills{Kretowiska} other{Pędraki}}'**
  String lawnProblem(String problem);

  /// No description provided for @assistantQuick.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie odpowiedzi'**
  String get assistantQuick;

  /// No description provided for @assistantOffline.
  ///
  /// In pl, this message translates to:
  /// **'offline'**
  String get assistantOffline;

  /// No description provided for @assistantOfflineAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedź offline, bez limitu'**
  String get assistantOfflineAnswer;

  /// No description provided for @quickWeek.
  ///
  /// In pl, this message translates to:
  /// **'Co zrobić w tym tygodniu?'**
  String get quickWeek;

  /// No description provided for @quickScarify.
  ///
  /// In pl, this message translates to:
  /// **'Kiedy mogę wertykulować?'**
  String get quickScarify;

  /// No description provided for @quickWinter.
  ///
  /// In pl, this message translates to:
  /// **'Jak przygotować trawnik do zimy?'**
  String get quickWinter;

  /// No description provided for @quickWeekNone.
  ///
  /// In pl, this message translates to:
  /// **'W najbliższych 7 dniach nie ma zaplanowanych prac.'**
  String get quickWeekNone;

  /// No description provided for @quickWeekIntro.
  ///
  /// In pl, this message translates to:
  /// **'Plan na najbliższe 7 dni:'**
  String get quickWeekIntro;

  /// No description provided for @quickScarifyNow.
  ///
  /// In pl, this message translates to:
  /// **'Tak, to dobry czas. Wertykulację rób na suchym, świeżo skoszonym trawniku, a łyse miejsca od razu dosiej.'**
  String get quickScarifyNow;

  /// No description provided for @quickScarifyLater.
  ///
  /// In pl, this message translates to:
  /// **'Teraz nie. Wertykulacja rani darń, więc trawa musi potem szybko odrosnąć: najlepiej wiosną albo pod koniec lata.'**
  String get quickScarifyLater;

  /// No description provided for @quickScarifyNext.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższy dobry termin: od {date}.'**
  String quickScarifyNext(String date);

  /// No description provided for @quickScarifyNowPreview.
  ///
  /// In pl, this message translates to:
  /// **'Teraz to dobry czas'**
  String get quickScarifyNowPreview;

  /// No description provided for @quickScarifyLaterPreview.
  ///
  /// In pl, this message translates to:
  /// **'Od {date}'**
  String quickScarifyLaterPreview(String date);

  /// No description provided for @quickWinterText.
  ///
  /// In pl, this message translates to:
  /// **'1. Ostatnie koszenie na ok. 5 cm, gdy trawa przestaje rosnąć.\n2. Do końca października nawóz jesienny z przewagą potasu.\n3. Grabienie liści: nie zostawiaj ich na zimę.\n4. Nie chodź po zamarzniętej trawie.'**
  String get quickWinterText;

  /// No description provided for @quickWinterPreview.
  ///
  /// In pl, this message translates to:
  /// **'4 kroki przed zimą'**
  String get quickWinterPreview;

  /// No description provided for @diagnoseSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Diagnoza ze zdjęcia'**
  String get diagnoseSubtitle;

  /// No description provided for @diagnosePhotos.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia'**
  String get diagnosePhotos;

  /// No description provided for @diagnosePhotosHint.
  ///
  /// In pl, this message translates to:
  /// **'Najlepiej dwa: cała plama i z bliska.'**
  String get diagnosePhotosHint;

  /// No description provided for @diagnoseDescribe.
  ///
  /// In pl, this message translates to:
  /// **'Opisz, co widzisz'**
  String get diagnoseDescribe;

  /// No description provided for @diagnoseDescribeHint.
  ///
  /// In pl, this message translates to:
  /// **'np. nieregularne plamy, trawa łatwo się odrywa'**
  String get diagnoseDescribeHint;

  /// No description provided for @diagnoseSince.
  ///
  /// In pl, this message translates to:
  /// **'Od kiedy?'**
  String get diagnoseSince;

  /// No description provided for @diagnoseSinceOption.
  ///
  /// In pl, this message translates to:
  /// **'{since, select, days{Kilka dni} weeks{1–2 tygodnie} month{Ponad miesiąc} other{Nie wiem}}'**
  String diagnoseSinceOption(String since);

  /// No description provided for @diagnoseContextTitle.
  ///
  /// In pl, this message translates to:
  /// **'Asystent dostanie też'**
  String get diagnoseContextTitle;

  /// No description provided for @diagnoseContext.
  ///
  /// In pl, this message translates to:
  /// **'Dane trawnika ({area} m², {mix}), opady z 14 dni, prognozę i ostatnie wpisy z dziennika.'**
  String diagnoseContext(int area, String mix);

  /// No description provided for @diagnoseButton.
  ///
  /// In pl, this message translates to:
  /// **'Zdiagnozuj'**
  String get diagnoseButton;

  /// No description provided for @diagnoseWorking.
  ///
  /// In pl, this message translates to:
  /// **'Analizuję…'**
  String get diagnoseWorking;

  /// No description provided for @resultTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wynik diagnozy'**
  String get resultTitle;

  /// No description provided for @resultMost.
  ///
  /// In pl, this message translates to:
  /// **'Najpewniej'**
  String get resultMost;

  /// No description provided for @resultUrgency.
  ///
  /// In pl, this message translates to:
  /// **'{urgency, select, actNow{działaj teraz} soon{w najbliższych tygodniach} other{nie pilne}}'**
  String resultUrgency(String urgency);

  /// No description provided for @resultLikelihood.
  ///
  /// In pl, this message translates to:
  /// **'{level, select, high{wysokie} medium{średnie} other{niskie}}'**
  String resultLikelihood(String level);

  /// No description provided for @resultCheck.
  ///
  /// In pl, this message translates to:
  /// **'Jak to sprawdzić'**
  String get resultCheck;

  /// No description provided for @resultActions.
  ///
  /// In pl, this message translates to:
  /// **'Proponowane zabiegi'**
  String get resultActions;

  /// No description provided for @assistantToCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Do kalendarza'**
  String get assistantToCalendar;

  /// No description provided for @assistantAddedToCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Dodano do kalendarza.'**
  String get assistantAddedToCalendar;

  /// No description provided for @assistantSaveJournal.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz w dzienniku'**
  String get assistantSaveJournal;

  /// No description provided for @assistantSavedJournal.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano w dzienniku.'**
  String get assistantSavedJournal;

  /// No description provided for @assistantReport.
  ///
  /// In pl, this message translates to:
  /// **'Zgłoś odpowiedź'**
  String get assistantReport;

  /// No description provided for @assistantAiNote.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedź AI może się mylić. Przy środkach ochrony roślin kieruj się etykietą produktu.'**
  String get assistantAiNote;

  /// No description provided for @reportTitle.
  ///
  /// In pl, this message translates to:
  /// **'Co jest nie tak z odpowiedzią?'**
  String get reportTitle;

  /// No description provided for @reportReason.
  ///
  /// In pl, this message translates to:
  /// **'{reason, select, wrong{Błędna} offensive{Obraźliwa} dangerous{Niebezpieczna} other{Inny powód}}'**
  String reportReason(String reason);

  /// No description provided for @reportNote.
  ///
  /// In pl, this message translates to:
  /// **'Komentarz'**
  String get reportNote;

  /// No description provided for @reportSend.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij zgłoszenie'**
  String get reportSend;

  /// No description provided for @reportSent.
  ///
  /// In pl, this message translates to:
  /// **'Dziękujemy, sprawdzimy tę odpowiedź.'**
  String get reportSent;

  /// No description provided for @assistantError.
  ///
  /// In pl, this message translates to:
  /// **'{error, select, quotaExceeded{Wykorzystałeś dzisiejsze pytania. Limit odnowi się jutro.} offline{Brak połączenia z internetem.} busy{Asystent jest teraz zajęty. Spróbuj za chwilę.} badImage{Nie udało się wysłać zdjęcia. Spróbuj z innym.} other{Nie udało się uzyskać odpowiedzi. Spróbuj ponownie.}}'**
  String assistantError(String error);

  /// No description provided for @assistantUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Asystent AI jest niedostępny w tej wersji aplikacji. Szybkie odpowiedzi działają offline.'**
  String get assistantUnavailable;

  /// No description provided for @assistantPrivacyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zanim zapytasz'**
  String get assistantPrivacyTitle;

  /// No description provided for @assistantPrivacy.
  ///
  /// In pl, this message translates to:
  /// **'Pytania, wybrane zdjęcia i dane trawnika trafiają przez nasz serwer do Google Gemini. Na darmowych warunkach Google może je wykorzystać do ulepszania swoich usług. Nie dołączaj zdjęć z osobami.'**
  String get assistantPrivacy;

  /// No description provided for @assistantPrivacyAccept.
  ///
  /// In pl, this message translates to:
  /// **'Rozumiem'**
  String get assistantPrivacyAccept;

  /// No description provided for @navToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś'**
  String get navToday;

  /// No description provided for @navCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get navCalendar;

  /// No description provided for @navJournal.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik'**
  String get navJournal;

  /// No description provided for @navAssistant.
  ///
  /// In pl, this message translates to:
  /// **'Asystent'**
  String get navAssistant;

  /// No description provided for @navLawn.
  ///
  /// In pl, this message translates to:
  /// **'Trawnik'**
  String get navLawn;

  /// No description provided for @guideTopicTitle.
  ///
  /// In pl, this message translates to:
  /// **'{topic, select, scarification{Wertykulacja} aeration{Aeracja} raking{Wyczesywanie} overseeding{Dosiewka} sanding{Piaskowanie} liming{Wapnowanie} other{}}'**
  String guideTopicTitle(String topic);

  /// No description provided for @guideTopicSummary.
  ///
  /// In pl, this message translates to:
  /// **'{topic, select, scarification{Usuwa filc i mech, przewietrza darń} aeration{Napowietrza ubitą glebę, woda i nawóz docierają do korzeni} raking{Lekko usuwa martwą trawę, liście i cienki filc} overseeding{Zagęszcza trawnik i wypełnia łyse miejsca} sanding{Rozluźnia ciężką glebę i wyrównuje powierzchnię} liming{Odkwasza glebę, gdy pH spadnie za nisko} other{}}'**
  String guideTopicSummary(String topic);

  /// No description provided for @guideTopicWhen.
  ///
  /// In pl, this message translates to:
  /// **'{topic, select, scarification{Kwiecień–maj, opcjonalnie koniec sierpnia–wrzesień} aeration{Kwiecień–maj albo wrzesień} raking{Marzec–kwiecień i jesienią, z liśćmi} overseeding{Koniec sierpnia–wrzesień, kwiecień–maj} sanding{Zaraz po aeracji, wiosną lub we wrześniu} liming{Październik–listopad, przy pH poniżej 5,5} other{}}'**
  String guideTopicWhen(String topic);

  /// No description provided for @guideTopicWhenText.
  ///
  /// In pl, this message translates to:
  /// **'{topic, select, scarification{Gdy trawa intensywnie rośnie, a gleba ma co najmniej 10°C. Zwykle po 2–3 wiosennym koszeniu. Nie w upale i nie na mokrej glebie.} aeration{Gdy trawa rośnie i szybko zarośnie otwory. Gleba ma być wilgotna, ale nie mokra: kolce wchodzą wtedy łatwo i nie mażą gleby.} raking{Wiosną, gdy trawnik obeschnie po zimie, i jesienią, gdy spadają liście. Jest delikatniejsze od wertykulacji, więc można je robić częściej.} overseeding{Najlepiej od końca sierpnia do połowy września: gleba jest ciepła, a rosa trzyma wilgoć. Wiosną wtedy, gdy gleba ma co najmniej 8–10°C.} sanding{Najlepiej od razu po aeracji lub wertykulacji, póki otwory są otwarte. Trawnik i piasek muszą być suche.} liming{Jesienią, po ostatnim nawożeniu, albo wczesną wiosną. Tylko gdy pomiar pokaże kwaśną glebę: trawa najlepiej rośnie przy pH 5,5–7.} other{}}'**
  String guideTopicWhenText(String topic);

  /// No description provided for @guideTopicSigns.
  ///
  /// In pl, this message translates to:
  /// **'{topic, select, scarification{Pod źdźbłami jest sprężysta warstwa filcu grubsza niż 1 cm\nMiędzy trawą rośnie mech\nTrawnik słabo reaguje na nawóz i podlewanie} aeration{Po deszczu na trawniku długo stoi woda\nGleba jest twarda, śrubokręt ledwo w nią wchodzi\nTrawa rzednie na ścieżkach i w miejscach zabaw} raking{Po zimie trawa jest zbita i zeschnięta\nNa trawniku leżą liście i resztki skoszonej trawy\nFilc jest cienki, poniżej 1 cm} overseeding{Trawnik rzednie i widać glebę\nPo zimie lub wertykulacji zostały łyse placki\nW lukach wyrastają chwasty} sanding{Gleba jest gliniasta i zbita\nPo deszczu długo stoi woda\nNa trawniku są drobne nierówności} liming{Pomiar pH pokazał wynik poniżej 5,5\nNa trawniku rozrasta się mech\nTrawa słabo reaguje na nawożenie} other{}}'**
  String guideTopicSigns(String topic);

  /// No description provided for @guideTopicSteps.
  ///
  /// In pl, this message translates to:
  /// **'{topic, select, scarification{Skoś nisko: Na 3–4 cm, dzień lub dwa wcześniej. Trawnik musi być suchy.\nUstaw noże płytko: Mają nacinać glebę na 2–3 mm. Głębiej uszkodzisz korzenie.\nPrzejdź wzdłuż, potem w poprzek: Równym tempem, bez zatrzymywania się w jednym miejscu.\nZgrab wyczesany filc: Może go być zaskakująco dużo. Trawnik przez 2 tygodnie wygląda gorzej, to normalne.\nDosiej i nawieź: Łyse miejsca dosiej od razu, potem nawóz wiosenny.\nPodlewaj: Regularnie przez 2–3 tygodnie, jeśli nie pada.} aeration{Skoś trawnik: Na zwykłą wysokość, dzień wcześniej.\nPodlej, jeśli jest sucho: Dzień przed aeracją, żeby gleba zmiękła.\nNakłuj glebę: Aeratorem z pustymi kolcami na 6–10 cm, co około 10 cm.\nZostaw rdzenie: Po 1–2 dniach wyschną, wtedy rozbij je grabiami.\nZasyp otwory piaskiem: Piaskowanie zaraz po aeracji daje najlepszy efekt.\nNawieź i podlej: Składniki trafią prosto do korzeni.} raking{Poczekaj, aż trawnik obeschnie: Mokrą darń łatwo wyrwać razem z korzeniami.\nWyczesz grabiami wachlarzowymi: Energicznie, ale płytko, w dwóch kierunkach.\nZbierz resztki: Liście i martwą trawę wyrzuć na kompost.\nDosiej ubytki: Łyse miejsca po zimie dosiej, gdy gleba ma 8–10°C.} overseeding{Przygotuj glebę: Wyczesz lub wertykuluj trawnik, łyse miejsca spulchnij grabiami.\nWysiej nasiona: 15–20 g/m², a na łyse miejsca 25–35 g/m². Siej w dwóch kierunkach.\nPrzykryj cienko: Około 0,5 cm ziemi lub piasku, potem lekko zwałuj.\nPodlewaj codziennie: Delikatnie, małą dawką, przez 2–3 tygodnie, aż trawa wzejdzie.\nSkoś pierwszy raz: Gdy młoda trawa ma 8–10 cm, skoś ją na 5–6 cm.} sanding{Zrób aerację: Piasek ma wpaść w otwory po kolcach.\nRozsyp piasek: 3–5 l/m², czyli warstwa 3–5 mm. Piasek płukany o ziarnie 0–2 mm.\nRozprowadź i wmieć: Odwróconymi grabiami lub szczotką, aż piasek zniknie w darni.\nPodlej: Woda spłucze resztki piasku z liści.} liming{Zmierz pH: Kwasomierzem lub paskami, w kilku miejscach trawnika.\nDobierz dawkę: Wapno węglanowe lub dolomit, zwykle 10–20 kg na 100 m². Dokładną dawkę podaje etykieta.\nRozsiej równo: Siewnikiem, przy bezwietrznej pogodzie, w dwóch kierunkach.\nPodlej lub poczekaj na deszcz: Wapno musi dostać się do gleby.\nSprawdź pH za rok: Nie wapnuj co sezon bez pomiaru.} other{}}'**
  String guideTopicSteps(String topic);

  /// No description provided for @guideTopicTools.
  ///
  /// In pl, this message translates to:
  /// **'{topic, select, scarification{Wertykulator\nGrabie\nNasiona do dosiewki\nNawóz wiosenny} aeration{Aerator z pustymi kolcami\nGrabie\nPiasek płukany} raking{Grabie wachlarzowe\nWyczesywarka (opcjonalnie)\nWorki lub kompostownik} overseeding{Nasiona tej samej mieszanki\nGrabie\nZiemia lub piasek do przykrycia\nWałek (opcjonalnie)} sanding{Piasek płukany 0–2 mm\nGrabie lub szczotka\nTaczka i łopata} liming{Kwasomierz lub paski pH\nWapno węglanowe lub dolomit\nSiewnik} other{}}'**
  String guideTopicTools(String topic);

  /// No description provided for @guideTopicAvoid.
  ///
  /// In pl, this message translates to:
  /// **'{topic, select, scarification{Trawnik młodszy niż 2 lata od siewu albo rok od położenia rolki. Wertykulacja w upale, suszy lub na mokrej glebie. Więcej niż 1–2 razy w roku.} aeration{Trawnik młodszy niż rok od założenia. Aeracja przesuszonej, twardej gleby albo w suszy. Pełne kolce na ciężkiej glebie tylko ją ugniatają. Na glebie gliniastej wystarczą 1–2 razy w roku, na piaszczystej rzadziej.} raking{Wyczesywanie mokrego lub zamarzniętego trawnika. Liście zostawione na zimę: trawa pod nimi gnije i łapie choroby.} overseeding{Siew w upał, w suszę albo w zimną glebę. Chodzenie po świeżym wysiewie. Środki na chwasty przez 6–8 tygodni przed siewem i po nim.} sanding{Piasek budowlany z gliną i drobny piasek pylasty. Warstwa grubsza niż 5 mm naraz: trawa się udusi. Na glebie piaszczystej piaskowanie zwykle nie jest potrzebne.} liming{Wapno razem z nawozem azotowym: zachowaj 3–4 tygodnie odstępu. Wapno tlenkowe (palone), które parzy trawę. Wapnowanie bez pomiaru pH.} other{}}'**
  String guideTopicAvoid(String topic);

  /// No description provided for @guideMonthTitle.
  ///
  /// In pl, this message translates to:
  /// **'{month, select, jan{Zima: trawnik odpoczywa} feb{Przygotowania do sezonu} mar{Wyczesywanie i pierwszy nawóz} apr{Wertykulacja i aeracja} may{Dosiewka i regularne koszenie} jun{Koszenie i podlewanie} jul{Upał: koś wyżej} aug{Dosiewka pod koniec miesiąca} sep{Aeracja, piaskowanie, dosiewka} oct{Wapnowanie i ostatnie koszenie} nov{Grabienie liści} dec{Zima: trawnik odpoczywa} other{}}'**
  String guideMonthTitle(String month);

  /// No description provided for @guideMonthText.
  ///
  /// In pl, this message translates to:
  /// **'{month, select, jan{Nie chodź po zamarzniętej trawie i zaplanuj wiosenne zabiegi.} feb{Naostrz noże kosiarki i sprawdź sprzęt przed wiosną.} mar{Gdy trawnik obeschnie, wygrab filc i liście. Pod koniec miesiąca daj nawóz startowy.} apr{Trawa rusza ze wzrostem. To najlepszy czas na zabiegi i dosiewkę łysych miejsc.} may{Ostatnia szansa na wiosenną wertykulację. Koś co 4–7 dni.} jun{Podlewaj rzadziej, ale obficiej, najlepiej rano.} jul{Podnieś kosiarkę o 1 cm i nie nawoź azotem w upale.} aug{Gdy upały miną, zaczyna się najlepszy czas na dosiewkę.} sep{Ciepła gleba i rosa pomagają trawnikowi szybko wrócić do siebie po zabiegach.} oct{Jesień to dobry moment, by odkwasić glebę przed zimą.} nov{Nie zostawiaj liści na zimę. Ostatnie koszenie na około 5 cm.} dec{Nie chodź po zamarzniętej trawie i nie zgarniaj na nią śniegu z solą.} other{}}'**
  String guideMonthText(String month);

  /// No description provided for @guideTitle.
  ///
  /// In pl, this message translates to:
  /// **'Poradnik'**
  String get guideTitle;

  /// No description provided for @guideCare.
  ///
  /// In pl, this message translates to:
  /// **'Zabiegi'**
  String get guideCare;

  /// No description provided for @guideCareSub.
  ///
  /// In pl, this message translates to:
  /// **'Wertykulacja, aeracja, dosiewka i inne'**
  String get guideCareSub;

  /// No description provided for @guideCarePageSub.
  ///
  /// In pl, this message translates to:
  /// **'Kiedy i jak je wykonać'**
  String get guideCarePageSub;

  /// No description provided for @guideFertilizing.
  ///
  /// In pl, this message translates to:
  /// **'Nawożenie'**
  String get guideFertilizing;

  /// No description provided for @guideFertilizingSub.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaje nawozów i skład NPK'**
  String get guideFertilizingSub;

  /// No description provided for @guideFertilizingPageSub.
  ///
  /// In pl, this message translates to:
  /// **'Jakie nawozy, kiedy i w jakim składzie'**
  String get guideFertilizingPageSub;

  /// No description provided for @guideMowing.
  ///
  /// In pl, this message translates to:
  /// **'Koszenie'**
  String get guideMowing;

  /// No description provided for @guideMowingSub.
  ///
  /// In pl, this message translates to:
  /// **'Wysokość, rytm i zasada 1/3'**
  String get guideMowingSub;

  /// No description provided for @guideMowingPageSub.
  ///
  /// In pl, this message translates to:
  /// **'Wysokość, rytm i dobre nawyki'**
  String get guideMowingPageSub;

  /// No description provided for @guideMixes.
  ///
  /// In pl, this message translates to:
  /// **'Mieszanki traw'**
  String get guideMixes;

  /// No description provided for @guideMixesSub.
  ///
  /// In pl, this message translates to:
  /// **'Dobór do trawnika i koszenie'**
  String get guideMixesSub;

  /// No description provided for @guideMixesPageSub.
  ///
  /// In pl, this message translates to:
  /// **'Jak dobrać i na jaką wysokość kosić'**
  String get guideMixesPageSub;

  /// No description provided for @guideNowGood.
  ///
  /// In pl, this message translates to:
  /// **'Teraz dobry czas'**
  String get guideNowGood;

  /// No description provided for @guideLater.
  ///
  /// In pl, this message translates to:
  /// **'Później w sezonie'**
  String get guideLater;

  /// No description provided for @guideNextSeason.
  ///
  /// In pl, this message translates to:
  /// **'W przyszłym sezonie'**
  String get guideNextSeason;

  /// No description provided for @guideNowBadge.
  ///
  /// In pl, this message translates to:
  /// **'Teraz'**
  String get guideNowBadge;

  /// No description provided for @guideOrderTip.
  ///
  /// In pl, this message translates to:
  /// **'Kolejność wiosną: wertykulacja, aeracja, piaskowanie, dosiewka, nawożenie. Każdy krok przygotowuje trawnik do następnego.'**
  String get guideOrderTip;

  /// No description provided for @guideWhen.
  ///
  /// In pl, this message translates to:
  /// **'Kiedy'**
  String get guideWhen;

  /// No description provided for @guideBest.
  ///
  /// In pl, this message translates to:
  /// **'najlepiej'**
  String get guideBest;

  /// No description provided for @guidePossible.
  ///
  /// In pl, this message translates to:
  /// **'można'**
  String get guidePossible;

  /// No description provided for @guideNowLegend.
  ///
  /// In pl, this message translates to:
  /// **'teraz'**
  String get guideNowLegend;

  /// No description provided for @guideSignsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Czy Twój trawnik tego potrzebuje?'**
  String get guideSignsTitle;

  /// No description provided for @guideStepsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Jak wykonać'**
  String get guideStepsTitle;

  /// No description provided for @guideToolsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Czego potrzebujesz'**
  String get guideToolsTitle;

  /// No description provided for @guideAvoidTitle.
  ///
  /// In pl, this message translates to:
  /// **'Czego unikać'**
  String get guideAvoidTitle;

  /// No description provided for @guidePlanNow.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanuj zabieg'**
  String get guidePlanNow;

  /// No description provided for @guideAsk.
  ///
  /// In pl, this message translates to:
  /// **'Zapytaj asystenta'**
  String get guideAsk;

  /// No description provided for @guideYoursMix.
  ///
  /// In pl, this message translates to:
  /// **'Twoja'**
  String get guideYoursMix;

  /// No description provided for @guideNpkTitle.
  ///
  /// In pl, this message translates to:
  /// **'Co oznacza N-P-K'**
  String get guideNpkTitle;

  /// No description provided for @guideNpkIntro.
  ///
  /// In pl, this message translates to:
  /// **'Liczby na worku to procent składników. 20-5-8 oznacza 20% azotu, 5% fosforu i 8% potasu.'**
  String get guideNpkIntro;

  /// No description provided for @guideNitrogen.
  ///
  /// In pl, this message translates to:
  /// **'Azot'**
  String get guideNitrogen;

  /// No description provided for @guideNitrogenText.
  ///
  /// In pl, this message translates to:
  /// **'Wzrost i zielony kolor'**
  String get guideNitrogenText;

  /// No description provided for @guidePhosphorus.
  ///
  /// In pl, this message translates to:
  /// **'Fosfor'**
  String get guidePhosphorus;

  /// No description provided for @guidePhosphorusText.
  ///
  /// In pl, this message translates to:
  /// **'Korzenie, ważny przy zakładaniu trawnika'**
  String get guidePhosphorusText;

  /// No description provided for @guidePotassium.
  ///
  /// In pl, this message translates to:
  /// **'Potas'**
  String get guidePotassium;

  /// No description provided for @guidePotassiumText.
  ///
  /// In pl, this message translates to:
  /// **'Odporność na mróz, suszę i choroby'**
  String get guidePotassiumText;

  /// No description provided for @guideMicro.
  ///
  /// In pl, this message translates to:
  /// **'Magnez (Mg) pogłębia kolor, a żelazo (Fe) daje intensywną zieleń i ogranicza mech.'**
  String get guideMicro;

  /// No description provided for @guideFertSeasonsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nawóz na porę roku'**
  String get guideFertSeasonsTitle;

  /// No description provided for @guideColSeason.
  ///
  /// In pl, this message translates to:
  /// **'Pora'**
  String get guideColSeason;

  /// No description provided for @guideColNpk.
  ///
  /// In pl, this message translates to:
  /// **'N-P-K'**
  String get guideColNpk;

  /// No description provided for @guideColWhy.
  ///
  /// In pl, this message translates to:
  /// **'Po co'**
  String get guideColWhy;

  /// No description provided for @guideFertSeason1.
  ///
  /// In pl, this message translates to:
  /// **'Marzec–kwiecień'**
  String get guideFertSeason1;

  /// No description provided for @guideFertSeason1Why.
  ///
  /// In pl, this message translates to:
  /// **'Start wzrostu po zimie'**
  String get guideFertSeason1Why;

  /// No description provided for @guideFertSeason2.
  ///
  /// In pl, this message translates to:
  /// **'Maj–czerwiec'**
  String get guideFertSeason2;

  /// No description provided for @guideFertSeason2Why.
  ///
  /// In pl, this message translates to:
  /// **'Gęsta, równa darń'**
  String get guideFertSeason2Why;

  /// No description provided for @guideFertSeason3.
  ///
  /// In pl, this message translates to:
  /// **'Lipiec–sierpień'**
  String get guideFertSeason3;

  /// No description provided for @guideFertSeason3Why.
  ///
  /// In pl, this message translates to:
  /// **'Mniej azotu, odporność na upał'**
  String get guideFertSeason3Why;

  /// No description provided for @guideFertSeason4.
  ///
  /// In pl, this message translates to:
  /// **'Wrzesień–październik'**
  String get guideFertSeason4;

  /// No description provided for @guideFertSeason4Why.
  ///
  /// In pl, this message translates to:
  /// **'Korzenie i przezimowanie, dużo potasu'**
  String get guideFertSeason4Why;

  /// No description provided for @guideFertTypesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaje nawozów'**
  String get guideFertTypesTitle;

  /// No description provided for @guideColType.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj'**
  String get guideColType;

  /// No description provided for @guideColWorks.
  ///
  /// In pl, this message translates to:
  /// **'Działa'**
  String get guideColWorks;

  /// No description provided for @guideColEvery.
  ///
  /// In pl, this message translates to:
  /// **'Co ile'**
  String get guideColEvery;

  /// No description provided for @guideFertSlow.
  ///
  /// In pl, this message translates to:
  /// **'Granulowany wolnodziałający'**
  String get guideFertSlow;

  /// No description provided for @guideFertFast.
  ///
  /// In pl, this message translates to:
  /// **'Granulowany szybki'**
  String get guideFertFast;

  /// No description provided for @guideFertLiquid.
  ///
  /// In pl, this message translates to:
  /// **'Płynny'**
  String get guideFertLiquid;

  /// No description provided for @guideFertOrganic.
  ///
  /// In pl, this message translates to:
  /// **'Organiczny'**
  String get guideFertOrganic;

  /// No description provided for @guideFertSlowWorks.
  ///
  /// In pl, this message translates to:
  /// **'2–3 mies.'**
  String get guideFertSlowWorks;

  /// No description provided for @guideFertSlowEvery.
  ///
  /// In pl, this message translates to:
  /// **'8–12 tyg.'**
  String get guideFertSlowEvery;

  /// No description provided for @guideFertFastWorks.
  ///
  /// In pl, this message translates to:
  /// **'4–6 tyg.'**
  String get guideFertFastWorks;

  /// No description provided for @guideFertFastEvery.
  ///
  /// In pl, this message translates to:
  /// **'4–6 tyg.'**
  String get guideFertFastEvery;

  /// No description provided for @guideFertLiquidWorks.
  ///
  /// In pl, this message translates to:
  /// **'1–2 tyg.'**
  String get guideFertLiquidWorks;

  /// No description provided for @guideFertLiquidEvery.
  ///
  /// In pl, this message translates to:
  /// **'2–3 tyg.'**
  String get guideFertLiquidEvery;

  /// No description provided for @guideFertOrganicWorks.
  ///
  /// In pl, this message translates to:
  /// **'2–3 mies.'**
  String get guideFertOrganicWorks;

  /// No description provided for @guideFertOrganicEvery.
  ///
  /// In pl, this message translates to:
  /// **'2–3 razy w sezonie'**
  String get guideFertOrganicEvery;

  /// No description provided for @guideFertHowTitle.
  ///
  /// In pl, this message translates to:
  /// **'Jak nawozić'**
  String get guideFertHowTitle;

  /// No description provided for @guideFertHow.
  ///
  /// In pl, this message translates to:
  /// **'Na suchą trawę, najlepiej przed lekkim deszczem. Inaczej podlej.\nSiewnikiem, w dwóch przejściach na krzyż, po pół dawki.\nNie w upale powyżej 25°C i nie przed ulewą.\nOd października bez azotu, tylko nawóz jesienny.'**
  String get guideFertHow;

  /// No description provided for @guideFertNote.
  ///
  /// In pl, this message translates to:
  /// **'Proporcje N-P-K w tabeli są przykładowe. Dawkę na m² zawsze bierz z etykiety nawozu.'**
  String get guideFertNote;

  /// No description provided for @guideMowRuleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zasada 1/3'**
  String get guideMowRuleLabel;

  /// No description provided for @guideMowRuleTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ścinaj najwyżej jedną trzecią wysokości'**
  String get guideMowRuleTitle;

  /// No description provided for @guideMowRhythmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Rytm w sezonie'**
  String get guideMowRhythmTitle;

  /// No description provided for @guideColHeight.
  ///
  /// In pl, this message translates to:
  /// **'Wysokość'**
  String get guideColHeight;

  /// No description provided for @guideMowSeason1.
  ///
  /// In pl, this message translates to:
  /// **'Kwiecień'**
  String get guideMowSeason1;

  /// No description provided for @guideMowSeason1Every.
  ///
  /// In pl, this message translates to:
  /// **'Gdy ma ok. 8 cm'**
  String get guideMowSeason1Every;

  /// No description provided for @guideMowSeason1Height.
  ///
  /// In pl, this message translates to:
  /// **'Pierwsze cięcie tylko o 1–2 cm'**
  String get guideMowSeason1Height;

  /// No description provided for @guideMowSeason2.
  ///
  /// In pl, this message translates to:
  /// **'Maj–czerwiec'**
  String get guideMowSeason2;

  /// No description provided for @guideMowSeason2Every.
  ///
  /// In pl, this message translates to:
  /// **'Co 4–7 dni'**
  String get guideMowSeason2Every;

  /// No description provided for @guideMowSeason2Height.
  ///
  /// In pl, this message translates to:
  /// **'Docelowa'**
  String get guideMowSeason2Height;

  /// No description provided for @guideMowSeason3.
  ///
  /// In pl, this message translates to:
  /// **'Lipiec–sierpień'**
  String get guideMowSeason3;

  /// No description provided for @guideMowSeason3Every.
  ///
  /// In pl, this message translates to:
  /// **'Co 7–10 dni'**
  String get guideMowSeason3Every;

  /// No description provided for @guideMowSeason3Height.
  ///
  /// In pl, this message translates to:
  /// **'O 1 cm wyżej w upał'**
  String get guideMowSeason3Height;

  /// No description provided for @guideMowSeason4.
  ///
  /// In pl, this message translates to:
  /// **'Wrzesień–listopad'**
  String get guideMowSeason4;

  /// No description provided for @guideMowSeason4Every.
  ///
  /// In pl, this message translates to:
  /// **'Co 7–14 dni, aż przestanie rosnąć'**
  String get guideMowSeason4Every;

  /// No description provided for @guideMowSeason4Height.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie cięcie na ok. 5 cm'**
  String get guideMowSeason4Height;

  /// No description provided for @guideMowHabitsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dobre nawyki'**
  String get guideMowHabitsTitle;

  /// No description provided for @guideMowHabits.
  ///
  /// In pl, this message translates to:
  /// **'Ostre noże. Tępe szarpią źdźbła i końcówki brązowieją.\nTylko sucha trawa, bez porannej rosy i nie w największy upał.\nZmieniaj kierunek koszenia, żeby trawa nie kładła się w jedną stronę.\nMulczowanie oddaje trawnikowi azot, ale tylko przy regularnym koszeniu suchej trawy.'**
  String get guideMowHabits;

  /// No description provided for @guideMowToday.
  ///
  /// In pl, this message translates to:
  /// **'Kiedy dziś kosić?'**
  String get guideMowToday;

  /// No description provided for @guideMowTodaySub.
  ///
  /// In pl, this message translates to:
  /// **'Dobre godziny mają zieloną ramkę w prognozie dnia'**
  String get guideMowTodaySub;

  /// No description provided for @guideMixHowTitle.
  ///
  /// In pl, this message translates to:
  /// **'Jak dobrać'**
  String get guideMixHowTitle;

  /// No description provided for @guideMixListTitle.
  ///
  /// In pl, this message translates to:
  /// **'Mieszanki i wysokość koszenia'**
  String get guideMixListTitle;

  /// No description provided for @guideMixWhenUniversal.
  ///
  /// In pl, this message translates to:
  /// **'Słońce, dzieci, pies'**
  String get guideMixWhenUniversal;

  /// No description provided for @guideMixWhenOrnamental.
  ///
  /// In pl, this message translates to:
  /// **'Reprezentacyjny, mało deptany'**
  String get guideMixWhenOrnamental;

  /// No description provided for @guideMixWhenShade.
  ///
  /// In pl, this message translates to:
  /// **'Pod drzewami, 3–4 h słońca'**
  String get guideMixWhenShade;

  /// No description provided for @guideMixWhenDrought.
  ///
  /// In pl, this message translates to:
  /// **'Piasek, rzadkie podlewanie'**
  String get guideMixWhenDrought;

  /// No description provided for @guideMixShort.
  ///
  /// In pl, this message translates to:
  /// **'{mix, select, universal{Uniwersalna} ornamental{Ozdobna} shade{Do cienia} drought{Na suszę} sport{Sportowa} other{}}'**
  String guideMixShort(String mix);

  /// No description provided for @guideMixText.
  ///
  /// In pl, this message translates to:
  /// **'{mix, select, universal{Odporna na deptanie, dla rodzin i zwierząt} ornamental{Gęsta i niska, kosić nawet co 3–5 dni} shade{Koszona wyżej, żeby łapała więcej światła} drought{Głębokie korzenie, wysoka trawa chroni glebę} sport{Najszybciej się odradza po intensywnym użytkowaniu} other{}}'**
  String guideMixText(String mix);

  /// No description provided for @guideMixSpecies.
  ///
  /// In pl, this message translates to:
  /// **'{mix, select, universal{Życica trwała, kostrzewa czerwona, wiechlina łąkowa} ornamental{Kostrzewa czerwona, mietlica pospolita, wiechlina łąkowa} shade{Kostrzewa czerwona, wiechlina gajowa, śmiałek darniowy} drought{Kostrzewa trzcinowa, kostrzewa owcza, kostrzewa czerwona} sport{Życica trwała, wiechlina łąkowa} other{}}'**
  String guideMixSpecies(String mix);

  /// No description provided for @guideSeedsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ile nasion?'**
  String get guideSeedsTitle;

  /// No description provided for @guideSeedsText.
  ///
  /// In pl, this message translates to:
  /// **'Nowy trawnik 25–35 g/m², dosiewka 15–20 g/m². Do dosiewki wybierz tę samą mieszankę, co trawnik.'**
  String get guideSeedsText;

  /// No description provided for @guideCm.
  ///
  /// In pl, this message translates to:
  /// **'cm'**
  String get guideCm;

  /// No description provided for @guideNowInSeason.
  ///
  /// In pl, this message translates to:
  /// **'Teraz w sezonie · {month}'**
  String guideNowInSeason(String month);

  /// No description provided for @guidePlanOn.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanuj na {month}'**
  String guidePlanOn(String month);

  /// No description provided for @guideAskQuestion.
  ///
  /// In pl, this message translates to:
  /// **'Czy mój trawnik potrzebuje teraz zabiegu: {topic}? Kiedy najlepiej go zrobić?'**
  String guideAskQuestion(String topic);

  /// No description provided for @guideMowRuleText.
  ///
  /// In pl, this message translates to:
  /// **'Trzymaj {height} cm i koś, gdy trawa ma około {max} cm.'**
  String guideMowRuleText(String height, String max);

  /// No description provided for @quickScarifyYoung.
  ///
  /// In pl, this message translates to:
  /// **'Jeszcze nie. Twój trawnik jest za młody: wertykulację robi się najwcześniej 2 lata po siewie albo rok po położeniu rolki.'**
  String get quickScarifyYoung;

  /// No description provided for @guideTooYoung.
  ///
  /// In pl, this message translates to:
  /// **'Twój trawnik jest jeszcze za młody na ten zabieg. Bezpiecznie będzie od: {date}.'**
  String guideTooYoung(String date);

  /// No description provided for @guideTooYoungTitle.
  ///
  /// In pl, this message translates to:
  /// **'Za młody trawnik'**
  String get guideTooYoungTitle;

  /// No description provided for @addTooYoung.
  ///
  /// In pl, this message translates to:
  /// **'Trawnik jest za młody na zabieg „{kind}”. Darń musi się najpierw dobrze ukorzenić: bezpiecznie będzie od {date}.'**
  String addTooYoung(String kind, String date);

  /// No description provided for @addMoveToReady.
  ///
  /// In pl, this message translates to:
  /// **'Przenieś na {date}'**
  String addMoveToReady(String date);

  /// No description provided for @noticeFrostTitle.
  ///
  /// In pl, this message translates to:
  /// **'Uwaga na przymrozek'**
  String get noticeFrostTitle;

  /// No description provided for @noticeFrostBody.
  ///
  /// In pl, this message translates to:
  /// **'{day} do {temp}°C. Wstrzymaj nawożenie i wyłącz automatyczne podlewanie.'**
  String noticeFrostBody(String day, int temp);

  /// No description provided for @noticeHeatTitle.
  ///
  /// In pl, this message translates to:
  /// **'Upał'**
  String get noticeHeatTitle;

  /// No description provided for @noticeHeatBody.
  ///
  /// In pl, this message translates to:
  /// **'{day} do {temp}°C. Podlewaj rano i nie kosz trawy.'**
  String noticeHeatBody(String day, int temp);

  /// No description provided for @noticeDownpourTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ulewa'**
  String get noticeDownpourTitle;

  /// No description provided for @noticeDownpourBody.
  ///
  /// In pl, this message translates to:
  /// **'{day} ok. {mm} mm deszczu. Nie nawoź przed opadem.'**
  String noticeDownpourBody(String day, String mm);

  /// No description provided for @noticeMovedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nawożenie przeniesione na {day}'**
  String noticeMovedTitle(String day);

  /// No description provided for @noticeMovedBody.
  ///
  /// In pl, this message translates to:
  /// **'Wybraliśmy lepszy dzień w oknie nawożenia.'**
  String get noticeMovedBody;

  /// No description provided for @noticeStaleTitle.
  ///
  /// In pl, this message translates to:
  /// **'Prognoza sprzed {hours, plural, =1{1 godziny} other{{hours} godzin}}'**
  String noticeStaleTitle(int hours);

  /// No description provided for @noticeStaleBody.
  ///
  /// In pl, this message translates to:
  /// **'Rady mogą być mniej trafne. Odświeżymy po połączeniu.'**
  String get noticeStaleBody;

  /// No description provided for @noticeToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś'**
  String get noticeToday;

  /// No description provided for @noticeTomorrow.
  ///
  /// In pl, this message translates to:
  /// **'Jutro'**
  String get noticeTomorrow;

  /// No description provided for @notifFertilizeIdealTitle.
  ///
  /// In pl, this message translates to:
  /// **'Idealny dzień do nawożenia'**
  String get notifFertilizeIdealTitle;

  /// No description provided for @notifFertilizeTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dziś nawożenie'**
  String get notifFertilizeTitle;

  /// No description provided for @notifFertilizeBody.
  ///
  /// In pl, this message translates to:
  /// **'Dzień {cycleDay} z {interval}. Sprawdź prognozę przed rozsypaniem nawozu.'**
  String notifFertilizeBody(int cycleDay, int interval);

  /// No description provided for @notifFertilizeFallbackBody.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz plan, żeby zobaczyć szczegóły.'**
  String get notifFertilizeFallbackBody;

  /// No description provided for @notifProgramTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dziś krok programu nawożenia'**
  String get notifProgramTitle;

  /// No description provided for @notifProgramRain.
  ///
  /// In pl, this message translates to:
  /// **'Zapowiadany deszcz: {mm} mm. Rozważ przesunięcie terminu, żeby nawóz się nie wypłukał.'**
  String notifProgramRain(int mm);

  /// No description provided for @notifMowingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Czas na koszenie'**
  String get notifMowingTitle;

  /// No description provided for @notifMowingBody.
  ///
  /// In pl, this message translates to:
  /// **'Trawa jest gotowa na koszenie. Sprawdź wysokość cięcia.'**
  String get notifMowingBody;

  /// No description provided for @notifWateringTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podlewanie'**
  String get notifWateringTitle;

  /// No description provided for @notifWateringBody.
  ///
  /// In pl, this message translates to:
  /// **'Dziś bez deszczu, trawnik potrzebuje wody.'**
  String get notifWateringBody;

  /// No description provided for @notifTaskTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanowany zabieg'**
  String get notifTaskTitle;

  /// No description provided for @notifTaskBody.
  ///
  /// In pl, this message translates to:
  /// **'Masz dziś zabieg w kalendarzu.'**
  String get notifTaskBody;

  /// No description provided for @notifSettingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia'**
  String get notifSettingsTitle;

  /// No description provided for @notifSettingsIntro.
  ///
  /// In pl, this message translates to:
  /// **'Najwyżej jedno dziennie. Wyjątek to ostrzeżenie o pogodzie dzień wcześniej. Cisza nocna od 21:00 do 7:00.'**
  String get notifSettingsIntro;

  /// No description provided for @notifSettingsEnable.
  ///
  /// In pl, this message translates to:
  /// **'Włącz powiadomienia'**
  String get notifSettingsEnable;

  /// No description provided for @notifSettingsDenied.
  ///
  /// In pl, this message translates to:
  /// **'Zezwól na powiadomienia w ustawieniach telefonu.'**
  String get notifSettingsDenied;

  /// No description provided for @notifSettingsHour.
  ///
  /// In pl, this message translates to:
  /// **'Pora poranna'**
  String get notifSettingsHour;

  /// No description provided for @notifSettingsHourValue.
  ///
  /// In pl, this message translates to:
  /// **'{hour}:00'**
  String notifSettingsHourValue(int hour);

  /// No description provided for @notifSettingsFertilizing.
  ///
  /// In pl, this message translates to:
  /// **'Nawożenie'**
  String get notifSettingsFertilizing;

  /// No description provided for @notifSettingsWatering.
  ///
  /// In pl, this message translates to:
  /// **'Podlewanie'**
  String get notifSettingsWatering;

  /// No description provided for @notifSettingsCare.
  ///
  /// In pl, this message translates to:
  /// **'Koszenie i zabiegi'**
  String get notifSettingsCare;

  /// No description provided for @notifSettingsWarnings.
  ///
  /// In pl, this message translates to:
  /// **'Ostrzeżenia pogodowe'**
  String get notifSettingsWarnings;

  /// No description provided for @notifSettingsOff.
  ///
  /// In pl, this message translates to:
  /// **'Wyłączone'**
  String get notifSettingsOff;

  /// No description provided for @notifSettingsOn.
  ///
  /// In pl, this message translates to:
  /// **'Włączone od {hour}:00'**
  String notifSettingsOn(int hour);

  /// No description provided for @notifPlanChangedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana planu'**
  String get notifPlanChangedTitle;

  /// No description provided for @notifPlanChangedBody.
  ///
  /// In pl, this message translates to:
  /// **'Nawożenie przeniesione na {date}.'**
  String notifPlanChangedBody(String date);

  /// No description provided for @homeOffSeasonTitle.
  ///
  /// In pl, this message translates to:
  /// **'Trawnik odpoczywa'**
  String get homeOffSeasonTitle;

  /// No description provided for @homeDoneNextWindow.
  ///
  /// In pl, this message translates to:
  /// **'Zapisane w dzienniku. Następne okno: {range}.'**
  String homeDoneNextWindow(String range);

  /// No description provided for @notifSeasonTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zaczyna się sezon'**
  String get notifSeasonTitle;

  /// No description provided for @notifSeasonBody.
  ///
  /// In pl, this message translates to:
  /// **'Plan prac na nowy sezon jest gotowy.'**
  String get notifSeasonBody;

  /// No description provided for @programsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Programy nawożenia'**
  String get programsTitle;

  /// No description provided for @programsOff.
  ///
  /// In pl, this message translates to:
  /// **'Wyłączone'**
  String get programsOff;

  /// No description provided for @programsIntro.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe harmonogramy producentów nawozów. Po włączeniu zabiegi trafiają do kalendarza z produktem i dawką dla Twojej powierzchni. Zastępują wtedy standardowy plan nawożenia.'**
  String get programsIntro;

  /// No description provided for @programsActive.
  ///
  /// In pl, this message translates to:
  /// **'Aktywny'**
  String get programsActive;

  /// No description provided for @programsEnable.
  ///
  /// In pl, this message translates to:
  /// **'Włącz program'**
  String get programsEnable;

  /// No description provided for @programsDisable.
  ///
  /// In pl, this message translates to:
  /// **'Wyłącz program'**
  String get programsDisable;

  /// No description provided for @programsEnabled.
  ///
  /// In pl, this message translates to:
  /// **'Program włączony. Zabiegi są w kalendarzu.'**
  String get programsEnabled;

  /// No description provided for @programsDisabled.
  ///
  /// In pl, this message translates to:
  /// **'Program wyłączony. Wrócił standardowy plan nawożenia.'**
  String get programsDisabled;

  /// No description provided for @programsSource.
  ///
  /// In pl, this message translates to:
  /// **'Źródło: {brand} ({site}). Programy i dawki są przykładowe, zawsze sprawdź etykietę produktu.'**
  String programsSource(String brand, String site);

  /// No description provided for @programsWindow.
  ///
  /// In pl, this message translates to:
  /// **'{from}–{to}'**
  String programsWindow(String from, String to);

  /// No description provided for @programsDose.
  ///
  /// In pl, this message translates to:
  /// **'{dose} g/m²'**
  String programsDose(String dose);

  /// No description provided for @programsFixedNote.
  ///
  /// In pl, this message translates to:
  /// **'Terminy programu są stałe. Pogoda nie przesuwa ich, najwyżej ostrzega.'**
  String get programsFixedNote;

  /// No description provided for @programsCustomTitle.
  ///
  /// In pl, this message translates to:
  /// **'Własne plany'**
  String get programsCustomTitle;

  /// No description provided for @programsCreate.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz własny plan'**
  String get programsCreate;

  /// No description provided for @programsEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get programsEdit;

  /// No description provided for @programsDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get programsDelete;

  /// No description provided for @programsDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Plan usunięty.'**
  String get programsDeleted;

  /// No description provided for @customSummary.
  ///
  /// In pl, this message translates to:
  /// **'{product}, {dose} g/m², co {days}'**
  String customSummary(String product, int dose, String days);

  /// No description provided for @customFormTitle.
  ///
  /// In pl, this message translates to:
  /// **'Własny plan nawożenia'**
  String get customFormTitle;

  /// No description provided for @customName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa planu'**
  String get customName;

  /// No description provided for @customProduct.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa nawozu'**
  String get customProduct;

  /// No description provided for @customDose.
  ///
  /// In pl, this message translates to:
  /// **'Dawka (g/m²)'**
  String get customDose;

  /// No description provided for @customInterval.
  ///
  /// In pl, this message translates to:
  /// **'Co ile dni'**
  String get customInterval;

  /// No description provided for @customStart.
  ///
  /// In pl, this message translates to:
  /// **'Pierwsze nawożenie'**
  String get customStart;

  /// No description provided for @customSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz plan'**
  String get customSave;

  /// No description provided for @customInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę nawozu, dawkę i odstęp w dniach.'**
  String get customInvalid;

  /// No description provided for @programsControlsDates.
  ///
  /// In pl, this message translates to:
  /// **'Terminy nawożenia ustawia program: {name}. Odstęp między zabiegami nie jest teraz używany.'**
  String programsControlsDates(String name);
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'pl':
      return L10nPl();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
