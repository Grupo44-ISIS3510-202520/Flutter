import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/utils/constants.dart';
import '../../core/utils/input_formatters.dart';
import '../../core/utils/validators.dart';
import '../components/banner_offline.dart';
import '../components/connectivity_status_icon.dart';
import '../viewmodels/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _code = TextEditingController();
  String _bg = kBloodGroups.first;
  String _role = kRoles.first;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _name.dispose();
    _lastName.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (_, RegisterViewModel vm, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Create account'),
            actions: const <Widget>[
              ConnectivityStatusIcon(),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: ListView(
                children: <Widget>[
                  if (!vm.isOnline)
                    // const Padding(
                    //   padding: EdgeInsets.only(bottom: 12),
                    //   child: Card(
                    //     color: Color(0xFFFFF3CD),
                    //     elevation: 0,
                    //     margin: EdgeInsets.zero,
                    //     child: Padding(
                    //       padding: EdgeInsets.all(16),
                    //       child: Text(
                    //         "Hey Uniandino, you’re offline! Reconnect to get all features back.",
                    //         style: TextStyle(color: Color(0xFF856404)),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const OfflineBanner(),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(hintText: 'name'),
                    validator: validateName,
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(15)],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(hintText: 'last name'),
                    validator: validateLastName,
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(15)],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _code,
                    decoration: const InputDecoration(
                      hintText: 'uniandes code (e.g., 202020133)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: validateUniandesCode,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _bg,
                    items: kBloodGroups
                        .map((String e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (String? v) =>
                        setState(() => _bg = v ?? kBloodGroups.first),
                    decoration: const InputDecoration(hintText: 'blood group'),
                    validator: validateBloodGroup,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _role,
                    items: kRoles
                        .map((String e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (String? v) => setState(() => _role = v ?? kRoles.first),
                    decoration: const InputDecoration(hintText: 'role'),
                    validator: validateRole,
                  ),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(hintText: 'email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (String? v) => validateEmailDomain(v),
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(30)],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(hintText: 'password'),
                    obscureText: true,
                    validator: validatePassword,
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(20)],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirm,
                    decoration: const InputDecoration(
                      hintText: 'confirm password',
                    ),
                    obscureText: true,
                    validator: (String? v) =>
                        validatePasswordConfirm(v, _password.text),
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(20)],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: vm.submitting
                        ? null
                        : () async {
                            if (!_form.currentState!.validate()) return;
                            final bool ok = await vm.submit(
                              email: _email.text.trim(),
                              password: _password.text,
                              confirmPassword: _confirm.text,
                              name: _name.text.trim(),
                              lastName: _lastName.text.trim(),
                              uniandesCode: _code.text.trim(),
                              bloodGroup: _bg,
                              role: _role,
                            );
                            if (!mounted) return;
                            if (!ok) {
                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Error'),
                                  content: Text(vm.error ?? 'unknown error'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Verify your email'),
                                  content: const Text(
                                    'Please check your email and verify your account.',
                                  ),
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
                    child: vm.submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create account'),
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
