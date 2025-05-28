// test/services/patient_service_test.dart
import 'package:doctors_app/services/patient_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirebaseDatabase, DatabaseReference, DataSnapshot, DatabaseEvent])
import 'patient_service_test.mocks.dart';

void main() {
  late PatientService patientService;
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

    patientService = PatientService.withDbRef(patientRef: mockDatabaseReference);
  });

  group('PatientService', () {
    test('checkUniqueCnp returns false if CNP exists', () async {
      when(mockDataSnapshot.exists).thenReturn(true);
      
      final isUnique = await patientService.checkUniqueCnp('some_cnp');

      expect(isUnique, false);
    });

    test('checkUniqueCnp returns true if CNP does not exist', () async {
      when(mockDataSnapshot.exists).thenReturn(false);

      final isUnique = await patientService.checkUniqueCnp('some_other_cnp');

      expect(isUnique, true);
    });
  });
}