import 'package:flutter/material.dart';
import '../utils/bookings_prefs.dart';
import '../model/consultation_models.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Booking> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final data = await BookingsPrefs.load();
    setState(() {
      _bookings = data;
      _loading = false;
    });
  }

  Future<void> _cancelBooking(Booking booking) async {
    booking.status = BookingStatus.cancelled;
    await BookingsPrefs.update(booking);
    await _loadBookings();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إلغاء الحجز بنجاح")),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
      case BookingStatus.processing:
        return Colors.orangeAccent;
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.redAccent;
      case BookingStatus.completed:
        return Colors.blueGrey;
      case BookingStatus.rejected:
        return Colors.red;
    }
  }

  String _statusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return "قيد الانتظار";
      case BookingStatus.processing:
        return "قيد المعالجة";
      case BookingStatus.accepted:
        return "مقبولة";
      case BookingStatus.cancelled:
        return "ملغاة";
      case BookingStatus.completed:
        return "مكتملة";
      case BookingStatus.rejected:
        return "مكتملة";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "حجوزاتي",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/booking.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _bookings.isEmpty
                ? const Center(
                    child: Text(
                      "لا يوجد حجوزات حالياً",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final status = booking.status;
                      final isPending = status == BookingStatus.pending ||
                          status == BookingStatus.processing;

                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            "${booking.type} - ${booking.provider.name}",
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "الخطة: ${booking.plan}\nالسعر: ${booking.price} \$\n${booking.date}",
                            textAlign: TextAlign.right,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _statusText(status),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                              if (isPending)
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.redAccent),
                                  onPressed: () => _cancelBooking(booking),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
