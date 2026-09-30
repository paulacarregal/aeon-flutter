import 'package:flutter/material.dart';

import '../../alerts/domain/alert.dart';
import '../../notifications/notification_service.dart';

class AlertMarkerWidget extends StatelessWidget {
  final Alert alert;

  const AlertMarkerWidget({super.key, required this.alert});

  Color _colorForNivel(String nivel) {
    switch (nivel) {
      case 'alto':
        return Colors.red;
      case 'medio':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForNivel(alert.nivel);

    return GestureDetector(
      onTap: () {
        NotificationService.showLocalAlert(
          title: 'Alerta AEON',
          body: 'Possível risco detectado nesta região.',
        );
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(alert.titulo),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.descricao),
                const SizedBox(height: 10),
                Text(
                  'Nível: ${alert.nivel}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      },
      child: Icon(Icons.warning, color: color, size: 35),
    );
  }
}
