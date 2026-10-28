import 'package:flutter/material.dart';

/// Mensagens de sucesso/erro exibidas nas operações de banco
/// (requisito não funcional da seção 7).

void mostrarSucesso(BuildContext context, String mensagem) {
  _mostrar(context, mensagem, Colors.green.shade700, Icons.check_circle);
}

void mostrarErro(BuildContext context, String mensagem) {
  _mostrar(context, mensagem, Colors.red.shade700, Icons.error);
}

void mostrarInfo(BuildContext context, String mensagem) {
  _mostrar(context, mensagem, Colors.grey.shade800, Icons.info);
}

void _mostrar(
  BuildContext context,
  String mensagem,
  Color cor,
  IconData icone,
) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cor,
      content: Row(
        children: [
          Icon(icone, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(mensagem)),
        ],
      ),
    ),
  );
}
