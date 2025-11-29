import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../helpers/utils/constants.dart';
import '../../helpers/utils/input_formatters.dart';
import '../../helpers/utils/validators.dart';
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
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
            title: const Text(
              'Create account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            actions: const <Widget>[
              ConnectivityStatusIcon(),
            ],
          ),
          body: SafeArea(
            child: Form(
              key: _form,
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: <Widget>[
                  const SizedBox(height: 8),
                  // App Icon
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 143, 143, 143).withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/icon-transparent.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Welcome text
                  const Text(
                    'Join BrigadeApp',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your account to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (!vm.isOnline)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: OfflineBanner(),
                    ),
                  // Name field
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your first name (max 15)',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: validateName,
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(15)],
                  ),
                  const SizedBox(height: 16),
                  // Last name field
                  TextFormField(
                    controller: _lastName,
                    decoration: InputDecoration(
                      labelText: 'Last name',
                      hintText: 'Enter your last name (max 15)',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: validateLastName,
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(15)],
                  ),
                  const SizedBox(height: 16),
                  // Uniandes code field
                  TextFormField(
                    controller: _code,
                    decoration: InputDecoration(
                      labelText: 'Uniandes code',
                      hintText: 'e.g., 202020133',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: validateUniandesCode,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Blood group dropdown
                  DropdownButtonFormField<String>(
                    value: _bg,
                    items: kBloodGroups
                        .map((String e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (String? v) =>
                        setState(() => _bg = v ?? kBloodGroups.first),
                    decoration: InputDecoration(
                      labelText: 'Blood group',
                      prefixIcon: const Icon(Icons.water_drop_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: validateBloodGroup,
                  ),
                  const SizedBox(height: 16),
                  // Role dropdown
                  DropdownButtonFormField<String>(
                    value: _role,
                    items: kRoles
                        .map((String e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (String? v) => setState(() => _role = v ?? kRoles.first),
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: const Icon(Icons.school_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: validateRole,
                  ),
                  const SizedBox(height: 16),
                  // Email field
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'yourname@uniandes.edu.co',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (String? v) => validateEmailDomain(v),
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(30)],
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Min 6, max 20 characters',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: validatePassword,
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(20)],
                  ),
                  const SizedBox(height: 16),
                  // Confirm password field
                  TextFormField(
                    controller: _confirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      hintText: 'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (String? v) =>
                        validatePasswordConfirm(v, _password.text),
                    inputFormatters: <TextInputFormatter>[NoEmojiAndLengthFormatter(20)],
                  ),
                  const SizedBox(height: 24),
                  // Submit button
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
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: vm.submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Create account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
