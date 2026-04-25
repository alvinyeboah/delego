import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../app.dart';
import '../../../core/branding/delego_brand.dart';
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

    final messenger = ScaffoldMessenger.of(context);
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
      if (!context.mounted) return;
      ref.read(authSessionProvider.notifier).state = session;
    } catch (e) {
      if (!context.mounted) return;
      String message = isSignUp ? 'Sign up failed' : 'Login failed';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          final raw = data['message'];
          if (raw is String && raw.trim().isNotEmpty) {
            message = raw;
          } else if (raw is List && raw.isNotEmpty) {
            message = raw.first.toString();
          }
        } else if (e.message != null && e.message!.trim().isNotEmpty) {
          message = e.message!.trim();
        }
      }
      messenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _LoginBackdropPainter(
              accent: cs.primary,
              accentTwo: cs.secondary,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          DelegoLogoBadge(
                            size: 52,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kAppDisplayName,
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        letterSpacing: -0.8,
                                      ),
                                ),
                                Text(
                                  'Field ops, tasks, and capture in one flow.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF2A3848)),
                          boxShadow: [
                            BoxShadow(
                              color: cs.secondary.withValues(alpha: 0.06),
                              blurRadius: 40,
                              spreadRadius: 0,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  isSignUp ? 'Create your workspace' : 'Welcome back',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isSignUp
                                      ? 'Spin up an org and invite your team when you are ready.'
                                      : 'Sign in to open the board, capture, and sync.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 22),
                                if (isSignUp) ...[
                                  TextField(
                                    controller: firstNameController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(labelText: 'First name'),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: lastNameController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(labelText: 'Last name'),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: tenantController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(labelText: 'Organization name'),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(labelText: 'Email'),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  autofillHints: const [AutofillHints.password],
                                  onSubmitted: (_) => isLoading ? null : _submit(),
                                  decoration: const InputDecoration(labelText: 'Password'),
                                ),
                                const SizedBox(height: 22),
                                FilledButton(
                                  onPressed: isLoading ? null : _submit,
                                  child: Text(
                                    isLoading
                                        ? 'Please wait…'
                                        : (isSignUp ? 'Create account' : 'Sign in'),
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Secure session · Encrypted transport',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft radial glow + vignette behind the form (no extra packages).
class _LoginBackdropPainter extends CustomPainter {
  _LoginBackdropPainter({required this.accent, required this.accentTwo});

  final Color accent;
  final Color accentTwo;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = const Color(0xFF0B0F14);
    canvas.drawRect(rect, Paint()..color = bg);

    final g1 = RadialGradient(
      colors: [
        accent.withValues(alpha: 0.22),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.08),
      size.shortestSide * 0.55,
      Paint()..shader = g1.createShader(Rect.fromCircle(center: Offset(size.width * 0.85, size.height * 0.08), radius: size.shortestSide * 0.55)),
    );

    final g2 = RadialGradient(
      colors: [
        accentTwo.withValues(alpha: 0.14),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.72),
      size.shortestSide * 0.65,
      Paint()..shader = g2.createShader(Rect.fromCircle(center: Offset(size.width * 0.12, size.height * 0.72), radius: size.shortestSide * 0.65)),
    );

    final vignette = RadialGradient(
      colors: [
        Colors.transparent,
        bg.withValues(alpha: 0.92),
      ],
      stops: const [0.55, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = vignette.createShader(rect)
        ..blendMode = BlendMode.srcOver,
    );
  }

  @override
  bool shouldRepaint(covariant _LoginBackdropPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.accentTwo != accentTwo;
  }
}
