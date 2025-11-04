import 'dart:convert';
import '../../Booking/model/consultation_models.dart';

class DoctorBooking {
  final String id;
  final String parentId;
  final String parentName;
  final String type;
  final String plan;
  final double price;
  final String date;
  final ProviderModel provider;
  String status;

  DoctorBooking({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.type,
    required this.plan,
    required this.price,
    required this.date,
    required this.provider,
    this.status = "pending",
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "parentId": parentId,
        "parentName": parentName,
        "type": type,
        "plan": plan,
        "price": price,
        "date": date,
        "status": status,
        "provider": provider.toMap(),
      };

  factory DoctorBooking.fromMap(Map<String, dynamic> map) => DoctorBooking(
        id: map["id"],
        parentId: map["parentId"],
        parentName: map["parentName"],
        type: map["type"],
        plan: map["plan"],
        price: (map["price"] is int)
            ? (map["price"] as int).toDouble()
            : map["price"] as double,
        date: map["date"],
        status: map["status"],
        provider:
            ProviderModel.fromMap(Map<String, dynamic>.from(map["provider"])),
      );
}
