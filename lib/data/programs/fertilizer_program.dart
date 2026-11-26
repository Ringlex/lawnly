import 'package:lawnly/data/plan/care_plan.dart';

class ProgramStep {
  const ProgramStep({
    required this.id,
    required this.product,
    required this.fromMonth,
    required this.toMonth,
    this.kind = CareKind.fertilizing,
    this.doseFrom,
    this.doseTo,
    this.note,
  });

  final String id;
  final String product;
  final int fromMonth;
  final int toMonth;
  final CareKind kind;

  final int? doseFrom;
  final int? doseTo;

  final String? note;

  bool get hasDose => doseFrom != null;

  double get dose => ((doseFrom ?? 0) + (doseTo ?? doseFrom ?? 0)) / 2;
}

class FertilizerProgram {
  const FertilizerProgram({
    required this.id,
    required this.brand,
    required this.name,
    required this.summary,
    required this.steps,
  });

  final String id;
  final String brand;
  final String name;
  final String summary;
  final List<ProgramStep> steps;
}

class ProgramSource {
  const ProgramSource({required this.brand, required this.site, required this.programs});

  final String brand;
  final String site;
  final List<FertilizerProgram> programs;
}
