class GrowingSeason {
  const GrowingSeason({
    this.startMonth = DateTime.april,
    this.startDay = 1,
    this.endMonth = DateTime.october,
    this.endDay = 31,
  });

  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;

  DateTime startOf(int year) => DateTime(year, startMonth, startDay);

  DateTime endOf(int year) => DateTime(year, endMonth, endDay);

  bool contains(DateTime date) =>
      !date.isBefore(startOf(date.year)) && !date.isAfter(endOf(date.year));

  DateTime startAfter(DateTime date) =>
      date.isBefore(startOf(date.year)) ? startOf(date.year) : startOf(date.year + 1);

  @override
  bool operator ==(Object other) =>
      other is GrowingSeason &&
      other.startMonth == startMonth &&
      other.startDay == startDay &&
      other.endMonth == endMonth &&
      other.endDay == endDay;

  @override
  int get hashCode => Object.hash(startMonth, startDay, endMonth, endDay);
}
