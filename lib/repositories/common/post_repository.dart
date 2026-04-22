import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/common.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost(PostModel model) async {
    try {
      await _firestore
          .collection(FirestoreCollections.posts)
          .doc()
          .set(model.toJson());

      LogService.info('New post created successfuly: ${model.positionTitle}');
    } catch (e, stackTrace) {
      LogService.error('An error occured when creating post', e, stackTrace);
      rethrow;
    }
  }

  Stream<List<PostModel>> getPostsStream(String companyId) {
    LogService.info('Getting all posts stream');
    try {
      return _firestore
          .collection(FirestoreCollections.posts)
          .where(FirestoreCompanyFields.companyId, isEqualTo: companyId)
          .orderBy(FireStorePostFields.createdAt, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();
      });
    } catch (e, stackTrace) {
      LogService.error(
          'An arror occured when getting posts stream!', e, stackTrace);
      rethrow;
    }
  }

  Stream<List<PostModel>> getActivePostsStream() {
    LogService.info('Getting active posts stream');
    try {
      return _firestore
          .collection(FirestoreCollections.posts)
          .where(FireStorePostFields.isActive, isEqualTo: true)
          .orderBy(FireStorePostFields.createdAt, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();
      });
    } catch (e, stackTrace) {
      LogService.error(
          'An arror occured when getting active posts stream!', e, stackTrace);
      rethrow;
    }
  }

  Future<PostModel?> getPostById(String postId) async {
    LogService.info('Getting post: $postId');
    try {
      final doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();
      if (doc.exists) {
        return PostModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePosts(PostModel model) async {
    try {
      await _firestore
          .collection(FirestoreCollections.posts)
          .doc(model.postId)
          .update(model.toJson());

      LogService.info('Post updated : ${model.positionTitle}');
    } catch (e, stackTrace) {
      LogService.error('An error occured when updating post', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.posts)
          .doc(postId)
          .delete();

      LogService.info('Post deleted: $postId');
    } catch (e, stackTrace) {
      LogService.error('An error occured when deleting post', e, stackTrace);
      rethrow;
    }
  }

  Future<void> togglePostStatus(String postId, bool currentStatus) async {
    try {
      await _firestore
          .collection(FirestoreCollections.posts)
          .doc(postId)
          .update({
        FireStorePostFields.isActive: !currentStatus,
      });

      LogService.info('Post status changed: $postId');
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when changing post status', e, stackTrace);
      rethrow;
    }
  }

  Stream<int> getActivePostCountStream(String companyId) {
    LogService.info('Getting active post count stream.');
    try {
      return _firestore
          .collection(FirestoreCollections.posts)
          .where(FirestoreCompanyFields.companyId, isEqualTo: companyId)
          .where(FireStorePostFields.isActive, isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when getting post count stream', e, stackTrace);
      rethrow;
    }
  }
}
