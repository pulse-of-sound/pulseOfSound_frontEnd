import 'package:flutter/material.dart';
import '../model/consultation_models.dart';
import '../utils/bookings_prefs.dart';

import 'booking_card.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  List<Booking> bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final list = await BookingsPrefs.load();
    setState(() => bookings = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("حجوزاتي"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/booking.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, i) => BookingCard(
            booking: bookings[i],
            onCancel: () async {
              bookings[i].status = BookingStatus.cancelled;
              await BookingsPrefs.update(bookings[i]);
              _loadBookings();
            },
          ),
        ),
      ),
    );
  }
}
