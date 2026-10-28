// Funções de formatação no padrão brasileiro (vírgula decimal).

/// 1.2 -> "1,2 km"
String formatarDistancia(double km) {
  return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
}

/// 4.8 -> "4,8"
String formatarAvaliacao(double nota) {
  return nota.toStringAsFixed(1).replaceAll('.', ',');
}

/// Lê um horário no formato "06:00 - 22:00" e diz se o local está aberto
/// em [agora]. Retorna `null` quando o texto não segue esse formato.
bool? estaAberto(String horario, DateTime agora) {
  final partes = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})\s*$')
      .firstMatch(horario);
  if (partes == null) return null;

  final abre = int.parse(partes.group(1)!) * 60 + int.parse(partes.group(2)!);
  final fecha =
      int.parse(partes.group(3)!) * 60 + int.parse(partes.group(4)!);
  final minutoAtual = agora.hour * 60 + agora.minute;

  if (abre == fecha) return true; // 24 horas
  if (abre < fecha) {
    return minutoAtual >= abre && minutoAtual < fecha;
  }
  // Atravessa a meia-noite (ex.: 18:00 - 02:00)
  return minutoAtual >= abre || minutoAtual < fecha;
}

/// "Aberto · 06:00 - 22:00" / "Fechado · 06:00 - 22:00" / horário puro.
String textoHorario(String horario, DateTime agora) {
  final aberto = estaAberto(horario, agora);
  if (aberto == null) return horario.isEmpty ? 'Horário não informado' : horario;
  return '${aberto ? 'Aberto' : 'Fechado'} · ${horario.trim()}';
}

/// Valida o formato "HH:MM - HH:MM".
bool horarioValido(String horario) {
  final partes = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})\s*$')
      .firstMatch(horario);
  if (partes == null) return false;
  final valores = [1, 2, 3, 4].map((i) => int.parse(partes.group(i)!)).toList();
  return valores[0] <= 23 &&
      valores[2] <= 23 &&
      valores[1] <= 59 &&
      valores[3] <= 59;
}

/// Converte texto digitado ("4,5" ou "4.5") em número.
double? lerNumero(String texto) {
  return double.tryParse(texto.trim().replaceAll(',', '.'));
}
