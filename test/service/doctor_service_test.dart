import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:doctors_app/services/doctor_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirebaseDatabase, DatabaseReference, DataSnapshot, DatabaseEvent])
import 'doctor_service_test.mocks.dart';

void main() {
  late DoctorService doctorService;
  late MockFirebaseDatabase mockFirebaseDatabase;
  late MockDatabaseReference mockDatabaseReference;
  late MockDataSnapshot mockDataSnapshot;
  late MockDatabaseEvent mockDatabaseEvent;

  setUp(() {
    mockFirebaseDatabase = MockFirebaseDatabase();
    mockDatabaseReference = MockDatabaseReference();
    mockDataSnapshot = MockDataSnapshot();
    mockDatabaseEvent = MockDatabaseEvent();

    when(mockFirebaseDatabase.ref()).thenReturn(mockDatabaseReference);
    when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
    when(mockDatabaseReference.orderByChild(any)).thenReturn(mockDatabaseReference);
    when(mockDatabaseReference.equalTo(any)).thenReturn(mockDatabaseReference);
    when(mockDatabaseReference.once()).thenAnswer((_) async => mockDatabaseEvent);
    when(mockDatabaseEvent.snapshot).thenReturn(mockDataSnapshot);

    doctorService = DoctorService.withDbRef(doctorRef: mockDatabaseReference);
  });

  group('DoctorService', () {
    test('getDoctorById returns empty doctor if id is empty', () async {
      final doctor = await doctorService.getDoctorById('');
      expect(doctor.isEmpty, isTrue);
    });

    test('getDoctorById returns doctor if found', () async {
      final mockDoctorData = {'firstName': 'Test', 'lastName': 'Doctor'};
      when(mockDataSnapshot.exists).thenReturn(true);
      when(mockDataSnapshot.value).thenReturn(mockDoctorData);

      final doctor = await doctorService.getDoctorById('doctor_id');
      expect(doctor.firstName, 'Test');
      expect(doctor.lastName, 'Doctor');
    });
  });
}