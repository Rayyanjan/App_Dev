import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/app_models.dart';
import '../providers.dart';
import '../ui_helpers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _signup = false;

  @override
  void dispose() { _name.dispose(); _email.dispose(); _pw.dispose(); super.dispose(); }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final n = ref.read(authActionProvider.notifier);
    _signup ? n.signUp(_name.text, _email.text, _pw.text) : n.signIn(_email.text, _pw.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authActionProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage(next.error))));
      }
    });
    final loading = ref.watch(authActionProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('IBA RoomBook')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _form,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_signup ? 'Create account' : 'Log in',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                if (_signup) ...[
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'IBA email'),
                  validator: (v) => Validators.isAllowedEmail(v ?? '')
                      ? null : 'Email must contain $kAllowedDomain',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pw,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_signup ? 'Sign up' : 'Log in'),
                ),
                TextButton(
                  onPressed: loading ? null : () => setState(() => _signup = !_signup),
                  child: Text(_signup ? 'Have an account? Log in' : 'New here? Sign up'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
