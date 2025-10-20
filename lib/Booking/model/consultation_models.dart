import 'dart:convert';

class ProviderModel {
  final String id;
  final String name;
  final String specialty;
  final String avatar;

  ProviderModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatar,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "specialty": specialty,
        "avatar": avatar,
      };

  factory ProviderModel.fromMap(Map<String, dynamic> m) => ProviderModel(
        id: m["id"],
        name: m["name"],
        specialty: m["specialty"],
        avatar: m["avatar"],
      );
}

enum BookingStatus { pending, processing, accepted, cancelled, completed }

class Booking {
  final String id;
  final String parentName;
  final String phone;
  final String type; // طبية أو نفسية
  final ProviderModel provider;
  final String plan;
  final double price;
  final String date;
  BookingStatus status;
  String? receiptPath;

  Booking({
    required this.id,
    required this.parentName,
    required this.phone,
    required this.type,
    required this.provider,
    required this.plan,
    required this.price,
    required this.date,
    this.status = BookingStatus.pending,
    this.receiptPath,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "parentName": parentName,
        "phone": phone,
        "type": type,
        "provider": provider.toMap(),
        "plan": plan,
        "price": price,
        "date": date,
        "status": status.index,
        "receiptPath": receiptPath,
      };

  factory Booking.fromMap(Map<String, dynamic> m) => Booking(
        id: m["id"],
        parentName: m["parentName"],
        phone: m["phone"],
        type: m["type"],
        provider:
            ProviderModel.fromMap(Map<String, dynamic>.from(m["provider"])),
        plan: m["plan"],
        price: (m["price"] is int)
            ? (m["price"] as int).toDouble()
            : m["price"] as double,
        date: m["date"],
        status: BookingStatus.values[m["status"]],
        receiptPath: m["receiptPath"],
      );

  String toJson() => json.encode(toMap());
  factory Booking.fromJson(String source) =>
      Booking.fromMap(json.decode(source));
}
