class MedicalHistory {
  String id;
  String bookingId;
  String results;
  String recommendations;
  String analysisResultsPdfUrl;
  DateTime? dateAdded;

  MedicalHistory({
    required this.id,
    required this.bookingId,
    required this.results,
    required this.recommendations,
    required this.analysisResultsPdfUrl,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'results': results,
      'recommendations': recommendations,
      'analysisResultsPdfUrl': analysisResultsPdfUrl,
      'dateAdded': dateAdded?.toIso8601String(),
    };
  }

  factory MedicalHistory.fromMap(Map<String, dynamic> json, [String id = '']) {
    return MedicalHistory(
      id: id,
      bookingId: json['bookingId'],
      results: json['results'],
      recommendations: json['recommendations'],
      analysisResultsPdfUrl: json['analysisResultsPdfUrl'] ?? '',
      dateAdded: json['dateAdded'] != null ? DateTime.parse(json['dateAdded']) : null,
    );
  }
}