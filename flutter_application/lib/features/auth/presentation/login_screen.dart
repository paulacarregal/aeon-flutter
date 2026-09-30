import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './auth_provider.dart';
import '../../../shared/routes/route_names.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      context.read<AuthProvider>().clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha.')),
      );
      return;
    }

    final ok = await context.read<AuthProvider>().login(email, senha);
    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacementNamed(context, RouteNames.navigation);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 320,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.circular(80),
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/cabecalho.png',
                  width: MediaQuery.of(context).size.width * 0.70,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'E-mail',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _senhaController,
                    hintText: 'Senha',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  if (auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(auth.error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Entrar',
                    onPressed: _login,
                    backgroundColor: AppColors.purple,
                    isLoading: auth.loading,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: 'Cadastre-se',
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.cadastro),
                    backgroundColor: AppColors.yellow,
                    textColor: Colors.black,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
