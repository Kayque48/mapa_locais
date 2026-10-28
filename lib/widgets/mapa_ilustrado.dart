import 'package:flutter/material.dart';

/// Estilos do botão de camadas (ícone de "layers" no wireframe).
enum EstiloMapa { padrao, satelite }

/// Representação de mapa desenhada com CustomPainter.
/// O PDF exige "mapa/representação"; o Google Maps real é o
/// Desafio Extra Nível 2. Assim o app funciona sem chave de API.
class MapaIlustrado extends StatelessWidget {
  final EstiloMapa estilo;

  const MapaIlustrado({super.key, this.estilo = EstiloMapa.padrao});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapaPainter(estilo),
      child: const SizedBox.expand(),
    );
  }
}

class _MapaPainter extends CustomPainter {
  final EstiloMapa estilo;

  _MapaPainter(this.estilo);

  bool get _satelite => estilo == EstiloMapa.satelite;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.clipRect(Offset.zero & size);

    // Fundo (quarteirões)
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color =
            _satelite ? const Color(0xFF5B6A4C) : const Color(0xFFE8E9EB),
    );

    // Quarteirões levemente destacados
    final quarteirao = Paint()
      ..color = _satelite ? const Color(0xFF66745A) : const Color(0xFFDEDFE2);
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 8; j++) {
        if ((i + j) % 3 != 0) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(i * w / 6 + 8, j * h / 8 + 8, w / 6 - 16,
                h / 8 - 16),
            const Radius.circular(4),
          ),
          quarteirao,
        );
      }
    }

    // Parque
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, h * 0.66, w * 0.26, h * 0.16),
        const Radius.circular(10),
      ),
      Paint()
        ..color =
            _satelite ? const Color(0xFF3E5A31) : const Color(0xFFCFE5C9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.70, h * 0.04, w * 0.22, h * 0.10),
        const Radius.circular(10),
      ),
      Paint()
        ..color =
            _satelite ? const Color(0xFF3E5A31) : const Color(0xFFCFE5C9),
    );

    // Ruas secundárias
    final rua = Paint()
      ..color = _satelite ? const Color(0xFFB9B4A2) : Colors.white
      ..strokeWidth = _satelite ? 3 : 6
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < 8; i++) {
      final y = h * i / 8;
      canvas.drawLine(Offset(0, y - 6), Offset(w, y + 6), rua);
    }
    for (var i = 1; i < 6; i++) {
      final x = w * i / 6;
      canvas.drawLine(Offset(x - 8, 0), Offset(x + 8, h), rua);
    }

    // Avenidas
    final avenida = Paint()
      ..color = _satelite ? const Color(0xFFD8CFB0) : Colors.white
      ..strokeWidth = _satelite ? 7 : 13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, h * 0.30), Offset(w, h * 0.08), avenida);
    canvas.drawLine(Offset(w * 0.08, h), Offset(w * 0.95, 0), avenida);

    // Rio
    final rio = Path()
      ..moveTo(-20, h * 0.55)
      ..cubicTo(w * 0.25, h * 0.45, w * 0.45, h * 0.80, w * 0.65, h * 0.72)
      ..cubicTo(w * 0.85, h * 0.64, w * 0.95, h * 0.90, w + 20, h * 0.95);
    canvas.drawPath(
      rio,
      Paint()
        ..color =
            _satelite ? const Color(0xFF2F4A63) : const Color(0xFFBCC9D6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22,
    );
  }

  @override
  bool shouldRepaint(covariant _MapaPainter antigo) => antigo.estilo != estilo;
}
