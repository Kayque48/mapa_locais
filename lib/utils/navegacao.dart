import 'package:flutter/material.dart';
import '../models/local.dart';
import '../screens/resultados_screen.dart';
import '../widgets/perfil_sheet.dart';

/// Quando o usuário toca em "Ver no mapa" na tela de detalhes, o local é
/// colocado aqui e a pilha de telas volta até o mapa. A [MapaScreen] escuta
/// este valor e destaca o marcador correspondente.
final ValueNotifier<Local?> localParaMostrarNoMapa = ValueNotifier(null);

/// Índices da barra inferior (igual ao wireframe).
const int abaMapa = 0;
const int abaFavoritos = 1;
const int abaPerfil = 2;

/// Volta para a tela principal (Mapa).
void voltarParaMapa(BuildContext context) {
  Navigator.of(context).popUntil((rota) => rota.isFirst);
}

/// Mostra o local no mapa (RF10 — navegação detalhes -> mapa).
void verNoMapa(BuildContext context, Local local) {
  localParaMostrarNoMapa.value = local;
  voltarParaMapa(context);
}

/// Tratamento padrão da barra inferior para as telas 2 e 3.
void navegarPelaBarra(BuildContext context, int indice) {
  switch (indice) {
    case abaMapa:
      voltarParaMapa(context);
      break;
    case abaFavoritos:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ResultadosScreen(
            cidade: 'Todas',
            pesquisa: '',
            apenasFavoritos: true,
          ),
        ),
      );
      break;
    case abaPerfil:
      mostrarPerfil(context);
      break;
  }
}
