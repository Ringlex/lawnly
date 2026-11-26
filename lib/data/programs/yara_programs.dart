import 'package:lawnly/core/l10n/localized_text.dart';
import 'package:lawnly/data/programs/fertilizer_program.dart';

const yaraPrograms = ProgramSource(
  brand: 'YaraMila Complex',
  site: 'e-hortico.pl',
  programs: [
    FertilizerProgram(
      id: 'yara-complex-lawn',
      brand: 'YaraMila Complex',
      name: LocalizedText(
        pl: 'Trawnik: 3 aplikacje do lipca',
        en: 'Lawn: 3 applications until July',
      ),
      summary: LocalizedText(
        pl: 'Nawóz o szybko działającym azocie. Po lipcu nie stosować, jesienią użyj nawozu jesiennego.',
        en: 'A fertilizer with fast-acting nitrogen. Do not use after July; use an autumn fertilizer in autumn.',
      ),
      steps: [
        ProgramStep(
          id: 'spring',
          product: LocalizedText.same('YaraMila Complex'),
          doseFrom: 25,
          doseTo: 30,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: LocalizedText(
            pl: 'Gdy gleba ma powyżej 5–8°C. Po aplikacji obficie podlej',
            en: 'When the soil is above 5–8°C. Water generously after applying',
          ),
        ),
        ProgramStep(
          id: 'late-spring',
          product: LocalizedText.same('YaraMila Complex'),
          doseFrom: 20,
          doseTo: 25,
          fromMonth: DateTime.may,
          toMonth: DateTime.june,
          note: LocalizedText(
            pl: 'Dzień lub dwa po koszeniu, nie na świeżo skoszoną trawę',
            en: 'A day or two after mowing, not on freshly cut grass',
          ),
        ),
        ProgramStep(
          id: 'july',
          product: LocalizedText.same('YaraMila Complex'),
          doseFrom: 15,
          doseTo: 20,
          fromMonth: DateTime.july,
          toMonth: DateTime.july,
          note: LocalizedText(
            pl: 'Ostatnie nawożenie w sezonie. Na glebach lekkich i młodych trawnikach dolny zakres dawki',
            en: 'Last feed of the season. On light soils and young lawns use the lower dose',
          ),
        ),
      ],
    ),
  ],
);
