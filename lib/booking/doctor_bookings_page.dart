import 'package:doctors_app/reporting/pdf_generator.dart';
import 'package:doctors_app/widgets/booking_card.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DoctorBookingsPage extends StatefulWidget {
  const DoctorBookingsPage({super.key});

  @override
  State<DoctorBookingsPage> createState() => _DoctorBookingsPageState();
}

class _DoctorBookingsPageState extends State<DoctorBookingsPage> with AutomaticKeepAliveClientMixin<DoctorBookingsPage> {
  @override
  bool get wantKeepAlive => true;

  var logger = Logger();

  final BookingService _bookingService = BookingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PdfGenerator _pdfGenerator = PdfGenerator();
  List<Booking> _bookings = <Booking>[];
  bool _isLoading = true;
  List<String> statuses = ['Pending', 'Confirmed', 'Cancelled'];
  String? currentStatus = 'Pending';

  void getBookings() async {
    _bookings = await _bookingService.getAllBookingsByDoctorId(_auth.currentUser!.uid);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getBookings();
  }

  void showPdfPreview(pw.Document pdf) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('PDF Preview'),
          content: SizedBox(
            height: 600,
            width: 400,
            child: PdfPreview(
              build: (format) => pdf.save(),
              canChangeOrientation: false,
              canChangePageFormat: false,
              allowPrinting: true,
              allowSharing: true,
              pdfFileName: 'Bookings_Report.pdf',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateReportBookingsInPeriod() async {
    DateTime now = DateTime.now();
    DateTime initialStartDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime initialEndDate = DateTime.now();

    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: initialStartDate, end: initialEndDate),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime.now(),
      helpText: 'Select Date Range for Report',
      cancelText: 'Cancel',
      confirmText: 'Generate',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      DateTime startDate = pickedDateRange.start;
      DateTime endDate = DateTime(pickedDateRange.end.year, pickedDateRange.end.month, pickedDateRange.end.day, 23, 59, 59);


      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        final pdf = await _pdfGenerator.bookingsInPeriod(startDate, endDate);
        
        if (!mounted) return;
        Navigator.of(context).pop();

        if (pdf != null) {
          showPdfPreview(pdf);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No bookings found for the selected period.')),
          );
        }

      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
        logger.e("Error generating PDF: $e");
      }
    } else {
      logger.e("Date range selection cancelled.");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings found.'))
              : Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _generateReportBookingsInPeriod, 
                      child: const Text('Generate Report'),
                    )
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return BookingCard(
                            booking: booking,
                            onStatusUpdated: () {
                              getBookings();
                            }
                          );
                        },
                      ),
                  ),
                ],
              )
    );
  }
   
}