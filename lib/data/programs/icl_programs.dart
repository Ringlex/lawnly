import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/programs/fertilizer_program.dart';

const _preWinterTip =
    ' Porada ICL: dodatkowo Landscaper Pro Pre Winter, 35 g/m², wrzesień–październik.';

const iclPrograms = ProgramSource(
  brand: 'ICL',
  site: 'icl-growingsolutions.com',
  programs: [
    FertilizerProgram(
      id: 'icl-one',
      brand: 'ICL',
      name: 'Jedna aplikacja w sezonie',
      summary: 'Minimum pracy: jeden nawóz o przedłużonym działaniu na 5–6 miesięcy.$_preWinterTip',
      steps: [
        ProgramStep(
          id: 'sierrablen',
          product: 'Sierrablen 28-5-5 Fe',
          doseFrom: 45,
          doseTo: 55,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
        ),
      ],
    ),
    FertilizerProgram(
      id: 'icl-two',
      brand: 'ICL',
      name: 'Dwie aplikacje',
      summary: 'Prosty program: start sezonu i intensywny wzrost w maju.$_preWinterTip',
      steps: [
        ProgramStep(
          id: 'maintenance',
          product: 'Landscaper Pro Maintenance',
          doseFrom: 35,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: 'Wczesna wiosna',
        ),
        ProgramStep(
          id: 'allround',
          product: 'Landscaper Pro All Round',
          doseFrom: 40,
          fromMonth: DateTime.may,
          toMonth: DateTime.may,
        ),
      ],
    ),
    FertilizerProgram(
      id: 'icl-three',
      brand: 'ICL',
      name: 'Trzy aplikacje',
      summary: 'Intensywna pielęgnacja przez cały sezon, także przed zimą.$_preWinterTip',
      steps: [
        ProgramStep(
          id: 'maintenance',
          product: 'Landscaper Pro Maintenance',
          doseFrom: 35,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: 'Wczesna wiosna',
        ),
        ProgramStep(
          id: 'allround',
          product: 'Landscaper Pro All Round',
          doseFrom: 40,
          fromMonth: DateTime.may,
          toMonth: DateTime.may,
        ),
        ProgramStep(
          id: 'stress',
          product: 'Landscaper Pro Stress Control',
          doseFrom: 35,
          fromMonth: DateTime.august,
          toMonth: DateTime.september,
          note: 'Późne lato lub początek jesieni',
        ),
      ],
    ),
    FertilizerProgram(
      id: 'icl-overseed-eco',
      brand: 'ICL',
      name: 'Dosiewka: program oszczędny',
      summary:
          'Jedno nawożenie przy dosiewce. Alternatywa: All Round 45 g/m² w maju lub czerwcu.$_preWinterTip',
      steps: [
        ProgramStep(
          id: 'overseed',
          product: 'Dosiewka nasion Landscaper Pro',
          kind: CareKind.overseeding,
          fromMonth: DateTime.march,
          toMonth: DateTime.may,
        ),
        ProgramStep(
          id: 'sierrablen',
          product: 'Sierrablen 28-5-5 Fe',
          doseFrom: 55,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: 'Można zastosować tuż po dosiewce',
        ),
      ],
    ),
    FertilizerProgram(
      id: 'icl-overseed-standard',
      brand: 'ICL',
      name: 'Dosiewka: program standardowy',
      summary:
          'Dwa okresy nawożenia: wiosenna regeneracja i wsparcie latem. Porada ICL: dodatkowo Landscaper Pro Pre Winter, 35 g/m², we wrześniu.',
      steps: [
        ProgramStep(
          id: 'overseed',
          product: 'Dosiewka nasion Landscaper Pro',
          kind: CareKind.overseeding,
          fromMonth: DateTime.march,
          toMonth: DateTime.may,
        ),
        ProgramStep(
          id: 'allround',
          product: 'Landscaper Pro All Round',
          doseFrom: 45,
          fromMonth: DateTime.march,
          toMonth: DateTime.may,
          note: 'Od razu po dosiewce',
        ),
        ProgramStep(
          id: 'stress',
          product: 'Landscaper Pro Stress Control',
          doseFrom: 30,
          fromMonth: DateTime.july,
          toMonth: DateTime.august,
          note: 'W tym okresie można wykonać kolejną dosiewkę',
        ),
      ],
    ),
    FertilizerProgram(
      id: 'icl-overseed-premium',
      brand: 'ICL',
      name: 'Dosiewka: program Premium',
      summary:
          'Trzy aplikacje dla trawników o wysokich wymaganiach, z dosiewką wiosną. Opcjonalnie jesienna dosiewka nasion Landscaper Pro: od drugiej połowy sierpnia do końca września.',
      steps: [
        ProgramStep(
          id: 'overseed-spring',
          product: 'Dosiewka nasion Landscaper Pro',
          kind: CareKind.overseeding,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
        ),
        ProgramStep(
          id: 'maintenance',
          product: 'Landscaper Pro Maintenance',
          doseFrom: 35,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
        ),
        ProgramStep(
          id: 'allround',
          product: 'Landscaper Pro All Round',
          doseFrom: 45,
          fromMonth: DateTime.may,
          toMonth: DateTime.may,
        ),
        ProgramStep(
          id: 'prewinter',
          product: 'Landscaper Pro Pre Winter',
          doseFrom: 45,
          fromMonth: DateTime.august,
          toMonth: DateTime.september,
        ),
      ],
    ),
  ],
);
