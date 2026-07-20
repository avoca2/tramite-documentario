import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/role_provider.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/secretaria/secretaria_dashboard_screen.dart';
import 'screens/estudiante/estudiante_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => RoleProvider(ApiService()),
        ),
      ],
      child: MaterialApp(
        title: 'Sistema de Trámite Documentario',
        theme: ThemeData(
          primaryColor: const Color(0xFFFF0000),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF0000),
            secondary: Color(0xFFFF0000),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFF0000),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF0000),
              foregroundColor: Colors.white,
            ),
          ),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/admin-dashboard': (context) => AdminDashboardScreen(),
          '/secretaria-dashboard': (context) => SecretariaDashboardScreen(),
          '/estudiante-dashboard': (context) => EstudianteDashboardScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}