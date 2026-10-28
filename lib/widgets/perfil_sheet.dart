import 'package:flutter/material.dart';
import '../services/local_service.dart';
import '../utils/mensagens.dart';

/// Aba "Perfil" da barra inferior. Para manter apenas três telas
/// principais, ela abre um Bottom Sheet com informações do app e a opção
/// de carregar os locais de exemplo no Firestore.
Future<void> mostrarPerfil(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CircleAvatar(
                radius: 32,
                child: Icon(Icons.person, size: 36),
              ),
              const SizedBox(height: 12),
              Text(
                'Usuário convidado',
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mapa de Locais · Flutter + Cloud Firestore\n'
                'Coleção utilizada: locais',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              StreamBuilder(
                stream: LocalService().listarLocais(),
                builder: (context, snapshot) {
                  final total = snapshot.data?.length;
                  final favoritos =
                      snapshot.data?.where((l) => l.favorito).length;
                  return ListTile(
                    leading: const Icon(Icons.cloud_done_outlined),
                    title: Text(
                      total == null
                          ? 'Conectando ao Firestore...'
                          : '$total locais cadastrados',
                    ),
                    subtitle: favoritos == null
                        ? null
                        : Text('$favoritos marcados como favoritos'),
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.playlist_add),
                label: const Text('Carregar locais de exemplo'),
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: sheetContext,
                    builder: (context) => AlertDialog(
                      title: const Text('Carregar locais de exemplo?'),
                      content: const Text(
                        'Serão criados 17 documentos na coleção "locais" '
                        '(São Paulo, Campinas e Jundiaí). '
                        'Use apenas uma vez para não duplicar os dados.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Carregar'),
                        ),
                      ],
                    ),
                  );
                  if (confirmar != true || !sheetContext.mounted) return;

                  try {
                    final total = await LocalService().cadastrarLocaisExemplo();
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    if (!context.mounted) return;
                    mostrarSucesso(
                      context,
                      '$total locais de exemplo cadastrados no Firestore!',
                    );
                  } catch (e) {
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    if (!context.mounted) return;
                    mostrarErro(context, 'Erro ao cadastrar exemplos: $e');
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
