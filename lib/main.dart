import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

void main() {
  runApp(const FrutiApp());
}

class FrutiApp extends StatelessWidget {
  const FrutiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrutiApp',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

// ==========================
// LOGIN
// ==========================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  bool recordar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'FrutiApp',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el correo';
                        }

                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Correo no válido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }

                        return null;
                      },
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: recordar,
                          onChanged: (value) {
                            setState(() {
                              recordar = value ?? false;
                            });
                          },
                        ),
                        const Text('Recordarme'),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        }
                      },
                      child: const Text('Ingresar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================
// HOME
// ==========================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Nombres de los productos
  final List<String> nombresFrutas = [
    'Manzana',
    'Piña',
    'Banano',
    'Mango',
    'Fresa',
    'Sandía',
    'Papaya',
    'Naranja',
    'Uva',
    'Melón',
  ];

  Future<List<dynamic>> cargarProductos() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('No se pudo cargar la información');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FrutiApp')),

      body: FutureBuilder<List<dynamic>>(
        future: cargarProductos(),

        builder: (context, snapshot) {
          // Mientras carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si ocurrió un error
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se pudo cargar la información.'),
            );
          }

          // Si hay información
          if (snapshot.hasData) {
            final productos = snapshot.data!;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),

                child: ListView.builder(
                  padding: const EdgeInsets.all(20),

                  itemCount: 10,

                  itemBuilder: (context, index) {
                    final producto = productos[index];

                    final int id = producto['id'];

                    final String nombre = nombresFrutas[index];

                    final int precio = id * 100;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),

                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),

                        leading: CircleAvatar(child: Text('$id')),

                        title: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          'Precio: $precio colones',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          return const Center(child: Text('No se pudo cargar la información.'));
        },
      ),
    );
  }
}
