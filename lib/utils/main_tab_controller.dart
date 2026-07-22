import 'package:flutter/material.dart';

/// Permite cambiar la pestaña del [MainScreen] desde pantallas apiladas
/// (p. ej. Perfil → Mis Reportes → Crear Reporte).
class MainTabController extends InheritedWidget {
  const MainTabController({
    super.key,
    required this.goToTab,
    required super.child,
  });

  final void Function(int index) goToTab;

  static MainTabController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainTabController>();
  }

  static MainTabController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'MainTabController no encontrado en el árbol');
    return controller!;
  }

  @override
  bool updateShouldNotify(MainTabController oldWidget) =>
      goToTab != oldWidget.goToTab;
}
