import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:doctors_app/services/patient_service.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BookingWithPatient {
  final Booking booking;
  final Patient patient;

  BookingWithPatient({required this.booking, required this.patient});
}

class PdfGenerator {
  final BookingService _bookingService = BookingService();
  final UserDataService _userDataService = UserDataService();
  final PatientService _patientService = PatientService();

  Future<pw.Document> bookingsInPeriod(DateTime periodStart, DateTime periodEnd) async {
    List<Booking> bookings = await _bookingService.getAllDoctorBookingsInPeriod(_userDataService.doctor!.uid, periodStart, periodEnd);
    Cabinet cabinet = _userDataService.cabinet ?? Cabinet.empty();
    Doctor doctor = _userDataService.doctor ?? Doctor.empty();
    final pdf = pw.Document();
    final image = pw.Image(await imageFromAssetBundle('lib/assets/images/doctors_symbol.png'));
    
    List<BookingWithPatient> bookingsWithPatients = [];
    for (var booking in bookings) {
      Patient patientData;
      if (booking.patientId.isNotEmpty) {
        patientData = await _patientService.getPatientById(booking.patientId) ?? Patient.empty();
      } else {
        patientData = Patient.empty();
      }
      bookingsWithPatients.add(BookingWithPatient(booking: booking, patient: patientData));
    }

    pdf.addPage(
      pw.Page(build: (context) => pw.Center(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8.0),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            ),
          ),
          child: pw.Column(
            children: [
              //Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Programări",
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold
                        ),
                      ),
                      pw.Text(
                        "În perioada: ${DateFormat("dd.MM.yyyy").format(periodStart)} ${DateFormat("dd.MM.yyyy").format(periodEnd)}",
                        style: const pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.Text(
                        "Cabinet: ${cabinet.name}",
                        style: const pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.Text(
                        "Doctor: ${doctor.lastName} ${doctor.lastName}",
                        style: const pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ]
                  ),
                  pw.Container(
                    width: 75,
                    height: 100,
                    child: image,
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              //Table header
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#007f00')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Pacient',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Data',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Ora',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Descriere',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Rezultat',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Recomandari',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Status',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Rezultat analize',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  //Table data
                  ...bookingsWithPatients.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            '${item.patient.lastName} ${item.patient.firstName}',
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            item.booking.date,
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            item.booking.time,
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            item.booking.description,
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            item.booking.results,
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            item.booking.recommendations,
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            item.booking.status,
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: item.booking.analysisResultsPdf.isNotEmpty ? 
                          pw.UrlLink(
                            child: pw.Text(
                              'Link',
                              style: const pw.TextStyle(fontSize: 6, color: PdfColors.blue, decoration: pw.TextDecoration.underline),
                            ), 
                            destination: item.booking.analysisResultsPdf,
                          )
                          : pw.Text(
                            'N/A',
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                      ],
                    )
                  ),
                ]
              ),
            ],
          ),
        ),
      )),
    );

    return pdf;
  }
}