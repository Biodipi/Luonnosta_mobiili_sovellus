import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luonnosta_app/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:luonnosta_app/logic/auth_cubit.dart';
import 'package:luonnosta_app/ui/page/landing_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final PageController _pageController = PageController(initialPage: 1);

  final _registerFormKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();
  final _resetPassFormKey = GlobalKey<FormState>();

  final String emailValidationPattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+";
  bool _isBackButtonVisible = false;
  bool _aboutToNavigate = false;

  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPassController = TextEditingController();

  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerPassController = TextEditingController();
  TextEditingController registerConfirmPassController = TextEditingController();

  TextEditingController resetPassEmailController = TextEditingController();

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPassController.dispose();

    registerConfirmPassController.dispose();
    registerEmailController.dispose();
    registerPassController.dispose();

    resetPassEmailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        if (_pageController.positions.isEmpty) {
          _isBackButtonVisible = false;
        } else {
          _isBackButtonVisible =
              _pageController.page == 2 || _pageController.page == 3;
        }
      });
    });
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().init();
    });
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
          _pageController.jumpToPage(1);
        } else if (state is AuthSuccess && !_aboutToNavigate) {
          _aboutToNavigate = true;
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const LandingPage(),
            ),
          );
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            extendBody: false,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniStartTop,
            backgroundColor: Colors.white,
            floatingActionButton: (!_isBackButtonVisible)
                ? null
                : FloatingActionButton(
                    elevation: 0,
                    backgroundColor: AppColors.greenButton,
                    onPressed: (() {
                      _pageController.jumpToPage(1);
                    }),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.greenButtonText,
                    )),
            body: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/image/background.png"),
                        fit: BoxFit.cover),
                  ),
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildInitial(), // 0
                      _buildLogin(context), // 1
                      _buildRegister(context), // 2
                      _buildResetPass(context), // 3
                    ],
                  ),
                ),
                if (state is AuthLoading)
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: AppColors.inputBorder.withOpacity(0.4),
                    child: const Center(child: CircularProgressIndicator()),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResetPass(BuildContext context1) {
    return Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _resetPassFormKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: Image.asset('assets/icon/icon.png'),
            ),
            const SizedBox(
              height: 30,
            ),
            Opacity(
              opacity: 0.9,
              child: TextFormField(
                controller: resetPassEmailController,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    filled: true,
                    errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: AppColors.greenButton,
                    focusedBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    enabledBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    errorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    border: AppBorder.textFormBorder(AppColors.inputBorder),
                    focusedErrorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    label: Center(
                        child: Text(AppLocalizations.of(context)!.loginEmail)),
                    floatingLabelBehavior: FloatingLabelBehavior.never),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(emailValidationPattern).hasMatch(value)) {
                    return AppLocalizations.of(context)!.loginInvalidEmail;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 11,
            ),
            Center(
              child: Opacity(
                opacity: 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    disabledBackgroundColor: AppColors.inputBorder,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    backgroundColor: AppColors.inputBorder,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_resetPassFormKey.currentState!.validate()) {
                      FocusManager.instance.primaryFocus?.unfocus();

                      context1
                          .read<AuthCubit>()
                          .resetPass(resetPassEmailController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Linkki salasanan palauttamiseen on lähetetty osoitteeseen: ${resetPassEmailController.text}')),
                      );
                      //resetPassEmailController.clear();
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.resetPassSubmit,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Represents the keyboard
            ),
          ],
        ));
  }

  Widget _buildRegister(BuildContext context1) {
    return Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _registerFormKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: Image.asset('assets/icon/icon.png'),
            ),
            const SizedBox(
              height: 30,
            ),
            Opacity(
              opacity: 0.9,
              child: TextFormField(
                controller: registerEmailController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    filled: true,
                    errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: AppColors.greenButton,
                    focusedBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    enabledBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    errorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    border: AppBorder.textFormBorder(AppColors.inputBorder),
                    focusedErrorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    label: Center(
                        child: Text(AppLocalizations.of(context)!.loginEmail)),
                    floatingLabelBehavior: FloatingLabelBehavior.never),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(emailValidationPattern).hasMatch(value)) {
                    return AppLocalizations.of(context)!.loginInvalidEmail;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Opacity(
              opacity: 0.9,
              child: TextFormField(
                controller: registerPassController,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                obscureText: true,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                    fillColor: AppColors.greenButton,
                    focusedBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    enabledBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    errorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    border: AppBorder.textFormBorder(AppColors.inputBorder),
                    focusedErrorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    label: Center(
                        child:
                            Text(AppLocalizations.of(context)!.loginPassword)),
                    floatingLabelBehavior: FloatingLabelBehavior.never),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.loginEmptyPassword;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Opacity(
              opacity: 0.9,
              child: TextFormField(
                controller: registerConfirmPassController,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                obscureText: true,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                    fillColor: AppColors.greenButton,
                    focusedBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    enabledBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    errorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    border: AppBorder.textFormBorder(AppColors.inputBorder),
                    focusedErrorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    label: Center(
                        child:
                            Text(AppLocalizations.of(context)!.loginPassword)),
                    floatingLabelBehavior: FloatingLabelBehavior.never),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.loginEmptyPassword;
                  }
                  if (value.length < 8) {
                    return AppLocalizations.of(context)!.registerPassTooShort;
                  }
                  if (registerConfirmPassController.text !=
                      registerPassController.text) {
                    return AppLocalizations.of(context)!.registerPassNotMatch;
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 11,
            ),
            Center(
              child: Opacity(
                opacity: 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    disabledBackgroundColor: AppColors.inputBorder,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    backgroundColor: AppColors.inputBorder,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (_registerFormKey.currentState != null &&
                          _registerFormKey.currentState!.validate())
                      ? () {
                          if (_registerFormKey.currentState!.validate()) {
                            context1.read<AuthCubit>().register(
                                registerEmailController.text,
                                registerPassController.text);
                          }
                        }
                      : null,
                  child: Text(
                    AppLocalizations.of(context)!.registerSubmit,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Represents the keyboard
            ),
          ],
        ));
  }

  Widget _buildLogin(BuildContext context1) {
    return Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _loginFormKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: Image.asset('assets/icon/icon.png'),
            ),
            const SizedBox(
              height: 30,
            ),
            Opacity(
              opacity: 0.9,
              child: TextFormField(
                controller: loginEmailController,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    filled: true,
                    errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    fillColor: AppColors.greenButton,
                    focusedBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    enabledBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    errorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    border: AppBorder.textFormBorder(AppColors.inputBorder),
                    focusedErrorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    label: Center(
                        child: Text(AppLocalizations.of(context)!.loginEmail)),
                    floatingLabelBehavior: FloatingLabelBehavior.never),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(emailValidationPattern).hasMatch(value)) {
                    return AppLocalizations.of(context)!.loginInvalidEmail;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Opacity(
              opacity: 0.9,
              child: TextFormField(
                controller: loginPassController,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                obscureText: true,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                    fillColor: AppColors.greenButton,
                    focusedBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    enabledBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    errorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    border: AppBorder.textFormBorder(AppColors.inputBorder),
                    focusedErrorBorder:
                        AppBorder.textFormBorder(AppColors.inputBorder),
                    label: Center(
                        child:
                            Text(AppLocalizations.of(context)!.loginPassword)),
                    floatingLabelBehavior: FloatingLabelBehavior.never),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.loginEmptyPassword;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.inputBorder.withOpacity(0.9),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.loginNoAccount1,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Questrial",
                      ),
                    ),
                    TextSpan(
                      style: const TextStyle(
                          color: AppColors.link,
                          decoration: TextDecoration.underline,
                          fontFamily: "Questrial",
                          fontWeight: FontWeight.bold),
                      text: AppLocalizations.of(context)!.loginNoAccount2,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          _pageController.jumpToPage(2);
                        },
                    ),
                    TextSpan(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: "Questrial",
                      ),
                      text:
                          "\n${AppLocalizations.of(context)!.loginForgotPass1}",
                    ),
                    TextSpan(
                      style: const TextStyle(
                          color: AppColors.link,
                          decoration: TextDecoration.underline,
                          fontFamily: "Questrial",
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      text: AppLocalizations.of(context)!.loginForgotPass2,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          _pageController.jumpToPage(3);
                        },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 11,
            ),
            Center(
              child: Opacity(
                opacity: 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    disabledBackgroundColor: AppColors.inputBorder,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    backgroundColor: AppColors.inputBorder,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (_loginFormKey.currentState != null &&
                          _loginFormKey.currentState!.validate())
                      ? () {
                          if (_loginFormKey.currentState!.validate()) {
                            context1.read<AuthCubit>().login(
                                loginEmailController.text,
                                loginPassController.text);
                          }
                        }
                      : null,
                  child: Text(
                    AppLocalizations.of(context)!.loginButton,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Represents the keyboard
            ),
          ],
        ));
  }

  Widget _buildInitial() {
    return Container(); // Blank page after splash screen
  }
}
