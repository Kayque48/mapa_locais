import 'package:flutter/material.dart';
import '../models/local.dart';
import '../utils/formatadores.dart';
import 'imagem_local.dart';

/// Item da lista de resultados (Tela 2 do wireframe):
/// imagem, nome, categoria, distância, avaliação e seta.
/// O menu (⋮) dá acesso a Editar e Excluir.
class LocalCard extends StatelessWidget {
  final Local local;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const LocalCard({
    super.key,
    required this.local,
    required this.onTap,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final cinza = Colors.grey.shade700;
    final estiloInfo = TextStyle(fontSize: 12, color: cinza);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ImagemLocal(
                categoria: local.categoria,
                largura: 84,
                altura: 72,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            local.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (local.favorito)
                          const Icon(Icons.favorite,
                              size: 16, color: Colors.red),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${local.categoria} · ${local.cidade}',
                        style: estiloInfo),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: cinza),
                        const SizedBox(width: 2),
                        Text(formatarDistancia(local.distancia),
                            style: estiloInfo),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.black87),
                        const SizedBox(width: 2),
                        Text(formatarAvaliacao(local.avaliacao),
                            style: estiloInfo),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                icon: const Icon(Icons.more_vert),
                onSelected: (opcao) {
                  if (opcao == 'editar') onEditar();
                  if (opcao == 'excluir') onExcluir();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'excluir',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Excluir',
                          style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
