import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:doctors_app/services/cabinet_service.dart';
import 'package:mockito/mockito.dart';
import 'package:doctors_app/model/cabinet.dart';

@GenerateMocks([FirebaseDatabase, DatabaseReference, DataSnapshot, DatabaseEvent])
import 'cabinet_service_test.mocks.dart';

void main() {
  late CabinetService cabinetService;
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

    cabinetService = CabinetService.withDbRef(cabinetRef: mockDatabaseReference);
  });

  group('CabinetService', () {
    test('getCabinetById returns empty cabinet if id is empty', () async {
      final cabinet = await cabinetService.getCabinetById('');
      expect(cabinet.isEmpty, isTrue);
    });

    test('getCabinetById throws exception if cabinet not found', () async {
      when(mockDataSnapshot.exists).thenReturn(false);

      expect(() async => await cabinetService.getCabinetById('non_existing_id'), throwsException);
    });

    test('getCabinetById returns cabinet if found', () async {
      final mockCabinetData = {
        'name': 'Test Cabinet', 
        'doctorId': 'doctor_id',
      };
      when(mockDataSnapshot.exists).thenReturn(true);
      when(mockDataSnapshot.value).thenReturn(mockCabinetData);

      final cabinet = await cabinetService.getCabinetById('cabinet_id');
      expect(cabinet.name, 'Test Cabinet');
      expect(cabinet.doctorId, 'doctor_id');
    });
  });
}