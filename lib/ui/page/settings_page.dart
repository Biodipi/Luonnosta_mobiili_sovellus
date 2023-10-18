import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luonnosta_app/logic/auth_cubit.dart';
import 'package:luonnosta_app/ui/widget/loading_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'about_app_page.dart';
import 'auth_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String bundleInfo = "";
  @override
  void initState() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        bundleInfo =
            "${packageInfo.appName} - ${packageInfo.version} (${packageInfo.buildNumber})";
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthInitial) {
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const AuthPage(),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.landingSettings),
            centerTitle: true,
            backgroundColor: AppColors.inputBorder,
          ),
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: AppColors.landingButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.settingsLogout),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutAppPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: AppColors.landingButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.commonLicenses),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().deleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        Text(AppLocalizations.of(context)!.settingsDeleteAcc),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  Text(bundleInfo)
                ],
              ),
              if (state is AuthLoading) const LoadingView()
            ],
          ),
        );
      },
    );
  }
}
