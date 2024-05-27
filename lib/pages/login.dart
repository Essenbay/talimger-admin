import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/components/app_logo.dart';
import 'package:increatorkz_admin/components/langauge_dropdown.dart';
import 'package:increatorkz_admin/configs/app_config.dart';
import 'package:increatorkz_admin/configs/assets_config.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/pages/home.dart';
import 'package:increatorkz_admin/providers/auth_state_provider.dart';
import 'package:increatorkz_admin/providers/user_data_provider.dart';
import 'package:increatorkz_admin/utils/reponsive.dart';
import 'package:increatorkz_admin/services/auth_service.dart';
import 'package:increatorkz_admin/utils/next_screen.dart';
import 'package:increatorkz_admin/utils/toasts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class Login extends ConsumerStatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  var emailCtlr = TextEditingController();
  var passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController _btnCtlr =
      RoundedLoadingButtonController();
  bool _obsecureText = true;
  IconData _lockIcon = CupertinoIcons.eye_fill;

  _onChangeVisiblity() {
    if (_obsecureText == true) {
      setState(() {
        _obsecureText = false;
        _lockIcon = CupertinoIcons.eye;
      });
    } else {
      setState(() {
        _obsecureText = true;
        _lockIcon = CupertinoIcons.eye_fill;
      });
    }
  }

  void _handleLogin() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _btnCtlr.start();
      UserCredential? userCredential = await AuthService()
          .loginWithEmailPassword(emailCtlr.text, passwordCtrl.text);
      if (userCredential?.user != null) {
        debugPrint('Login Success');
        _checkVerification(userCredential!);
      } else {
        _btnCtlr.reset();
        if (!mounted) return;
        openFailureToast(context, context.localized.auth_invalid);
      }
    }
  }

  _checkVerification(UserCredential userCredential) async {
    final UserRoles role =
        await AuthService().checkUserRole(userCredential.user!.uid);
    if (role == UserRoles.admin || role == UserRoles.author) {
      ref.read(userRoleProvider.notifier).update((state) => role);

      await ref.read(userDataProvider.notifier).getData();
      if (!mounted) {
        return;
      } else {
        NextScreen.replaceAnimation(context, const Home());
      }
    } else {
      await AuthService().adminLogout().then((value) =>
          openFailureToast(context, context.localized.access_denied));
    }
  }

  // _handleDemoAdminLogin() async {
  //   ref.read(userRoleProvider.notifier).update((state) => UserRoles.guest);
  //   await AuthService().loginAnnonumously().then((value) => NextScreen.replaceAnimation(context, const Home()));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppConfig.themeColor,
        child: Row(
          children: [
            Visibility(
              visible: Responsive.isDesktop(context) ||
                  Responsive.isDesktopLarge(context),
              child: const Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: AppLogo(
                    imageString: AssetsConfig.logo, height: 400, width: 400),
              ),
            ),
            Flexible(
              flex: 1,
              // fit: FlexFit.tight,
              child: Form(
                key: formKey,
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getHorizontalPadding(),
                      vertical: 30.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: ChangeLanguageDropdown(),
                        ),
                        Text(
                          context.localized.sign_in,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.blueGrey),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.localized.email,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              color: Colors.grey.shade100,
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: emailCtlr,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return context.localized.email_required;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () => emailCtlr.clear(),
                                    icon: const Icon(Icons.clear),
                                  ),
                                  hintText: context.localized.email,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(15),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              context.localized.password,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              color: Colors.grey.shade100,
                              child: TextFormField(
                                controller: passwordCtrl,
                                obscureText: _obsecureText,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return context.localized.password_required;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    suffixIcon: Wrap(
                                      children: [
                                        IconButton(
                                            onPressed: _onChangeVisiblity,
                                            icon: Icon(_lockIcon)),
                                        IconButton(
                                            onPressed: () =>
                                                passwordCtrl.clear(),
                                            icon: const Icon(Icons.clear)),
                                      ],
                                    ),
                                    hintText: context.localized.password,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(15)),
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            RoundedLoadingButton(
                              onPressed: _handleLogin,
                              controller: _btnCtlr,
                              color: Theme.of(context).primaryColor,
                              width: MediaQuery.of(context).size.width,
                              borderRadius: 0,
                              height: 55,
                              animateOnTap: false,
                              elevation: 0,
                              child: Text(
                                context.localized.login,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     TextButton(
                            //       child: const Text('Test Demo Admin'),
                            //       onPressed: () => _handleDemoAdminLogin(),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getHorizontalPadding() {
    if (Responsive.isDesktopLarge(context)) {
      return 120;
    } else if (Responsive.isDesktop(context)) {
      return 80;
    } else if (Responsive.isTablet(context)) {
      return 100;
    } else {
      return 30;
    }
  }
}
