import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Términos y Condiciones',
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
        future: _loadTermsOfService(),
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
                    'Error al cargar los términos de servicio',
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

  Future<String> _loadTermsOfService() async {
    try {
      final content = await rootBundle.loadString('docs/terminos_servicio.md');
      return content;
    } catch (e) {
      // Si no se puede cargar desde assets, usar contenido hardcodeado
      return _getDefaultTermsOfService();
    }
  }

  String _getDefaultTermsOfService() {
    return '''# Términos y Condiciones de Uso – Playas RD

Fecha de entrada en vigor: 8 de noviembre de 2025  
Última actualización: 8 de noviembre de 2025

## 1. Aceptación de los términos
Al descargar o utilizar la aplicación Playas RD ("la Aplicación"), aceptas estos Términos y Condiciones. Si no estás de acuerdo, no podrás usar la Aplicación. Playas RD es operada por [Nombre de la Empresa o Responsable], con domicilio en [Dirección Legal], República Dominicana.

## 2. Descripción del servicio
Playas RD ofrece información sobre playas, reportes de usuarios, mapas, clima y otros servicios relacionados. Nos reservamos el derecho de modificar o interrumpir funciones en cualquier momento, con o sin aviso.

## 3. Elegibilidad
Debes tener al menos 13 años para usar la Aplicación. Si es la ley de tu país requiere una edad mayor, deberás cumplirla. Los usuarios menores de edad requieren autorización de sus padres o tutores.

## 4. Cuenta del usuario
- Debes proporcionar información verídica al registrarte.
- Eres responsable de mantener la confidencialidad de tus credenciales.
- Notifica inmediatamente sobre uso no autorizado a **soporteplayasrd@outlook.com**.
- Podemos suspender o cancelar tu cuenta si incumples estos términos.

## 5. Uso permitido
Te comprometes a:
- Utilizar la aplicación conforme a la ley y a estos términos.
- No realizar ingeniería inversa, duplicar o distribuir el código.
- No subir contenido malicioso, ofensivo, difamatorio o que infrinja derechos de terceros.
- No interferir con el funcionamiento de la aplicación ni con la experiencia de otros usuarios.

## 6. Contenido del usuario
- Conservas los derechos sobre el contenido que subes (reportes, fotos, comentarios).
- Al subir contenido, nos otorgas una licencia mundial, no exclusiva y gratuita para usarlo, reproducirlo y mostrarlo dentro de Playas RD con fines de operación y promoción.
- Debes garantizar que tienes derechos sobre el contenido que compartes y que no viola la ley ni derechos de terceros.
- Podemos eliminar contenido que consideremos inapropiado o que infrinja estos términos.

## 7. Propiedad intelectual
Todo el contenido de la Aplicación (marcas, logos, diseños, código, textos) pertenece a [Nombre de la Empresa] o a sus licenciantes. No se autoriza su uso sin permiso expreso, salvo lo previsto en estos términos.

## 8. Servicios de terceros
La Aplicación puede incluir enlaces o integraciones con servicios de terceros (mapas, clima, autenticación). No somos responsables de sus contenidos, políticas o prácticas. Al usarlos, aceptas sus términos y condiciones respectivos.

## 9. Tarifas
Playas RD es gratuita. Si en el futuro se ofrecen funciones de pago, se notificará claramente el costo y las condiciones antes de cualquier cargo.

## 10. Limitación de responsabilidad
- La Aplicación se ofrece "tal cual" y "según disponibilidad".
- No garantizamos precisión absoluta en información de playas, clima o reportes.
- No somos responsables por daños indirectos, incidentales o consecuentes derivados del uso o imposibilidad de uso de la Aplicación.
- Tu uso de la Aplicación es bajo tu propio riesgo. Verifica información crítica con autoridades locales cuando corresponda.

## 11. Indemnización
Aceptas indemnizar y mantener indemne a [Nombre de la Empresa] y sus afiliados frente a reclamaciones o gastos (incluidos honorarios legales) derivados de tu uso indebido de la Aplicación, violación de estos términos o infracción de derechos de terceros.

## 12. Terminación
Podemos suspender o terminar tu acceso a la Aplicación en cualquier momento si incumples estos términos o si la operación de la Aplicación cesa. Puedes dejar de usar la Aplicación en cualquier momento y solicitar la eliminación de tu cuenta y datos asociados.

## 13. Modificaciones
Podemos actualizar estos términos. Notificaremos cambios importantes mediante la Aplicación, correo electrónico o el sitio web. El uso continuo después de la actualización implica aceptación.

## 14. Legislación aplicable
Estos términos se rigen por las leyes de la República Dominicana. Cualquier disputa se resolverá en los tribunales competentes de Santo Domingo, salvo que la ley exija otra jurisdicción.

## 15. Contacto
Para consultas sobre estos términos:
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

