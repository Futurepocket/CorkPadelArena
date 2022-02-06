class Reservation {


  late String userEmail;
  late bool completed;
  late String dateMade;
  late String pin;
  late String day;
  late String hour;
  late String duration;
  late String price;
  late String state;


  late String id;
  late String timeMade;

  Reservation(
      {required this.pin,
      required this.day,
      required this.hour,
      required this.duration,
      required this.state,
        required this.price,
      required this.userEmail,
      required this.completed,
      required this.id,
      required this.dateMade,
      required this.timeMade});


  factory Reservation.fromRTDB(Map<String, dynamic> data) {
    return Reservation(
        pin: data['pin'],
        day: data['day'],
        hour: data['hour'],
        duration: data['duration'],
        state: data['state'],
        userEmail: data['client_email'],
        completed: data['completed'],
        price: data['price'],
        id: data['id'],
        dateMade: '',
        timeMade: '');
  }
}
