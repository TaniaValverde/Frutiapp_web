import 'package:flutter/material.dart';

import '../models/access_record.dart';
import '../services/access_log_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final AccessLogService? logService;

  const LoginPage({super.key, this.logService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();
  late final AccessLogService logService;
  String mensaje = '';

  @override
  void initState() {
    super.initState();
    logService = widget.logService ?? AccessLogService();
  }

  void validarAcceso() {
    final usuario = usuarioController.text.trim();
    final password = passwordController.text;
    final exitoso = usuario == 'admin' && password == '1234';

    logService.add(
      AccessRecord(
        usuario: usuario,
        fechaHora: DateTime.now(),
        exitoso: exitoso,
        origen: 'Web',
      ),
    );

    setState(() {
      mensaje = exitoso
          ? 'Acceso autorizado'
          : 'Usuario o contraseña incorrectos';
    });

    if (exitoso) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(logService: logService)),
        );
      });
    }
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8B95A5)),
    prefixIcon: Icon(icon, size: 21, color: const Color(0xFF74818A)),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFFF0F4FF),
    contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD9F5F0), Color(0xFFE9F8FD), Color(0xFFDDF3FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: Colors.white.withValues(alpha: 0.94),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F6F8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.eco, color: Color(0xFF39B98B), size: 18),
                              Text('FrutiApp', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF16735A))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text('FrutiApp', textAlign: TextAlign.center, style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF007B5B))),
                      const SizedBox(height: 6),
                      const Text('CONTROL DE ACCESO', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, letterSpacing: 1.3, color: Color(0xFF465057))),
                      const SizedBox(height: 29),
                      const Text('Usuario', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF33414A))),
                      const SizedBox(height: 7),
                      TextField(
                        controller: usuarioController,
                        style: const TextStyle(fontSize: 14),
                        decoration: _inputDecoration(hint: 'Ingrese su usuario', icon: Icons.person_outline),
                      ),
                      const SizedBox(height: 19),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Contraseña', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF33414A))),
                          Text('¿Olvidó su clave?', style: TextStyle(fontSize: 12, color: Color(0xFF007B5B))),
                        ],
                      ),
                      const SizedBox(height: 7),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 14),
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          suffixIcon: const Icon(Icons.visibility_off_outlined, size: 21, color: Color(0xFF74818A)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: validarAcceso,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF007B57),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('Ingresar'), SizedBox(width: 12), Icon(Icons.arrow_forward, size: 20)],
                          ),
                        ),
                      ),
                      if (mensaje.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(mensaje, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: mensaje == 'Acceso autorizado' ? Colors.green : Colors.red)),
                      ],
                      const SizedBox(height: 25),
                      const Text('Plataforma de gestión logística', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFFB5C6C1))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
