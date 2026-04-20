import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../data/auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final tenantController = TextEditingController();
  bool isSignUp = false;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    tenantController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (isLoading) {
      return;
    }

    final authRepository = AuthRepository(ref.read(apiClientProvider));
    setState(() => isLoading = true);
    try {
      final session = isSignUp
          ? await authRepository.register(
              email: emailController.text,
              password: passwordController.text,
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              tenantName: tenantController.text,
            )
          : await authRepository.login(
              email: emailController.text,
              password: passwordController.text,
            );
      ref.read(authSessionProvider.notifier).state = session;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isSignUp ? 'Sign up failed' : 'Login failed')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delego', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Precision operations, beautifully managed.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSignUp) ...[
                            TextField(
                              controller: firstNameController,
                              decoration:
                                  const InputDecoration(labelText: 'First name'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: lastNameController,
                              decoration:
                                  const InputDecoration(labelText: 'Last name'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: tenantController,
                              decoration: const InputDecoration(
                                labelText: 'Organization name',
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Password'),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isLoading ? null : _submit,
                              child: Text(
                                isLoading
                                    ? 'Please wait...'
                                    : (isSignUp ? 'Create account' : 'Sign in'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => setState(() => isSignUp = !isSignUp),
                            child: Text(
                              isSignUp
                                  ? 'Already have an account? Sign in'
                                  : 'No account yet? Sign up',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
