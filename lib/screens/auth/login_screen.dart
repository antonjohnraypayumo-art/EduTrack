import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isSignUp) {
        final cred = await _auth.signUp(_emailCtrl.text, _passCtrl.text);
        await cred.user?.updateDisplayName(_nameCtrl.text.trim());
        await FirestoreService()
            .createInitialProfileIfMissing(name: _nameCtrl.text.trim());
      } else {
        await _auth.signIn(_emailCtrl.text, _passCtrl.text);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('LearnTrack',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 6),
              Text(
                _isSignUp ? 'Create your account' : 'Welcome back',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 32),
              if (_isSignUp) ...[
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isSignUp ? 'Sign Up' : 'Log In'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp
                    ? 'Already have an account? Log In'
                    : "Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
