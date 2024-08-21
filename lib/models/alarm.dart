class Alarm {
  final int? id;
  final DateTime dateTime;
  final List<bool> repeatDays;
  final String alarmName;
  final bool isExpired;

  Alarm({
    this.id,
    required this.dateTime,
    required this.repeatDays,
    required this.alarmName,
    this.isExpired = false,
  });

  String get formattedDateTime {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }

  String get repeatDaysString {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.asMap().entries
        .where((entry) => entry.value)
        .map((entry) => days[entry.key])
        .join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'repeatDays': repeatDays.map((day) => day ? 1 : 0).join(','),
      'alarmName': alarmName,
      'isExpired': isExpired ? 1 : 0,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      repeatDays: (map['repeatDays'] as String)
          .split(',')
          .map((day) => day == '1')
          .toList(),
      alarmName: map['alarmName'],
      isExpired: map['isExpired'] == 1,
    );
  }
}
