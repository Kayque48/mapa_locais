import 'package:flutter/material.dart';
import '../utils/constantes.dart';

/// Placeholder de imagem igual ao wireframe (retângulo cinza com montanhas).
/// O upload de imagens reais (Firebase Storage) é o Desafio Extra Nível 1.
class ImagemLocal extends StatelessWidget {
  final String categoria;
  final double? largura;
  final double? altura;
  final double raio;
  final double tamanhoIcone;

  const ImagemLocal({
    super.key,
    required this.categoria,
    this.largura,
    this.altura,
    this.raio = 8,
    this.tamanhoIcone = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: const Color(0xFFD9DBDF),
        borderRadius: BorderRadius.circular(raio),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.landscape_rounded,
              size: tamanhoIcone,
              color: const Color(0xFFA3A7AE),
            ),
          ),
          Positioned(
            left: 6,
            top: 6,
            child: Icon(
              iconeCategoria(categoria),
              size: tamanhoIcone * 0.35,
              color: const Color(0xFF8A8F97),
            ),
          ),
        ],
      ),
    );
  }
}
