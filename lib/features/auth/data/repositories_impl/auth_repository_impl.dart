import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/data/models/json_user.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
class FirebaseAuthRepositoryImpl extends AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseStorage _firebaseStorage;
  FirebaseAuthRepositoryImpl(this._firebaseAuth, this._firebaseFirestore,this._firebaseStorage);

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
   @override
  Future<Either<AuthFailure, UserEntity>> updateUserProfile({
    required String uid,
    required String name,
    File? photoFile,
  }) async {
    try {
      final userRef = _firebaseFirestore.collection('users').doc(uid);
      String? photoUrl;

      // 1. UPLOAD NEW PHOTO (if one was provided)
      if (photoFile != null) {
        
        final compressedPhotoFile = await _compressImage(photoFile);

        // Create a reference to the file in Firebase Storage
        final storageRef = _firebaseStorage.ref().child('user_photos/$uid.jpg');
        
        // Upload the file
        await storageRef.putFile(compressedPhotoFile);
        
        // Get the download URL to save in Firestore and Auth
        photoUrl = await storageRef.getDownloadURL();
      }

      // 2. PREPARE DATA FOR FIRESTORE
      // Create a map of the data that needs to be updated.
      final Map<String, dynamic> dataToUpdate = {
        'name': name,
      };
      // Only add the photoUrl to the map if a new one was uploaded.
      if (photoUrl != null) {
        dataToUpdate['photoUrl'] = photoUrl;
      }
      
      // 3. UPDATE THE FIRESTORE DOCUMENT
      await userRef.update(dataToUpdate);

      // 4. UPDATE FIREBASE AUTH PROFILE
      // This is good practice as it keeps Firebase Auth's own profile in sync.
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(name);
        if (photoUrl != null) {
          await currentUser.updatePhotoURL(photoUrl);
        }
      }
      
      // 5. FETCH THE UPDATED USER DATA AND RETURN IT (Read-after-write)
      // This ensures the data returned to the BLoC is 100% fresh from the server.
      final updatedDoc = await userRef.get();
      if (!updatedDoc.exists) {
        return Left(AuthFailure('Failed to retrieve updated user profile.'));
      }
      
      // We need a way to create a UserEntity from the map.
      // Assuming your UserEntity has a fromMap factory or similar.
      final updatedUserEntity = UserEntity(
        id: updatedDoc.id,
        name: updatedDoc.data()?['name'] ?? '',
        email: updatedDoc.data()?['email'] ?? '',
        role: updatedDoc.data()?['role'] ?? '',
        photoUrl: updatedDoc.data()?['photoUrl'],
      );
      
      return Right(updatedUserEntity);

    } on FirebaseException catch (e) {
      return Left(AuthFailure(e.message ?? 'An error occurred during profile update.'));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: $e'));
    }
  }

   // --- Helper method for image compression ---
  Future<File> _compressImage(File file) async {
    // 1. Decode the image file into an Image object from the package
    final image = img.decodeImage(await file.readAsBytes());
    if (image == null) {
      // If decoding fails, return the original file
      return file;
    }

    // 2. Resize the image to a maximum width/height (e.g., 1024 pixels)
    // This is the most effective way to reduce file size.
    final resizedImage = img.copyResize(image, width: 1024);

    // 3. Encode the resized image as a JPEG with a specific quality (e.g., 85%)
    final compressedBytes = img.encodeJpg(resizedImage, quality: 85);

    // 4. Write the compressed bytes back to the original file path
    await file.writeAsBytes(compressedBytes);
    
    // Return the (now compressed) file
    return file;
  }
}
