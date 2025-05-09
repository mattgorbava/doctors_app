class Consultation {
  String title;
  int periodInMonths;
  int ageInMonthsStart;
  int ageInMonthsEnd;

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

  factory Consultation.empty() {
    return Consultation(
      title: '',
      periodInMonths: 0,
      ageInMonthsStart: 0,
      ageInMonthsEnd: 0,
    );
  }

  bool get isEmpty {
    return title.isEmpty && periodInMonths == 0 && ageInMonthsStart == 0 && ageInMonthsEnd == 0;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }
}