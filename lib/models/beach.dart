import 'package:cloud_firestore/cloud_firestore.dart';

class Beach {
  final String id;
  final String name;
  final String province;
  final String municipality;
  final String description;
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
  final DateTime? lastUpdated;

  Beach({
    required this.id,
    required this.name,
    required this.province,
    required this.municipality,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrls = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.currentCondition = 'Desconocido',
    this.amenities = const {},
    this.activities = const [],
    this.isFavorite = false,
    this.lastUpdated,
  });

  // Crear Beach desde Firestore
  factory Beach.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Beach(
      id: doc.id,
      name: data['name'] ?? '',
      province: data['province'] ?? '',
      municipality: data['municipality'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      currentCondition: data['currentCondition'] ?? 'Desconocido',
      amenities: Map<String, dynamic>.from(data['amenities'] ?? {}),
      activities: List<String>.from(data['activities'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  // Convertir Beach a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'province': province,
      'municipality': municipality,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'rating': rating,
      'reviewCount': reviewCount,
      'currentCondition': currentCondition,
      'amenities': amenities,
      'activities': activities,
      'isFavorite': isFavorite,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // CopyWith para crear copias modificadas
  Beach copyWith({
    String? id,
    String? name,
    String? province,
    String? municipality,
    String? description,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    String? currentCondition,
    Map<String, dynamic>? amenities,
    List<String>? activities,
    bool? isFavorite,
    DateTime? lastUpdated,
  }) {
    return Beach(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      municipality: municipality ?? this.municipality,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      currentCondition: currentCondition ?? this.currentCondition,
      amenities: amenities ?? this.amenities,
      activities: activities ?? this.activities,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Modelo para Reportes de Condiciones
class BeachReport {
  final String id;
  final String beachId;
  final String userId;
  final String userName;
  final String condition; // Excelente, Bueno, Moderado, Peligroso
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
      comment: data['comment'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      helpfulCount: data['helpfulCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'beachId': beachId,
      'userId': userId,
      'userName': userName,
      'condition': condition,
      'comment': comment,
      'imageUrls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
      'helpfulCount': helpfulCount,
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
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
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
