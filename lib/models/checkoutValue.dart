class checkoutValue {
  static checkoutValue _check = checkoutValue._internal();

  int _reservations = 0;
  int _price = 0;

  factory checkoutValue() {
    return _check;
  }

  int get reservations => _reservations;
  int get price => _price;

  set reservations(int value) => _reservations = value;
  set price(int value) => _price = value;
  void moreReservations() => _reservations++;
  void lessReservations() => _reservations--;

  checkoutValue._internal();
}
