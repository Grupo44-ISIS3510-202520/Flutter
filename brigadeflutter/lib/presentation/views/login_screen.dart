import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _obscurePassword = true;

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
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 24),
                    // App Icon
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 173, 173, 173).withOpacity(0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/icon-transparent.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Welcome text
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
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
                  // Email field
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    inputFormatters: <TextInputFormatter>[
                      NoEmojiAndLengthFormatter(30),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: validatePassword,
                    inputFormatters: <TextInputFormatter>[
                      NoEmojiAndLengthFormatter(20),
                    ],
                    onFieldSubmitted: (_) {
                      if (!vm.signingIn && _form.currentState!.validate()) {
                        vm.login(_email.text.trim(), _password.text);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // Sign in button
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
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: vm.signingIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  // Forgot password
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
                                        hintText: 'Email',
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
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Row(
                    children: <Widget>[
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Create account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: vm.signingIn
                            ? null
                            : () =>
                                  Navigator.of(context).pushNamed('/register'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Create account',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ));
      },
    );
  }
}
