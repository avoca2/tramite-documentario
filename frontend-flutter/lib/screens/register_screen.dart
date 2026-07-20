import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _codigoEnviado = false;
  bool _codigoVerificado = false;
  String? _errorMessage;
  String? _successMessage;
  bool _dniValidado = false;
  Map<String, dynamic>? _dniData;

  final ApiService _apiService = ApiService();

  // Validación local del DNI (permite 7 u 8 dígitos)
  bool _validarDniLocal(String dni) {
    final trimmedDni = dni.trim();
    // Permitir 7 u 8 dígitos
    if (trimmedDni.length < 7 || trimmedDni.length > 8) return false;
    if (!RegExp(r'^[0-9]{7,8}$').hasMatch(trimmedDni)) return false;
    return true;
  }

  Future<void> _validarDni() async {
    final dni = dniController.text.trim();
    
    // Validación local primero
    if (!_validarDniLocal(dni)) {
      setState(() {
        _errorMessage = 'DNI inválido. Debe tener 7 u 8 dígitos.';
        _dniValidado = false;
        _dniData = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Usando el método consultarDni del ApiService
      final data = await _apiService.consultarDni(dni);
      
      // Verificar si la respuesta es válida
      if (data != null && data.isNotEmpty && data['nombres'] != null) {
        setState(() {
          _dniData = data;
          _dniValidado = true;
          _isLoading = false;
          _successMessage = 'DNI validado correctamente: ${data['nombres'] ?? ''} ${data['apellidoPaterno'] ?? ''}';
          
          // Auto-llenar nombre con los datos del DNI
          final nombres = data['nombres'] ?? '';
          final apellidoPaterno = data['apellidoPaterno'] ?? '';
          final apellidoMaterno = data['apellidoMaterno'] ?? '';
          final nombreCompleto = '$nombres $apellidoPaterno $apellidoMaterno'.trim();
          
          if (nombreCompleto.isNotEmpty && nombreCompleto != ' ') {
            nameController.text = nombreCompleto;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DNI validado: ${data['nombres']} ${data['apellidoPaterno']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Si no hay datos, validar solo el formato
        setState(() {
          _dniValidado = true;
          _isLoading = false;
          _successMessage = 'DNI válido (formato correcto)';
          _dniData = {
            'dni': dni,
            'nombres': '',
            'apellidoPaterno': '',
            'apellidoMaterno': '',
          };
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('DNI válido (formato correcto)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Si hay error, validar solo el formato
      if (_validarDniLocal(dni)) {
        setState(() {
          _dniValidado = true;
          _isLoading = false;
          _successMessage = 'DNI válido (formato correcto)';
          _dniData = {
            'dni': dni,
            'nombres': '',
            'apellidoPaterno': '',
            'apellidoMaterno': '',
          };
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('DNI válido (formato correcto)'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'DNI inválido. Verifica el formato.';
          _isLoading = false;
          _dniValidado = false;
        });
      }
    }
  }

  Future<void> _enviarCodigo() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese un email';
      });
      return;
    }

    if (!_dniValidado) {
      setState(() {
        _errorMessage = 'Primero valide su DNI';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _apiService.dio.post(
        '/enviar-codigo',
        data: {
          'email': email,
          'dni': dniController.text.trim(),
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _codigoEnviado = true;
          _isLoading = false;
          final message = response.data['message'] ?? 'Código enviado';
          final codigo = response.data['codigo'];
          if (codigo != null) {
            _successMessage = 'Código: $codigo - $message';
          } else {
            _successMessage = message;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_successMessage ?? 'Código enviado'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Error al enviar código. Intente nuevamente.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al enviar código. Verifica tu conexión.';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar código. Verifica tu conexión.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verificarCodigo() async {
    final codigo = codigoController.text.trim();
    if (codigo.length < 6) {
      setState(() {
        _errorMessage = 'Ingrese el código de 6 dígitos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = emailController.text.trim();
      
      final response = await _apiService.dio.post(
        '/verificar-codigo',
        data: {
          'email': email,
          'codigo': codigo,
        },
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _codigoVerificado = true;
          _isLoading = false;
          _successMessage = 'Código verificado exitosamente';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código verificado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Código inválido o expirado';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Código inválido o expirado';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código inválido o expirado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registrar() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final dni = dniController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final codigo = codigoController.text.trim();

    // Validaciones
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese su nombre completo';
      });
      return;
    }

    if (dni.length < 7 || dni.length > 8) {
      setState(() {
        _errorMessage = 'Ingrese un DNI válido de 7 u 8 dígitos';
      });
      return;
    }

    if (!_dniValidado) {
      setState(() {
        _errorMessage = 'Primero valide su DNI';
      });
      return;
    }

    if (!_codigoVerificado) {
      setState(() {
        _errorMessage = 'Primero verifique su código';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _errorMessage = 'La contraseña debe tener al menos 8 caracteres';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _apiService.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'dni': dni,
          'password': password,
          'codigo': codigo,
          'dni_data': _dniData,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setUserAndToken(response.data['user'], response.data['token']);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Usuario registrado exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Error al registrar usuario';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar: ${e.toString()}';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Panel Izquierdo - Imagen institucional
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
                                'Regístrate y forma parte de nuestra comunidad educativa.',
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
                  // Panel Derecho - Formulario
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
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2430),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Regístrate para acceder al Sistema de Trámites',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 35),

                            // Campo DNI
                            const Text(
                              'DNI *',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2430),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _dniValidado ? Colors.green : const Color(0xFFE0E0E0),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 16),
                                        const Icon(
                                          Icons.badge,
                                          color: Color(0xFF666666),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: TextField(
                                            controller: dniController,
                                            keyboardType: TextInputType.number,
                                            maxLength: 8,
                                            textInputAction: TextInputAction.next,
                                            style: const TextStyle(fontSize: 16),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'DNI (7 u 8 dígitos)',
                                              hintStyle: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF999999),
                                              ),
                                              counterText: '',
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _dniValidado = false;
                                                _dniData = null;
                                                _errorMessage = null;
                                                _successMessage = null;
                                              });
                                            },
                                          ),
                                        ),
                                        if (_dniValidado)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 12),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 22,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _validarDni,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB51414),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      minimumSize: const Size(0, 56),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Validar',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            if (_dniValidado && _dniData != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade700,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _dniData?['nombres'] != null && _dniData?['nombres'] != ''
                                            ? 'DNI: ${_dniData?['nombres']} ${_dniData?['apellidoPaterno'] ?? ''}'
                                            : 'DNI válido (formato correcto)',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),

                            // Campo Nombre Completo
                            const Text(
                              'Nombre Completo *',
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
                                    Icons.person_outline,
                                    color: Color(0xFF666666),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextField(
                                      controller: nameController,
                                      textInputAction: TextInputAction.next,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Nombres y Apellidos',
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

                            // Campo Email
                            const Text(
                              'Correo institucional *',
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
                                  color: _codigoVerificado ? Colors.green : const Color(0xFFE0E0E0),
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
                                      onChanged: (value) {
                                        setState(() {
                                          _codigoEnviado = false;
                                          _codigoVerificado = false;
                                        });
                                      },
                                    ),
                                  ),
                                  if (_codigoVerificado)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 22,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Código de verificación
                            const Text(
                              'Verificación',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2430),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _codigoVerificado ? Colors.green : const Color(0xFFE0E0E0),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 16),
                                        const Icon(
                                          Icons.pin,
                                          color: Color(0xFF666666),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: TextField(
                                            controller: codigoController,
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            textInputAction: TextInputAction.done,
                                            style: const TextStyle(fontSize: 16),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Código de 6 dígitos',
                                              hintStyle: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF999999),
                                              ),
                                              counterText: '',
                                            ),
                                          ),
                                        ),
                                        if (_codigoVerificado)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 12),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 22,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _isLoading || _codigoVerificado
                                      ? null
                                      : (_codigoEnviado ? _verificarCodigo : _enviarCodigo),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _codigoVerificado
                                        ? Colors.green
                                        : const Color(0xFFB51414),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    minimumSize: const Size(0, 56),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _codigoVerificado
                                              ? '✓ Verificado'
                                              : (_codigoEnviado ? 'Verificar' : 'Enviar'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            if (_codigoEnviado && !_codigoVerificado)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Revisa tu correo para obtener el código',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Campo Contraseña
                            const Text(
                              'Contraseña *',
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
                                      textInputAction: TextInputAction.next,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Mínimo 8 caracteres',
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
                            const SizedBox(height: 20),

                            // Campo Confirmar Contraseña
                            const Text(
                              'Confirmar Contraseña *',
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
                                      controller: confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _registrar(),
                                      style: const TextStyle(fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Repite la contraseña',
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF666666),
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Mensajes de error/success
                            if (_errorMessage != null) ...[
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
                                        _errorMessage!,
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
                            if (_successMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _successMessage!,
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Botón Registrarse
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _registrar,
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
                                            'Registrando...',
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
                                            Icons.person_add,
                                            size: 22,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Registrarse',
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

                            // Botón Iniciar Sesión
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/login');
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
                                      Icons.login,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
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
    nameController.dispose();
    emailController.dispose();
    dniController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    codigoController.dispose();
    super.dispose();
  }
}