import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/professional_profile_service.dart';
import '../domain/professional_profile.dart';

import '../../../core/observability/logging_service.dart';

class ProfessionalAccountScreen extends StatefulWidget {
  const ProfessionalAccountScreen({super.key});

  @override
  State<ProfessionalAccountScreen> createState() =>
      _ProfessionalAccountScreenState();
}

class _ProfessionalAccountScreenState
    extends State<ProfessionalAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _documentController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  final _service = ProfessionalProfileService();

  ProfessionalProfileType? _selectedType;
  String? _selectedCategory;

  bool _loading = true;
  bool _saving = false;
  bool _hasExistingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _documentController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _cityController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final profile = await _service.getCurrentProfile();

      if (!mounted) return;

      if (profile != null) {
        _hasExistingProfile = true;
        _selectedType = profile.type;
        _selectedCategory = profile.category;
        _displayNameController.text = profile.displayName;
        _documentController.text = profile.document;
        _descriptionController.text = profile.description;
        _phoneController.text = profile.phone;
        _websiteController.text = profile.website;
        _instagramController.text = profile.instagram;
        _cityController.text = profile.city;
        _addressController.text = profile.address;
      }
    } catch (error, stackTrace) {
        log.error(
          'ProfessionalProfile',
          'Failed to load professional profile from screen',
          error: error,
          stack: stackTrace,
        );
      

      if (!mounted) return;

      _showMessage(
        'Não foi possível carregar seu cadastro profissional.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<String> get _categories {
    switch (_selectedType) {
      case ProfessionalProfileType.establishment:
        return const [
          'Restaurante',
          'Bar',
          'Café',
          'Loja',
          'Hotel',
          'Evento',
          'Cultura',
          'Lazer',
          'Serviços',
          'Outro',
        ];

      case ProfessionalProfileType.brand:
        return const [
          'Alimentação',
          'Moda',
          'Tecnologia',
          'Beleza',
          'Entretenimento',
          'Turismo',
          'Mobilidade',
          'Varejo',
          'Serviços',
          'Outro',
        ];

      case ProfessionalProfileType.creator:
        return const [
          'Lifestyle',
          'Gastronomia',
          'Moda',
          'Viagem',
          'Cultura',
          'Entretenimento',
          'Tecnologia',
          'Fitness',
          'Outro',
        ];

      case null:
        return const [];
    }
  }

  bool get _isEstablishment =>
      _selectedType == ProfessionalProfileType.establishment;

  bool get _isBusiness =>
      _selectedType == ProfessionalProfileType.establishment ||
      _selectedType == ProfessionalProfileType.brand;
  
  bool _isValidCnpj(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 14) {
      return false;
    }

    if (RegExp(r'^(\d)\1{13}$').hasMatch(digits)) {
      return false;
    }

    int calculateDigit(String value, List<int> weights) {
      var sum = 0;

      for (var i = 0; i < weights.length; i++) {
        sum += int.parse(value[i]) * weights[i];
      }

      final remainder = sum % 11;

      return remainder < 2 ? 0 : 11 - remainder;
    }

    final firstDigit = calculateDigit(
      digits.substring(0, 12),
      const [
        5, 4, 3, 2, 9, 8,
        7, 6, 5, 4, 3, 2,
      ],
    );

    if (firstDigit != int.parse(digits[12])) {
      return false;
    }

    final secondDigit = calculateDigit(
      digits.substring(0, 13),
      const [
        6, 5, 4, 3, 2, 9,
        8, 7, 6, 5, 4, 3, 2,
      ],
    );

    return secondDigit == int.parse(digits[13]);
  }

  String get _title {
    if (_hasExistingProfile) {
      return 'Editar conta profissional';
    }

    return 'Ativar conta profissional';
  }

  String get _subtitle {
    if (_selectedType == null) {
      return 'Escolha como você quer participar do AEON.';
    }

    return 'Preencha apenas as informações necessárias para começar.';
  }

  Future<void> _save() async {
    if (_selectedType == null) {
      _showMessage('Escolha um tipo de perfil para continuar.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Sua sessão expirou. Faça login novamente.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final profile = ProfessionalProfile(
        ownerUid: user.uid,
        type: _selectedType!,
        displayName: _displayNameController.text.trim(),
        category: _selectedCategory!,
        document: _documentController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        instagram: _instagramController.text.trim(),
        city: _cityController.text.trim(),
        address: _addressController.text.trim(),
        status: 'pending',
      );

      await _service.saveCurrentProfile(profile);

      if (!mounted) return;

      setState(() {
        _hasExistingProfile = true;
      });

      await _showSuccessDialog();
    } catch (error, stackTrace) {
        log.error(
          'ProfessionalProfile',
          'Failed to save professional profile from screen',
          error: error,
          stack: stackTrace,
        );

        debugPrint('=== ERRO AO SALVAR PERFIL PROFISSIONAL ===');
        debugPrint('TIPO: ${error.runtimeType}');
        debugPrint('ERRO: $error');
        debugPrint('STACK: $stackTrace');
        debugPrint('==========================================');

        if (!mounted) return;

        _showMessage(
          'ERRO: $error',
        );
      }finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cadastro salvo'),
          content: const Text(
            'Seu perfil profissional foi criado e está '
            'aguardando análise. Você poderá continuar '
            'usando sua conta pessoal normalmente.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7B1FA2),
              ),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _selectType(ProfessionalProfileType type) {
    setState(() {
      _selectedType = type;

      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FFF5),
        elevation: 0,
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: _saving
              ? null
              : () => Navigator.of(context).pop(),
        ),
        title: Text(
          _title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7B1FA2),
              ),
            )
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 720,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            _Header(
                              title: _selectedType == null
                                  ? 'Conta profissional'
                                  : _selectedType!.label,
                              subtitle: _subtitle,
                            ),
                            const SizedBox(height: 18),

                            if (_selectedType == null)
                              _buildTypeSelection()
                            else
                              _buildForm(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Escolha seu perfil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Essa escolha define o tipo de cadastro que '
          'vamos criar para você.',
          style: TextStyle(
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),

        _ProfileTypeCard(
          icon: Icons.storefront_outlined,
          title: 'Estabelecimento',
          description:
              'Para restaurantes, lojas, bares, cafés, '
              'eventos e outros locais.',
          onTap: () => _selectType(
            ProfessionalProfileType.establishment,
          ),
        ),

        const SizedBox(height: 12),

        _ProfileTypeCard(
          icon: Icons.sell_outlined,
          title: 'Marca',
          description:
              'Para empresas que querem divulgar '
              'campanhas, experiências e ativações.',
          onTap: () => _selectType(
            ProfessionalProfileType.brand,
          ),
        ),

        const SizedBox(height: 12),

        _ProfileTypeCard(
          icon: Icons.auto_awesome_outlined,
          title: 'Criador / Influenciador',
          description:
              'Para criadores de conteúdo e parceiros '
              'que desejam participar do AEON.',
          onTap: () => _selectType(
            ProfessionalProfileType.creator,
          ),
        ),

        const SizedBox(height: 24),

        _SecurityNotice(),
      ],
    );
  }

  Widget _buildForm() {
    final type = _selectedType!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SelectedTypeHeader(
            type: type,
            onChange: () {
              setState(() {
                _selectedType = null;
              });
            },
          ),

          const SizedBox(height: 16),

          _SectionCard(
            title: 'Informações principais',
            children: [
              _buildTextField(
                controller: _displayNameController,
                label: _isEstablishment
                    ? 'Nome do estabelecimento'
                    : type == ProfessionalProfileType.brand
                        ? 'Nome da marca'
                        : 'Nome público',
                hint: _isEstablishment
                    ? 'Ex.: Café AEON'
                    : type == ProfessionalProfileType.brand
                        ? 'Ex.: AEON Studio'
                        : 'Ex.: Blair Willows',
                icon: Icons.badge_outlined,
                maxLength: 80,
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Informe um nome válido.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                decoration: _inputDecoration(
                  label: 'Categoria',
                  icon: Icons.category_outlined,
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione uma categoria.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _descriptionController,
                label: 'Descrição',
                hint: 'Conte brevemente o que você oferece.',
                icon: Icons.description_outlined,
                maxLength: 300,
                maxLines: 4,
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (_isBusiness)
            _SectionCard(
              title: 'Identificação comercial',
              children: [
                _buildTextField(
                  controller: _documentController,
                  label: 'CNPJ',
                  hint: 'Somente números',
                  icon: Icons.business_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(14),
                  ],
                  maxLength: 14,
                  validator: (value) {
                    final digits =
                        value?.replaceAll(RegExp(r'\D'), '') ?? '';

                    if (digits.isEmpty) {
                      return 'Informe o CNPJ.';
                    }

                    if (!_isValidCnpj(digits)) {
                      return 'Informe um CNPJ válido.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 8),

                const Text(
                  'Nesta etapa o CNPJ será usado apenas para '
                  'identificação do perfil. Não estamos cadastrando '
                  'dados de pagamento.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
              ],
            ),

          if (_isBusiness)
            const SizedBox(height: 14),

          _SectionCard(
            title: _isEstablishment
                ? 'Localização'
                : 'Contato',
            children: [
              if (_isEstablishment) ...[
                _buildTextField(
                  controller: _addressController,
                  label: 'Endereço comercial',
                  hint: 'Rua, número e complemento',
                  icon: Icons.location_on_outlined,
                  maxLength: 160,
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Informe o endereço comercial.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _buildTextField(
                  controller: _cityController,
                  label: 'Cidade',
                  hint: 'Ex.: São Paulo',
                  icon: Icons.location_city_outlined,
                  maxLength: 80,
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Informe a cidade.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),
              ],

              if (_isBusiness) ...[
                _buildTextField(
                  controller: _phoneController,
                  label: 'Telefone comercial',
                  hint: '(11) 99999-9999',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  maxLength: 20,
                ),

                const SizedBox(height: 14),
              ],

              _buildTextField(
                controller: _instagramController,
                label: 'Instagram',
                hint: '@sua_marca',
                icon: Icons.camera_alt_outlined,
                maxLength: 80,
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _websiteController,
                label: 'Site',
                hint: 'https://...',
                icon: Icons.language_outlined,
                keyboardType: TextInputType.url,
                maxLength: 200,
              ),
            ],
          ),

          const SizedBox(height: 18),

          _SecurityNotice(),

          const SizedBox(height: 18),

          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7B1FA2),
                disabledBackgroundColor:
                    const Color(0xFFBFA6C8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _hasExistingProfile
                          ? 'Salvar alterações'
                          : 'Criar perfil profissional',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLength = 100,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.black12,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.black12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF7B1FA2),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ProfileTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ProfileTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF7B1FA2),
                  size: 27,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedTypeHeader extends StatelessWidget {
  final ProfessionalProfileType type;
  final VoidCallback onChange;

  const _SelectedTypeHeader({
    required this.type,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF7B1FA2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  type.description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD8EBDD),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline,
            color: Color(0xFF4E7D5A),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Seus dados são vinculados à sua conta autenticada. '
              'Nesta etapa não solicitamos senha, dados bancários '
              'ou informações de pagamento.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}