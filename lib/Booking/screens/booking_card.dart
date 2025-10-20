import 'package:flutter/material.dart';
import '../model/consultation_models.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCancel;

  const BookingCard({super.key, required this.booking, this.onCancel});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusText = "قيد المعالجة";
        break;
      case BookingStatus.accepted:
        statusColor = Colors.green;
        statusText = "مقبولة";
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = "ملغاة";
        break;
      default:
        statusColor = Colors.blueGrey;
        statusText = "مكتملة";
    }

    return Card(
      color: Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(booking.provider.avatar),
          radius: 25,
        ),
        title: Text(booking.provider.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("النوع: ${booking.type}"),
            Text("الخطة: ${booking.plan}"),
            Text("التاريخ: ${booking.date}"),
            Text("الحالة: $statusText", style: TextStyle(color: statusColor)),
          ],
        ),
        trailing: (booking.status == BookingStatus.pending)
            ? IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: onCancel,
              )
            : null,
      ),
    );
  }
}
