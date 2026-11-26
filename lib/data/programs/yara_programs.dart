import 'package:lawnly/data/programs/fertilizer_program.dart';

const yaraPrograms = ProgramSource(
  brand: 'YaraMila Complex',
  site: 'e-hortico.pl',
  programs: [
    FertilizerProgram(
      id: 'yara-complex-lawn',
      brand: 'YaraMila Complex',
      name: 'Trawnik: 3 aplikacje do lipca',
      summary:
          'Nawóz o szybko działającym azocie. Po lipcu nie stosować, jesienią użyj nawozu jesiennego.',
      steps: [
        ProgramStep(
          id: 'spring',
          product: 'YaraMila Complex',
          doseFrom: 25,
          doseTo: 30,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: 'Gdy gleba ma powyżej 5–8°C. Po aplikacji obficie podlej',
        ),
        ProgramStep(
          id: 'late-spring',
          product: 'YaraMila Complex',
          doseFrom: 20,
          doseTo: 25,
          fromMonth: DateTime.may,
          toMonth: DateTime.june,
          note: 'Dzień lub dwa po koszeniu, nie na świeżo skoszoną trawę',
        ),
        ProgramStep(
          id: 'july',
          product: 'YaraMila Complex',
          doseFrom: 15,
          doseTo: 20,
          fromMonth: DateTime.july,
          toMonth: DateTime.july,
          note:
              'Ostatnie nawożenie w sezonie. Na glebach lekkich i młodych trawnikach dolny zakres dawki',
        ),
      ],
    ),
  ],
);
