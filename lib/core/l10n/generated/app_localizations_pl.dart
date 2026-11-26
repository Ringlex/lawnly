// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class L10nPl extends L10n {
  L10nPl([String locale = 'pl']) : super(locale);

  @override
  String get appTagline => 'Właściwy zabieg we właściwym dniu';

  @override
  String get splashChecking => 'Sprawdzam prognozę pogody…';

  @override
  String get commonNext => 'Dalej';

  @override
  String get commonBack => 'Wstecz';

  @override
  String get commonDontKnow => 'Nie wiem';

  @override
  String get commonOptional => '(opcjonalnie)';

  @override
  String get commonLess => 'Mniej dni';

  @override
  String get commonMore => 'Więcej dni';

  @override
  String get commonRetry => 'Spróbuj ponownie';

  @override
  String get routeNotFoundTitle => 'Nie ma takiej strony';

  @override
  String get routeNotFoundAction => 'Wróć na start';

  @override
  String get commonMinutes => 'min';

  @override
  String get commonSquareMeters => 'm²';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni',
      one: '1 dzień',
    );
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Pn',
      'tue': 'Wt',
      'wed': 'Śr',
      'thu': 'Cz',
      'fri': 'Pt',
      'sat': 'Sb',
      'sun': 'Nd',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String onboardingStep(int step, int total) {
    return 'Krok $step z $total';
  }

  @override
  String get onboardingFinish => 'Utwórz mój plan';

  @override
  String get onboardingSkipRest => 'Utwórz plan teraz, resztę uzupełnię później';

  @override
  String get onboardingSaveError => 'Nie udało się zapisać. Spróbuj ponownie.';

  @override
  String get locationTitle => 'Poznajmy Twój trawnik';

  @override
  String get locationBody =>
      'Bez zakładania konta. Wszystkie dane zostają w aplikacji, a lokalizacja służy tylko do pobierania prognozy pogody.';

  @override
  String get locationNameLabel => 'Nazwa trawnika';

  @override
  String get locationNameHint => 'np. Przed domem';

  @override
  String get locationLabel => 'Lokalizacja';

  @override
  String get locationUseMine => 'Użyj mojej lokalizacji';

  @override
  String get locationOr => 'lub';

  @override
  String get locationCityHint => 'Wpisz miejscowość';

  @override
  String get locationCurrent => 'Bieżąca lokalizacja';

  @override
  String get locationTip =>
      'Dokładna lokalizacja trawnika poprawia trafność rad, bo deszcz w mieście nie zawsze pada nad Twoim ogrodem.';

  @override
  String get locationServiceDisabled =>
      'Włącz usługi lokalizacji w telefonie albo wpisz miejscowość.';

  @override
  String get locationPermissionDenied => 'Bez zgody na lokalizację wpisz miejscowość ręcznie.';

  @override
  String get locationNotFound => 'Nie znalazłem takiej miejscowości.';

  @override
  String get locationNetwork => 'Brak połączenia z internetem. Spróbuj ponownie.';

  @override
  String get basicsTitle => 'Podstawowe dane';

  @override
  String get basicsBody => 'Wiek trawnika decyduje, kiedy można robić wertykulację czy aerację.';

  @override
  String get basicsAreaLabel => 'Powierzchnia';

  @override
  String get basicsAreaHelper => 'Potrzebne do wyliczenia dawki nawozu i nasion.';

  @override
  String get basicsEstablishedLabel => 'Data założenia trawnika';

  @override
  String get basicsEstablishedHint => 'Wybierz miesiąc i rok';

  @override
  String get basicsEstablishedHelper => 'Wystarczy miesiąc i rok.';

  @override
  String basicsLawnAge(int seasons) {
    String _temp0 = intl.Intl.pluralLogic(
      seasons,
      locale: localeName,
      other: 'ok. $seasons sezonów',
      few: 'ok. $seasons sezony',
      one: 'ok. 1 sezon',
      zero: 'pierwszy sezon',
    );
    return 'Wystarczy miesiąc i rok. Wiek trawnika: $_temp0.';
  }

  @override
  String get basicsMethodLabel => 'Sposób założenia';

  @override
  String get basicsMethodSeeded => 'Z siewu';

  @override
  String get basicsMethodSod => 'Z rolki';

  @override
  String get basicsSunLabel => 'Nasłonecznienie';

  @override
  String get basicsSunFull => 'Słońce';

  @override
  String get basicsSunPartial => 'Półcień';

  @override
  String get basicsSunShade => 'Cień';

  @override
  String get soilTitle => 'Mieszanka i gleba';

  @override
  String get soilBody => 'Nie wiesz? Wybierz „nie wiem”, uzupełnisz później.';

  @override
  String get soilMixLabel => 'Mieszanka traw';

  @override
  String get soilMixUniversal => 'Uniwersalna / rekreacyjna';

  @override
  String get soilMixUniversalHint => 'Odporna na deptanie, dla rodzin i zwierząt';

  @override
  String get soilMixOrnamental => 'Ozdobna / parterowa';

  @override
  String get soilMixOrnamentalHint => 'Gęsta, niskie koszenie, wymagająca';

  @override
  String get soilMixShade => 'Do cienia';

  @override
  String get soilMixDrought => 'Na suszę';

  @override
  String get soilMixSport => 'Sportowa';

  @override
  String get soilTypeLabel => 'Rodzaj gleby';

  @override
  String get soilTypeSandy => 'Piaszczysta';

  @override
  String get soilTypeMedium => 'Średnia';

  @override
  String get soilTypeClay => 'Gliniasta';

  @override
  String get soilPhLabel => 'pH gleby';

  @override
  String get soilPhHint => 'np. 6,2 z testu paskowego';

  @override
  String get soilPhError => 'Podaj wartość od 3 do 9.';

  @override
  String get careTitle => 'Podlewanie i koszenie';

  @override
  String get careWateringLabel => 'Jak podlewasz?';

  @override
  String get careWateringAuto => 'Automatycznie';

  @override
  String get careWateringManual => 'Ręcznie';

  @override
  String get careSectionTime => 'Czas pracy jednej sekcji';

  @override
  String get careSectionHelper =>
      'Ile to milimetrów wody, zmierzymy później prostym testem z kubeczkiem.';

  @override
  String get careManualHelper => 'Podpowiemy, kiedy podlać i ile wody dać.';

  @override
  String get careMowingLabel => 'Koszenie co';

  @override
  String get careLastMowedLabel => 'Ostatnie koszenie';

  @override
  String get careGardenDaysLabel => 'Kiedy masz czas na ogród?';

  @override
  String get careGardenDaysHelper => 'Zabiegi zaplanujemy na najlepszy z tych dni.';

  @override
  String get feedTitle => 'Nawożenie';

  @override
  String get feedBody => 'Podaj, jak nawozisz. Dzień wybierzemy sami, gdy pogoda będzie sprzyjać.';

  @override
  String get feedIntervalLabel => 'Nawożę co';

  @override
  String get feedWindowLabel => 'Elastyczne okno';

  @override
  String feedWindowRange(int start, int end) {
    return '$start–$end dzień';
  }

  @override
  String feedWindowHelper(int interval) {
    return 'Jeśli warunki będą idealne, powiadomimy Cię wcześniej lub później niż $interval. dnia.';
  }

  @override
  String get feedLastLabel => 'Ostatnie nawożenie';

  @override
  String get feedLastHint => 'Wybierz datę';

  @override
  String get feedLastUnknown => 'Nie pamiętam';

  @override
  String get homeBadgeIdeal => 'Idealny dzień';

  @override
  String homeCycleDay(int day, int interval) {
    return 'dzień $day z $interval';
  }

  @override
  String homeRainFrom(int hour, String mm) {
    return 'Od $hour:00 lekki deszcz, ok. $mm mm, wmyje nawóz';
  }

  @override
  String homeRain(String mm) {
    return 'Lekki deszcz, ok. $mm mm, wmyje nawóz';
  }

  @override
  String get homeNoRain => 'Bez deszczu: podlej trawnik po nawożeniu';

  @override
  String homeSeason(String season) {
    String _temp0 = intl.Intl.selectLogic(season, {
      'spring': 'Wiosną: nawóz z przewagą azotu.',
      'summer': 'Latem: mniejsze dawki, nie nawoź w upał.',
      'autumn': 'Jesienią: nawóz z przewagą potasu.',
      'other': 'Zimą trawnik odpoczywa, nawożenie wstrzymane.',
    });
    return '$_temp0';
  }

  @override
  String get homeDone => 'Zrobione';

  @override
  String homeDoneSnack(int interval) {
    return 'Zapisane. Następne nawożenie za ok. $interval dni.';
  }

  @override
  String get homePostponedSnack => 'Szukam innego dnia w oknie nawożenia.';

  @override
  String get homeTodayWork => 'Dziś do zrobienia';

  @override
  String get homeNothingToday => 'Dziś nie ma prac w ogrodzie.';

  @override
  String homeSeasonOver(String date) {
    return 'Sezon na trawniku zakończony. Trawa odpoczywa, plan prac wróci $date.';
  }

  @override
  String get homeBadgeToday => 'Dziś';

  @override
  String get homeBadgeNext => 'Najbliższe prace';

  @override
  String get homePostponeFertilizing => 'Przesuń nawożenie';

  @override
  String get homeDoneGeneric => 'Zapisane jako zrobione.';

  @override
  String get homeMarkDone => 'Oznacz jako zrobione';

  @override
  String get homeNextDays => 'Najbliższe dni';

  @override
  String get homeCalendar => 'Kalendarz';

  @override
  String homeRainMm(String mm) {
    return '$mm mm';
  }

  @override
  String homeTemperatureShort(int temp) {
    return '$temp°';
  }

  @override
  String get homeWateringNotNeeded => 'Podlewanie: niepotrzebne';

  @override
  String get homeWateringNeeded => 'Podlewanie: potrzebne';

  @override
  String get homeWateringRain => 'Bilans wody w normie, deszcz zrobi swoje';

  @override
  String get homeWateringCool => 'Chłodno, trawnik zużywa mało wody';

  @override
  String homeWateringAuto(int minutes) {
    return 'Zraszacz: $minutes min na sekcję, wcześnie rano';
  }

  @override
  String homeWateringManual(int litres) {
    return 'Podlej wcześnie rano, ok. $litres l wody na każdy m²';
  }

  @override
  String get homeLoadError => 'Nie udało się wczytać prognozy pogody.';

  @override
  String get homeBadgePinned => 'Przypięte';

  @override
  String careKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'fertilizing': 'Nawożenie',
      'mowing': 'Koszenie',
      'watering': 'Podlewanie',
      'aeration': 'Aeracja',
      'scarification': 'Wertykulacja',
      'overseeding': 'Dosiewanie',
      'liming': 'Wapnowanie',
      'other': 'Inny',
    });
    return '$_temp0';
  }

  @override
  String get calendarTitle => 'Kalendarz';

  @override
  String get calendarAdd => 'Dodaj zabieg';

  @override
  String get calendarPrevMonth => 'Poprzedni miesiąc';

  @override
  String get calendarNextMonth => 'Następny miesiąc';

  @override
  String get calendarLegendOwn => 'Twój zabieg';

  @override
  String get calendarLegendWindow => 'Okno nawożenia';

  @override
  String get calendarLegendTentative => 'Termin wstępny, bez prognozy';

  @override
  String calendarToday(String date) {
    return 'Dziś, $date';
  }

  @override
  String get calendarEmptyDay => 'Brak zabiegów tego dnia.';

  @override
  String weatherRainFrom(int temp, int hour) {
    return '$temp°, deszcz od $hour:00';
  }

  @override
  String weatherRain(int temp, String mm) {
    return '$temp°, $mm mm deszczu';
  }

  @override
  String weatherDry(int temp) {
    return '$temp°, sucho';
  }

  @override
  String get entryDone => 'Zrobione';

  @override
  String entryTentative(String start, String end) {
    return 'Termin wstępny · okno $start–$end';
  }

  @override
  String get entryPinned => 'Przypięte';

  @override
  String entryEvery(String days) {
    return 'Co $days';
  }

  @override
  String get entryBeforeRain => 'Rano, zanim zacznie padać';

  @override
  String get entryOwn => 'Twój zabieg';

  @override
  String entryMoved(String date) {
    return 'Przesunięte z $date przez pogodę';
  }

  @override
  String sheetFromPlan(String days) {
    return 'Z Twojego planu, co $days';
  }

  @override
  String get sheetTagTentative => 'Termin wstępny';

  @override
  String get sheetTagMatched => 'Dopasowane do pogody';

  @override
  String get sheetTagFixed => 'Stały termin';

  @override
  String sheetWindow(String start, String end, int from, int to) {
    return 'Okno nawożenia: $start–$end, czyli $from.–$to. dzień od poprzedniego nawożenia.';
  }

  @override
  String sheetForecastLater(String date) {
    return 'Prognoza obejmie to okno ok. $date. Wtedy wybierzemy najlepszy z Twoich dni.';
  }

  @override
  String get sheetNextCycle => 'Dokładny termin ustalimy po poprzednim nawożeniu.';

  @override
  String sheetMowing(String days) {
    return 'Koszenie co $days, w Twoje dni na ogród.';
  }

  @override
  String get sheetFlexible => 'Przesuniemy zabieg najwyżej o 2 dni, jeśli pogoda będzie lepsza.';

  @override
  String get sheetFixed => 'Stały termin, nie przesuwamy go.';

  @override
  String sheetPin(String date) {
    return 'Przypnij do $date';
  }

  @override
  String get sheetPinHelper => 'Przypiętego dnia nie przesuniemy, ale ostrzeżemy przed złą pogodą.';

  @override
  String get sheetUnpin => 'Dopasuj do pogody';

  @override
  String get sheetChangeDate => 'Zmień termin';

  @override
  String get sheetSkipCycle => 'Pomiń ten cykl';

  @override
  String get sheetDelete => 'Usuń';

  @override
  String get sheetRemove => 'Usuń z kalendarza';

  @override
  String get sheetRemoved => 'Usunięto z kalendarza.';

  @override
  String get sheetUndo => 'Cofnij';

  @override
  String get sheetClose => 'Zamknij';

  @override
  String get addTitle => 'Nowy zabieg';

  @override
  String get addEditTitle => 'Zmień zabieg';

  @override
  String get addKind => 'Rodzaj';

  @override
  String get addDate => 'Termin';

  @override
  String get addFlexLabel => 'Gdy pogoda się zmieni';

  @override
  String get addKeepDay => 'Trzymaj ten dzień';

  @override
  String get addFitWeather => 'Dopasuj do pogody';

  @override
  String get addFlexHelper => 'Przesuniemy zabieg najwyżej o 2 dni i damy Ci znać.';

  @override
  String get addNote => 'Notatka';

  @override
  String get addNoteHint => 'np. pożyczyć aerator od sąsiada';

  @override
  String get addSave => 'Zapisz w kalendarzu';

  @override
  String get addNoForecast => 'Prognozy na ten dzień jeszcze nie ma. Sprawdzimy ją bliżej terminu.';

  @override
  String addGoodWeather(String date, String weather) {
    return '$date: $weather. Pogoda sprzyja.';
  }

  @override
  String addBadWeather(String date, String weather, String hint) {
    return '$date: $weather. $hint';
  }

  @override
  String addMoveTo(String date, String weather) {
    return 'Przenieś na $date · $weather';
  }

  @override
  String careWeatherHint(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'fertilizing': 'Pogoda nie sprzyja nawożeniu.',
      'mowing': 'Mokra trawa źle się kosi.',
      'watering': 'Deszcz podleje trawnik za Ciebie.',
      'aeration': 'Mokra gleba oblepia kolce aeratora.',
      'scarification': 'Wertykulację rób na suchym trawniku.',
      'overseeding': 'Ulewa albo upał zaszkodzą nasionom.',
      'liming': 'Wapno rozsiewaj bez silnego wiatru i ulewy.',
      'other': 'Pogoda tego dnia nie sprzyja.',
    });
    return '$_temp0';
  }

  @override
  String get sheetStripPlan => 'plan';

  @override
  String get sheetStripBusy => 'bez czasu';

  @override
  String get sheetTagPinned => 'Przypięte';

  @override
  String get weatherOpen => 'Prognoza na 14 dni';

  @override
  String get weatherTitle => 'Pogoda';

  @override
  String get weatherNow => 'Teraz';

  @override
  String weatherWind(int speed) {
    return 'Wiatr $speed km/h';
  }

  @override
  String weatherTodayRange(int max, int min) {
    return 'Dziś $max° / $min°';
  }

  @override
  String weatherRainChance(int chance) {
    return 'Szansa opadu $chance%';
  }

  @override
  String get weatherDays => 'Najbliższe 14 dni';

  @override
  String get weatherLessCertain => 'Dalsze dni: prognoza mniej pewna';

  @override
  String get weatherToday => 'Dziś';

  @override
  String get weatherTomorrow => 'Jutro';

  @override
  String weatherMinMax(int max, int min) {
    return '$max° / $min°';
  }

  @override
  String get weatherSource => 'Dane pogodowe: MET Norway (met.no)';

  @override
  String get dayHourly => 'Godzina po godzinie';

  @override
  String get dayNoForecast => 'Prognoza na ten dzień jeszcze niedostępna.';

  @override
  String get dayPlanned => 'Zaplanowane prace';

  @override
  String get dayMowingLegend => 'Dobra pora na koszenie: sucha trawa, bez rosy i upału';

  @override
  String dayWindMax(int speed) {
    return 'Wiatr do $speed km/h';
  }

  @override
  String get journalTitle => 'Dziennik';

  @override
  String get journalAdd => 'Dodaj wpis';

  @override
  String journalSeason(int year) {
    return 'Sezon $year';
  }

  @override
  String get journalSummary => 'Podsumowanie';

  @override
  String journalMowings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'koszeń',
      many: 'koszeń',
      few: 'koszenia',
      one: 'koszenie',
    );
    return '$_temp0';
  }

  @override
  String journalFertilizings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nawożeń',
      many: 'nawożeń',
      few: 'nawożenia',
      one: 'nawożenie',
    );
    return '$_temp0';
  }

  @override
  String journalWaterings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'podlewań',
      many: 'podlewań',
      few: 'podlewania',
      one: 'podlewanie',
    );
    return '$_temp0';
  }

  @override
  String get journalFilterAll => 'Wszystko';

  @override
  String get journalFilterNotes => 'Notatki';

  @override
  String get journalFilterPhotos => 'Zdjęcia';

  @override
  String get journalEmpty =>
      'Dziennik jest pusty. Wpisy pojawią się, gdy oznaczysz zabieg jako zrobiony albo dodasz notatkę.';

  @override
  String get journalFilterEmpty => 'Brak wpisów tego rodzaju.';

  @override
  String journalKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'observation': 'Obserwacja',
      'photo': 'Zdjęcie',
      'measurement': 'Pomiar pH',
      'other': 'Zabieg',
    });
    return '$_temp0';
  }

  @override
  String observationTag(String tag) {
    String _temp0 = intl.Intl.selectLogic(tag, {
      'moss': 'Mech',
      'weeds': 'Chwasty',
      'yellowPatches': 'Żółte plamy',
      'bareSpots': 'Łyse miejsca',
      'grubs': 'Pędraki',
      'other': 'Kretowisko',
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
    return '$amount $_temp0 na $area m²';
  }

  @override
  String journalHeight(String cm) {
    return 'Wysokość $cm cm';
  }

  @override
  String journalPh(String value) {
    return 'pH $value';
  }

  @override
  String get journalDetailsMissing => 'Dodaj szczegóły: nawóz i dawkę';

  @override
  String get journalRainConfirmed => 'Wmyte deszczem';

  @override
  String journalDoneAt(String time) {
    return 'zrobione o $time';
  }

  @override
  String get journalProduct => 'Nawóz';

  @override
  String get journalNpk => 'NPK';

  @override
  String get journalDoseLabel => 'Dawka';

  @override
  String get journalWholeLawn => 'Na cały trawnik';

  @override
  String get journalRainAfter => 'Opady po zabiegu';

  @override
  String get journalRainDays => '3 dni';

  @override
  String get journalRainSource => 'Według modelu pogody dla Twojej lokalizacji.';

  @override
  String get journalRainQuestion => 'Czy u Ciebie padało?';

  @override
  String get journalYes => 'Tak';

  @override
  String get journalNo => 'Nie';

  @override
  String get journalRainYes => 'Potwierdziłeś, że u Ciebie padało. Nawóz został wmyty.';

  @override
  String get journalRainNo =>
      'U Ciebie nie padało. Przy nawożeniu bez deszczu podlej potem trawnik.';

  @override
  String get journalNote => 'Notatka';

  @override
  String get journalEdit => 'Edytuj';

  @override
  String get journalDelete => 'Usuń wpis';

  @override
  String get journalDeleted => 'Wpis usunięty.';

  @override
  String get journalNewTitle => 'Nowy wpis';

  @override
  String get journalEditTitle => 'Edytuj wpis';

  @override
  String get journalWhatSeen => 'Co zauważyłeś?';

  @override
  String get journalDescription => 'Opis';

  @override
  String get journalDescriptionHint => 'np. mech pod brzozą, ok. 2 m²';

  @override
  String get journalPhotos => 'Zdjęcia';

  @override
  String get journalCamera => 'Aparat';

  @override
  String get journalGallery => 'Galeria';

  @override
  String get journalRemovePhoto => 'Usuń zdjęcie';

  @override
  String get journalDate => 'Data';

  @override
  String get journalPhValue => 'Wynik pomiaru pH';

  @override
  String get journalPhHint => 'np. 6,2';

  @override
  String get journalProductHint => 'np. jesienny z potasem';

  @override
  String get journalNpkHint => 'np. 5-3-10';

  @override
  String get journalDoseHint => 'np. 30';

  @override
  String get journalHeightLabel => 'Wysokość koszenia';

  @override
  String get journalMinutesLabel => 'Czas podlewania';

  @override
  String get journalSave => 'Zapisz w dzienniku';

  @override
  String journalSeasonRange(String start, String end, String name) {
    return '$start – $end · $name';
  }

  @override
  String get journalMonths => 'Zabiegi w miesiącach';

  @override
  String get journalLegendMowing => 'koszenie';

  @override
  String get journalLegendFertilizing => 'nawożenie';

  @override
  String get journalNitrogen => 'Azot w sezonie';

  @override
  String journalNitrogenValue(String kg) {
    return '$kg kg / 100 m²';
  }

  @override
  String journalNitrogenRange(String min, String max) {
    return 'Orientacyjnie dla Twojej mieszanki: $min–$max kg.';
  }

  @override
  String get journalNitrogenMissing =>
      'Uzupełnij skład NPK i dawkę przy nawożeniach, żeby policzyć azot.';

  @override
  String get journalFertilizerUsed => 'Nawóz';

  @override
  String journalLiquid(String litres) {
    return 'i $litres l płynnego';
  }

  @override
  String get journalRain => 'Deszcz';

  @override
  String journalRainMm(String mm) {
    return '$mm mm';
  }

  @override
  String get journalObservations => 'Obserwacje do sprawdzenia';

  @override
  String homeWateringCalibrated(int minutes, String mm) {
    return 'Zraszacz: $minutes min na sekcję, ok. $mm mm, wcześnie rano';
  }

  @override
  String journalWateringMm(String mm) {
    return 'i $mm mm z podlewania';
  }

  @override
  String get languageTitle => 'Język';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get notifChannelName => 'Pielęgnacja trawnika';

  @override
  String programNoteAverage(String value) {
    return 'średnio $value';
  }

  @override
  String programNoteSource(String site) {
    return 'Źródło: $site';
  }

  @override
  String get lawnTitle => 'Trawnik';

  @override
  String get lawnsTitle => 'Twoje trawniki';

  @override
  String get lawnsOpen => 'Zmień lub dodaj trawnik';

  @override
  String get lawnsEditSection => 'Edytuj wybrany trawnik';

  @override
  String get lawnsEditData => 'Nazwa i dane trawnika';

  @override
  String get lawnsAdd => 'Dodaj nowy trawnik';

  @override
  String get lawnsNotificationsNote => 'Powiadomienia przychodzą dla wybranego trawnika.';

  @override
  String lawnSubtitle(String place, int area, String age) {
    return '$place · $area m² · $age';
  }

  @override
  String lawnAge(int seasons) {
    String _temp0 = intl.Intl.pluralLogic(
      seasons,
      locale: localeName,
      other: '$seasons sezonów',
      few: '$seasons sezony',
      one: '1 sezon',
      zero: 'pierwszy sezon',
    );
    return '$_temp0';
  }

  @override
  String get lawnPh => 'pH gleby';

  @override
  String get lawnLastFertilized => 'Nawożenie';

  @override
  String get lawnLastMowed => 'Koszenie';

  @override
  String lawnObservations(int count, String tags) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count obserwacji do sprawdzenia',
      few: '$count obserwacje do sprawdzenia',
      one: '1 obserwacja do sprawdzenia',
    );
    return '$_temp0: $tags';
  }

  @override
  String get lawnSettings => 'Ustawienia trawnika';

  @override
  String lawnSoilSummary(String soil) {
    return 'gleba $soil';
  }

  @override
  String get lawnData => 'Dane trawnika';

  @override
  String get lawnCare => 'Pielęgnacja';

  @override
  String get lawnCalibration => 'Kalibracja zraszacza';

  @override
  String lawnMowingEvery(String days) {
    return 'Koszenie co $days';
  }

  @override
  String lawnCareSub(String days, String weekdays) {
    return 'Nawożenie co $days · $weekdays';
  }

  @override
  String get lawnNotCalibrated => 'Nie wykonano';

  @override
  String lawnRate(String rate) {
    return '$rate mm/min';
  }

  @override
  String get lawnAppearance => 'Wygląd';

  @override
  String get lawnThemeLight => 'Jasny';

  @override
  String get lawnThemeDark => 'Ciemny';

  @override
  String get lawnThemeSystem => 'Systemowy';

  @override
  String get lawnSave => 'Zapisz';

  @override
  String get lawnSaved => 'Zapisano.';

  @override
  String get lawnEstablished => 'Założony';

  @override
  String get lawnMix => 'Mieszanka';

  @override
  String get lawnSoil => 'Gleba';

  @override
  String lawnPhFromJournal(String date) {
    return 'Z pomiaru w dzienniku, $date.';
  }

  @override
  String get lawnHeight => 'Wysokość';

  @override
  String lawnHeightValue(int cm) {
    return '$cm cm';
  }

  @override
  String get lawnGardenDays => 'Dni na ogród';

  @override
  String get lawnWatering => 'Podlewanie';

  @override
  String lawnSectionMm(String mm) {
    return 'Ok. $mm mm na jedno podlewanie.';
  }

  @override
  String get lawnSeason => 'Sezon';

  @override
  String get lawnSeasonStart => 'Początek';

  @override
  String get lawnSeasonEnd => 'Koniec';

  @override
  String get lawnSeasonHelper => 'Poza sezonem nie planujemy koszenia, nawożenia ani podlewania.';

  @override
  String get lawnSeasonInvalid => 'Koniec sezonu musi być po jego początku.';

  @override
  String get calSubtitle => 'Ile wody daje minuta podlewania';

  @override
  String get calStep1Title => 'Rozstaw 4 kubki';

  @override
  String get calStep1 => 'Proste naczynia o płaskim dnie, w różnych miejscach jednej sekcji.';

  @override
  String calStep2Title(int minutes) {
    return 'Włącz sekcję na $minutes min';
  }

  @override
  String get calStep2 => 'Tak jak zwykle podlewasz, bez zmiany ustawień zraszaczy.';

  @override
  String get calStep3Title => 'Zmierz wodę linijką';

  @override
  String get calStep3 => 'Wpisz wysokość wody w każdym kubku.';

  @override
  String get calTestTime => 'Czas testu';

  @override
  String calCup(int number) {
    return 'Kubek $number';
  }

  @override
  String get calResult => 'Wynik';

  @override
  String calRate(String rate) {
    return '$rate mm na minutę';
  }

  @override
  String calAverage(String mm, int minutes, int target, int needed) {
    return 'Średnio $mm mm w $minutes min. Żeby podlać $target mm, włącz sekcję na $needed min.';
  }

  @override
  String calEven(String mm) {
    return 'Kubki różnią się o $mm mm: rozkład wody jest równy.';
  }

  @override
  String calUneven(String mm) {
    return 'Kubki różnią się o $mm mm: sprawdź zraszacze, część trawnika dostaje mniej wody.';
  }

  @override
  String get calMissing => 'Wpisz wynik z co najmniej jednego kubka.';

  @override
  String get calSave => 'Zapisz wynik';

  @override
  String homeWateringMoves(int minutes, int moves) {
    return 'Zraszacz na wężu: $minutes min w jednym miejscu, przestaw ok. $moves razy';
  }

  @override
  String homeWateringSpot(int minutes) {
    return 'Zraszacz na wężu: $minutes min w jednym miejscu';
  }

  @override
  String homeWateringHose(String perSqm, String total) {
    return 'Wąż: ok. $perSqm min na m², cały trawnik ok. $total.';
  }

  @override
  String homeWateringInParts(int parts) {
    String _temp0 = intl.Intl.pluralLogic(
      parts,
      locale: localeName,
      other: 'Podziel na $parts wieczory.',
      many: 'Podziel na $parts wieczorów.',
      few: 'Podziel na $parts wieczory.',
    );
    return '$_temp0';
  }

  @override
  String homeWateringCan(String litres, String cans, int can) {
    return 'Konewka: $litres l na m², czyli $cans konewki $can l. Zacznij od najsuchszych miejsc.';
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
  String get manualMethodLabel => 'Czym podlewasz?';

  @override
  String get manualSprinkler => 'Zraszacz';

  @override
  String get manualHose => 'Wąż';

  @override
  String get manualCan => 'Konewka';

  @override
  String get lawnMeasurement => 'Pomiar podlewania';

  @override
  String get lawnMethodNone => 'Nie wybrano';

  @override
  String lawnFlow(String flow) {
    return '$flow l/min';
  }

  @override
  String lawnCanValue(int litres) {
    return 'Konewka $litres l';
  }

  @override
  String get calCoverage => 'Zasięg zraszacza';

  @override
  String get calCoverageHelper =>
      'Powierzchnia podlewana z jednego miejsca. Koło o średnicy 6 m to ok. 28 m².';

  @override
  String calMoves(int area, int moves) {
    return 'Przy $area m² przestawiaj zraszacz ok. $moves razy.';
  }

  @override
  String get calHoseSubtitle => 'Ile wody daje wąż w minutę';

  @override
  String get calBucketStep1Title => 'Weź wiadro o znanej pojemności';

  @override
  String get calBucketStep1 => 'Najlepiej 10 l. Ustaw pistolet tak, jak zwykle podlewasz.';

  @override
  String get calBucketStep2Title => 'Zmierz czas napełniania';

  @override
  String get calBucketStep2 => 'Odkręć wodę i stoperem zmierz, po ilu sekundach wiadro jest pełne.';

  @override
  String get calBucket => 'Pojemność wiadra';

  @override
  String calBucketLitres(int litres) {
    return '$litres l';
  }

  @override
  String get calSeconds => 'Czas napełniania';

  @override
  String get calSecondsHint => 'np. 50';

  @override
  String calFlow(String flow) {
    return '$flow l na minutę';
  }

  @override
  String calHoseResult(int target, String perSqm, int area, String total) {
    return 'Żeby podlać $target mm: ok. $perSqm min na każdy m², cały trawnik ($area m²) ok. $total.';
  }

  @override
  String get calSecondsMissing => 'Wpisz, po ilu sekundach wiadro jest pełne.';

  @override
  String get calCanTitle => 'Podlewanie konewką';

  @override
  String calCanText(int target, String litres, String cans, int can, int area, int total) {
    return 'Na $target mm wody potrzeba $litres l na każdy m², czyli $cans konewki $can l. Cały trawnik ($area m²) to ok. $total l, dlatego konewką podlewaj tylko najbardziej suche miejsca.';
  }

  @override
  String get journalMinutesSpot => 'Minut w jednym miejscu';

  @override
  String get journalLitresLabel => 'Ilość wody';

  @override
  String journalLitres(String litres) {
    return '$litres l wody';
  }

  @override
  String get calHoseByBucket => 'Wiadro';

  @override
  String get calHoseByCups => 'Kubki';

  @override
  String get calHoseCupsStep1Title => 'Wyznacz kawałek trawnika';

  @override
  String get calHoseCupsStep1 => 'Np. kwadrat 3 × 3 m. Rozstaw w nim 4 kubki.';

  @override
  String calHoseCupsStep2Title(int minutes) {
    return 'Podlewaj go wężem przez $minutes min';
  }

  @override
  String get calHoseCupsStep2 =>
      'Tak jak zwykle, równo po całym kawałku, bez wychodzenia poza niego.';

  @override
  String get calTestArea => 'Powierzchnia kawałka';

  @override
  String calHoseCupsFlow(String mm, int minutes, String flow) {
    return 'Na trawnik trafia średnio $mm mm w $minutes min, czyli ok. $flow l na minutę.';
  }

  @override
  String get calAreaMissing => 'Wpisz powierzchnię kawałka i wynik z co najmniej jednego kubka.';

  @override
  String get assistantTitle => 'Asystent';

  @override
  String get assistantSubtitle => 'Zna Twój trawnik, pogodę i dziennik';

  @override
  String get assistantAskHint => 'Zapytaj o swój trawnik…';

  @override
  String get assistantFollowHint => 'Dopytaj…';

  @override
  String get assistantSend => 'Wyślij';

  @override
  String get assistantAddPhoto => 'Dodaj zdjęcie';

  @override
  String assistantQuota(int remaining, int limit) {
    return 'Zostało $remaining z $limit pytań na dziś';
  }

  @override
  String assistantQuotaCost(int remaining) {
    return 'Zużyje 1 z $remaining pozostałych pytań';
  }

  @override
  String get assistantProblems => 'Co Cię niepokoi?';

  @override
  String lawnProblem(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'yellowPatches': 'Żółte plamy',
      'dryGrass': 'Sucha trawa',
      'moss': 'Mech',
      'weeds': 'Chwasty',
      'bareSpots': 'Łyse miejsca',
      'fungus': 'Grzyby, pleśń',
      'molehills': 'Kretowiska',
      'other': 'Pędraki',
    });
    return '$_temp0';
  }

  @override
  String get assistantQuick => 'Szybkie odpowiedzi';

  @override
  String get assistantOffline => 'offline';

  @override
  String get assistantOfflineAnswer => 'Odpowiedź offline, bez limitu';

  @override
  String get quickWeek => 'Co zrobić w tym tygodniu?';

  @override
  String get quickScarify => 'Kiedy mogę wertykulować?';

  @override
  String get quickWinter => 'Jak przygotować trawnik do zimy?';

  @override
  String get quickWeekNone => 'W najbliższych 7 dniach nie ma zaplanowanych prac.';

  @override
  String get quickWeekIntro => 'Plan na najbliższe 7 dni:';

  @override
  String get quickScarifyNow =>
      'Tak, to dobry czas. Wertykulację rób na suchym, świeżo skoszonym trawniku, a łyse miejsca od razu dosiej.';

  @override
  String get quickScarifyLater =>
      'Teraz nie. Wertykulacja rani darń, więc trawa musi potem szybko odrosnąć: najlepiej wiosną albo pod koniec lata.';

  @override
  String quickScarifyNext(String date) {
    return 'Najbliższy dobry termin: od $date.';
  }

  @override
  String get quickScarifyNowPreview => 'Teraz to dobry czas';

  @override
  String quickScarifyLaterPreview(String date) {
    return 'Od $date';
  }

  @override
  String get quickWinterText =>
      '1. Ostatnie koszenie na ok. 5 cm, gdy trawa przestaje rosnąć.\n2. Do końca października nawóz jesienny z przewagą potasu.\n3. Grabienie liści: nie zostawiaj ich na zimę.\n4. Nie chodź po zamarzniętej trawie.';

  @override
  String get quickWinterPreview => '4 kroki przed zimą';

  @override
  String get diagnoseSubtitle => 'Diagnoza ze zdjęcia';

  @override
  String get diagnosePhotos => 'Zdjęcia';

  @override
  String get diagnosePhotosHint => 'Najlepiej dwa: cała plama i z bliska.';

  @override
  String get diagnoseDescribe => 'Opisz, co widzisz';

  @override
  String get diagnoseDescribeHint => 'np. nieregularne plamy, trawa łatwo się odrywa';

  @override
  String get diagnoseSince => 'Od kiedy?';

  @override
  String diagnoseSinceOption(String since) {
    String _temp0 = intl.Intl.selectLogic(since, {
      'days': 'Kilka dni',
      'weeks': '1–2 tygodnie',
      'month': 'Ponad miesiąc',
      'other': 'Nie wiem',
    });
    return '$_temp0';
  }

  @override
  String get diagnoseContextTitle => 'Asystent dostanie też';

  @override
  String diagnoseContext(int area, String mix) {
    return 'Dane trawnika ($area m², $mix), opady z 14 dni, prognozę i ostatnie wpisy z dziennika.';
  }

  @override
  String get diagnoseButton => 'Zdiagnozuj';

  @override
  String get diagnoseWorking => 'Analizuję…';

  @override
  String get resultTitle => 'Wynik diagnozy';

  @override
  String get resultMost => 'Najpewniej';

  @override
  String resultUrgency(String urgency) {
    String _temp0 = intl.Intl.selectLogic(urgency, {
      'actNow': 'działaj teraz',
      'soon': 'w najbliższych tygodniach',
      'other': 'nie pilne',
    });
    return '$_temp0';
  }

  @override
  String resultLikelihood(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'high': 'wysokie',
      'medium': 'średnie',
      'other': 'niskie',
    });
    return '$_temp0';
  }

  @override
  String get resultCheck => 'Jak to sprawdzić';

  @override
  String get resultActions => 'Proponowane zabiegi';

  @override
  String get assistantToCalendar => 'Do kalendarza';

  @override
  String get assistantAddedToCalendar => 'Dodano do kalendarza.';

  @override
  String get assistantSaveJournal => 'Zapisz w dzienniku';

  @override
  String get assistantSavedJournal => 'Zapisano w dzienniku.';

  @override
  String get assistantReport => 'Zgłoś odpowiedź';

  @override
  String get assistantAiNote =>
      'Odpowiedź AI może się mylić. Przy środkach ochrony roślin kieruj się etykietą produktu.';

  @override
  String get reportTitle => 'Co jest nie tak z odpowiedzią?';

  @override
  String reportReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'wrong': 'Błędna',
      'offensive': 'Obraźliwa',
      'dangerous': 'Niebezpieczna',
      'other': 'Inny powód',
    });
    return '$_temp0';
  }

  @override
  String get reportNote => 'Komentarz';

  @override
  String get reportSend => 'Wyślij zgłoszenie';

  @override
  String get reportSent => 'Dziękujemy, sprawdzimy tę odpowiedź.';

  @override
  String assistantError(String error) {
    String _temp0 = intl.Intl.selectLogic(error, {
      'quotaExceeded': 'Wykorzystałeś dzisiejsze pytania. Limit odnowi się jutro.',
      'offline': 'Brak połączenia z internetem.',
      'busy': 'Asystent jest teraz zajęty. Spróbuj za chwilę.',
      'badImage': 'Nie udało się wysłać zdjęcia. Spróbuj z innym.',
      'other': 'Nie udało się uzyskać odpowiedzi. Spróbuj ponownie.',
    });
    return '$_temp0';
  }

  @override
  String get assistantUnavailable =>
      'Asystent AI jest niedostępny w tej wersji aplikacji. Szybkie odpowiedzi działają offline.';

  @override
  String get assistantPrivacyTitle => 'Zanim zapytasz';

  @override
  String get assistantPrivacy =>
      'Pytania, wybrane zdjęcia i dane trawnika trafiają przez nasz serwer do Google Gemini. Na darmowych warunkach Google może je wykorzystać do ulepszania swoich usług. Nie dołączaj zdjęć z osobami.';

  @override
  String get assistantPrivacyAccept => 'Rozumiem';

  @override
  String get navToday => 'Dziś';

  @override
  String get navCalendar => 'Kalendarz';

  @override
  String get navJournal => 'Dziennik';

  @override
  String get navAssistant => 'Asystent';

  @override
  String get navLawn => 'Trawnik';

  @override
  String guideTopicTitle(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification': 'Wertykulacja',
      'aeration': 'Aeracja',
      'raking': 'Wyczesywanie',
      'overseeding': 'Dosiewka',
      'sanding': 'Piaskowanie',
      'liming': 'Wapnowanie',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicSummary(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification': 'Usuwa filc i mech, przewietrza darń',
      'aeration': 'Napowietrza ubitą glebę, woda i nawóz docierają do korzeni',
      'raking': 'Lekko usuwa martwą trawę, liście i cienki filc',
      'overseeding': 'Zagęszcza trawnik i wypełnia łyse miejsca',
      'sanding': 'Rozluźnia ciężką glebę i wyrównuje powierzchnię',
      'liming': 'Odkwasza glebę, gdy pH spadnie za nisko',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicWhen(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification': 'Kwiecień–maj, opcjonalnie koniec sierpnia–wrzesień',
      'aeration': 'Kwiecień–maj albo wrzesień',
      'raking': 'Marzec–kwiecień i jesienią, z liśćmi',
      'overseeding': 'Koniec sierpnia–wrzesień, kwiecień–maj',
      'sanding': 'Zaraz po aeracji, wiosną lub we wrześniu',
      'liming': 'Październik–listopad, przy pH poniżej 5,5',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicWhenText(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification':
          'Gdy trawa intensywnie rośnie, a gleba ma co najmniej 10°C. Zwykle po 2–3 wiosennym koszeniu. Nie w upale i nie na mokrej glebie.',
      'aeration':
          'Gdy trawa rośnie i szybko zarośnie otwory. Gleba ma być wilgotna, ale nie mokra: kolce wchodzą wtedy łatwo i nie mażą gleby.',
      'raking':
          'Wiosną, gdy trawnik obeschnie po zimie, i jesienią, gdy spadają liście. Jest delikatniejsze od wertykulacji, więc można je robić częściej.',
      'overseeding':
          'Najlepiej od końca sierpnia do połowy września: gleba jest ciepła, a rosa trzyma wilgoć. Wiosną wtedy, gdy gleba ma co najmniej 8–10°C.',
      'sanding':
          'Najlepiej od razu po aeracji lub wertykulacji, póki otwory są otwarte. Trawnik i piasek muszą być suche.',
      'liming':
          'Jesienią, po ostatnim nawożeniu, albo wczesną wiosną. Tylko gdy pomiar pokaże kwaśną glebę: trawa najlepiej rośnie przy pH 5,5–7.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicSigns(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification':
          'Pod źdźbłami jest sprężysta warstwa filcu grubsza niż 1 cm\nMiędzy trawą rośnie mech\nTrawnik słabo reaguje na nawóz i podlewanie',
      'aeration':
          'Po deszczu na trawniku długo stoi woda\nGleba jest twarda, śrubokręt ledwo w nią wchodzi\nTrawa rzednie na ścieżkach i w miejscach zabaw',
      'raking':
          'Po zimie trawa jest zbita i zeschnięta\nNa trawniku leżą liście i resztki skoszonej trawy\nFilc jest cienki, poniżej 1 cm',
      'overseeding':
          'Trawnik rzednie i widać glebę\nPo zimie lub wertykulacji zostały łyse placki\nW lukach wyrastają chwasty',
      'sanding':
          'Gleba jest gliniasta i zbita\nPo deszczu długo stoi woda\nNa trawniku są drobne nierówności',
      'liming':
          'Pomiar pH pokazał wynik poniżej 5,5\nNa trawniku rozrasta się mech\nTrawa słabo reaguje na nawożenie',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicSteps(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification':
          'Skoś nisko: Na 3–4 cm, dzień lub dwa wcześniej. Trawnik musi być suchy.\nUstaw noże płytko: Mają nacinać glebę na 2–3 mm. Głębiej uszkodzisz korzenie.\nPrzejdź wzdłuż, potem w poprzek: Równym tempem, bez zatrzymywania się w jednym miejscu.\nZgrab wyczesany filc: Może go być zaskakująco dużo. Trawnik przez 2 tygodnie wygląda gorzej, to normalne.\nDosiej i nawieź: Łyse miejsca dosiej od razu, potem nawóz wiosenny.\nPodlewaj: Regularnie przez 2–3 tygodnie, jeśli nie pada.',
      'aeration':
          'Skoś trawnik: Na zwykłą wysokość, dzień wcześniej.\nPodlej, jeśli jest sucho: Dzień przed aeracją, żeby gleba zmiękła.\nNakłuj glebę: Aeratorem z pustymi kolcami na 6–10 cm, co około 10 cm.\nZostaw rdzenie: Po 1–2 dniach wyschną, wtedy rozbij je grabiami.\nZasyp otwory piaskiem: Piaskowanie zaraz po aeracji daje najlepszy efekt.\nNawieź i podlej: Składniki trafią prosto do korzeni.',
      'raking':
          'Poczekaj, aż trawnik obeschnie: Mokrą darń łatwo wyrwać razem z korzeniami.\nWyczesz grabiami wachlarzowymi: Energicznie, ale płytko, w dwóch kierunkach.\nZbierz resztki: Liście i martwą trawę wyrzuć na kompost.\nDosiej ubytki: Łyse miejsca po zimie dosiej, gdy gleba ma 8–10°C.',
      'overseeding':
          'Przygotuj glebę: Wyczesz lub wertykuluj trawnik, łyse miejsca spulchnij grabiami.\nWysiej nasiona: 15–20 g/m², a na łyse miejsca 25–35 g/m². Siej w dwóch kierunkach.\nPrzykryj cienko: Około 0,5 cm ziemi lub piasku, potem lekko zwałuj.\nPodlewaj codziennie: Delikatnie, małą dawką, przez 2–3 tygodnie, aż trawa wzejdzie.\nSkoś pierwszy raz: Gdy młoda trawa ma 8–10 cm, skoś ją na 5–6 cm.',
      'sanding':
          'Zrób aerację: Piasek ma wpaść w otwory po kolcach.\nRozsyp piasek: 3–5 l/m², czyli warstwa 3–5 mm. Piasek płukany o ziarnie 0–2 mm.\nRozprowadź i wmieć: Odwróconymi grabiami lub szczotką, aż piasek zniknie w darni.\nPodlej: Woda spłucze resztki piasku z liści.',
      'liming':
          'Zmierz pH: Kwasomierzem lub paskami, w kilku miejscach trawnika.\nDobierz dawkę: Wapno węglanowe lub dolomit, zwykle 10–20 kg na 100 m². Dokładną dawkę podaje etykieta.\nRozsiej równo: Siewnikiem, przy bezwietrznej pogodzie, w dwóch kierunkach.\nPodlej lub poczekaj na deszcz: Wapno musi dostać się do gleby.\nSprawdź pH za rok: Nie wapnuj co sezon bez pomiaru.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicTools(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification': 'Wertykulator\nGrabie\nNasiona do dosiewki\nNawóz wiosenny',
      'aeration': 'Aerator z pustymi kolcami\nGrabie\nPiasek płukany',
      'raking': 'Grabie wachlarzowe\nWyczesywarka (opcjonalnie)\nWorki lub kompostownik',
      'overseeding':
          'Nasiona tej samej mieszanki\nGrabie\nZiemia lub piasek do przykrycia\nWałek (opcjonalnie)',
      'sanding': 'Piasek płukany 0–2 mm\nGrabie lub szczotka\nTaczka i łopata',
      'liming': 'Kwasomierz lub paski pH\nWapno węglanowe lub dolomit\nSiewnik',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideTopicAvoid(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'scarification':
          'Trawnik młodszy niż 2 lata od siewu albo rok od położenia rolki. Wertykulacja w upale, suszy lub na mokrej glebie. Więcej niż 1–2 razy w roku.',
      'aeration':
          'Trawnik młodszy niż rok od założenia. Aeracja przesuszonej, twardej gleby albo w suszy. Pełne kolce na ciężkiej glebie tylko ją ugniatają. Na glebie gliniastej wystarczą 1–2 razy w roku, na piaszczystej rzadziej.',
      'raking':
          'Wyczesywanie mokrego lub zamarzniętego trawnika. Liście zostawione na zimę: trawa pod nimi gnije i łapie choroby.',
      'overseeding':
          'Siew w upał, w suszę albo w zimną glebę. Chodzenie po świeżym wysiewie. Środki na chwasty przez 6–8 tygodni przed siewem i po nim.',
      'sanding':
          'Piasek budowlany z gliną i drobny piasek pylasty. Warstwa grubsza niż 5 mm naraz: trawa się udusi. Na glebie piaszczystej piaskowanie zwykle nie jest potrzebne.',
      'liming':
          'Wapno razem z nawozem azotowym: zachowaj 3–4 tygodnie odstępu. Wapno tlenkowe (palone), które parzy trawę. Wapnowanie bez pomiaru pH.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideMonthTitle(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Zima: trawnik odpoczywa',
      'feb': 'Przygotowania do sezonu',
      'mar': 'Wyczesywanie i pierwszy nawóz',
      'apr': 'Wertykulacja i aeracja',
      'may': 'Dosiewka i regularne koszenie',
      'jun': 'Koszenie i podlewanie',
      'jul': 'Upał: koś wyżej',
      'aug': 'Dosiewka pod koniec miesiąca',
      'sep': 'Aeracja, piaskowanie, dosiewka',
      'oct': 'Wapnowanie i ostatnie koszenie',
      'nov': 'Grabienie liści',
      'dec': 'Zima: trawnik odpoczywa',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideMonthText(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Nie chodź po zamarzniętej trawie i zaplanuj wiosenne zabiegi.',
      'feb': 'Naostrz noże kosiarki i sprawdź sprzęt przed wiosną.',
      'mar': 'Gdy trawnik obeschnie, wygrab filc i liście. Pod koniec miesiąca daj nawóz startowy.',
      'apr': 'Trawa rusza ze wzrostem. To najlepszy czas na zabiegi i dosiewkę łysych miejsc.',
      'may': 'Ostatnia szansa na wiosenną wertykulację. Koś co 4–7 dni.',
      'jun': 'Podlewaj rzadziej, ale obficiej, najlepiej rano.',
      'jul': 'Podnieś kosiarkę o 1 cm i nie nawoź azotem w upale.',
      'aug': 'Gdy upały miną, zaczyna się najlepszy czas na dosiewkę.',
      'sep': 'Ciepła gleba i rosa pomagają trawnikowi szybko wrócić do siebie po zabiegach.',
      'oct': 'Jesień to dobry moment, by odkwasić glebę przed zimą.',
      'nov': 'Nie zostawiaj liści na zimę. Ostatnie koszenie na około 5 cm.',
      'dec': 'Nie chodź po zamarzniętej trawie i nie zgarniaj na nią śniegu z solą.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get guideTitle => 'Poradnik';

  @override
  String get guideCare => 'Zabiegi';

  @override
  String get guideCareSub => 'Wertykulacja, aeracja, dosiewka i inne';

  @override
  String get guideCarePageSub => 'Kiedy i jak je wykonać';

  @override
  String get guideFertilizing => 'Nawożenie';

  @override
  String get guideFertilizingSub => 'Rodzaje nawozów i skład NPK';

  @override
  String get guideFertilizingPageSub => 'Jakie nawozy, kiedy i w jakim składzie';

  @override
  String get guideMowing => 'Koszenie';

  @override
  String get guideMowingSub => 'Wysokość, rytm i zasada 1/3';

  @override
  String get guideMowingPageSub => 'Wysokość, rytm i dobre nawyki';

  @override
  String get guideMixes => 'Mieszanki traw';

  @override
  String get guideMixesSub => 'Dobór do trawnika i koszenie';

  @override
  String get guideMixesPageSub => 'Jak dobrać i na jaką wysokość kosić';

  @override
  String get guideNowGood => 'Teraz dobry czas';

  @override
  String get guideLater => 'Później w sezonie';

  @override
  String get guideNextSeason => 'W przyszłym sezonie';

  @override
  String get guideNowBadge => 'Teraz';

  @override
  String get guideOrderTip =>
      'Kolejność wiosną: wertykulacja, aeracja, piaskowanie, dosiewka, nawożenie. Każdy krok przygotowuje trawnik do następnego.';

  @override
  String get guideWhen => 'Kiedy';

  @override
  String get guideBest => 'najlepiej';

  @override
  String get guidePossible => 'można';

  @override
  String get guideNowLegend => 'teraz';

  @override
  String get guideSignsTitle => 'Czy Twój trawnik tego potrzebuje?';

  @override
  String get guideStepsTitle => 'Jak wykonać';

  @override
  String get guideToolsTitle => 'Czego potrzebujesz';

  @override
  String get guideAvoidTitle => 'Czego unikać';

  @override
  String get guidePlanNow => 'Zaplanuj zabieg';

  @override
  String get guideAsk => 'Zapytaj asystenta';

  @override
  String get guideYoursMix => 'Twoja';

  @override
  String get guideNpkTitle => 'Co oznacza N-P-K';

  @override
  String get guideNpkIntro =>
      'Liczby na worku to procent składników. 20-5-8 oznacza 20% azotu, 5% fosforu i 8% potasu.';

  @override
  String get guideNitrogen => 'Azot';

  @override
  String get guideNitrogenText => 'Wzrost i zielony kolor';

  @override
  String get guidePhosphorus => 'Fosfor';

  @override
  String get guidePhosphorusText => 'Korzenie, ważny przy zakładaniu trawnika';

  @override
  String get guidePotassium => 'Potas';

  @override
  String get guidePotassiumText => 'Odporność na mróz, suszę i choroby';

  @override
  String get guideMicro =>
      'Magnez (Mg) pogłębia kolor, a żelazo (Fe) daje intensywną zieleń i ogranicza mech.';

  @override
  String get guideFertSeasonsTitle => 'Nawóz na porę roku';

  @override
  String get guideColSeason => 'Pora';

  @override
  String get guideColNpk => 'N-P-K';

  @override
  String get guideColWhy => 'Po co';

  @override
  String get guideFertSeason1 => 'Marzec–kwiecień';

  @override
  String get guideFertSeason1Why => 'Start wzrostu po zimie';

  @override
  String get guideFertSeason2 => 'Maj–czerwiec';

  @override
  String get guideFertSeason2Why => 'Gęsta, równa darń';

  @override
  String get guideFertSeason3 => 'Lipiec–sierpień';

  @override
  String get guideFertSeason3Why => 'Mniej azotu, odporność na upał';

  @override
  String get guideFertSeason4 => 'Wrzesień–październik';

  @override
  String get guideFertSeason4Why => 'Korzenie i przezimowanie, dużo potasu';

  @override
  String get guideFertTypesTitle => 'Rodzaje nawozów';

  @override
  String get guideColType => 'Rodzaj';

  @override
  String get guideColWorks => 'Działa';

  @override
  String get guideColEvery => 'Co ile';

  @override
  String get guideFertSlow => 'Granulowany wolnodziałający';

  @override
  String get guideFertFast => 'Granulowany szybki';

  @override
  String get guideFertLiquid => 'Płynny';

  @override
  String get guideFertOrganic => 'Organiczny';

  @override
  String get guideFertSlowWorks => '2–3 mies.';

  @override
  String get guideFertSlowEvery => '8–12 tyg.';

  @override
  String get guideFertFastWorks => '4–6 tyg.';

  @override
  String get guideFertFastEvery => '4–6 tyg.';

  @override
  String get guideFertLiquidWorks => '1–2 tyg.';

  @override
  String get guideFertLiquidEvery => '2–3 tyg.';

  @override
  String get guideFertOrganicWorks => '2–3 mies.';

  @override
  String get guideFertOrganicEvery => '2–3 razy w sezonie';

  @override
  String get guideFertHowTitle => 'Jak nawozić';

  @override
  String get guideFertHow =>
      'Na suchą trawę, najlepiej przed lekkim deszczem. Inaczej podlej.\nSiewnikiem, w dwóch przejściach na krzyż, po pół dawki.\nNie w upale powyżej 25°C i nie przed ulewą.\nOd października bez azotu, tylko nawóz jesienny.';

  @override
  String get guideFertNote =>
      'Proporcje N-P-K w tabeli są przykładowe. Dawkę na m² zawsze bierz z etykiety nawozu.';

  @override
  String get guideMowRuleLabel => 'Zasada 1/3';

  @override
  String get guideMowRuleTitle => 'Ścinaj najwyżej jedną trzecią wysokości';

  @override
  String get guideMowRhythmTitle => 'Rytm w sezonie';

  @override
  String get guideColHeight => 'Wysokość';

  @override
  String get guideMowSeason1 => 'Kwiecień';

  @override
  String get guideMowSeason1Every => 'Gdy ma ok. 8 cm';

  @override
  String get guideMowSeason1Height => 'Pierwsze cięcie tylko o 1–2 cm';

  @override
  String get guideMowSeason2 => 'Maj–czerwiec';

  @override
  String get guideMowSeason2Every => 'Co 4–7 dni';

  @override
  String get guideMowSeason2Height => 'Docelowa';

  @override
  String get guideMowSeason3 => 'Lipiec–sierpień';

  @override
  String get guideMowSeason3Every => 'Co 7–10 dni';

  @override
  String get guideMowSeason3Height => 'O 1 cm wyżej w upał';

  @override
  String get guideMowSeason4 => 'Wrzesień–listopad';

  @override
  String get guideMowSeason4Every => 'Co 7–14 dni, aż przestanie rosnąć';

  @override
  String get guideMowSeason4Height => 'Ostatnie cięcie na ok. 5 cm';

  @override
  String get guideMowHabitsTitle => 'Dobre nawyki';

  @override
  String get guideMowHabits =>
      'Ostre noże. Tępe szarpią źdźbła i końcówki brązowieją.\nTylko sucha trawa, bez porannej rosy i nie w największy upał.\nZmieniaj kierunek koszenia, żeby trawa nie kładła się w jedną stronę.\nMulczowanie oddaje trawnikowi azot, ale tylko przy regularnym koszeniu suchej trawy.';

  @override
  String get guideMowToday => 'Kiedy dziś kosić?';

  @override
  String get guideMowTodaySub => 'Dobre godziny mają zieloną ramkę w prognozie dnia';

  @override
  String get guideMixHowTitle => 'Jak dobrać';

  @override
  String get guideMixListTitle => 'Mieszanki i wysokość koszenia';

  @override
  String get guideMixWhenUniversal => 'Słońce, dzieci, pies';

  @override
  String get guideMixWhenOrnamental => 'Reprezentacyjny, mało deptany';

  @override
  String get guideMixWhenShade => 'Pod drzewami, 3–4 h słońca';

  @override
  String get guideMixWhenDrought => 'Piasek, rzadkie podlewanie';

  @override
  String guideMixShort(String mix) {
    String _temp0 = intl.Intl.selectLogic(mix, {
      'universal': 'Uniwersalna',
      'ornamental': 'Ozdobna',
      'shade': 'Do cienia',
      'drought': 'Na suszę',
      'sport': 'Sportowa',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideMixText(String mix) {
    String _temp0 = intl.Intl.selectLogic(mix, {
      'universal': 'Odporna na deptanie, dla rodzin i zwierząt',
      'ornamental': 'Gęsta i niska, kosić nawet co 3–5 dni',
      'shade': 'Koszona wyżej, żeby łapała więcej światła',
      'drought': 'Głębokie korzenie, wysoka trawa chroni glebę',
      'sport': 'Najszybciej się odradza po intensywnym użytkowaniu',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideMixSpecies(String mix) {
    String _temp0 = intl.Intl.selectLogic(mix, {
      'universal': 'Życica trwała, kostrzewa czerwona, wiechlina łąkowa',
      'ornamental': 'Kostrzewa czerwona, mietlica pospolita, wiechlina łąkowa',
      'shade': 'Kostrzewa czerwona, wiechlina gajowa, śmiałek darniowy',
      'drought': 'Kostrzewa trzcinowa, kostrzewa owcza, kostrzewa czerwona',
      'sport': 'Życica trwała, wiechlina łąkowa',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get guideSeedsTitle => 'Ile nasion?';

  @override
  String get guideSeedsText =>
      'Nowy trawnik 25–35 g/m², dosiewka 15–20 g/m². Do dosiewki wybierz tę samą mieszankę, co trawnik.';

  @override
  String get guideCm => 'cm';

  @override
  String guideNowInSeason(String month) {
    return 'Teraz w sezonie · $month';
  }

  @override
  String guidePlanOn(String month) {
    return 'Zaplanuj na $month';
  }

  @override
  String guideAskQuestion(String topic) {
    return 'Czy mój trawnik potrzebuje teraz zabiegu: $topic? Kiedy najlepiej go zrobić?';
  }

  @override
  String guideMowRuleText(String height, String max) {
    return 'Trzymaj $height cm i koś, gdy trawa ma około $max cm.';
  }

  @override
  String get quickScarifyYoung =>
      'Jeszcze nie. Twój trawnik jest za młody: wertykulację robi się najwcześniej 2 lata po siewie albo rok po położeniu rolki.';

  @override
  String guideTooYoung(String date) {
    return 'Twój trawnik jest jeszcze za młody na ten zabieg. Bezpiecznie będzie od: $date.';
  }

  @override
  String get guideTooYoungTitle => 'Za młody trawnik';

  @override
  String addTooYoung(String kind, String date) {
    return 'Trawnik jest za młody na zabieg „$kind”. Darń musi się najpierw dobrze ukorzenić: bezpiecznie będzie od $date.';
  }

  @override
  String addMoveToReady(String date) {
    return 'Przenieś na $date';
  }

  @override
  String get noticeFrostTitle => 'Uwaga na przymrozek';

  @override
  String noticeFrostBody(String day, int temp) {
    return '$day do $temp°C. Wstrzymaj nawożenie i wyłącz automatyczne podlewanie.';
  }

  @override
  String get noticeHeatTitle => 'Upał';

  @override
  String noticeHeatBody(String day, int temp) {
    return '$day do $temp°C. Podlewaj rano i nie kosz trawy.';
  }

  @override
  String get noticeDownpourTitle => 'Ulewa';

  @override
  String noticeDownpourBody(String day, String mm) {
    return '$day ok. $mm mm deszczu. Nie nawoź przed opadem.';
  }

  @override
  String noticeMovedTitle(String day) {
    return 'Nawożenie przeniesione na $day';
  }

  @override
  String get noticeMovedBody => 'Wybraliśmy lepszy dzień w oknie nawożenia.';

  @override
  String noticeStaleTitle(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours godzin',
      one: '1 godziny',
    );
    return 'Prognoza sprzed $_temp0';
  }

  @override
  String get noticeStaleBody => 'Rady mogą być mniej trafne. Odświeżymy po połączeniu.';

  @override
  String get noticeToday => 'Dziś';

  @override
  String get noticeTomorrow => 'Jutro';

  @override
  String get notifFertilizeIdealTitle => 'Idealny dzień do nawożenia';

  @override
  String get notifFertilizeTitle => 'Dziś nawożenie';

  @override
  String notifFertilizeBody(int cycleDay, int interval) {
    return 'Dzień $cycleDay z $interval. Sprawdź prognozę przed rozsypaniem nawozu.';
  }

  @override
  String get notifFertilizeFallbackBody => 'Otwórz plan, żeby zobaczyć szczegóły.';

  @override
  String get notifProgramTitle => 'Dziś krok programu nawożenia';

  @override
  String notifProgramRain(int mm) {
    return 'Zapowiadany deszcz: $mm mm. Rozważ przesunięcie terminu, żeby nawóz się nie wypłukał.';
  }

  @override
  String get notifMowingTitle => 'Czas na koszenie';

  @override
  String get notifMowingBody => 'Trawa jest gotowa na koszenie. Sprawdź wysokość cięcia.';

  @override
  String get notifWateringTitle => 'Podlewanie';

  @override
  String get notifWateringBody => 'Dziś bez deszczu, trawnik potrzebuje wody.';

  @override
  String get notifTaskTitle => 'Zaplanowany zabieg';

  @override
  String get notifTaskBody => 'Masz dziś zabieg w kalendarzu.';

  @override
  String get notifSettingsTitle => 'Powiadomienia';

  @override
  String get notifSettingsIntro =>
      'Najwyżej jedno dziennie. Wyjątek to ostrzeżenie o pogodzie dzień wcześniej. Cisza nocna od 21:00 do 7:00.';

  @override
  String get notifSettingsEnable => 'Włącz powiadomienia';

  @override
  String get notifSettingsDenied => 'Zezwól na powiadomienia w ustawieniach telefonu.';

  @override
  String get notifSettingsHour => 'Pora poranna';

  @override
  String notifSettingsHourValue(int hour) {
    return '$hour:00';
  }

  @override
  String get notifSettingsFertilizing => 'Nawożenie';

  @override
  String get notifSettingsWatering => 'Podlewanie';

  @override
  String get notifSettingsCare => 'Koszenie i zabiegi';

  @override
  String get notifSettingsWarnings => 'Ostrzeżenia pogodowe';

  @override
  String get notifSettingsOff => 'Wyłączone';

  @override
  String notifSettingsOn(int hour) {
    return 'Włączone od $hour:00';
  }

  @override
  String get notifPlanChangedTitle => 'Zmiana planu';

  @override
  String notifPlanChangedBody(String date) {
    return 'Nawożenie przeniesione na $date.';
  }

  @override
  String get homeOffSeasonTitle => 'Trawnik odpoczywa';

  @override
  String homeDoneNextWindow(String range) {
    return 'Zapisane w dzienniku. Następne okno: $range.';
  }

  @override
  String get notifSeasonTitle => 'Zaczyna się sezon';

  @override
  String get notifSeasonBody => 'Plan prac na nowy sezon jest gotowy.';

  @override
  String get programsTitle => 'Programy nawożenia';

  @override
  String get programsOff => 'Wyłączone';

  @override
  String get programsIntro =>
      'Gotowe harmonogramy producentów nawozów. Po włączeniu zabiegi trafiają do kalendarza z produktem i dawką dla Twojej powierzchni. Zastępują wtedy standardowy plan nawożenia.';

  @override
  String get programsActive => 'Aktywny';

  @override
  String get programsEnable => 'Włącz program';

  @override
  String get programsDisable => 'Wyłącz program';

  @override
  String get programsEnabled => 'Program włączony. Zabiegi są w kalendarzu.';

  @override
  String get programsDisabled => 'Program wyłączony. Wrócił standardowy plan nawożenia.';

  @override
  String programsSource(String brand, String site) {
    return 'Źródło: $brand ($site). Programy i dawki są przykładowe, zawsze sprawdź etykietę produktu.';
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
      'Terminy programu są stałe. Pogoda nie przesuwa ich, najwyżej ostrzega.';

  @override
  String get programsCustomTitle => 'Własne plany';

  @override
  String get programsCreate => 'Utwórz własny plan';

  @override
  String get programsEdit => 'Edytuj';

  @override
  String get programsDelete => 'Usuń';

  @override
  String get programsDeleted => 'Plan usunięty.';

  @override
  String customSummary(String product, int dose, String days) {
    return '$product, $dose g/m², co $days';
  }

  @override
  String get customFormTitle => 'Własny plan nawożenia';

  @override
  String get customName => 'Nazwa planu';

  @override
  String get customProduct => 'Nazwa nawozu';

  @override
  String get customDose => 'Dawka (g/m²)';

  @override
  String get customInterval => 'Co ile dni';

  @override
  String get customStart => 'Pierwsze nawożenie';

  @override
  String get customSave => 'Zapisz plan';

  @override
  String get customInvalid => 'Podaj nazwę nawozu, dawkę i odstęp w dniach.';

  @override
  String programsControlsDates(String name) {
    return 'Terminy nawożenia ustawia program: $name. Odstęp między zabiegami nie jest teraz używany.';
  }
}
