import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class CompleteBookingPage extends StatefulWidget {
  CompleteBookingPage({super.key, required this.booking});

  final Booking booking;

  @override
  State<CompleteBookingPage> createState() => _CompleteBookingPageState();
}

class _CompleteBookingPageState extends State<CompleteBookingPage> {
  final BookingService _bookingService = BookingService();

  final TextEditingController _resultsController = TextEditingController();

  final TextEditingController _recommendationsController = TextEditingController();

  bool _addAnalysis = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.completeBooking.getString(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: LocaleData.resultsLabel.getString(context)),
              controller: _resultsController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: LocaleData.recommendationsLabel.getString(context)),
              controller: _recommendationsController,
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: Text(LocaleData.addAnalysis.getString(context)),
              value: _addAnalysis,
              onChanged: (bool? value) {
                setState(() {
                _addAnalysis = value ?? false;
                });
              },
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                widget.booking.recommendations = _recommendationsController.text;
                widget.booking.results = _resultsController.text;
                widget.booking.status = _addAnalysis ? 'AnalysisPending' : 'Completed';
                _bookingService.completeBooking(widget.booking.id, widget.booking.status, widget.booking.recommendations, widget.booking.results);
                Navigator.of(context).pop();
              },
              child: Text(LocaleData.completeBooking.getString(context)),
            ),
          ],
        ),
      ),
    );
  }
}