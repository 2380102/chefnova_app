class UserModel {
  int    id;
  String name;
  String email;
  String phone;
  String address;
  String password; // only used locally, not sent back from server

  UserModel({
    this.id       = 0,
    this.name     = '',
    this.email    = '',
    this.phone    = '',
    this.address  = '',
    this.password = '',
  });

  Map<String, dynamic> toMap() => {
    'id':      id,
    'name':    name,
    'email':   email,
    'phone':   phone,
    'address': address,
  };
}
