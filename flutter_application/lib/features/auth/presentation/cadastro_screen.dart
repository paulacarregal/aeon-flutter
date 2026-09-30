import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './auth_provider.dart';
import '../../../shared/routes/route_names.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController  = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  Future<void> _cadastrar() async {
    final nome  = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    if (senha.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('A senha deve possuir no mínimo 8 caracteres.')),
      );
      return;
    }

    final ok = await context.read<AuthProvider>().register(
          email: email,
          password: senha,
          nome: nome,
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
      Navigator.pushReplacementNamed(context, RouteNames.quiz);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
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
              height: 280,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.circular(80),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AEON',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFBFF31),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Crie sua conta',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _nomeController,
                    hintText: 'Nome completo',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'E-mail',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _senhaController,
                    hintText: 'Senha (mín. 8 caracteres)',
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
                    label: 'Cadastrar',
                    onPressed: _cadastrar,
                    backgroundColor: AppColors.purple,
                    isLoading: auth.loading,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Já tenho conta'),
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
