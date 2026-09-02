class AccessRecord {
  final String usuario;
  final DateTime fechaHora;
  final bool exitoso;
  final String origen;

  const AccessRecord({
    required this.usuario,
    required this.fechaHora,
    required this.exitoso,
    this.origen = 'Web',
  });

  Map<String, dynamic> toJson() => {
    'usuario': usuario,
    'fechaHora': fechaHora.toIso8601String(),
    'exitoso': exitoso,
    'origen': origen,
  };

  factory AccessRecord.fromJson(Map<String, dynamic> json) {
    return AccessRecord(
      usuario: json['usuario'] as String,
      fechaHora: DateTime.parse(json['fechaHora'] as String),
      exitoso: json['exitoso'] as bool,
      origen: json['origen'] as String? ?? 'Web',
    );
  }
}
