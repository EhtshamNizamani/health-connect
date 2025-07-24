import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/data/models/json_user.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthRepositoryImpl extends AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  FirebaseAuthRepositoryImpl(this._firebaseAuth, this._firebaseFirestore);

  @override
  Future<Either<AuthFailure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        final userDoc = await _firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          return Left(AuthFailure('User document not found in Firestore.'));
        }

        final data = userDoc.data()!;
        final role = data['role'] ?? 'patient';
        final name = data['name'] ?? user.displayName ?? '';

        return Right(
          UserModel(
            id: user.uid,
            name: name,
            email: user.email ?? '',
            role: role,
          ).toDomain(),
        );
      } else {
        return Left(AuthFailure('User not found'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Firebase Authentication failed.'));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String selectedRole,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await user.updateProfile(displayName: name);

        await _firebaseFirestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': selectedRole,
        });

        return Right(
          UserModel(
            id: user.uid,
            name: name,
            email: email,
            role: selectedRole,
          ).toDomain(),
        );
      } else {
        return Left(AuthFailure('User not found'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Firebase Authentication failed.'));
    } catch (e) {
      return Left(AuthFailure('Registration failed: $e'));
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) return null;

    final userDoc = await _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .get();

    // Check if the document exists
    final role = userDoc.exists && userDoc.data()!.containsKey('role')
        ? userDoc['role'] as String
        : 'patient'; // default fallback

    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      role: role,
    ).toDomain();
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.updateProfile(displayName: user.name);
      await firebaseUser.reload();
    }
  }

  @override
  Future<Either<AuthFailure, bool>> isDoctorProfileExists(String uid) async {
    try {
      final doc = await _firebaseFirestore.collection('doctors').doc(uid).get();
      if (doc.exists) {
        return Right(true);
      } else {
        return Right(false);
      }
    } catch (e) {
      return Left(AuthFailure('Failed to check doctor profile existence: $e'));
    }
  }
}
