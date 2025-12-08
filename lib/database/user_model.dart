class UserModel {
  int? id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String cnic;
  String gender;
  String password;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.gender,
    required this.password,
  });

  // Convert object -> Map (for database)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "firstName": firstName.trim(),
      "lastName": lastName.trim(),
      "email": email.toLowerCase().trim(),   // IMPORTANT FIX
      "phone": phone.trim(),
      "cnic": cnic.trim(),
      "gender": gender,
      "password": password.trim(),
    };
  }

  // Convert database row -> object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      firstName: map["firstName"],
      lastName: map["lastName"],
      email: map["email"],
      phone: map["phone"],
      cnic: map["cnic"],
      gender: map["gender"],
      password: map["password"],
    );
  }
}
