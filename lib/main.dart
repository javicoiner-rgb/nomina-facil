import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/purchase_service.dart';

/// Punto de entrada. Nómina Fácil funciona 100 % offline: aquí solo se
/// inicializa el servicio de compras (que degrada con elegancia si no hay
/// red ni configuración de RevenueCat).
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final purchaseService = PurchaseService();
  // No bloqueamos el arranque: la inicialización va en segundo plano.
  purchaseService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PurchaseService>.value(value: purchaseService),
      ],
      child: const NominaFacilApp(),
    ),
  );
}
