import 'package:lawnly/core/l10n/localized_text.dart';
import 'package:lawnly/data/programs/fertilizer_program.dart';

const mrGreenGrassPrograms = ProgramSource(
  brand: 'Mr. Green Grass',
  site: 'mrgreengrass.pl',
  programs: [
    FertilizerProgram(
      id: 'mgg-four-steps',
      brand: 'Mr. Green Grass',
      name: LocalizedText(pl: 'Program w 4 krokach', en: '4-step program'),
      summary: LocalizedText(
        pl: 'Cztery nawozy kontrolowanego uwalniania, każdy raz w sezonie, co około 8 tygodni.',
        en: 'Four controlled-release fertilizers, each once a season, about every 8 weeks.',
      ),
      steps: [
        ProgramStep(
          id: 'early-spring',
          product: LocalizedText.same('Nawóz wczesnowiosenny – Szybka regeneracja'),
          doseFrom: 30,
          doseTo: 40,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: LocalizedText(
            pl: 'Po skoszeniu na 5 cm, gdy ziemia nie jest zamarznięta',
            en: 'After mowing to 5 cm, when the ground is not frozen',
          ),
        ),
        ProgramStep(
          id: 'spring',
          product: LocalizedText.same('Nawóz wiosenny – Intensywny wzrost'),
          doseFrom: 30,
          doseTo: 40,
          fromMonth: DateTime.may,
          toMonth: DateTime.june,
          note: LocalizedText(
            pl: 'Około 8 tygodni po kroku pierwszym',
            en: 'About 8 weeks after step one',
          ),
        ),
        ProgramStep(
          id: 'summer',
          product: LocalizedText.same('Nawóz letni – Kompleksowa ochrona'),
          doseFrom: 30,
          doseTo: 40,
          fromMonth: DateTime.july,
          toMonth: DateTime.august,
          note: LocalizedText(
            pl: 'Najlepiej wieczorem lub rano na suchą trawę, nie w czasie suszy',
            en: 'Best in the evening or morning on dry grass, not during drought',
          ),
        ),
        ProgramStep(
          id: 'autumn',
          product: LocalizedText.same('Nawóz jesienny – Bezpieczna zima'),
          doseFrom: 30,
          doseTo: 40,
          fromMonth: DateTime.september,
          toMonth: DateTime.november,
          note: LocalizedText(pl: 'Zanim ziemia zamarznie', en: 'Before the ground freezes'),
        ),
      ],
    ),
  ],
);
