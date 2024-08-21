import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../helpers/database_helper.dart';

class AlarmFormScreen extends StatefulWidget {
  final Alarm? alarm;

  AlarmFormScreen({this.alarm});

  @override
  _AlarmFormScreenState createState() => _AlarmFormScreenState();
}

class _AlarmFormScreenState extends State<AlarmFormScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  List<bool> _repeatDays = List.filled(7, false);
  final TextEditingController _nameController = TextEditingController(); // Controller for alarm name

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _selectedDate = widget.alarm!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.alarm!.dateTime);
      _repeatDays = widget.alarm!.repeatDays;
      _nameController.text = widget.alarm!.alarmName; // Set initial alarm name
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveAlarm() async {
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final alarm = Alarm(
      id: widget.alarm?.id,
      dateTime: dateTime,
      repeatDays: _repeatDays,
      alarmName: _nameController.text, // Save the alarm name
    );

    if (widget.alarm == null) {
      await DatabaseHelper.instance.insertAlarm(alarm);
    } else {
      await DatabaseHelper.instance.updateAlarm(alarm);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Add Alarm' : 'Edit Alarm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Alarm Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Select Date: ${_selectedDate.toString().split(' ')[0]}'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('Select Time: ${_selectedTime.format(context)}'),
            ),
            SizedBox(height: 16),
            Text('Repeat:'),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < 7; i++)
                  FilterChip(
                    label: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i]),
                    selected: _repeatDays[i],
                    onSelected: (bool selected) {
                      setState(() {
                        _repeatDays[i] = selected;
                      });
                    },
                  ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveAlarm,
              child: Text('Save Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
