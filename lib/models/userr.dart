class Userr {
  static final Userr _user = new Userr._internal();

  String _id = '';
  String _role = '';
  String _name = '';
  String _surname = '';
  String _address = '';
  String _city = '';
  String _postCode = '';
  String _phoneNbr = '';
  String _nif = '';
  String _email = '';

  factory Userr() {
    return _user;}
  Userr._internal();

  String get id => _id;
  String get role => _role;
  String get name => _name;
  String get surname => _surname;
  String get address => _address;
  String get city => _city;
  String get phoneNbr => _phoneNbr;
  String get postCode => _postCode;
  String get nif => _nif;
  String get email => _email;

  set id(String value) => _id = value;
  set role(String value) => _role = value;
  set name(String value) => _name = value;
  set surname(String value) => _surname = value;
  set address(String value) => _address = value;
  set city(String value) => _city = value;
  set phoneNbr(String value) => _phoneNbr = value;
  set postCode(String value) => _postCode = value;
  set nif(String value) => _nif = value;
  set email(String value) => _email = value;

}
