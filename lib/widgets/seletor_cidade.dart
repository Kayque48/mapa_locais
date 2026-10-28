import 'package:flutter/material.dart';
import '../utils/constantes.dart';

/// Abre um Bottom Sheet para escolher a cidade (RF01).
/// Com [incluirTodas] = true aparece também a opção "Todas" (filtro).
Future<String?> selecionarCidade(
  BuildContext context, {
  required String cidadeAtual,
  bool incluirTodas = false,
}) {
  final opcoes = [if (incluirTodas) todasCidades, ...cidades];

  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Selecione a cidade',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            for (final cidade in opcoes)
              ListTile(
                leading: Icon(
                  cidade == todasCidades
                      ? Icons.public
                      : Icons.location_city_outlined,
                ),
                title: Text(cidade),
                trailing: cidade == cidadeAtual
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(context, cidade),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
