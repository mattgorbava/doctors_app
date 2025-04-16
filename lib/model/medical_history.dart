class MedicalHistory {
  String id;
  String bookingId;
  String results;
  String recommendations;

  MedicalHistory({
    required this.id,
    required this.bookingId,
    required this.results,
    required this.recommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'results': results,
      'recommendations': recommendations,
    };
  }

  factory MedicalHistory.fromMap(Map<String, dynamic> json, [String id = '']) {
    return MedicalHistory(
      id: id,
      bookingId: json['bookingId'],
      results: json['results'],
      recommendations: json['recommendations'],
    );
  }
}