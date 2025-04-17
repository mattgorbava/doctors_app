import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key, required this.patient, required this.cabinet, required this.desiredDate, this.description});

  final Patient patient;
  final Cabinet cabinet;
  final DateTime desiredDate;
  final String? description;

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late List<Booking> _bookings;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _focusedDay;
  Map<DateTime, bool> _availabilityCache = {};
  bool _isLoading = true;
  DateTime? firstDay;
  DateTime? lastDay;

  final _descriptionController = TextEditingController();
  bool _prefillDescription = false;
  bool _mandatoryConsultation = false;
  
  @override
  void initState() {
    super.initState();
    _fetchBookings().then((_) {
      _precomputeAvailability(widget.desiredDate);
    });
    if (widget.description != null) {
      _descriptionController.text = widget.description!;
      _prefillDescription = true;
      _mandatoryConsultation = true;
    }
    selectedDate = widget.desiredDate;
    _focusedDay = widget.desiredDate;
  }

  DateTime _firstOfTheMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime _lastOfTheMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
  
  Future<void> _fetchBookings() async {
    DatabaseReference _bookingsRef = FirebaseDatabase.instance.ref().child('Bookings');

    try {
        await _bookingsRef.orderByChild('doctorId').equalTo(widget.cabinet.doctorId).once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        List<Booking> bookings = [];

        if (snapshot.value != null) {
          Map<dynamic, dynamic> bookingMap = snapshot.value as Map<dynamic, dynamic>;
          bookingMap.forEach((key, value) {
            bookings.add(Booking.fromMap(Map<String, dynamic>.from(value)));
          });
        }

        setState(() {
          _bookings = bookings;
        });
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not get bookings.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<bool> _dayHasAvailableSlots(DateTime date) {
    List<TimeOfDay> allSlots = _generateTimeSlots(date);
    
    List<TimeOfDay> bookedSlots = _getBookedSlotsForDate(date);
    
    allSlots.removeWhere((slot) => bookedSlots.contains(slot));
    
    return Future.value(allSlots.isNotEmpty);
  }
  
  List<TimeOfDay> _generateTimeSlots(DateTime date) {
    List<TimeOfDay> slots = [];
    Duration openDuration = calculateOpenDuration();
    int slotDurationMinutes = 15;
    
    List<String> openingParts = widget.cabinet.openingTime.split(':');
    int startHour = int.parse(openingParts[0]);
    int startMinute = int.parse(openingParts[1]);
    
    int totalSlots = openDuration.inMinutes ~/ slotDurationMinutes;
    
    for (int i = 0; i < totalSlots; i++) {
      int minutes = startMinute + (i * slotDurationMinutes);
      int hours = startHour + (minutes ~/ 60);
      minutes = minutes % 60;
      
      slots.add(TimeOfDay(hour: hours, minute: minutes));
    }
    
    return slots;
  }
  
  List<TimeOfDay> _getBookedSlotsForDate(DateTime date) {
    String dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    List<TimeOfDay> bookedTimes = [];
    
    for (Booking booking in _bookings) {
      if (booking.date == dateStr && booking.status != 'Cancelled') {
        List<String> timeParts = booking.time.split(':');
        bookedTimes.add(TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        ));
      }
    }
    
    return bookedTimes;
  }
  
  Future<void> _precomputeAvailability(DateTime desiredDate) async {
    setState(() {
      _isLoading = true;
    });
    
    desiredDate.subtract(const Duration(days: 30));
    DateTime now = DateTime.now();
    if (desiredDate.isBefore(now)) {
      desiredDate = now;
      firstDay = _firstOfTheMonth(now.subtract(const Duration(days: 30)));
      lastDay = _lastOfTheMonth(now.add(const Duration(days: 30)));
    } else {
      firstDay = _firstOfTheMonth(desiredDate.subtract(const Duration(days: 30)));
      lastDay = _lastOfTheMonth(desiredDate.add(const Duration(days: 30)));
    }

    _availabilityCache.clear();
    DateTime date = firstDay!;
    for (int i = 1; i < 90 && date.isBefore(lastDay!); i++) {
      date = firstDay!.add(Duration(days: i));
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      bool hasSlots = await _dayHasAvailableSlots(date);
      _availabilityCache[normalizedDate] = hasSlots;
    }
    
    setState(() {
      _isLoading = false;
    });
  }


  Duration calculateOpenDuration() {
    List<String> openingParts = widget.cabinet.openingTime.split(':');
    List<String> closingParts = widget.cabinet.closingTime.split(':');
    
    int openingHour = int.parse(openingParts[0]);
    int openingMinute = int.parse(openingParts[1]);
    int closingHour = int.parse(closingParts[0]);
    int closingMinute = int.parse(closingParts[1]);
    
    DateTime now = DateTime.now();
    DateTime opening = DateTime(
      now.year, now.month, now.day, openingHour, openingMinute);
    DateTime closing = DateTime(
      now.year, now.month, now.day, closingHour, closingMinute);
    
    if (closing.isBefore(opening)) {
      closing = closing.add(const Duration(days: 1));
    }
    
    return closing.difference(opening);
  }

  Future<void> _selectTimeSlot() async {
    List<TimeOfDay> availableSlots = _generateTimeSlots(selectedDate!);
    
    List<TimeOfDay> bookedSlots = _getBookedSlotsForDate(selectedDate!);
    availableSlots.removeWhere((slot) => bookedSlots.contains(slot));
    
    if (availableSlots.isNotEmpty) {
      TimeOfDay? selectedSlot = await showDialog<TimeOfDay>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select a time slot'),
            content: SingleChildScrollView(
              child: ListBody(
                children: availableSlots.map((slot) {
                  return ListTile(
                    title: Text('${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}'),
                    onTap: () {
                      Navigator.of(context).pop(slot);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
      
      if (selectedSlot != null) {
        setState(() {
          selectedTime = selectedSlot;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available time slots for this date')),
      );
    }
  }

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try{
        DatabaseReference _bookingsRef = FirebaseDatabase.instance.ref().child('Bookings');

        if (selectedDate == null || selectedTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a date and time')),
          );
          return;
        }
        
        String dateStr = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
        String timeStr = "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
        
        Map<String, dynamic> bookingData = {
          'patientId': widget.patient.uid,
          'doctorId': widget.cabinet.doctorId,
          'date': dateStr,
          'time': timeStr,
          'description': _descriptionController.text,
          'status': 'Pending',
          'isMandatory': _mandatoryConsultation,
        };

        String bookingId = _bookingsRef.push().key!;
        await _bookingsRef.child(bookingId).set(bookingData).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment booked successfully')),
          );
          Navigator.pop(context);
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to book appointment')),
          );
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to book appointment')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Appointment'),
        ),
        body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select a date:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          firstDay: firstDay!,
                          lastDay: lastDay!,
                          focusedDay: _focusedDay!,
                          calendarFormat: _calendarFormat,
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false
                          ),
                          selectedDayPredicate: (day) {
                            return isSameDay(selectedDate, day);
                          },
                          enabledDayPredicate: (day) {
                            return day.weekday != DateTime.sunday && day.weekday != DateTime.saturday;
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              selectedDate = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            
                            bool hasSlots = _availabilityCache[DateTime(
                              selectedDay.year, selectedDay.month, selectedDay.day
                            )] ?? false;
                            
                            if (hasSlots) {
                              _selectTimeSlot();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No available slots for this day')),
                              );
                            }
                          },
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            selectedDecoration: const BoxDecoration(
                              color: Color(0xFF2B962B),
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Color(0xFF2B962B).withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            weekendTextStyle: const TextStyle(
                              color: Colors.grey
                            ),
                            disabledTextStyle: const TextStyle(
                              color: Colors.grey
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
                                return null;
                              }
                              DateTime normalizedDate = DateTime(date.year, date.month, date.day);
                              bool? hasSlots = _availabilityCache[normalizedDate];
                              
                              if (hasSlots != null) {
                                return Positioned(
                                  bottom: 1,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: hasSlots ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (selectedDate != null && selectedTime != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Selected Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}\n\nSelectedTime: ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: _descriptionController,
                        maxLength: 240,
                        readOnly: _prefillDescription,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _bookAppointment();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B962B),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Book Appointment', style: TextStyle(fontSize: 16, color: Colors.white),),
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ),
      ),
    );
  }
}