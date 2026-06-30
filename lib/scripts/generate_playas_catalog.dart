import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const _apiKey = 'AIzaSyDM9AnOHCBlyKJ98jNI_5r1y-xfAcJYLgI';
const _projectId = 'playas-rd-2b475';

Future<void> main() async {
  final beaches = await _fetchAllBeachesFromFirestore();
  beaches.sort(_compareBeachIds);

  const amenLabels = {
    'baños': 'Baños',
    'duchas': 'Duchas',
    'parking': 'Estacionamiento',
    'restaurantes': 'Restaurantes',
    'sombrillas': 'Sombrillas',
    'salvavidas': 'Salvavidas',
  };

  final buffer = StringBuffer();
  buffer.writeln('# Catálogo de Playas — Playas RD');
  buffer.writeln();
  buffer.writeln(
    '> Fuente: colección `beaches` en Firestore (`playas-rd-2b475`).',
  );
  buffer.writeln(
    '> Es la misma base que carga la app al iniciar (`BeachProvider` → Firestore).',
  );
  buffer.writeln('> Total de playas registradas: **${beaches.length}**');
  final needsReviewCount =
      beaches.where((b) => b['needsReview'] == true).length;
  if (needsReviewCount > 0) {
    buffer.writeln(
      '> Playas pendientes de revisión de descripción: **$needsReviewCount**',
    );
  }
  buffer.writeln();

  final byProvince = <String, List<Map<String, dynamic>>>{};
  for (final b in beaches) {
    byProvince.putIfAbsent(b['province'] as String, () => []).add(b);
  }
  final provinces = byProvince.keys.toList()..sort();

  buffer.writeln('## Resumen');
  buffer.writeln();
  buffer.writeln('| Provincia | Cantidad |');
  buffer.writeln('|-----------|----------|');
  for (final prov in provinces) {
    buffer.writeln('| $prov | ${byProvince[prov]!.length} |');
  }
  buffer.writeln('| **Total** | **${beaches.length}** |');
  buffer.writeln();

  buffer.writeln('## Índice por provincia');
  buffer.writeln();
  for (final prov in provinces) {
    buffer.writeln('- [$prov](#${_slug(prov)}) (${byProvince[prov]!.length} playas)');
  }
  buffer.writeln();

  buffer.writeln('## Índice alfabético');
  buffer.writeln();
  final sortedByName = List<Map<String, dynamic>>.from(beaches)
    ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  for (final b in sortedByName) {
    buffer.writeln('- [${b['name']}](#${_slug(b['name'] as String)}) — ${b['province']}');
  }
  buffer.writeln();
  buffer.writeln('---');
  buffer.writeln();

  for (final prov in provinces) {
    final list = byProvince[prov]!;
    list.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    buffer.writeln('## $prov');
    buffer.writeln();

    for (final b in list) {
      buffer.writeln('### ${b['name']}');
      buffer.writeln();
      buffer.writeln('| Campo | Valor |');
      buffer.writeln('|-------|-------|');
      buffer.writeln('| **ID** | ${b['id']} |');
      buffer.writeln('| **Municipio** | ${b['municipality']} |');
      if ((b['postalCode'] as String).isNotEmpty) {
        buffer.writeln('| **Código postal** | ${b['postalCode']} |');
      }
      if ((b['address'] as String).isNotEmpty) {
        buffer.writeln('| **Dirección** | ${b['address']} |');
      }
      buffer.writeln('| **Coordenadas (lat, lng)** | ${b['latitude']}, ${b['longitude']} |');
      buffer.writeln(
        '| **Google Maps** | [Ver en mapa](https://www.google.com/maps?q=${b['latitude']},${b['longitude']}) |',
      );
      buffer.writeln('| **Calificación** | ${b['rating']} / 5.0 |');
      buffer.writeln('| **Reseñas** | ${b['reviewCount']} |');
      buffer.writeln('| **Condición actual** | ${b['currentCondition']} |');
      if (b['needsReview'] == true) {
        buffer.writeln('| **Revisión pendiente** | Sí (`needsReview`) |');
      }
      if ((b['imageCount'] as int) > 0) {
        buffer.writeln('| **Fotos** | ${b['imageCount']} |');
      }
      buffer.writeln();

      final desc = b['description'] as String;
      if (desc.isNotEmpty) {
        buffer.writeln('#### Descripción (Español)');
        buffer.writeln();
        buffer.writeln(desc);
        buffer.writeln();
      }

      final descEn = b['descriptionEn'] as String;
      if (descEn.isNotEmpty) {
        buffer.writeln('#### Description (English)');
        buffer.writeln();
        buffer.writeln(descEn);
        buffer.writeln();
      }

      final am = b['amenities'] as Map<String, bool>;
      if (am.isNotEmpty) {
        final avail = amenLabels.entries
            .where((e) => am[e.key] == true)
            .map((e) => e.value)
            .toList();
        final unavail = amenLabels.entries
            .where((e) => am[e.key] == false)
            .map((e) => e.value)
            .toList();
        buffer.writeln('#### Servicios y comodidades');
        buffer.writeln();
        buffer.writeln(
          '- **Disponibles:** ${avail.isEmpty ? 'Ninguno registrado' : avail.join(', ')}',
        );
        if (unavail.isNotEmpty) {
          buffer.writeln('- **No disponibles:** ${unavail.join(', ')}');
        }
        buffer.writeln();
      }

      final activities = b['activities'] as List<String>;
      if (activities.isNotEmpty) {
        buffer.writeln('#### Actividades');
        buffer.writeln();
        buffer.writeln(activities.join(', '));
        buffer.writeln();
      }

      buffer.writeln('---');
      buffer.writeln();
    }
  }

  File('PLAYAS_CATALOGO.md').writeAsStringSync(buffer.toString());
  stdout.writeln('Generado PLAYAS_CATALOGO.md con ${beaches.length} playas');
}

Future<List<Map<String, dynamic>>> _fetchAllBeachesFromFirestore() async {
  final beaches = <Map<String, dynamic>>[];
  String? pageToken;

  do {
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/beaches'
      '?pageSize=300&key=$_apiKey${pageToken != null ? '&pageToken=$pageToken' : ''}',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Firestore HTTP ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['documents'] as List<dynamic>? ?? [];
    for (final doc in docs) {
      beaches.add(_parseFirestoreDocument(doc as Map<String, dynamic>));
    }
    pageToken = data['nextPageToken'] as String?;
  } while (pageToken != null);

  return beaches;
}

Map<String, dynamic> _parseFirestoreDocument(Map<String, dynamic> doc) {
  final namePath = doc['name'] as String;
  final id = namePath.split('/').last;
  final fields = doc['fields'] as Map<String, dynamic>? ?? {};

  String str(String key) => _fieldString(fields[key]) ?? '';
  double num(String key) => _fieldDouble(fields[key]) ?? 0.0;
  int integer(String key) => _fieldInt(fields[key]) ?? 0;

  final amenities = <String, bool>{};
  final amenField = fields['amenities'];
  if (amenField is Map && amenField['mapValue'] != null) {
    final mapFields =
        (amenField['mapValue'] as Map<String, dynamic>)['fields']
            as Map<String, dynamic>? ??
        {};
    for (final entry in mapFields.entries) {
      amenities[entry.key] = _fieldBool(entry.value) ?? false;
    }
  }

  final activities = <String>[];
  final actField = fields['activities'];
  if (actField is Map && actField['arrayValue'] != null) {
    final values =
        (actField['arrayValue'] as Map<String, dynamic>)['values']
            as List<dynamic>? ??
        [];
    for (final v in values) {
      final s = _fieldString(v);
      if (s != null && s.isNotEmpty) activities.add(s);
    }
  }

  final imageUrls = <String>[];
  final imgField = fields['imageUrls'];
  if (imgField is Map && imgField['arrayValue'] != null) {
    final values =
        (imgField['arrayValue'] as Map<String, dynamic>)['values']
            as List<dynamic>? ??
        [];
    for (final v in values) {
      final s = _fieldString(v);
      if (s != null && s.isNotEmpty) imageUrls.add(s);
    }
  }

  return {
    'id': id,
    'name': str('name'),
    'province': str('province'),
    'municipality': str('municipality'),
    'postalCode': str('postalCode'),
    'address': str('address'),
    'description': str('description'),
    'descriptionEn': str('descriptionEn'),
    'latitude': num('latitude'),
    'longitude': num('longitude'),
    'rating': num('rating'),
    'reviewCount': integer('reviewCount'),
    'currentCondition': str('currentCondition').isEmpty ? 'Desconocido' : str('currentCondition'),
    'amenities': amenities,
    'activities': activities,
    'imageCount': imageUrls.length,
    'needsReview': _fieldBool(fields['needsReview']) ?? false,
  };
}

String? _fieldString(dynamic field) {
  if (field is! Map) return null;
  return field['stringValue'] as String?;
}

double? _fieldDouble(dynamic field) {
  if (field is! Map) return null;
  if (field.containsKey('doubleValue')) {
    return (field['doubleValue'] as num).toDouble();
  }
  if (field.containsKey('integerValue')) {
    return double.tryParse(field['integerValue'].toString());
  }
  return null;
}

int? _fieldInt(dynamic field) {
  if (field is! Map) return null;
  if (field.containsKey('integerValue')) {
    return int.tryParse(field['integerValue'].toString());
  }
  if (field.containsKey('doubleValue')) {
    return (field['doubleValue'] as num).round();
  }
  return null;
}

bool? _fieldBool(dynamic field) {
  if (field is! Map) return null;
  return field['booleanValue'] as bool?;
}

int _compareBeachIds(Map<String, dynamic> a, Map<String, dynamic> b) {
  final idA = a['id'] as String;
  final idB = b['id'] as String;
  final numA = int.tryParse(idA);
  final numB = int.tryParse(idB);
  if (numA != null && numB != null) return numA.compareTo(numB);
  if (numA != null) return -1;
  if (numB != null) return 1;
  return idA.compareTo(idB);
}

String _slug(String text) {
  return text
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
