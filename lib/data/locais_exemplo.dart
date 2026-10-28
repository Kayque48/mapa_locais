import '../models/local.dart';

/// Locais de exemplo para popular a coleção `locais` rapidamente
/// (checklist: "Pelo menos 10 locais cadastrados").
/// São gravados pelo botão "Carregar locais de exemplo" (aba Perfil).
/// O id fica vazio porque o Firestore gera o ID automaticamente.
final List<Local> locaisExemplo = [
  // ---------------- São Paulo ----------------
  Local(
    id: '',
    nome: 'Academia Fitness',
    categoria: 'Academia',
    cidade: 'São Paulo',
    avaliacao: 4.8,
    distancia: 1.2,
    horario: '06:00 - 22:00',
    descricao: 'Academia completa com musculação, funcional, aulas coletivas '
        'e personal trainer. Ambiente moderno e bem equipado.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Smart Fit',
    categoria: 'Academia',
    cidade: 'São Paulo',
    avaliacao: 4.5,
    distancia: 2.4,
    horario: '05:00 - 23:00',
    descricao: 'Rede de academias com ampla área de musculação e cardio, '
        'aulas de bike e planos acessíveis.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Body Center',
    categoria: 'Academia',
    cidade: 'São Paulo',
    avaliacao: 4.3,
    distancia: 3.1,
    horario: '06:00 - 22:00',
    descricao: 'Academia de bairro com treinos personalizados, pilates e '
        'avaliação física mensal.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Proforma Academia',
    categoria: 'Academia',
    cidade: 'São Paulo',
    avaliacao: 4.0,
    distancia: 4.7,
    horario: '06:00 - 21:00',
    descricao: 'Espaço focado em treinamento funcional, cross training e '
        'aulas em grupo.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Iron Gym',
    categoria: 'Academia',
    cidade: 'São Paulo',
    avaliacao: 4.2,
    distancia: 5.2,
    horario: '00:00 - 00:00',
    descricao: 'Academia 24 horas voltada para musculação e levantamento '
        'de peso, com equipamentos importados.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Cantina Bella Napoli',
    categoria: 'Restaurante',
    cidade: 'São Paulo',
    avaliacao: 4.7,
    distancia: 1.9,
    horario: '11:30 - 23:00',
    descricao: 'Cantina italiana tradicional com massas artesanais, '
        'pizzas no forno a lenha e ambiente familiar.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Hospital Santa Clara',
    categoria: 'Hospital',
    cidade: 'São Paulo',
    avaliacao: 4.4,
    distancia: 3.8,
    horario: '00:00 - 00:00',
    descricao: 'Hospital geral com pronto-socorro 24 horas, exames de '
        'imagem e atendimento por convênios.',
    favorito: false,
  ),

  // ---------------- Campinas ----------------
  Local(
    id: '',
    nome: 'Campinas Fit Club',
    categoria: 'Academia',
    cidade: 'Campinas',
    avaliacao: 4.6,
    distancia: 0.8,
    horario: '06:00 - 23:00',
    descricao: 'Academia com piscina semiolímpica, musculação e aulas de '
        'natação para todas as idades.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Sabor Caipira',
    categoria: 'Restaurante',
    cidade: 'Campinas',
    avaliacao: 4.5,
    distancia: 2.2,
    horario: '11:00 - 15:00',
    descricao: 'Comida caseira no fogão a lenha, buffet por quilo e '
        'sobremesas típicas do interior.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Hospital Vida Campinas',
    categoria: 'Hospital',
    cidade: 'Campinas',
    avaliacao: 4.1,
    distancia: 4.5,
    horario: '00:00 - 00:00',
    descricao: 'Pronto atendimento adulto e infantil, centro cirúrgico e '
        'laboratório próprio.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Farmácia Central',
    categoria: 'Farmácia',
    cidade: 'Campinas',
    avaliacao: 4.3,
    distancia: 1.1,
    horario: '07:00 - 22:00',
    descricao: 'Medicamentos, perfumaria e aferição de pressão. Entrega '
        'em domicílio na região central.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Mercado Bom Preço',
    categoria: 'Mercado',
    cidade: 'Campinas',
    avaliacao: 3.9,
    distancia: 3.0,
    horario: '07:00 - 21:00',
    descricao: 'Supermercado de bairro com hortifrúti, padaria e açougue.',
    favorito: false,
  ),

  // ---------------- Jundiaí ----------------
  Local(
    id: '',
    nome: 'Serra Fit Academia',
    categoria: 'Academia',
    cidade: 'Jundiaí',
    avaliacao: 4.4,
    distancia: 1.6,
    horario: '06:00 - 22:00',
    descricao: 'Academia com musculação, spinning e aulas de dança, '
        'próxima à Serra do Japi.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Cantina do Vinhedo',
    categoria: 'Restaurante',
    cidade: 'Jundiaí',
    avaliacao: 4.8,
    distancia: 6.3,
    horario: '11:30 - 22:00',
    descricao: 'Restaurante na rota da uva com vinhos da região, massas e '
        'pratos típicos italianos.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Hospital Jundiaí Saúde',
    categoria: 'Hospital',
    cidade: 'Jundiaí',
    avaliacao: 4.0,
    distancia: 2.7,
    horario: '00:00 - 00:00',
    descricao: 'Hospital com pronto-socorro, maternidade e '
        'especialidades clínicas.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Farmácia Saúde Já',
    categoria: 'Farmácia',
    cidade: 'Jundiaí',
    avaliacao: 4.2,
    distancia: 0.9,
    horario: '08:00 - 22:00',
    descricao: 'Farmácia com manipulação, vacinas e programa de descontos.',
    favorito: false,
  ),
  Local(
    id: '',
    nome: 'Empório da Uva',
    categoria: 'Mercado',
    cidade: 'Jundiaí',
    avaliacao: 4.6,
    distancia: 4.1,
    horario: '08:00 - 19:00',
    descricao: 'Mercado de produtos regionais: uvas, vinhos, queijos e '
        'doces artesanais.',
    favorito: false,
  ),
];
