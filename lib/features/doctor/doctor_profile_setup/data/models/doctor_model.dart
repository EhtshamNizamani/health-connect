// lib/features/doctor_profile_setup/data/models/doctor_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/core/data/model/daily_availability_model.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

class DoctorModel {
  final String uid;
  final String name;
  final String email;
  final String specialization;
  final String bio;
  final int experience;
  final String photoUrl;
  final String clinicAddress;
  final int consultationFee;
  final double totalRating;
  final int reviewCount;
  // The old list is replaced with the new map of MODELS
  final Map<String, DailyAvailabilityModel> weeklyAvailability;

  const DoctorModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.specialization,
    required this.bio,
    required this.experience,
    required this.photoUrl,
    required this.clinicAddress,
    required this.consultationFee,
    required this.weeklyAvailability,
    this.reviewCount =0,
    this.totalRating=0,
  });


  factory DoctorModel.fromSnapshot(DocumentSnapshot doc) {
    // Get the data from the snapshot, defaulting to an empty map if null
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Logic to parse the nested weeklyAvailability map from Firestore
    final availabilityData = data['weeklyAvailability'] as Map<String, dynamic>? ?? {};
    final weeklyAvailability = availabilityData.map(
      (day, dailyData) => MapEntry(day, DailyAvailabilityModel.fromMap(dailyData)),
    );

    return DoctorModel(
      // The document ID is the UID
      uid: doc.id, 
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      specialization: data['specialization'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      experience: data['experience'] as int? ?? 0,
      photoUrl: data['photoUrl'] as String? ?? '',
      clinicAddress: data['clinicAddress'] as String? ?? '',
      consultationFee: data['consultationFee'] as int? ?? 0,
      totalRating: (data['totalRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      weeklyAvailability: weeklyAvailability,
    );
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    final availabilityData = map['weeklyAvailability'] as Map<String, dynamic>? ?? {};
    final weeklyAvailability = availabilityData.map(
      (day, dailyData) => MapEntry(day, DailyAvailabilityModel.fromMap(dailyData)),
    );

    return DoctorModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      specialization: map['specialization'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      experience: map['experience'] as int? ?? 0,
      photoUrl: map['photoUrl'] as String? ?? '',
      clinicAddress: map['clinicAddress'] as String? ?? '',
      consultationFee: map['consultationFee'] as int? ?? 0,
      totalRating: (map['totalRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      weeklyAvailability: weeklyAvailability,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'specialization': specialization,
      'bio': bio,
      'experience': experience,
      'photoUrl': photoUrl,
      'clinicAddress': clinicAddress,
      'consultationFee': consultationFee,
      'totalRating': totalRating,
      'reviewCount': reviewCount,
      'weeklyAvailability': weeklyAvailability.map(
        (day, dailyModel) => MapEntry(day, dailyModel.toMap()),
      ),
    };
  }

  DoctorEntity toDomain() {
    return DoctorEntity(
      uid: uid,
      name: name,
      email: email,
      specialization: specialization,
      bio: bio,
      experience: experience,
      photoUrl: photoUrl,
      clinicAddress: clinicAddress,
      consultationFee: consultationFee,
      totalRating: totalRating,
      reviewCount: reviewCount,
      weeklyAvailability: weeklyAvailability.map(
        (day, dailyModel) => MapEntry(day, dailyModel.toDomain()),
      ),
    );
  }

  factory DoctorModel.fromEntity(DoctorEntity entity) {
    return DoctorModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      specialization: entity.specialization,
      bio: entity.bio,
      experience: entity.experience,
      photoUrl: entity.photoUrl,
      clinicAddress: entity.clinicAddress,
      consultationFee: entity.consultationFee,
      totalRating: entity.totalRating,
      reviewCount: entity.reviewCount,
      weeklyAvailability: entity.weeklyAvailability.map(
        (day, dailyEntity) => MapEntry(day, DailyAvailabilityModel.fromEntity(dailyEntity)),
      ),
    );
  }

  DoctorModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? specialization,
    String? bio,
    int? experience,
    String? photoUrl,
    String? clinicAddress,
    int? consultationFee,
    double? totalRating,
    int? reviewCount,
    Map<String, DailyAvailabilityModel>? weeklyAvailability,
  }) {
    return DoctorModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      specialization: specialization ?? this.specialization,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      photoUrl: photoUrl ?? this.photoUrl,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      consultationFee: consultationFee ?? this.consultationFee,
      totalRating: totalRating ?? this.totalRating,
      reviewCount: reviewCount ?? this.reviewCount,
      weeklyAvailability: weeklyAvailability ?? this.weeklyAvailability,
    );
  }}