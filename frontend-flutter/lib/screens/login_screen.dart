import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await authProvider.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success && context.mounted) {
      try {
        await roleProvider.loadUserRole(authProvider.token!);
        
        print('ROL CARGADO: ${roleProvider.rol}');
        
        // Redirigir según el rol
        if (roleProvider.isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else if (roleProvider.rol == 'secretaria') {
          Navigator.pushReplacementNamed(context, '/secretaria-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/estudiante-dashboard');
        }
      } catch (e) {
        print('Error cargando rol: $e');
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Credenciales inválidas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 900;

          return SingleChildScrollView(
            child: Container(
              height: constraints.maxHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Panel Izquierdo
                  if (!isSmallScreen)
                    Expanded(
                      flex: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: const AssetImage('assets/images/campus.jpg'),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Si no hay imagen, usar color
                            },
                          ),
                          color: Colors.grey.shade300,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xCC750505),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 30,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo_iestp.png',
                                height: 140,
                                width: 200,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.school,
                                    size: 140,
                                    color: Colors.white,
                                  );
                                },
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Sistema de Trámites de Gestión Académica',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: 80,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3F3F),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Plataforma institucional para la gestión de trámites académicos.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Panel Derecho
                  Expanded(
                    flex: 48,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.school,
                              size: 40,
                              color: const Color(0xFFB81616),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2430),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Bienvenido al Sistema de Trámites',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 35),

                            // Campo Email
                            const Text(
                              'Correo institucional',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2430),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF666666),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextField(
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'usuario@iestpjdsp.edu.pe',
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo Contraseña
                            const Text(
                              'Contraseña',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2430),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF666666),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _login(context),
                                      style: const TextStyle(fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Ingrese su contraseña',
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF666666),
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Mensaje de error
                            if (authProvider.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Botón Login
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () => _login(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB51414),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Iniciando sesión...',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.login,
                                            size: 22,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Iniciar sesión',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Separador
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFD8D8D8),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'o',
                                    style: TextStyle(
                                      color: const Color(0xFF666666),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFD8D8D8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),

                            // Botón Registrarse
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFDDDDDD),
                                    width: 2,
                                  ),
                                  foregroundColor: const Color(0xFF1B2430),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Credenciales de prueba
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Credenciales de prueba',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Admin: admin@iestp.edu.pe / admin123',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Secretaria: secretaria@iestp.edu.pe / admin123',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Estudiante: joseavocado2@gmail.com / Papaamor8154@',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Seguro
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 16,
                                  color: const Color(0xFF666666),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Sistema seguro - IESTP Jorge Desmaison Seminario',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}