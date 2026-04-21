import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class ActivityLogProvider {
  final client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getLogsByClassroom(String classroomId) async {
    final userId = client.auth.currentUser?.id;
    final response = await client
        .from(AppDatabase.tableActivityLogs)
        .select('''
          *, 
          ${AppDatabase.tableActivityImages}(*), 
          students(*),
          activity_likes!left(count), 
          activity_comments!left(count),
          isLiked:activity_likes!left(user_id)
        ''')
        .eq(AppDatabase.colClassroomId, classroomId)
        .eq('activity_likes.user_id', userId ?? '')
        .order(AppDatabase.colCreatedAt, ascending: false);
    
    return _processResponse(response);
  }

  Future<List<Map<String, dynamic>>> getLogsByStudent(String studentId, String classroomId) async {
    final userId = client.auth.currentUser?.id;
    // We use a complex select to get counts and check if current user liked it
    final response = await client
        .from(AppDatabase.tableActivityLogs)
        .select('''
          *, 
          ${AppDatabase.tableActivityImages}(*), 
          students(*),
          like_count:activity_likes(count),
          comment_count:activity_comments(count),
          my_like:activity_likes(id)
        ''')
        .or('${AppDatabase.colStudentId}.eq.$studentId,${AppDatabase.colStudentId}.is.null')
        .eq(AppDatabase.colClassroomId, classroomId)
        .order(AppDatabase.colCreatedAt, ascending: false);
    
    // Note: To get "isLiked" for EACH log properly in a single query with Supabase 
    // when filtering on user_id inside a join is tricky if not using RPC.
    // We'll process the response to map counts and isLiked status.
    return _processResponse(response, userId);
  }

  List<Map<String, dynamic>> _processResponse(List<dynamic> response, [String? userId]) {
    return response.map((item) {
      final map = Map<String, dynamic>.from(item);
      
      // Extract counts from the list-of-count-objects structure Supabase returns
      final likeCountList = map['like_count'] as List?;
      map['likeCount'] = (likeCountList != null && likeCountList.isNotEmpty) 
          ? likeCountList[0]['count'] 
          : 0;

      final commentCountList = map['comment_count'] as List?;
      map['commentCount'] = (commentCountList != null && commentCountList.isNotEmpty) 
          ? commentCountList[0]['count'] 
          : 0;
      
      // Check if current user liked it
      final myLikes = map['my_like'] as List?;
      if (userId != null && myLikes != null) {
        map['isLiked'] = myLikes.isNotEmpty; 
      } else {
        map['isLiked'] = false;
      }
      
      return map;
    }).toList();
  }

  Future<void> toggleLike(String activityId, String userId, bool isLiked) async {
    if (isLiked) {
      await client
          .from(AppDatabase.tableActivityLikes)
          .delete()
          .match({
            'activity_log_id': activityId,
            'user_id': userId,
          });
    } else {
      await client
          .from(AppDatabase.tableActivityLikes)
          .insert({
            'activity_log_id': activityId,
            'user_id': userId,
          });
    }
  }

  Future<Map<String, dynamic>> addComment(String activityId, String userId, String content) async {
    return await client
        .from(AppDatabase.tableActivityComments)
        .insert({
          'activity_log_id': activityId,
          'user_id': userId,
          'content': content,
        })
        .select()
        .single();
  }

  Future<List<Map<String, dynamic>>> getComments(String activityId) async {
    final response = await client
        .from(AppDatabase.tableActivityComments)
        .select('*, users!user_id(name, avatar_url, user_roles(roles(name)))')
        .eq('activity_log_id', activityId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertLog(Map<String, dynamic> data) async {
    final response = await client
        .from(AppDatabase.tableActivityLogs)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<void> insertImages(List<Map<String, dynamic>> imagesData) async {
    await client.from(AppDatabase.tableActivityImages).insert(imagesData);
  }

  Future<String> uploadFile(File file, String path) async {
    await client.storage.from('activities').upload(path, file);
    return client.storage.from('activities').getPublicUrl(path);
  }
}
