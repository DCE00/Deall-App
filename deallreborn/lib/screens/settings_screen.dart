import 'package:connectivity/connectivity.dart';
import 'package:deallreborn/interceptor/dio_connectivity_retry_interceptor.dart';
import 'package:deallreborn/interceptor/retry_interceptor.dart';
import 'package:deallreborn/screens/globals.dart';
import 'package:deallreborn/screens/languages_screen.dart';
import 'package:deallreborn/screens/logout_confirm.dart';
import 'package:deallreborn/screens/menu_screen.dart';
import 'package:deallreborn/screens/password_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  Dio dio;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    isLoading = false;
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;

    dio.interceptors.add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: Dio(),
          connectivity: Connectivity(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings UI'),
        leading: BackButton(
          onPressed: () {
            cardsSwiped = 0;
            firstTime = true;
            anuncios.clear();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuScreen(),
              ),
            );
          },
        ),
      ),
      body: SettingsList(
        // backgroundColor: Colors.orange,
        sections: [
          /**SettingsSection(
              title: 'Common',
              // titleTextStyle: TextStyle(fontSize: 30),
              tiles: [
              SettingsTile(
              title: 'Language',
              subtitle: 'English',
              leading: Icon(Icons.language),
              onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => LanguagesScreen()));
              },
              ),
              ],
              ),**/
          SettingsSection(
            title: 'Account',
            tiles: [
              //SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
              //SettingsTile(title: 'Email', leading: Icon(Icons.email)),
              SettingsTile(
                  title: 'Sign out',
                  leading: Icon(Icons.exit_to_app),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => LogoutScreen()));
                  }),
            ],
          ),
          SettingsSection(
            title: 'Security',
            tiles: [
              /**SettingsTile.switchTile(
                  title: 'Lock app in background',
                  leading: Icon(Icons.phonelink_lock),
                  switchValue: lockInBackground,
                  onToggle: (bool value) {
                  setState(() {
                  lockInBackground = value;
                  notificationsEnabled = value;
                  });
                  },
                  ),**/
              SettingsTile(
                  title: 'Change password',
                  leading: Icon(Icons.lock),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PasswordScreen()));
                  }),

              /**SettingsTile.switchTile(
                  title: 'Enable Notifications',
                  enabled: notificationsEnabled,
                  leading: Icon(Icons.notifications_active),
                  switchValue: true,
                  onToggle: (value) {},
                  ),**/
            ],
          ),
          SettingsSection(
            title: 'Misc',
            tiles: [
              SettingsTile(
                  title: 'Terms of Service', leading: Icon(Icons.description)),
            ],
          ),
          CustomSection(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Image.asset(
                    'assets/images/settings.png',
                    height: 50,
                    width: 50,
                    color: Color(0xFF777777),
                  ),
                ),
                Text(
                  'Version: 0.0.1 (11/2020)',
                  style: TextStyle(color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
