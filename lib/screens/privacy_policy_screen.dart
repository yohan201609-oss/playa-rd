import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Política de Privacidad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientTop, AppColors.gradientTop.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: _loadPrivacyPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar la política de privacidad',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final content = snapshot.data ?? '';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildFormattedContent(content),
          );
        },
      ),
    );
  }

  Future<String> _loadPrivacyPolicy() async {
    try {
      final content = await rootBundle.loadString('docs/politica_privacidad.md');
      return content;
    } catch (e) {
      // Si no se puede cargar desde assets, usar contenido hardcodeado
      return _getDefaultPrivacyPolicy();
    }
  }

  String _getDefaultPrivacyPolicy() {
    return '''# Política de Privacidad – Playas RD

Fecha de entrada en vigor: 8 de noviembre de 2025  
Última actualización: 8 de noviembre de 2025

## 1. Introducción
Playas RD ("la Aplicación") es ofrecida por [Nombre de la Empresa o Responsable], con domicilio en [Dirección Legal], República Dominicana. Esta Política de Privacidad explica cómo recopilamos, usamos, compartimos y protegemos la información personal de los usuarios que utilizan la Aplicación.

Al usar Playas RD, aceptas las prácticas descritas en esta política. Si no estás de acuerdo, deberás dejar de utilizar la Aplicación.

## 2. Información que recopilamos
### 2.1 Información proporcionada por el usuario
- **Datos de registro**: nombre, correo electrónico y contraseña cuando creas una cuenta.
- **Perfil**: foto, preferencias, idioma y otra información que decidas almacenar en tu perfil.
- **Reportes**: contenidos, comentarios, calificaciones o alertas relacionadas con playas (incluyendo fotografías opcionales).

### 2.2 Información recopilada automáticamente
- **Datos de dispositivo**: modelo, sistema operativo, identificadores publicitarios y versión de la aplicación.
- **Datos de uso**: interacciones dentro de la aplicación, fecha y hora de acceso, funciones utilizadas.
- **Información de ubicación**: ubicación aproximada (país/ciudad) e información precisa (GPS) cuando otorgas permiso para mapas, clima o reportes asociados a tu posición.

### 2.3 Fuentes externas
- **Servicios en la nube**: Firebase para autenticación, almacenamiento y analítica.
- **APIs de terceros**: servicios meteorológicos, mapas y notificaciones.

## 3. Cómo usamos la información
- Proveer y mantener el funcionamiento de la aplicación.
- Personalizar la experiencia (idioma, favoritos, recomendaciones).
- Enviar notificaciones relevantes (clima, alertas, recordatorios).
- Analizar estadísticas de uso para mejorar Playas RD.
- Prevenir fraude, abuso o actividades ilícitas.
- Cumplir obligaciones legales y responder a requerimientos de autoridades.

## 4. Bases legales para el tratamiento
Tratamos datos personales conforme a:
- **Consentimiento** expreso del usuario.
- **Ejecución de un contrato** (provisión del servicio).
- **Intereses legítimos** (mejora de la app, seguridad).
- **Cumplimiento legal** (requerimientos normativos).

## 5. Compartir información
No vendemos datos personales. Compartimos información solo con:
- **Proveedores de servicios** (Firebase, almacenamiento, analítica) que actúan en nuestro nombre bajo acuerdos de confidencialidad.
- **Autoridades** cuando la ley lo exige o para proteger derechos propios o de terceros.
- **Otros usuarios** cuando compartes contenido público (ej. reportes o comentarios visibles en la app).

## 6. Transferencias internacionales
Podemos transferir datos a servidores ubicados fuera de tu país, incluyendo Estados Unidos. Tomamos medidas para asegurar que los datos estén protegidos (cláusulas contractuales estándar u otros mecanismos equivalentes).

## 7. Retención de datos
Conservamos tu información mientras mantengas una cuenta activa o según sea necesario para prestarte el servicio. Tras la desactivación o solicitud de supresión, eliminaremos o anonimizaremos los datos, salvo obligación legal de conservarlos.

## 8. Derechos del usuario
Dependiendo de la legislación aplicable, puedes ejercer los siguientes derechos:
- Acceder a tus datos personales.
- Rectificar información incorrecta o incompleta.
- Solicitar la eliminación o restricción del tratamiento.
- Oponerte a ciertos usos o solicitar portabilidad.

Para ejercer estos derechos, contáctanos en **soporteplayasrd@outlook.com**. Responderemos en un plazo razonable y conforme a la normativa vigente.

## 9. Seguridad
Implementamos medidas técnicas y organizativas para proteger los datos (encriptación, control de accesos, prácticas de seguridad). No obstante, ningún sistema es completamente seguro; mantén contraseñas fuertes y notifica sospechas de acceso no autorizado.

## 10. Privacidad de menores
La aplicación no está dirigida a menores de 13 años. Si descubrimos que hemos recopilado datos de un menor sin consentimiento verificable de sus padres o tutores, eliminaremos esa información.

## 11. Cambios a esta política
Podemos actualizar esta Política de Privacidad. Notificaremos cambios significativos vía la aplicación o correo electrónico. La fecha de "Última actualización" indicará la versión vigente.

## 12. Contacto
Si tienes preguntas sobre esta política o el manejo de tus datos, contáctanos en:
- Correo electrónico: **soporteplayasrd@outlook.com**
- Dirección postal: **[Dirección Legal]**''';
  }

  Widget _buildFormattedContent(String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      if (line.startsWith('# ')) {
        // Título principal
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        // Subtítulo
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 20),
            child: Text(
              line.substring(3),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        // Sub-subtítulo
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 16),
            child: Text(
              line.substring(4),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        // Lista
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Texto en negrita
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
                height: 1.6,
              ),
            ),
          ),
        );
      } else {
        // Texto normal
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.6,
              ),
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}

