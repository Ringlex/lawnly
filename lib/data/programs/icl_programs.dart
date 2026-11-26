import 'package:lawnly/core/l10n/localized_text.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/programs/fertilizer_program.dart';

const _preWinterTipPl =
    ' Porada ICL: dodatkowo Landscaper Pro Pre Winter, 35 g/m², wrzesień–październik.';
const _preWinterTipEn = ' ICL tip: also Landscaper Pro Pre Winter, 35 g/m², September–October.';

const iclPrograms = ProgramSource(
  brand: 'ICL',
  site: 'icl-growingsolutions.com',
  programs: [
    FertilizerProgram(
      id: 'icl-one',
      brand: 'ICL',
      name: LocalizedText(pl: 'Jedna aplikacja w sezonie', en: 'One application per season'),
      summary: LocalizedText(
        pl: 'Minimum pracy: jeden nawóz o przedłużonym działaniu na 5–6 miesięcy.$_preWinterTipPl',
        en: 'Minimum work: one long-lasting fertilizer for 5–6 months.$_preWinterTipEn',
      ),
      steps: [
        ProgramStep(
          id: 'sierrablen',
          product: LocalizedText.same('Sierrablen 28-5-5 Fe'),
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
      name: LocalizedText(pl: 'Dwie aplikacje', en: 'Two applications'),
      summary: LocalizedText(
        pl: 'Prosty program: start sezonu i intensywny wzrost w maju.$_preWinterTipPl',
        en: 'A simple program: season start and strong growth in May.$_preWinterTipEn',
      ),
      steps: [
        ProgramStep(
          id: 'maintenance',
          product: LocalizedText.same('Landscaper Pro Maintenance'),
          doseFrom: 35,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: LocalizedText(pl: 'Wczesna wiosna', en: 'Early spring'),
        ),
        ProgramStep(
          id: 'allround',
          product: LocalizedText.same('Landscaper Pro All Round'),
          doseFrom: 40,
          fromMonth: DateTime.may,
          toMonth: DateTime.may,
        ),
      ],
    ),
    FertilizerProgram(
      id: 'icl-three',
      brand: 'ICL',
      name: LocalizedText(pl: 'Trzy aplikacje', en: 'Three applications'),
      summary: LocalizedText(
        pl: 'Intensywna pielęgnacja przez cały sezon, także przed zimą.$_preWinterTipPl',
        en: 'Intensive care all season, including before winter.$_preWinterTipEn',
      ),
      steps: [
        ProgramStep(
          id: 'maintenance',
          product: LocalizedText.same('Landscaper Pro Maintenance'),
          doseFrom: 35,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: LocalizedText(pl: 'Wczesna wiosna', en: 'Early spring'),
        ),
        ProgramStep(
          id: 'allround',
          product: LocalizedText.same('Landscaper Pro All Round'),
          doseFrom: 40,
          fromMonth: DateTime.may,
          toMonth: DateTime.may,
        ),
        ProgramStep(
          id: 'stress',
          product: LocalizedText.same('Landscaper Pro Stress Control'),
          doseFrom: 35,
          fromMonth: DateTime.august,
          toMonth: DateTime.september,
          note: LocalizedText(
            pl: 'Późne lato lub początek jesieni',
            en: 'Late summer or early autumn',
          ),
        ),
      ],
    ),
    FertilizerProgram(
      id: 'icl-overseed-eco',
      brand: 'ICL',
      name: LocalizedText(pl: 'Dosiewka: program oszczędny', en: 'Overseeding: economy program'),
      summary: LocalizedText(
        pl: 'Jedno nawożenie przy dosiewce. Alternatywa: All Round 45 g/m² w maju lub czerwcu.$_preWinterTipPl',
        en: 'One feed at overseeding. Alternative: All Round 45 g/m² in May or June.$_preWinterTipEn',
      ),
      steps: [
        ProgramStep(
          id: 'overseed',
          product: LocalizedText(
            pl: 'Dosiewka nasion Landscaper Pro',
            en: 'Overseed with Landscaper Pro seed',
          ),
          kind: CareKind.overseeding,
          fromMonth: DateTime.march,
          toMonth: DateTime.may,
        ),
        ProgramStep(
          id: 'sierrablen',
          product: LocalizedText.same('Sierrablen 28-5-5 Fe'),
          doseFrom: 55,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
          note: LocalizedText(
            pl: 'Można zastosować tuż po dosiewce',
            en: 'Can be applied right after overseeding',
          ),
        ),
      ],
    ),
    FertilizerProgram(
      id: 'icl-overseed-standard',
      brand: 'ICL',
      name: LocalizedText(pl: 'Dosiewka: program standardowy', en: 'Overseeding: standard program'),
      summary: LocalizedText(
        pl: 'Dwa okresy nawożenia: wiosenna regeneracja i wsparcie latem. Porada ICL: dodatkowo Landscaper Pro Pre Winter, 35 g/m², we wrześniu.',
        en: 'Two feeding periods: spring recovery and summer support. ICL tip: also Landscaper Pro Pre Winter, 35 g/m², in September.',
      ),
      steps: [
        ProgramStep(
          id: 'overseed',
          product: LocalizedText(
            pl: 'Dosiewka nasion Landscaper Pro',
            en: 'Overseed with Landscaper Pro seed',
          ),
          kind: CareKind.overseeding,
          fromMonth: DateTime.march,
          toMonth: DateTime.may,
        ),
        ProgramStep(
          id: 'allround',
          product: LocalizedText.same('Landscaper Pro All Round'),
          doseFrom: 45,
          fromMonth: DateTime.march,
          toMonth: DateTime.may,
          note: LocalizedText(pl: 'Od razu po dosiewce', en: 'Right after overseeding'),
        ),
        ProgramStep(
          id: 'stress',
          product: LocalizedText.same('Landscaper Pro Stress Control'),
          doseFrom: 30,
          fromMonth: DateTime.july,
          toMonth: DateTime.august,
          note: LocalizedText(
            pl: 'W tym okresie można wykonać kolejną dosiewkę',
            en: 'You can overseed again in this period',
          ),
        ),
      ],
    ),
    FertilizerProgram(
      id: 'icl-overseed-premium',
      brand: 'ICL',
      name: LocalizedText(pl: 'Dosiewka: program Premium', en: 'Overseeding: Premium program'),
      summary: LocalizedText(
        pl: 'Trzy aplikacje dla trawników o wysokich wymaganiach, z dosiewką wiosną. Opcjonalnie jesienna dosiewka nasion Landscaper Pro: od drugiej połowy sierpnia do końca września.',
        en: 'Three applications for demanding lawns, with spring overseeding. Optional autumn overseeding with Landscaper Pro seed: from mid-August to the end of September.',
      ),
      steps: [
        ProgramStep(
          id: 'overseed-spring',
          product: LocalizedText(
            pl: 'Dosiewka nasion Landscaper Pro',
            en: 'Overseed with Landscaper Pro seed',
          ),
          kind: CareKind.overseeding,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
        ),
        ProgramStep(
          id: 'maintenance',
          product: LocalizedText.same('Landscaper Pro Maintenance'),
          doseFrom: 35,
          fromMonth: DateTime.march,
          toMonth: DateTime.april,
        ),
        ProgramStep(
          id: 'allround',
          product: LocalizedText.same('Landscaper Pro All Round'),
          doseFrom: 45,
          fromMonth: DateTime.may,
          toMonth: DateTime.may,
        ),
        ProgramStep(
          id: 'prewinter',
          product: LocalizedText.same('Landscaper Pro Pre Winter'),
          doseFrom: 45,
          fromMonth: DateTime.august,
          toMonth: DateTime.september,
        ),
      ],
    ),
  ],
);
