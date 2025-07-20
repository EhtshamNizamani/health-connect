import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final FirebaseAuth _firebaseAuth;
  AuthRepositoryImpl(this._firebaseAuth);

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
        return Right(
          UserEntity(
            id: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
          ),
        );
      } else {
        return Left(AuthFailure('User not found'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Firebase Authentication failed.'));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        // Update the user's display name
        await user.updateProfile(displayName: name);
        return Right(
          UserEntity(id: user.uid, name: name, email: user.email ?? ''),
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
  UserEntity? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserEntity(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email!,
      );
    }
    return null;
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.updateProfile(displayName: user.name);
      await firebaseUser.reload();
    }
  }
}
