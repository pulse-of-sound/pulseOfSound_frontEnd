import 'dart:convert';

class Receipt {
  final String id;
  final String parentPhone;
  final double amount;
  final String imagePath;
  String status; 

  Receipt({
    required this.id,
    required this.parentPhone,
    required this.amount,
    required this.imagePath,
    this.status = "pending",
  });

  
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "parentPhone": parentPhone,
      "amount": amount,
      "imagePath": imagePath,
      "status": status,
    };
  }


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

  
  String toJson() => json.encode(toMap());

  factory Receipt.fromJson(String source) =>
      Receipt.fromMap(json.decode(source));
}
