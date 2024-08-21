import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../helpers/database_helper.dart';
import 'alarm_form_screen.dart';

class AlarmListScreen extends StatefulWidget {
  @override
  _AlarmListScreenState createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  List<Alarm> _alarms = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final alarms = await DatabaseHelper.instance.getAlarms();
    setState(() {
      _alarms = alarms;
    });
  }

  Future<void> _searchAlarms(String query) async {
    if (query.isEmpty) {
      await _loadAlarms();
    } else {
      final alarms = await DatabaseHelper.instance.searchAlarms(query);
      setState(() {
        _alarms = alarms;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Clock'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _searchAlarms(value);
              },
              decoration: InputDecoration(
                labelText: 'Search Alarms',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return ListTile(
                  title: Text(alarm.alarmName.isNotEmpty
                      ? alarm.alarmName
                      : 'No Name'), // Display alarm name or 'No Name'
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alarm.formattedDateTime),
                      Text(alarm.repeatDaysString),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlarmFormScreen(alarm: alarm),
                            ),
                          );
                          _loadAlarms();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseHelper.instance.deleteAlarm(alarm.id!);
                          _loadAlarms();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlarmFormScreen(),
            ),
          );
          _loadAlarms();
        },
      ),
    );
  }
}
