// lib/utils/date_extensions.dart

extension DateTimeExtensions on DateTime {
  /// Retorna uma string de tempo relativo (ex: "há 2 dias")
  String toRelativeTime() {
    final Duration difference = DateTime.now().difference(this);

    if (difference.inSeconds < 60) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'há $minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'há $hours ${hours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'há $days ${days == 1 ? 'dia' : 'dias'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'há $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'há $months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'há $years ${years == 1 ? 'ano' : 'anos'}';
    }
  }

  /// Retorna uma string no formato "dd/MM/yyyy"
  String toDateString() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
}
