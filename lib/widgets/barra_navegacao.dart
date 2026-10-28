import 'package:flutter/material.dart';

/// Barra inferior do wireframe: Mapa | Favoritos | Perfil.
class BarraNavegacao extends StatelessWidget {
  final int indiceAtual;
  final ValueChanged<int> onSelecionar;

  const BarraNavegacao({
    super.key,
    required this.indiceAtual,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: indiceAtual,
      onDestinationSelected: onSelecionar,
      height: 68,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
