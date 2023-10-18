import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:luonnosta_app/logic/create_marking_cubit.dart';
import 'package:luonnosta_app/logic/delete_marking_cubit.dart';
import 'package:luonnosta_app/logic/update_marking_cubit.dart';
import 'package:luonnosta_app/ui/page/auth_page.dart';
import 'logic/auth_cubit.dart';
import 'logic/list_markings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => ListMarkingsCubit(),
        ),
        BlocProvider(
          create: (context) => DeleteMarkingCubit(),
        ),
        BlocProvider(
          create: (context) => UpdateMarkingCubit(),
        ),
        BlocProvider(
          create: (context) => CreateMarkingCubit(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Montserrat',
        ),
        title: 'Luonnosta',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthPage(),
      ),
    );
  }
}
