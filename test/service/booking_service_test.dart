import 'package:mockito/annotations.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';
import 'package:doctors_app/model/booking.dart';


@GenerateMocks([FirebaseDatabase, DatabaseReference, DataSnapshot, DatabaseEvent])
import 'booking_service_test.mocks.dart';

void main() {
  late BookingService bookingService;
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

    bookingService = BookingService.withDbRef(bookingRef: mockDatabaseReference);
  });

  group('BookingService', () {
    test('getAllBookingsByPatientId returns empty list if no bookings found', () async {
      when(mockDataSnapshot.exists).thenReturn(false);

      final bookings = await bookingService.getAllBookingsByPatientId('patient_id');

      expect(bookings, isEmpty);
    });

    test('getAllBookingsByPatientId returns list of bookings', () async {
      final bookingMap = {
        'booking1': {'id': 'booking1', 'patientId': 'patient_id', 'doctorId': 'doctor_id'},
        'booking2': {'id': 'booking2', 'patientId': 'patient_id', 'doctorId': 'doctor_id'}
      };
      when(mockDataSnapshot.exists).thenReturn(true);
      when(mockDataSnapshot.value).thenReturn(bookingMap);

      final bookings = await bookingService.getAllBookingsByPatientId('patient_id');

      expect(bookings.length, 2);
      expect(bookings[0].id, 'booking1');
      expect(bookings[1].id, 'booking2');
    });
  });
}