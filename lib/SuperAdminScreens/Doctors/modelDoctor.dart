class Doctor {
  String name;
  String? birthDate;
  String phone;
  String? email;
  String password;
  String? certificates;
  String? experience;
  String? workplace;

  Doctor({
    required this.name,
    this.birthDate,
    required this.phone,
    this.email,
    required this.password,
    this.certificates,
    this.experience,
    this.workplace,
  });
}
