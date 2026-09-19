import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../shared/models/wiwit_api/auth/login_request.dart';
import '../../shared/models/wiwit_api/instance/instance_response.dart';
import '../../shared/models/wiwit_api/problem_details.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/chopper_provider.dart';
import '../../shared/providers/server_url_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  InstanceResponse? _instance;

  @override
  void initState() {
    super.initState();
    // Deferred to avoid calling setState. It crashing somewhere
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadServerVersion());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadServerVersion() async {
    try {
      final instance = await ref.read(instanceServiceProvider).getInstance();

      if (!mounted) return;
      setState(() => _instance = instance);
    } catch (e) {
      debugPrint('Failed to load server version: $e');
    }
  }

  Future<void> _changeServer() => ref.read(serverUrlProvider.notifier).clear();

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final request = LoginRequest(
        email: email,
        password: password,
        deviceName: await _getDeviceName(),
      );

      final loginResponse = await ref.read(authServiceProvider).login(request);

      if (!mounted) return;

      final token = loginResponse.token;
      if (token.isEmpty) {
        throw Exception('The server did not return a token');
      }

      // Storing the token is the whole navigation: the root view watches it
      // and swaps onboarding/login out for home.
      await ref.read(authTokenProvider.notifier).set(token);
    } on ProblemDetails catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.detail)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Get device name per platform
  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.manufacturer + androidInfo.model;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    }
    return 'Unknown Device';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final serverUrl = ref.watch(serverUrlProvider).value;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'appLogo',
                          child: Image.asset(
                            'assets/logos/icon-${Theme.brightnessOf(context).name}-84.png',
                            height: 42,
                          ),
                        ),
                        Gap(18),
                        Text(
                          'Welcome back',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap(8),
                        Text(
                          'Sign in to your account',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Gap(20),

                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                'Email',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Gap(12),

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 0.0,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28.0),
                                  ),
                                  fillColor:
                                      theme.colorScheme.secondaryContainer,
                                  filled: true,
                                  hintText: 'you@example.com',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  final emailReg = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                                  );
                                  if (!emailReg.hasMatch(v.trim())) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              Gap(12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Password',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 24),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Gap(8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 0.0,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28.0),
                                  ),
                                  fillColor:
                                      theme.colorScheme.secondaryContainer,
                                  filled: true,
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (v.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),

                              Gap(20),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        )
                                      : Text(
                                          'Sign in',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                fontSize: 16,
                                              ),
                                        ),
                                ),
                              ),
                              Gap(18),
                              Center(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: TextStyle(
                                        color: theme.textTheme.bodySmall!.color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Create one',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 24),
                              Center(
                                child: TextButton.icon(
                                  onPressed: _isLoading ? null : _changeServer,
                                  icon: const Icon(
                                    Icons.dns_outlined,
                                    size: 16,
                                  ),
                                  label: Text(
                                    _instance == null
                                        ? (serverUrl ?? 'Change server')
                                        : '${_instance!.instanceName}'
                                              '${_instance!.version.display != null ? ' · ${_instance!.version.display}' : ''}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        theme.colorScheme.onSurfaceVariant,
                                    textStyle: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
