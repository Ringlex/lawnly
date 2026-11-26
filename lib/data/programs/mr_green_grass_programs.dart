import 'package:lawnly/data/programs/fertilizer_program.dart';

const mrGreenGrassPrograms = ProgramSource(
  brand: 'Mr. Green Grass',
  site: 'mrgreengrass.pl',
  programs: [
    FertilizerProgram(
      id: 'mgg-four-steps',
      brand: 'Mr. Green Grass',
      name: 'Program w 4 krokach',
      summary: 'Cztery nawozy kontrolowanego uwalniania, każdy raz w sezonie, co około 8 tygodni.',
      steps: [
        ProgramStep(
          id: 'early-spring',
          product: 'Nawóz wczesnowiosenny – Szybka regeneracja',
          doseFrom: 30,
          doseTo: 40,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: 'Po skoszeniu na 5 cm, gdy ziemia nie jest zamarznięta',
        ),
        ProgramStep(
          id: 'spring',
          product: 'Nawóz wiosenny – Intensywny wzrost',
          doseFrom: 30,
          doseTo: 40,
          fromMonth: DateTime.may,
          toMonth: DateTime.june,
          note: 'Około 8 tygodni po kroku pierwszym',
        ),
        ProgramStep(
          id: 'summer',
          product: 'Nawóz letni – Kompleksowa ochrona',
          doseFrom: 30,
          doseTo: 40,
          fromMonth: DateTime.july,
          toMonth: DateTime.august,
          note: 'Najlepiej wieczorem lub rano na suchą trawę, nie w czasie suszy',
        ),
        ProgramStep(
          id: 'autumn',
          product: 'Nawóz jesienny – Bezpieczna zima',
          doseFrom: 30,
          doseTo: 40,
          fromMonth: DateTime.september,
          toMonth: DateTime.november,
          note: 'Zanim ziemia zamarznie',
        ),
      ],
    ),
  ],
);
