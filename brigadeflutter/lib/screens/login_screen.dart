// imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(), pass = TextEditingController();
  bool create = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
            }
          });
          return const SizedBox.shrink();
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Sign in')),
          body: BlocConsumer<AuthCubit, AuthState>(
            listener: (ctx, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.error!)));
              }
            },
            builder: (ctx, state) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pass,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Password'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Switch(value: create, onChanged: (v) => setState(() => create = v)),
                        Text(create ? 'Create account' : 'Login'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: state.loading
                          ? null
                          : () {
                              final c = context.read<AuthCubit>();
                              final e = email.text.trim(), p = pass.text.trim();
                              create ? c.signUpWithEmail(e, p) : c.signInWithEmail(e, p);
                            },
                      child: state.loading
                          ? const CircularProgressIndicator()
                          : Text(create ? 'Create' : 'Sign in'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: state.loading
                          ? null
                          : () async {
                              final e = email.text.trim();
                              if (e.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enter your email first.')),
                                );
                                return;
                              }
                              await context.read<AuthCubit>().sendPasswordReset(e);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reset link sent (if email exists).')),
                                );
                              }
                            },
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
