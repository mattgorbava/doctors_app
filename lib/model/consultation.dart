class Consultation {
  final String title;
  final int periodInMonths;
  final int ageInMonthsStart;
  final int ageInMonthsEnd;

  Consultation({
    required this.title,
    required this.periodInMonths,
    required this.ageInMonthsStart,
    required this.ageInMonthsEnd,
  });

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      title: map['title'] ?? '',
      periodInMonths: int.parse(map['periodInMonths']) ?? 0,
      ageInMonthsStart: int.parse(map['ageInMonthsStart']) ?? 0,
      ageInMonthsEnd: int.parse(map['ageInMonthsEnd']) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'periodInMonths': periodInMonths,
      'ageInMonthsStart': ageInMonthsStart,
      'ageInMonthsEnd': ageInMonthsEnd,
    };
  }
}