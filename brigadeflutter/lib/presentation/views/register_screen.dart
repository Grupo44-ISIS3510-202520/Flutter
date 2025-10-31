import 'package:brigadeflutter/presentation/components/banner_offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/input_formatters.dart';
import '../viewmodels/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _code = TextEditingController();
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
      builder: (_, vm, __) {
        return Scaffold(
          appBar: AppBar(title: const Text('Create account')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: ListView(
                children: [
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
                    inputFormatters: [NoEmojiAndLengthFormatter(15)],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(hintText: 'last name'),
                    validator: validateLastName,
                    inputFormatters: [NoEmojiAndLengthFormatter(15)],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _code,
                    decoration: const InputDecoration(
                      hintText: 'uniandes code (e.g., 202020133)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: validateUniandesCode,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _bg,
                    items: kBloodGroups
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _bg = v ?? kBloodGroups.first),
                    decoration: const InputDecoration(hintText: 'blood group'),
                    validator: validateBloodGroup,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _role,
                    items: kRoles
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _role = v ?? kRoles.first),
                    decoration: const InputDecoration(hintText: 'role'),
                    validator: validateRole,
                  ),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(hintText: 'email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => validateEmailDomain(v),
                    inputFormatters: [NoEmojiAndLengthFormatter(30)],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(hintText: 'password'),
                    obscureText: true,
                    validator: validatePassword,
                    inputFormatters: [NoEmojiAndLengthFormatter(20)],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirm,
                    decoration: const InputDecoration(
                      hintText: 'confirm password',
                    ),
                    obscureText: true,
                    validator: (v) =>
                        validatePasswordConfirm(v, _password.text),
                    inputFormatters: [NoEmojiAndLengthFormatter(20)],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: vm.submitting
                        ? null
                        : () async {
                            if (!_form.currentState!.validate()) return;
                            final ok = await vm.submit(
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
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Error'),
                                  content: Text(vm.error ?? 'unknown error'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Verify your email'),
                                  content: const Text(
                                    'Please check your email and verify your account.',
                                  ),
                                  actions: [
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
