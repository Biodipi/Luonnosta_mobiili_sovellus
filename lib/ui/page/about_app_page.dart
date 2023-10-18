// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({Key? key}) : super(key: key);

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  Map<String, String> _licenses = {};

  Future<void> load(BuildContext context) async {
    _licenses = {};
    const path = "assets/licenses/";

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final licensePaths =
        manifestMap.keys.where((String key) => key.contains(path)).toList();

    for (String license in licensePaths) {
      _licenses[license.replaceFirst(path, "")] =
          await DefaultAssetBundle.of(context).loadString(license);
    }
    setState(() {
      _licenses = _licenses; // Update state
    });
  }

  @override
  void initState() {
    super.initState();
    load(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.inputBorder,
        title: Text(AppLocalizations.of(context)!.commonLicenses),
      ),
      extendBodyBehindAppBar: false,
      body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _licenses.keys.length,
          itemBuilder: ((context, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    _licenses.keys.elementAt(index),
                  ),
                ),
                Text(
                  _licenses[_licenses.keys.elementAt(index)].toString(),
                  textAlign: TextAlign.left,
                ),
                const Divider()
              ],
            );
          })),
    );
  }
}
