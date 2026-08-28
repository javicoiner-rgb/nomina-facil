import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

import '../constants/app_constants.dart';

/// Servicio de compras in-app (RevenueCat) para la suscripción PRO.
///
/// La app funciona 100 % offline: si RevenueCat no está configurado o no
/// hay red, este servicio degrada con elegancia y simplemente mantiene
/// [isPro] en `false`. El paywall solo afecta al Modo Negociación; los
/// modos Directo y Sorpresa son siempre gratuitos.
class PurchaseService extends ChangeNotifier {
  bool _isPro = false;
  bool _inicializado = false;
  bool _cargando = false;
  Offerings? _offerings;

  /// `true` si el usuario tiene el entitlement PRO activo.
  bool get isPro => _isPro;

  /// `true` mientras se resuelve una compra o la carga de ofertas.
  bool get cargando => _cargando;

  /// `true` cuando ya se ha intentado configurar el SDK.
  bool get inicializado => _inicializado;

  /// Oferta actual (el primer paquete disponible), o `null`.
  Package? get paquetePro =>
      _offerings?.current?.availablePackages.isNotEmpty == true
          ? _offerings!.current!.availablePackages.first
          : null;

  /// Precio ya formateado del paquete PRO (p. ej. "2,99 €"), o `null`.
  String? get precioPro => paquetePro?.storeProduct.priceString;

  /// Configura el SDK y consulta el estado de suscripción.
  ///
  /// En web (donde `purchases_flutter` no está soportado) o si falta la
  /// clave, no hace nada y deja la app en modo gratuito.
  Future<void> init() async {
    if (_inicializado) return;
    _inicializado = true;

    if (kIsWeb) return;

    try {
      final apiKey = Platform.isAndroid
          ? AppConstants.revenueCatApiKeyAndroid
          : AppConstants.revenueCatApiKeyIos;

      // Clave sin rellenar: no configuramos RevenueCat.
      if (apiKey.contains('TU_CLAVE')) return;

      await Purchases.setLogLevel(LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(apiKey));

      Purchases.addCustomerInfoUpdateListener(_actualizarDesde);

      await _refrescarEstado();
      await _cargarOfertas();
    } catch (e) {
      debugPrint('PurchaseService.init error: $e');
    }
  }

  Future<void> _cargarOfertas() async {
    try {
      _offerings = await Purchases.getOfferings();
      notifyListeners();
    } catch (e) {
      debugPrint('PurchaseService._cargarOfertas error: $e');
    }
  }

  Future<void> _refrescarEstado() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _actualizarDesde(info);
    } catch (e) {
      debugPrint('PurchaseService._refrescarEstado error: $e');
    }
  }

  void _actualizarDesde(CustomerInfo info) {
    final activo =
        info.entitlements.active.containsKey(AppConstants.entitlementPro);
    if (activo != _isPro) {
      _isPro = activo;
      notifyListeners();
    }
  }

  /// Lanza el flujo de compra del paquete PRO.
  ///
  /// Devuelve `true` si al terminar el usuario es PRO.
  Future<bool> comprarPro() async {
    final paquete = paquetePro;
    if (paquete == null) return false;

    _cargando = true;
    notifyListeners();
    try {
      final info = await Purchases.purchasePackage(paquete);
      _actualizarDesde(info);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('PurchaseService.comprarPro error: $e');
      }
    } catch (e) {
      debugPrint('PurchaseService.comprarPro error: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
    return _isPro;
  }

  /// Restaura compras anteriores.
  Future<bool> restaurar() async {
    _cargando = true;
    notifyListeners();
    try {
      final info = await Purchases.restorePurchases();
      _actualizarDesde(info);
    } catch (e) {
      debugPrint('PurchaseService.restaurar error: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
    return _isPro;
  }

  /// Solo para pruebas / demo: fuerza el estado PRO sin pasar por la store.
  @visibleForTesting
  void activarProDemo() {
    _isPro = true;
    notifyListeners();
  }
}
