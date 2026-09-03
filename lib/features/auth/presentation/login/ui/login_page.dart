import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/flavors/flavor_config.dart';
import '../../../../../core/widgets/vimes_logo.dart';
import '../bloc/auth_cubit.dart';

bool get _firebaseOn =>
    FlavorConfig.isInitialized && FlavorConfig.instance.useFirebase;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController(
    text: _firebaseOn ? '' : 'admin@vimes.local',
  ); //TODO BYPASS LOGIN FOR TEST
  final _password = TextEditingController(text: _firebaseOn ? '' : '123456');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final cubit = context.read<AuthCubit>();
    final ok = await cubit.signIn(_email.text, _password.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(cubit.signInError ?? 'Đăng nhập thất bại')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: VimesLogo(size: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'VIMES Inventory',
                    textAlign: TextAlign.center,
                    style: context.texts.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Quản lý nhập kho',
                    textAlign: TextAlign.center,
                    style: context.texts.bodyMedium?.copyWith(
                      color: context.colors.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, _) {
                      final busy = context.read<AuthCubit>().signingIn;
                      return FilledButton(
                        onPressed: busy ? null : _submit,
                        child: busy
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Đăng nhập'),
                      );
                    },
                  ),
                  if (!_firebaseOn) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Chế độ offline — tài khoản demo:\n'
                      'admin@vimes.local · thukho@vimes.local · '
                      'ketoan@vimes.local\nMật khẩu: 123456',
                      textAlign: TextAlign.center,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.colors.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
