import 'package:lawnly/data/programs/fertilizer_program.dart';
import 'package:lawnly/data/programs/icl_programs.dart';
import 'package:lawnly/data/programs/mr_green_grass_programs.dart';
import 'package:lawnly/data/programs/yara_programs.dart';

const programSources = [iclPrograms, mrGreenGrassPrograms, yaraPrograms];

FertilizerProgram? programById(String? id) {
  for (final source in programSources) {
    for (final program in source.programs) {
      if (program.id == id) return program;
    }
  }
  return null;
}

ProgramSource? sourceOf(FertilizerProgram program) {
  for (final source in programSources) {
    if (source.programs.contains(program)) return source;
  }
  return null;
}
