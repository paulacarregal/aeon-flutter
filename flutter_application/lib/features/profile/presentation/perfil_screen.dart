import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../routes/route_names.dart';
import '../../feed/presentation/post_provider.dart';
import '../data/user_service.dart';
import '../../reviews/data/review_service.dart';
import '../../reviews/domain/review.dart';




class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  void _reloadProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'nome': 'Usuario', 'email': ''};

    Map<String, dynamic> firestoreData = {};
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();
      firestoreData = doc.data() ?? {};
    } catch (_) {
      firestoreData = {};
    }

    final firestoreName = firestoreData['nome']?.toString().trim();
    final authName = user.displayName?.trim();
    final email =
        firestoreData['email']?.toString().trim() ?? user.email?.trim() ?? '';

    return {
      ...firestoreData,
      'nome': firestoreName != null && firestoreName.isNotEmpty
          ? firestoreName
          : authName != null && authName.isNotEmpty
              ? authName
              : email.isNotEmpty
                  ? email.split('@').first
                  : 'Usuario',
      'email': email,
    };
  }

  Future<List<Review>> _getUserReviews() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return ReviewService().getReviewsByUser(user.uid);
  }

  Future<_ProfileData> _loadProfile() async {
    final userData = await _getUserData();
    final reviews = await _getUserReviews();

    return _ProfileData(
      userData: userData,
      reviews: reviews,
    );
  }

  Future<void> _openSettings(Map<String, dynamic> userData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileSettingsScreen(userData: userData),
      ),
    );
    if (mounted) _reloadProfile();
  }

  Future<void> _openPreferences(Map<String, dynamic> userData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendationPreferencesScreen(userData: userData),
      ),
    );
    if (mounted) _reloadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF5),
      body: SafeArea(
        child: FutureBuilder<_ProfileData>(
          future: _profileFuture,
          builder: (context, snapshot) {
            final data = snapshot.data ??
                const _ProfileData(userData: {}, reviews: []);
            final userData = data.userData;
            final reviews = data.reviews;
            final currentUser = FirebaseAuth.instance.currentUser;
            final email =
                userData['email']?.toString() ?? currentUser?.email ?? '';
            final nome = userData['nome']?.toString() ??
                currentUser?.displayName?.trim() ??
                (email.isNotEmpty ? email.split('@').first : 'Perfil AEON');
            final photoUrl = userData['photoUrl']?.toString() ?? '';
            final isBlair = nome.toLowerCase().contains('blair') ||
                email.toLowerCase().contains('blair');
            final ImageProvider? avatarImage = photoUrl.startsWith('http')
                ? NetworkImage(photoUrl)
                : photoUrl.isNotEmpty
                    ? AssetImage(photoUrl)
                    : isBlair
                        ? const AssetImage('assets/images/places/blair.jpg')
                        : null;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            top: 50, left: 20, right: 20),
                        padding: const EdgeInsets.only(
                            top: 70, left: 20, right: 20, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(blurRadius: 8, color: Colors.black12)
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nome,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Preferencias',
                                      onPressed: () => _openPreferences(userData),
                                      icon: const Icon(Icons.tune),
                                    ),
                                    IconButton(
                                      tooltip: 'Configuracoes',
                                      onPressed: () => _openSettings(userData),
                                      icon: const Icon(Icons.settings),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _ReviewCountPill(count: reviews.length),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? const Icon(Icons.person, size: 44)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: reviews.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(18),
                            child: Column(
                              children: [
                                Icon(Icons.rate_review_outlined,
                                    size: 36, color: Colors.black45),
                                SizedBox(height: 10),
                                Text(
                                  'Quando voce publicar uma review, ela aparece aqui.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: reviews
                                .map(
                                  (review) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: _ReviewCard(
                                      review: review,
                                      onChanged: _reloadProfile,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileData {
  final Map<String, dynamic> userData;
  final List<Review> reviews;

  const _ProfileData({
    required this.userData,
    required this.reviews,
  });
}

class ProfileSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileSettingsScreen({
    super.key,
    required this.userData,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class RecommendationPreferencesScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const RecommendationPreferencesScreen({
    super.key,
    required this.userData,
  });

  @override
  State<RecommendationPreferencesScreen> createState() =>
      _RecommendationPreferencesScreenState();
}

class _RecommendationPreferencesScreenState
    extends State<RecommendationPreferencesScreen> {
  final _userService = UserService();
  late double _outdoor;
  late double _active;
  late double _night;
  late double _social;
  late double _novelty;
  late double _maxDistanceKm;
  late String _savedProfileName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _applyUserData(widget.userData);
    _loadLatestUserData();
  }

  void _applyUserData(Map<String, dynamic> userData) {
    final prefs = Map<String, dynamic>.from(
      userData['recommendationPreferences'] as Map? ?? const {},
    );
    final tags = Set<String>.from(
      userData['preferredTags'] as List? ?? const [],
    );
    _outdoor = _readDouble(
      prefs,
      'outdoor',
      _readTopLevelDouble(
        userData,
        'radarOutdoor',
        tags.contains('outdoor') ? 1.0 : tags.contains('urban') ? 0.0 : 0.5,
      ),
    );
    _active = _readDouble(
      prefs,
      'active',
      _readTopLevelDouble(
        userData,
        'radarActive',
        tags.contains('active') ? 1.0 : tags.contains('calm') ? 0.0 : 0.5,
      ),
    );
    _night = _readDouble(
      prefs,
      'night',
      _readTopLevelDouble(
        userData,
        'radarNight',
        tags.contains('night') ? 1.0 : tags.contains('day') ? 0.0 : 0.5,
      ),
    );
    _social = _readDouble(
      prefs,
      'social',
      _readTopLevelDouble(
        userData,
        'radarSocial',
        tags.contains('social') ? 1.0 : tags.contains('solo') ? 0.0 : 0.5,
      ),
    );
    _novelty = _readDouble(
      prefs,
      'novelty',
      _readTopLevelDouble(
        userData,
        'radarNovelty',
        tags.contains('new') ? 1.0 : tags.contains('rated') ? 0.0 : 0.5,
      ),
    );
    _maxDistanceKm = _readDouble(
      prefs,
      'maxDistanceKm',
      _readTopLevelDouble(userData, 'maxDistanceKm', 8),
    );
    _savedProfileName = prefs['profileMapped']?.toString() ??
        userData['profileMapped']?.toString() ??
        userData['profileName']?.toString() ??
        _mappedProfileName;
  }

  Future<void> _loadLatestUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (!mounted || data == null) return;
      setState(() => _applyUserData(data));
    } catch (_) {
      // Keep the data received from the profile page.
    }
  }

  double _readDouble(Map<String, dynamic> prefs, String key, double fallback) {
    final value = (prefs[key] as num?)?.toDouble();
    if (value == null) return fallback;
    if (key != 'maxDistanceKm' && value > 1) return value / 100;
    return value;
  }

  double _readTopLevelDouble(
    Map<String, dynamic> data,
    String key,
    double fallback,
  ) {
    final value = (data[key] as num?)?.toDouble();
    if (value == null) return fallback;
    if (key != 'maxDistanceKm' && value > 1) return value / 100;
    return value;
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final preferences = {
        'outdoor': _snapPreference(_outdoor),
        'active': _snapPreference(_active),
        'night': _snapPreference(_night),
        'social': _snapPreference(_social),
        'novelty': _snapPreference(_novelty),
        'maxDistanceKm': _maxDistanceKm.roundToDouble(),
        'profileMapped': _mappedProfileName,
      };
      await _userService.updateRecommendationPreferences(
        uid: user.uid,
        preferences: preferences,
      );

      final savedDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();
      final savedData = savedDoc.data();
      final savedProfile = savedData?['profileMapped']?.toString();
      final expectedProfile = preferences['profileMapped'].toString();
      final savedDistance = (savedData?['maxDistanceKm'] as num?)?.toDouble();
      final savedOutdoor = (savedData?['radarOutdoor'] as num?)?.toDouble();
      if (savedData == null ||
          savedProfile != expectedProfile ||
          savedDistance != preferences['maxDistanceKm'] ||
          savedOutdoor != preferences['outdoor']) {
        throw StateError('O Firestore nao confirmou o salvamento.');
      }

      setState(() {
        _applyUserData(savedData);
        _saving = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Radar salvo.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  double _snapPreference(double value) {
    if (value <= 0.25) return 0.0;
    if (value >= 0.75) return 1.0;
    return 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userData['nome']?.toString() ??
        FirebaseAuth.instance.currentUser?.displayName?.trim() ??
        'Explorador AEON';
    final email = widget.userData['email']?.toString() ??
        FirebaseAuth.instance.currentUser?.email ??
        '';
    final photoUrl = widget.userData['photoUrl']?.toString() ?? '';
    final isBlair = name.toLowerCase().contains('blair') ||
        email.toLowerCase().contains('blair');
    final ImageProvider? avatarImage = photoUrl.startsWith('http')
        ? NetworkImage(photoUrl)
        : photoUrl.isNotEmpty
            ? AssetImage(photoUrl)
            : isBlair
                ? const AssetImage('assets/images/places/blair.jpg')
                : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FFF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meu Radar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(blurRadius: 8, color: Colors.black12),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ProfileMappedPill(profileName: _savedProfileName),
                  const SizedBox(height: 22),
                  _PreferenceSlider(
                    leftLabel: 'Fechado',
                    rightLabel: 'Ar livre',
                    value: _outdoor,
                    onChanged: (value) => setState(() => _outdoor = value),
                  ),
                  _PreferenceSlider(
                    leftLabel: 'Calmo',
                    rightLabel: 'Agitado',
                    value: _active,
                    onChanged: (value) => setState(() => _active = value),
                  ),
                  _PreferenceSlider(
                    leftLabel: 'Dia',
                    rightLabel: 'Noite',
                    value: _night,
                    onChanged: (value) => setState(() => _night = value),
                  ),
                  _PreferenceSlider(
                    leftLabel: 'Sozinho',
                    rightLabel: 'Social',
                    value: _social,
                    onChanged: (value) => setState(() => _social = value),
                  ),
                  _PreferenceSlider(
                    leftLabel: 'Conhecido',
                    rightLabel: 'Novidade',
                    value: _novelty,
                    onChanged: (value) => setState(() => _novelty = value),
                  ),
                  _DistanceSlider(
                    value: _maxDistanceKm,
                    onChanged: (value) =>
                        setState(() => _maxDistanceKm = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1FA2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
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
                    : const Text(
                        'Salvar meu radar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _mappedProfileName {
    if (_active == 1.0 && _night >= 0.5 && _social >= 0.5) {
      return 'Noturno Social';
    }
    if (_outdoor == 1.0 && _active >= 0.5) {
      return 'Livre em Movimento';
    }
    if (_novelty == 1.0 && _social >= 0.5) {
      return 'Cacador de Novidades';
    }
    if (_outdoor == 0.0 && _active <= 0.5) {
      return 'Refugio Calmo';
    }
    if (_night == 0.0 && _social <= 0.5) {
      return 'Roteiro Leve';
    }
    return 'Explorador Equilibrado';
  }
}

class _ProfileMappedPill extends StatelessWidget {
  final String profileName;

  const _ProfileMappedPill({required this.profileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6DDED)),
      ),
      child: Text(
        profileName,
        style: const TextStyle(
          color: Color(0xFF7B1FA2),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PreferenceSlider extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final double value;
  final ValueChanged<double> onChanged;

  const _PreferenceSlider({
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(leftLabel)),
              Expanded(
                child: Text(
                  rightLabel,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 2,
            activeColor: const Color(0xFF7B1FA2),
            inactiveColor: const Color(0xFFE6DDED),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DistanceSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _DistanceSlider({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Distancia da recomendacao')),
              Text(
                '${value.round()} km',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 20,
            divisions: 20,
            activeColor: const Color(0xFF7B1FA2),
            inactiveColor: const Color(0xFFE6DDED),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(
      text: widget.userData['nome']?.toString() ??
          user?.displayName?.trim() ??
          '',
    );
    _emailController = TextEditingController(
      text: widget.userData['email']?.toString() ?? user?.email ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final name = _nameController.text.trim();
    if (user == null || name.isEmpty) return;

    setState(() => _saving = true);
    try {
      await user.updateDisplayName(name);
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .set({
        'nome': name,
        'email': user.email,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final isBlair = name.toLowerCase().contains('blair') ||
        email.toLowerCase().contains('blair');
    final photoUrl = widget.userData['photoUrl']?.toString() ?? '';
    final ImageProvider? avatarImage = photoUrl.startsWith('http')
        ? NetworkImage(photoUrl)
        : photoUrl.isNotEmpty
            ? AssetImage(photoUrl)
            : isBlair
                ? const AssetImage('assets/images/places/blair.jpg')
                : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FFF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configuracoes',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(blurRadius: 8, color: Colors.black12),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? const Icon(Icons.person, size: 46)
                            : null,
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B1FA2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SettingsField(
                    controller: _nameController,
                    label: 'Nome de exibicao',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 12),
                  _SettingsField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.mail_outline,
                    enabled: false,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B1FA2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
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
                          : const Text(
                              'Salvar alteracoes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SettingsAction(
              icon: Icons.chat_bubble_outline,
              title: 'Fale conosco',
              subtitle: 'Envie duvidas, ideias ou problemas do app.',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Canal de contato em breve.')),
              ),
            ),
            const SizedBox(height: 12),
            _SettingsAction(
              icon: Icons.account_balance_outlined,
              title: 'Conta profissional',
              subtitle:
                  'Ative um perfil para seu estabelecimento, marca ou conteúdo.',
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  RouteNames.professionalAccount,
                );
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7B1FA2),
                  side: const BorderSide(color: Color(0xFF7B1FA2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exclusao de conta em breve.')),
              ),
              child: const Text(
                'Deletar a conta',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;

  const _SettingsField({
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: enabled ? const Color(0xFFF8F8F8) : const Color(0xFFECECEC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF7B1FA2)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCountPill extends StatelessWidget {
  final int count;

  const _ReviewCountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.rate_review_outlined, size: 18),
          const SizedBox(width: 6),
          Text(
            count == 1 ? '1 review publicada' : '$count reviews publicadas',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onChanged;

  const _ReviewCard({
    required this.review,
    required this.onChanged,
  });

  Future<void> _deleteReview(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deletar review?'),
        content: const Text('Essa acao remove a review do seu perfil e do feed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ReviewService().deleteReview(review.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deletada.')),
      );
      await context.read<PostProvider>().refresh();
      onChanged();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel deletar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: const Color(0xFFEBEBEB),
      collapsedBackgroundColor: const Color(0xFFEBEBEB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(review.placeName,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        review.spendRange.isNotEmpty
            ? '${review.address} | Gasto ${review.spendRange}'
            : review.address,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${review.rating}'),
          const Icon(Icons.star, color: Colors.amber),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Editar review'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Deletar review'),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edicao de review em breve.'),
                  ),
                );
                return;
              }
              if (value == 'delete') {
                _deleteReview(context);
              }
            },
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            review.comment.isNotEmpty
                ? review.comment
                : 'Sem comentario adicional.',
          ),
        ),
      ],
    );
  }
}
