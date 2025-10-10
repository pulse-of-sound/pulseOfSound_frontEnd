class Admin {
  String name;
  String? birthDate;
  String phone;
  String? email;
  String password;

  Admin({
    required this.name,
    this.birthDate,
    required this.phone,
    this.email,
    required this.password,
  });
}
