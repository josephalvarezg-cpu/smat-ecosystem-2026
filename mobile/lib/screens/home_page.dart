import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'add_estacion.dart';
import '../models/estacion.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Estacion>> futureEstaciones;
  @override
  void initState() {
    super.initState();
    futureEstaciones = ApiService().fetchEstaciones();
  }

  void _refreshData() {
    setState(() {
      futureEstaciones = ApiService().fetchEstaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estaciones SMAT'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEstacionScreen())
              );
            },
            child: const Text("Agregar Estación"),
          ),
          IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await AuthService().logout();
            // Reinicia la navegación al Login y borra el historial
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
          ),
        ],
      ),
      body: FutureBuilder<List<Estacion>>(
        future: futureEstaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Error de conexión'));
          } else {
            return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final est = snapshot.data![index];
              return ListTile(
                leading: const Icon(Icons.satellite_alt),
                title: Text(est.nombre),
                subtitle: Text(est.ubicacion),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
