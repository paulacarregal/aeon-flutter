enum ProfessionalProfileType {
  establishment,
  brand,
  creator,

  
}

extension ProfessionalProfileTypeExtension on ProfessionalProfileType {
  String get value {
    switch (this) {
      case ProfessionalProfileType.establishment:
        return 'establishment';
      case ProfessionalProfileType.brand:
        return 'brand';
      case ProfessionalProfileType.creator:
        return 'creator';
    }
  }

  String get label {
    switch (this) {
      case ProfessionalProfileType.establishment:
        return 'Estabelecimento';
      case ProfessionalProfileType.brand:
        return 'Marca';
      case ProfessionalProfileType.creator:
        return 'Criador';
    }
  }

  String get description {
    switch (this) {
      case ProfessionalProfileType.establishment:
        return 'Restaurante, loja, bar, espaço, evento ou outro local.';
      case ProfessionalProfileType.brand:
        return 'Empresa ou marca que deseja divulgar campanhas e experiências.';
      case ProfessionalProfileType.creator:
        return 'Criador de conteúdo ou influenciador.';
    }
  }
}

ProfessionalProfileType professionalProfileTypeFromValue(String value) {
  switch (value) {
    case 'brand':
      return ProfessionalProfileType.brand;
    case 'creator':
      return ProfessionalProfileType.creator;
    case 'establishment':
    default:
      return ProfessionalProfileType.establishment;
  }
}

class ProfessionalProfile {
  final String ownerUid;
  final ProfessionalProfileType type;
  final String displayName;
  final String category;
  final String document;
  final String description;
  final String phone;
  final String website;
  final String instagram;
  final String city;
  final String address;
  final String status;

  bool get requiresDocument =>
      type == ProfessionalProfileType.establishment ||
      type == ProfessionalProfileType.brand;

  const ProfessionalProfile({
    required this.ownerUid,
    required this.type,
    required this.displayName,
    required this.category,
    this.document = '',
    this.description = '',
    this.phone = '',
    this.website = '',
    this.instagram = '',
    this.city = '',
    this.address = '',
    this.status = 'pending',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'ownerUid': ownerUid,
      'type': type.value,
      'displayName': displayName.trim(),
      'category': category.trim(),
      'document': document.replaceAll(RegExp(r'\D'), ''),
      'description': description.trim(),
      'phone': phone.trim(),
      'website': website.trim(),
      'instagram': instagram.trim(),
      'city': city.trim(),
      'address': address.trim(),
      'status': status,
    };
  }

  factory ProfessionalProfile.fromFirestore(
    Map<String, dynamic> data,
  ) {
    return ProfessionalProfile(
      ownerUid: data['ownerUid']?.toString() ?? '',
      type: professionalProfileTypeFromValue(
        data['type']?.toString() ?? 'establishment',
      ),
      displayName: data['displayName']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      document: data['document']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      website: data['website']?.toString() ?? '',
      instagram: data['instagram']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
    );
  }
}