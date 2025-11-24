import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:provider/provider.dart';

import '../../helpers/utils/input_formatters.dart';
import '../../helpers/utils/validators.dart';
import '../components/banner_offline.dart';
import '../components/connectivity_status_icon.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, AuthViewModel vm, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Sign in',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            actions: const <Widget>[
              ConnectivityStatusIcon(),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (!vm.isOnline)
                    // const Padding(
                    //   padding: EdgeInsets.only(bottom: 12),
                    //   child: MaterialBanner(
                    //     backgroundColor: Color(0xFFFFF3CD),
                    //     content: Text(
                    //       "Hey Uniandino, you’re offline! Reconnect to get all features back.",
                    //       style: TextStyle(color: Color(0xFF856404)),
                    //     ),
                    //     actions: [
                    //       TextButton(
                    //         onPressed: null,
                    //         child: Text(
                    //           'OK',
                    //           style: TextStyle(color: Color(0xFF856404)),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const OfflineBanner(),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(hintText: 'email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (String? v) => validateEmailDomain(v),
                    inputFormatters: <TextInputFormatter>[
                      NoEmojiAndLengthFormatter(30),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(hintText: 'password'),
                    obscureText: true,
                    validator: validatePassword,
                    inputFormatters: <TextInputFormatter>[
                      NoEmojiAndLengthFormatter(20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: vm.signingIn
                        ? null
                        : () async {
                            if (!_form.currentState!.validate()) return;
                            await vm.login(_email.text.trim(), _password.text);
                            if (!mounted) return;
                            if (vm.error != null) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Error'),
                                  content: Text(vm.error!),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                    child: vm.signingIn
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: vm.resetting
                          ? null
                          : () async {
                              final TextEditingController ctrl =
                                  TextEditingController(
                                    text: _email.text.trim(),
                                  );
                              final GlobalKey<FormState> dlgFormKey =
                                  GlobalKey<FormState>();

                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Forgot password'),
                                  content: Form(
                                    key: dlgFormKey,
                                    child: TextFormField(
                                      controller: ctrl,
                                      decoration: const InputDecoration(
                                        hintText: 'email',
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (String? v) =>
                                          validateEmailDomain(v),
                                      inputFormatters: <TextInputFormatter>[
                                        NoEmojiAndLengthFormatter(30),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: vm.resetting
                                          ? null
                                          : () async {
                                              if (!dlgFormKey.currentState!
                                                  .validate()) {
                                                return;
                                              }
                                              final bool ok = await vm
                                                  .forgotPassword(
                                                    ctrl.text.trim(),
                                                  );
                                              if (!mounted) return;
                                              Navigator.pop(context);
                                              if (!ok) {
                                                await showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text('Error'),
                                                    content: Text(
                                                      vm.error ??
                                                          'unknown error',
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                await showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text(
                                                      'Check your email',
                                                    ),
                                                    content: const Text(
                                                      'We sent you a password reset link.',
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                      child: vm.resetting
                                          ? const Text('Sending...')
                                          : const Text('Send link'),
                                    ),
                                  ],
                                ),
                              );
                            },
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: vm.signingIn
                            ? null
                            : () =>
                                  Navigator.of(context).pushNamed('/register'),
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
