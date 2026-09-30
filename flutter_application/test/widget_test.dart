
import 'package:flutter_test/flutter_test.dart';


import 'package:flutter_application/features/professional/domain/professional_profile.dart';

void main() {
  group('ProfessionalProfileType', () {
    test('deve possuir os três tipos de perfil profissional', () {
      expect(
        ProfessionalProfileType.values,
        containsAll([
          ProfessionalProfileType.establishment,
          ProfessionalProfileType.brand,
          ProfessionalProfileType.creator,
        ]),
      );
    });
  });
  
}