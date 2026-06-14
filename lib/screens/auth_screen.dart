import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  final bool isLoggingIn;
  final ILocalStorageService? storage;

  const AuthScreen({super.key, this.isLoggingIn = true, this.storage});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isLoggingIn;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _hasInitializedRouteArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedRouteArgs) {
      _hasInitializedRouteArgs = true;
      final routeArg = ModalRoute.of(context)?.settings.arguments;
      if (routeArg is bool) {
        _isLoggingIn = routeArg;
      } else {
        _isLoggingIn = widget.isLoggingIn;
      }
      final storage = widget.storage ??
          LocalStorageService.instance as ILocalStorageService;
      if (storage.currentUser != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/mood-selection');
        });
      }
    }
  }

  bool get _isChecking => LocalStorageService.instance.currentUser != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final storage = widget.storage ??
          LocalStorageService.instance as ILocalStorageService;
      debugPrint('AuthScreen submit: isLoggingIn=$_isLoggingIn');
      if (_isLoggingIn) {
        await storage.loginUser(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await storage.registerUser(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      // small pause to allow storage flushes to settle on slower CI/Windows
      await Future.delayed(const Duration(milliseconds: 100));

      debugPrint('AuthScreen navigation: about to navigate to /mood-selection');
      if (!mounted) {
        debugPrint('AuthScreen navigation: widget no longer mounted');
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/mood-selection');
          debugPrint(
              'AuthScreen navigation: pushReplacementNamed /mood-selection');
        });
      }
    } catch (error) {
      debugPrint('AuthScreen error: $error');
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isLoggingIn ? 'Welcome back' : 'Create your account',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoggingIn
                        ? 'Login to continue discovering books for your mood.'
                        : 'Sign up to save your shelf and keep your reading list across sessions.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLoggingIn) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Your name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(_isLoggingIn ? 'Sign in' : 'Create account'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _isLoggingIn = !_isLoggingIn;
                              _errorMessage = null;
                            });
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondaryAccent,
                    ),
                    child: Text(_isLoggingIn
                        ? 'New here? Create an account'
                        : 'Already have an account? Sign in'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.bgCardDarker),
                  const SizedBox(height: 16),
                  Text(
                    'Inked keeps your preferences locally and helps you build a personal book shelf.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
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
