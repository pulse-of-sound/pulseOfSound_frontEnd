import 'dart:convert';

class Receipt {
  final String id;
  final String parentPhone;
  final double amount;
  final String imagePath;
  String status; // pending / approved / rejected

  Receipt({
    required this.id,
    required this.parentPhone,
    required this.amount,
    required this.imagePath,
    this.status = "pending",
  });

  /// تحويل الكائن إلى Map لتخزينه محليًا
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "parentPhone": parentPhone,
      "amount": amount,
      "imagePath": imagePath,
      "status": status,
    };
  }

  /// تحويل Map إلى كائن Receipt عند القراءة
  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map["id"] ?? "",
      parentPhone: map["parentPhone"] ?? "",
      amount: (map["amount"] is int)
          ? (map["amount"] as int).toDouble()
          : (map["amount"] ?? 0.0),
      imagePath: map["imagePath"] ?? "",
      status: map["status"] ?? "pending",
    );
  }

  /// تحويل إلى JSON
  String toJson() => json.encode(toMap());

  /// إنشاء كائن من JSON
  factory Receipt.fromJson(String source) =>
      Receipt.fromMap(json.decode(source));
}
