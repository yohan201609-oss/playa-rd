import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const _projectId = 'playas-rd-2b475';

String get _apiKey {
  final options = File('lib/firebase_options.dart').readAsStringSync();
  final match = RegExp(r"apiKey:\s*'([^']+)'").firstMatch(options);
  if (match == null) {
    throw StateError('No se encontró apiKey en lib/firebase_options.dart');
  }
  return match.group(1)!;
}
const _outputPath = 'lib/services/beach_service.dart';

const _amenityKeys = [
  'baños',
  'duchas',
  'parking',
  'restaurantes',
  'sombrillas',
  'salvavidas',
];

Future<void> main() async {
  stdout.writeln('Descargando playas desde Firestore...');
  final beaches = await _fetchAllBeachesFromFirestore();
  stdout.writeln('${beaches.length} playas encontradas. Generando $_outputPath...');

  final content = _generateBeachServiceFile(beaches);
  File(_outputPath).writeAsStringSync(content);

  stdout.writeln('Listo: $_outputPath actualizado con ${beaches.length} playas.');
}

String _generateBeachServiceFile(List<Map<String, dynamic>> beaches) {
  final byProvince = <String, List<Map<String, dynamic>>>{};
  for (final b in beaches) {
    byProvince.putIfAbsent(b['province'] as String, () => []).add(b);
  }
  final provinces = byProvince.keys.toList()..sort();

  final buffer = StringBuffer();
  buffer.writeln("import '../models/beach.dart';");
  buffer.writeln();
  buffer.writeln('class BeachService {');
  buffer.writeln('  // Base de datos completa de playas de República Dominicana');
  buffer.writeln(
    '  // Sincronizado desde Firestore ($_projectId) — ${beaches.length} playas',
  );
  buffer.writeln(
    '  // Regenerar: dart run lib/scripts/sync_firestore_to_beach_service.dart',
  );
  buffer.writeln('  static List<Beach> getDominicanBeaches() {');
  buffer.writeln('    return [');

  for (final province in provinces) {
    final list = byProvince[province]!;
    list.sort(
      (a, b) => (a['name'] as String).compareTo(b['name'] as String),
    );
    buffer.writeln('      // $province (${list.length})');
    for (var i = 0; i < list.length; i++) {
      buffer.write(_formatBeach(list[i]));
      buffer.writeln(i < list.length - 1 ? ',' : ',');
    }
  }

  buffer.writeln('    ];');
  buffer.writeln('  }');
  buffer.write(_helperMethods);
  return buffer.toString();
}

String _formatBeach(Map<String, dynamic> b) {
  final buffer = StringBuffer();
  buffer.writeln('      Beach(');
  buffer.writeln("        id: '${_escapeDart(b['id'] as String)}',");
  buffer.writeln("        name: '${_escapeDart(b['name'] as String)}',");
  buffer.writeln("        province: '${_escapeDart(b['province'] as String)}',");
  buffer.writeln(
    "        municipality: '${_escapeDart(b['municipality'] as String)}',",
  );

  final postalCode = b['postalCode'] as String;
  if (postalCode.isNotEmpty) {
    buffer.writeln("        postalCode: '${_escapeDart(postalCode)}',");
  }

  final address = b['address'] as String;
  if (address.isNotEmpty) {
    buffer.writeln("        address: '${_escapeDart(address)}',");
  }

  buffer.writeln('        description:');
  buffer.writeln("            '${_escapeDart(b['description'] as String)}',");

  final descriptionEn = b['descriptionEn'] as String;
  if (descriptionEn.isNotEmpty) {
    buffer.writeln('        descriptionEn:');
    buffer.writeln("            '${_escapeDart(descriptionEn)}',");
  }

  buffer.writeln('        latitude: ${_formatNum(b['latitude'] as double)},');
  buffer.writeln('        longitude: ${_formatNum(b['longitude'] as double)},');

  final imageUrls = b['imageUrls'] as List<String>;
  if (imageUrls.isEmpty) {
    buffer.writeln('        imageUrls: [],');
  } else {
    buffer.writeln('        imageUrls: [');
    for (final url in imageUrls) {
      buffer.writeln("          '${_escapeDart(url)}',");
    }
    buffer.writeln('        ],');
  }

  buffer.writeln('        rating: ${_formatNum(b['rating'] as double)},');
  buffer.writeln('        reviewCount: ${b['reviewCount']},');
  buffer.writeln(
    "        currentCondition: '${_escapeDart(b['currentCondition'] as String)}',",
  );

  final amenities = b['amenities'] as Map<String, bool>;
  buffer.writeln('        amenities: {');
  for (final key in _amenityKeys) {
    final value = amenities[key] ?? false;
    buffer.writeln("          '$key': $value,");
  }
  buffer.writeln('        },');

  final activities = b['activities'] as List<String>;
  buffer.writeln('        activities: [${activities.map((a) => "'${_escapeDart(a)}'").join(', ')}],');

  if (b['needsReview'] == true) {
    buffer.writeln('        needsReview: true,');
  }

  buffer.write('      )');
  return buffer.toString();
}

String _escapeDart(String value) {
  final normalized = value
      .replaceAll('\r\n', ' ')
      .replaceAll('\n', ' ')
      .replaceAll('\r', ' ')
      .replaceAll('\u2019', "'")
      .replaceAll('\u2018', "'")
      .replaceAll('\u201c', '"')
      .replaceAll('\u201d', '"')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return normalized.replaceAll('\\', r'\\').replaceAll("'", r"\'");
}

String _formatNum(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value
      .toString()
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}

const _helperMethods = '''
  // Filtrar playas por provincia
  static List<Beach> filterByProvince(List<Beach> beaches, String province) {
    if (province.isEmpty || province == 'Todas') {
      return beaches;
    }
    return beaches.where((beach) => beach.province == province).toList();
  }

  // Filtrar playas por condición
  static List<Beach> filterByCondition(List<Beach> beaches, String condition) {
    if (condition.isEmpty || condition == 'Todas') {
      return beaches;
    }
    return beaches
        .where((beach) => beach.currentCondition == condition)
        .toList();
  }

  // Buscar playas por nombre
  static List<Beach> searchBeaches(List<Beach> beaches, String query) {
    if (query.isEmpty) {
      return beaches;
    }
    return beaches
        .where(
          (beach) =>
              beach.name.toLowerCase().contains(query.toLowerCase()) ||
              beach.province.toLowerCase().contains(query.toLowerCase()) ||
              beach.municipality.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Playas con descripciones pendientes de revisión manual
  static List<Beach> filterNeedsReview(List<Beach> beaches) {
    return beaches.where((beach) => beach.needsReview).toList();
  }

  // Ordenar playas
  static List<Beach> sortBeaches(List<Beach> beaches, String sortBy) {
    List<Beach> sorted = List.from(beaches);
    switch (sortBy) {
      case 'rating':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'condition':
        // Ordenar por severidad: Excelente > Bueno > Moderado > Peligroso > Desconocido
        sorted.sort((a, b) {
          int priorityA = _getConditionPriority(a.currentCondition);
          int priorityB = _getConditionPriority(b.currentCondition);
          return priorityA.compareTo(priorityB);
        });
        break;
      default:
        break;
    }
    return sorted;
  }

  // Obtener prioridad de condición (menor número = mejor condición)
  static int _getConditionPriority(String condition) {
    switch (condition) {
      case 'Excelente':
        return 1;
      case 'Bueno':
        return 2;
      case 'Moderado':
        return 3;
      case 'Peligroso':
        return 4;
      default:
        return 5; // Desconocido
    }
  }
}
''';

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

  final condition = str('currentCondition');
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
    'currentCondition': condition.isEmpty ? 'Desconocido' : condition,
    'amenities': amenities,
    'activities': activities,
    'imageUrls': imageUrls,
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
