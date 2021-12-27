import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<String> _getLocationBackgroundFromSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('location') ?? 'Middle';
  }

  _setLocationBackgroundToSF(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('location', text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      backgroundColor: const Color(0xFF24282F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 10),
                    Icon(Icons.now_wallpaper, color: Colors.white),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Background',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) {
                  //     return const BackgroundScreen();
                  //   }),
                  // );
                },
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.vertical_distribute, color: Colors.white),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Location on screen',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.grey[800],
                    ),
                    child: FutureBuilder(
                        future: _getLocationBackgroundFromSP(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return DropdownButton(
                              underline: const SizedBox.shrink(),
                              value: snapshot.data.toString(),
                              items: [
                                'Top',
                                'Middle',
                                'Bottom'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _setLocationBackgroundToSF(newValue!);
                                });
                              },
                            );
                          }

                          return SizedBox.shrink();
                        }),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
