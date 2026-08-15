import 'package:cloud_firestore/cloud_firestore.dart';

class Beach {
  final String id;
  final String name;
  final String province;
  final String municipality;
  final String? postalCode;
  final String? address;
  final String description;
  final String? descriptionEn; // Descripción en inglés
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final String currentCondition; // Excelente, Bueno, Moderado, Peligroso
  final Map<String, dynamic>
  amenities; // baños, duchas, parking, restaurantes, etc
  final List<String> activities; // natación, surf, snorkel, etc
  final bool isFavorite;
  final bool needsReview;
  final DateTime? lastUpdated;

  Beach({
    required this.id,
    required this.name,
    required this.province,
    required this.municipality,
    this.postalCode,
    this.address,
    required this.description,
    this.descriptionEn,
    required this.latitude,
    required this.longitude,
    this.imageUrls = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.currentCondition = 'Desconocido',
    this.amenities = const {},
    this.activities = const [],
    this.isFavorite = false,
    this.needsReview = false,
    this.lastUpdated,
  });

  /// Acepta Timestamp, DateTime o ISO string (scripts REST a veces escriben string).
  static DateTime? parseFirestoreDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // Crear Beach desde Firestore
  factory Beach.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Beach(
      id: doc.id,
      name: data['name'] ?? '',
      province: data['province'] ?? '',
      municipality: data['municipality'] ?? '',
      postalCode: data['postalCode'],
      address: data['address'],
      description: data['description'] ?? '',
      descriptionEn: data['descriptionEn'],
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      currentCondition: data['currentCondition'] ?? 'Desconocido',
      amenities: Map<String, dynamic>.from(data['amenities'] ?? {}),
      activities: List<String>.from(data['activities'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
      needsReview: data['needsReview'] ?? false,
      lastUpdated: parseFirestoreDate(data['lastUpdated']),
    );
  }

  // Convertir Beach a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'province': province,
      'municipality': municipality,
      'postalCode': postalCode,
      'address': address,
      'description': description,
      'descriptionEn': descriptionEn,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'rating': rating,
      'reviewCount': reviewCount,
      'currentCondition': currentCondition,
      'amenities': amenities,
      'activities': activities,
      'isFavorite': isFavorite,
      'needsReview': needsReview,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // CopyWith para crear copias modificadas
  Beach copyWith({
    String? id,
    String? name,
    String? province,
    String? municipality,
    String? postalCode,
    String? address,
    String? description,
    String? descriptionEn,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    String? currentCondition,
    Map<String, dynamic>? amenities,
    List<String>? activities,
    bool? isFavorite,
    bool? needsReview,
    DateTime? lastUpdated,
  }) {
    return Beach(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      municipality: municipality ?? this.municipality,
      postalCode: postalCode ?? this.postalCode,
      address: address ?? this.address,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      currentCondition: currentCondition ?? this.currentCondition,
      amenities: amenities ?? this.amenities,
      activities: activities ?? this.activities,
      isFavorite: isFavorite ?? this.isFavorite,
      needsReview: needsReview ?? this.needsReview,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Obtiene la descripción traducida según el idioma
  String getLocalizedDescription(String language) {
    if (language == 'en' && descriptionEn != null && descriptionEn!.isNotEmpty) {
      return descriptionEn!;
    }
    return description;
  }
}

// Modelo para Reportes de Condiciones
class BeachReport {
  final String id;
  final String beachId;
  final String userId;
  final String userName;
  final String condition; // Excelente, Bueno, Moderado, Peligroso
  final double? rating; // Calificación de 1.0 a 5.0
  final String? comment;
  final List<String> imageUrls;
  final DateTime timestamp;
  final int helpfulCount;

  BeachReport({
    required this.id,
    required this.beachId,
    required this.userId,
    required this.userName,
    required this.condition,
    this.rating,
    this.comment,
    this.imageUrls = const [],
    required this.timestamp,
    this.helpfulCount = 0,
  });

  factory BeachReport.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BeachReport(
      id: doc.id,
      beachId: data['beachId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anónimo',
      condition: data['condition'] ?? 'Desconocido',
      rating: data['rating'] != null ? (data['rating'] as num).toDouble() : null,
      comment: data['comment'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      timestamp: Beach.parseFirestoreDate(data['timestamp']) ?? DateTime.now(),
      helpfulCount: data['helpfulCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'beachId': beachId,
      'userId': userId,
      'userName': userName,
      'condition': condition,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
      'helpfulCount': helpfulCount,
    };
  }
}

// Modelo para Propuesta de Nueva Playa
class BeachProposal {
  final String id;
  final String beachName;
  final String province;
  final String? municipality;
  final String? description;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String status;

  BeachProposal({
    required this.id,
    required this.beachName,
    required this.province,
    this.municipality,
    this.description,
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    required this.userId,
    required this.userName,
    required this.timestamp,
    this.status = 'pending',
  });

  factory BeachProposal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BeachProposal(
      id: doc.id,
      beachName: data['beachName'] ?? '',
      province: data['province'] ?? '',
      municipality: data['municipality'],
      description: data['description'],
      latitude: data['latitude'] != null ? (data['latitude'] as num).toDouble() : null,
      longitude: data['longitude'] != null ? (data['longitude'] as num).toDouble() : null,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anónimo',
      timestamp: Beach.parseFirestoreDate(data['timestamp']) ?? DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'beachName': beachName,
      'province': province,
      'municipality': municipality,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'userId': userId,
      'userName': userName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status,
    };
  }
}

// Modelo para Usuario
class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final int points;
  final List<String> favoriteBeaches;
  final List<String> visitedBeaches;
  final int reportsCount;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.points = 0,
    this.favoriteBeaches = const [],
    this.visitedBeaches = const [],
    this.reportsCount = 0,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      points: data['points'] ?? 0,
      favoriteBeaches: List<String>.from(data['favoriteBeaches'] ?? []),
      visitedBeaches: List<String>.from(data['visitedBeaches'] ?? []),
      reportsCount: data['reportsCount'] ?? 0,
      createdAt: Beach.parseFirestoreDate(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'points': points,
      'favoriteBeaches': favoriteBeaches,
      'visitedBeaches': visitedBeaches,
      'reportsCount': reportsCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    int? points,
    List<String>? favoriteBeaches,
    List<String>? visitedBeaches,
    int? reportsCount,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      favoriteBeaches: favoriteBeaches ?? this.favoriteBeaches,
      visitedBeaches: visitedBeaches ?? this.visitedBeaches,
      reportsCount: reportsCount ?? this.reportsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
