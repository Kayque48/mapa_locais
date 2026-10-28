import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/formatadores.dart';
import '../utils/mensagens.dart';

/// Abre o formulário em um Bottom Sheet (seções 17 e 18).
/// - [local] == null  -> CADASTRO (cria documento na coleção locais)
/// - [local] != null  -> EDIÇÃO (formulário preenchido com os dados atuais)
Future<void> abrirFormularioLocal(
  BuildContext context, {
  Local? local,
  String? cidadeInicial,
}) async {
  final mensagem = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => LocalForm(local: local, cidadeInicial: cidadeInicial),
  );

  if (mensagem != null && context.mounted) {
    mostrarSucesso(context, mensagem);
  }
}

class LocalForm extends StatefulWidget {
  final Local? local;
  final String? cidadeInicial;

  const LocalForm({super.key, this.local, this.cidadeInicial});

  @override
  State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = LocalService();

  late final TextEditingController nomeController;
  late final TextEditingController horarioController;
  late final TextEditingController avaliacaoController;
  late final TextEditingController distanciaController;
  late final TextEditingController descricaoController;

  late String categoriaSelecionada;
  late String cidadeSelecionada;

  bool _salvando = false;
  String? _erro;

  bool get _editando => widget.local != null;

  @override
  void initState() {
    super.initState();
    final local = widget.local;

    nomeController = TextEditingController(text: local?.nome ?? '');
    horarioController = TextEditingController(text: local?.horario ?? '');
    avaliacaoController = TextEditingController(
      text: local == null ? '' : formatarAvaliacao(local.avaliacao),
    );
    distanciaController = TextEditingController(
      text: local == null
          ? ''
          : local.distancia.toStringAsFixed(1).replaceAll('.', ','),
    );
    descricaoController = TextEditingController(text: local?.descricao ?? '');

    categoriaSelecionada = local?.categoria ?? categorias.first;

    final cidadeInicial = widget.cidadeInicial;
    cidadeSelecionada = local?.cidade ??
        (cidadeInicial != null && cidades.contains(cidadeInicial)
            ? cidadeInicial
            : cidades.first);
  }

  @override
  void dispose() {
    nomeController.dispose();
    horarioController.dispose();
    avaliacaoController.dispose();
    distanciaController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  /// CREATE — mesmo fluxo da seção 17 do tutorial.
  Future<void> cadastrarLocal() async {
    final novoLocal = Local(
      id: '',
      nome: nomeController.text.trim(),
      categoria: categoriaSelecionada,
      cidade: cidadeSelecionada,
      avaliacao: lerNumero(avaliacaoController.text) ?? 0,
      distancia: lerNumero(distanciaController.text) ?? 0,
      horario: horarioController.text.trim(),
      descricao: descricaoController.text.trim(),
      favorito: false,
    );

    await LocalService().adicionar(novoLocal);
  }

  /// UPDATE — seção 18: mantém o mesmo ID e o valor de favorito.
  Future<void> editarLocal() async {
    final localEditado = widget.local!.copyWith(
      nome: nomeController.text.trim(),
      categoria: categoriaSelecionada,
      cidade: cidadeSelecionada,
      avaliacao: lerNumero(avaliacaoController.text) ?? 0,
      distancia: lerNumero(distanciaController.text) ?? 0,
      horario: horarioController.text.trim(),
      descricao: descricaoController.text.trim(),
    );

    await _service.atualizar(localEditado);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      if (_editando) {
        await editarLocal();
      } else {
        await cadastrarLocal();
      }
      if (!mounted) return;
      Navigator.pop(
        context,
        _editando
            ? 'Local "${nomeController.text.trim()}" atualizado com sucesso!'
            : 'Local "${nomeController.text.trim()}" cadastrado com sucesso!',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = 'Erro ao salvar no Firestore: $e';
      });
      mostrarErro(context, 'Não foi possível salvar o local.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final categoriasDisponiveis = [
      ...categorias,
      if (!categorias.contains(categoriaSelecionada)) categoriaSelecionada,
    ];

    return Padding(
      // Sobe o formulário quando o teclado abre.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editando ? 'Editar local' : 'Cadastrar novo local',
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nomeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.store_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Informe o nome do local'
                    : null,
              ),
              const SizedBox(height: 16),
              Text('Categoria', style: tema.textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final categoria in categoriasDisponiveis)
                    ChoiceChip(
                      label: Text(categoria),
                      selected: categoriaSelecionada == categoria,
                      onSelected: (_) =>
                          setState(() => categoriaSelecionada = categoria),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Cidade', style: tema.textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final cidade in cidades)
                    ChoiceChip(
                      label: Text(cidade),
                      selected: cidadeSelecionada == cidade,
                      onSelected: (_) =>
                          setState(() => cidadeSelecionada = cidade),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: horarioController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Horário de funcionamento *',
                  hintText: '06:00 - 22:00',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => horarioValido(valor ?? '')
                    ? null
                    : 'Use o formato 06:00 - 22:00',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: avaliacaoController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Avaliação (0 a 5) *',
                        prefixIcon: Icon(Icons.star_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        final nota = lerNumero(valor ?? '');
                        if (nota == null) return 'Informe um número';
                        if (nota < 0 || nota > 5) return 'Entre 0 e 5';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: distanciaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Distância (km) *',
                        prefixIcon: Icon(Icons.near_me_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        final km = lerNumero(valor ?? '');
                        if (km == null) return 'Informe um número';
                        if (km < 0) return 'Não pode ser negativa';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descricaoController,
                maxLines: 3,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _erro!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_editando ? Icons.save : Icons.add),
                label: Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
