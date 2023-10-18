import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:luonnosta_app/ui/page/map_page.dart';

import '../../constants.dart';
import 'markings_page.dart';
import 'settings_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.greenButton,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          child: const Icon(Icons.settings),
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/image/background.png"),
                fit: BoxFit.cover),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(70, 10, 20, 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 3),
                              color: AppColors.logoLime,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(40))),
                          child: Text(
                            "${AppLocalizations.of(context)!.landingWelcome} ${_user!.email!.split("@").first}!                                                     ",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 90,
                        child: Image.asset('assets/icon/icon.png'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 34,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 22,
                      ),
                      Expanded(
                        child: Transform.scale(
                          scale: 0.95,
                          child: SizedBox(
                            height: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: "select_location"),
                                      builder: (context) =>
                                          const WMSLayerPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: AppColors.landingButton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                  AppLocalizations.of(context)!.landingCreate),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Transform.scale(
                          scale: 0.95,
                          child: SizedBox(
                            height: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MarkingsPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: AppColors.landingButton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                  AppLocalizations.of(context)!.landingLog),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 22,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 22,
                      ),
                      Expanded(
                        child: Transform.scale(
                          scale: 0.95,
                          child: SizedBox(
                            height: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WMSLayerPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: AppColors.landingButton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                  AppLocalizations.of(context)!.landingMap),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Transform.scale(
                          scale: 0.95,
                          child: SizedBox(height: 100, child: Container()),
                        ),
                      ),
                      const SizedBox(
                        width: 22,
                      ),
                    ],
                  ),
                  Flexible(child: Container()),
                  Transform.scale(
                    scale: 0.8,
                    child: Transform.translate(
                      offset: Offset(0, -20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/image/1_oamk.png",
                            width: 86,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Image.asset(
                            "assets/image/2_vipuvoimaa.png",
                            width: 70,
                          ),
                          const SizedBox(
                            width: 9,
                          ),
                          Image.asset(
                            "assets/image/3_EU.png",
                            width: 60,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Image.asset(
                            "assets/image/4_pohjois-pohjanmaa.png",
                            width: 70,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
