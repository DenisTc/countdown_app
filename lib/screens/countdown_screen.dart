import 'dart:io';
import 'package:countdown_calendar/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:countdown_calendar/constants.dart' as constants;

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<CountdownScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;

  String get seconds {
    Duration count = controller.duration! * controller.value;
    return (count.inSeconds % 60).toString().padLeft(2, '0');
  }

  String get minutes {
    Duration count = controller.duration! * controller.value;
    return (count.inMinutes % 60).toString().padLeft(2, '0');
  }

  String get hours {
    Duration count = controller.duration! * controller.value;
    return (count.inHours % 24).toString().padLeft(2, '0');
  }

  String get days {
    Duration count = controller.duration! * controller.value;
    return count.inDays.toString();
  }

  Future<File?> _getBackgroundFromSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final directory = (await getApplicationDocumentsDirectory()).path;
    if (prefs.getString('background') != null) {
      return File(directory +
          '/' +
          prefs.getString('background')!.split('/').last);
    }
    return null;
  }

  Future<String> _getLocationBackgroundFromSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('location') ?? 'Middle';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  setCountdown() {
    int year = DateTime.now().year + 1;
    final DateTime newYear = DateTime(year, 1, 1);
    DateTime dateTimeNow = DateTime.now();
    int dateSeconds = dateTimeNow.difference(newYear).inSeconds;

    controller = AnimationController(
      vsync: this,
      value: 10,
      duration: Duration(seconds: dateSeconds.abs()),
    );
  }

  @override
  Widget build(BuildContext context) {
    setCountdown();
    controller.reverse();

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      body: Stack(
        children: [
          FutureBuilder<File?>(
            future: _getBackgroundFromSP(),
            builder: (context, snapshot) {
              return AnimatedOpacity(
                  opacity: snapshot.connectionState == ConnectionState.done ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: snapshot.data != null
                            ? FileImage(snapshot.data!)
                            : const AssetImage(constants.defaultBackground)
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ));
            },
          ),
          FutureBuilder(
              future: _getLocationBackgroundFromSP(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  MainAxisAlignment position;
                  if (snapshot.data == 'Middle') {
                    position = MainAxisAlignment.center;
                  } else if (snapshot.data == 'Top') {
                    position = MainAxisAlignment.start;
                  } else {
                    position = MainAxisAlignment.end;
                  }

                  return SafeArea(
                    child: Column(
                      mainAxisAlignment: position,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 400,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AnimatedBuilder(
                                  animation: controller,
                                  builder: (context, child) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        timeCard(time: days, header: constants.textDays),
                                        const SizedBox(width: 10),
                                        timeCard(time: hours, header: constants.textHours),
                                        const SizedBox(width: 10),
                                        timeCard(
                                            time: minutes, header: constants.textMinutes),
                                        const SizedBox(width: 10),
                                        timeCard(
                                            time: seconds, header: constants.textSeconds),
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return const SettingsScreen();
            }),
          );
        },
        child: const Icon(
          Icons.settings,
          size: 30,
        ),
        elevation: 0.0,
        foregroundColor: Colors.white.withOpacity(0.4),
        backgroundColor: Colors.black.withOpacity(0.2),
      ),
    );
  }

  Widget timeCard({required String time, required String header}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 34,
            color: Colors.white,
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          header,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
