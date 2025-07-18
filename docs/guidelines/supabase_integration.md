# Supabase Integration Guidelines

## Table of Contents
1. [Setup and Initialization](#setup-and-initialization)
2. [Authentication](#authentication)
3. [Database Operations](#database-operations)
4. [Row Level Security (RLS)](#row-level-security-rls)
5. [Realtime Subscriptions](#realtime-subscriptions)
6. [Storage](#storage)
7. [Edge Functions](#edge-functions)
8. [Riverpod Integration](#riverpod-integration)
9. [Performance Optimization](#performance-optimization)
10. [Error Handling](#error-handling)
11. [Testing](#testing)
12. [Best Practices](#best-practices)

## Setup and Initialization

### Dependencies
Add these to your `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.8.4
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0
  # For JSON serialization
  freezed_annotation: ^3.1.0
  json_annotation: ^4.9.0
  # For environment variables
  flutter_dotenv: ^5.2.1

dev_dependencies:
  build_runner: ^2.5.4
  freezed: ^3.1.0
  json_serializable: ^6.9.5
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.0.0
```

### Initialization
Initialize Supabase in your `main.dart` with enhanced configuration:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: "supabase_config.env");
  
  // Initialize Supabase with enhanced configuration
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    realtimeClientOptions: const RealtimeClientOptions(
      heartbeatIntervalMs: 25000, // Lowered heartbeat interval for better performance
      reconnectAfterMs: (tries) => [1000, 2000, 5000, 10000][tries - 1] ?? 10000,
    ),
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Enhanced security with PKCE
      detectSessionInUri: true,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 3,
    ),
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### Environment Variables
Store sensitive data in `supabase_config.env` file:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

### Global Supabase Client Access
Create a convenient global accessor:

```dart
// lib/core/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Helper for checking authentication status
bool get isAuthenticated => supabase.auth.currentUser != null;

// Safe access token getter (returns null when user not signed in)
String? get currentAccessToken => supabase.auth.currentSession?.accessToken;

// Current user ID helper
String? get currentUserId => supabase.auth.currentUser?.id;
```

## Authentication

### Email/Password Authentication

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Sign up with enhanced error handling
Future<AuthResponse> signUp(String email, String password) async {
  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'io.supabase.todo://login-callback',
    );
    
    if (response.user != null && response.session == null) {
      // User needs to verify email
      throw const AuthException('Please check your email for verification link');
    }
    
    return response;
  } on AuthException catch (error) {
    // Handle specific auth errors
    switch (error.message) {
      case 'User already registered':
        throw const AuthException('An account with this email already exists');
      case 'Password should be at least 6 characters':
        throw const AuthException('Password must be at least 6 characters long');
      default:
        rethrow;
    }
  }
}

// Sign in with improved error handling
Future<AuthResponse> signIn(String email, String password) async {
  final response = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  
  // Verify session and access token
  if (response.session?.accessToken == null) {
    throw const AuthException('Failed to obtain access token');
  }
  
  return response;
}

// Enhanced sign out with cleanup
Future<void> signOut() async {
  await supabase.auth.signOut(scope: SignOutScope.global);
}

// Safe current user access
User? get currentUser => supabase.auth.currentUser;

// Safe access token getter (improved in 2.8.4)
String? get accessToken {
  final session = supabase.auth.currentSession;
  return session?.accessToken; // Now correctly returns null when not signed in
}

// Check if session is valid and not expired
bool get hasValidSession {
  final session = supabase.auth.currentSession;
  if (session == null) return false;
  
  final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
  return DateTime.now().isBefore(expiresAt);
}

// Listen to auth state changes with proper cleanup
StreamSubscription<AuthState>? _authSubscription;

void initAuthListener() {
  _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;
    
    switch (event) {
      case AuthChangeEvent.signedIn:
        // Handle successful sign in
        break;
      case AuthChangeEvent.signedOut:
        // Handle sign out, clear local data
        break;
      case AuthChangeEvent.tokenRefreshed:
        // Handle token refresh
        break;
      case AuthChangeEvent.userUpdated:
        // Handle user profile updates
        break;
      case AuthChangeEvent.passwordRecovery:
        // Handle password recovery
        break;
    }
  });
}

void disposeAuthListener() {
  _authSubscription?.cancel();
  _authSubscription = null;
}
```

### Social Authentication

```dart
// Enhanced OAuth with scopes and additional options
Future<bool> signInWithGoogle() async {
  try {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.todo://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
      queryParams: {
        'access_type': 'offline',
        'prompt': 'consent',
      },
      scopes: 'email profile',
    );
    return true;
  } on AuthException catch (error) {
    print('OAuth error: ${error.message}');
    return false;
  }
}

// Sign in with Apple with enhanced configuration
Future<bool> signInWithApple() async {
  try {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.todo://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
    return true;
  } on AuthException catch (error) {
    print('Apple sign in error: ${error.message}');
    return false;
  }
}

// GitHub OAuth (new in 2.8.4)
Future<bool> signInWithGitHub() async {
  try {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: 'io.supabase.todo://login-callback',
      scopes: 'user:email',
    );
    return true;
  } on AuthException catch (error) {
    print('GitHub sign in error: ${error.message}');
    return false;
  }
}
```

### Magic Link and OTP Authentication

```dart
// Enhanced magic link with custom templates
Future<void> sendMagicLink(String email) async {
  await supabase.auth.signInWithOtp(
    email: email,
    emailRedirectTo: 'io.supabase.todo://login-callback',
    shouldCreateUser: false, // Only allow existing users
    data: {
      'app_name': 'Todo App',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

// Phone OTP authentication
Future<void> sendPhoneOtp(String phone) async {
  await supabase.auth.signInWithOtp(
    phone: phone,
    shouldCreateUser: true,
  );
}

// Verify OTP
Future<AuthResponse> verifyOtp({
  required String token,
  required OtpType type,
  String? email,
  String? phone,
}) async {
  return await supabase.auth.verifyOTP(
    token: token,
    type: type,
    email: email,
    phone: phone,
  );
}
```

### Session Management and Refresh

```dart
// Manual session refresh
Future<AuthResponse> refreshSession() async {
  final response = await supabase.auth.refreshSession();
  
  if (response.session == null) {
    throw const AuthException('Failed to refresh session');
  }
  
  return response;
}

// Set session from external source
Future<AuthResponse> setSession(String accessToken, String refreshToken) async {
  return await supabase.auth.setSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
  );
}

// Get session with validation
Session? getValidSession() {
  final session = supabase.auth.currentSession;
  if (session == null) return null;
  
  // Check if session is expired
  final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
  if (DateTime.now().isAfter(expiresAt)) {
    return null;
  }
  
  return session;
}
```

## Database Operations

### Basic CRUD Operations

```dart
// Enhanced CRUD operations with better error handling and type safety

// Create with returning specific columns
Future<Todo> createTodo(String title) async {
  final response = await supabase
      .from('todos')
      .insert({
        'title': title,
        'user_id': currentUserId!,
        'created_at': DateTime.now().toIso8601String(),
      })
      .select('id, title, is_complete, created_at, user_id')
      .single();
  
  return Todo.fromJson(response);
}

// Read with advanced filtering and pagination
Future<List<Todo>> getTodos({
  bool? isComplete,
  int limit = 50,
  int offset = 0,
  String? searchQuery,
}) async {
  var query = supabase
      .from('todos')
      .select('id, title, is_complete, created_at, user_id')
      .eq('user_id', currentUserId!)
      .order('created_at', ascending: false)
      .range(offset, offset + limit - 1);

  if (isComplete != null) {
    query = query.eq('is_complete', isComplete);
  }

  if (searchQuery != null && searchQuery.isNotEmpty) {
    query = query.ilike('title', '%$searchQuery%');
  }

  final response = await query;
  return (response as List).map((json) => Todo.fromJson(json)).toList();
}

// Update with optimistic updates
Future<Todo> updateTodo(String id, Map<String, dynamic> updates) async {
  final response = await supabase
      .from('todos')
      .update({
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', id)
      .eq('user_id', currentUserId!) // Ensure user owns the todo
      .select('id, title, is_complete, created_at, updated_at, user_id')
      .single();
  
  return Todo.fromJson(response);
}

// Soft delete with archive functionality
Future<void> deleteTodo(String id, {bool softDelete = true}) async {
  if (softDelete) {
    await supabase
        .from('todos')
        .update({
          'deleted_at': DateTime.now().toIso8601String(),
          'is_deleted': true,
        })
        .eq('id', id)
        .eq('user_id', currentUserId!);
  } else {
    await supabase
        .from('todos')
        .delete()
        .eq('id', id)
        .eq('user_id', currentUserId!);
  }
}

// Bulk operations for better performance
Future<List<Todo>> createMultipleTodos(List<String> titles) async {
  final inserts = titles.map((title) => {
    'title': title,
    'user_id': currentUserId!,
    'created_at': DateTime.now().toIso8601String(),
  }).toList();

  final response = await supabase
      .from('todos')
      .insert(inserts)
      .select('id, title, is_complete, created_at, user_id');

  return (response as List).map((json) => Todo.fromJson(json)).toList();
}

// Bulk update with transaction-like behavior
Future<void> markMultipleComplete(List<String> todoIds) async {
  await supabase
      .from('todos')
      .update({
        'is_complete': true,
        'completed_at': DateTime.now().toIso8601String(),
      })
      .in_('id', todoIds)
      .eq('user_id', currentUserId!);
}
```

### Using Models with Freezed

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'is_complete') @Default(false) bool isComplete,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    String? description,
    @JsonKey(name: 'priority_level') @Default(TodoPriority.medium) TodoPriority priority,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    List<String>? tags,
  }) = _Todo;

  const Todo._();

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  // Computed properties
  bool get isOverdue => dueDate != null && 
      DateTime.now().isAfter(dueDate!) && 
      !isComplete;

  bool get isDueToday => dueDate != null &&
      DateUtils.isSameDay(dueDate!, DateTime.now());

  String get displayTitle => title.trim().isEmpty ? 'Untitled' : title;
}

@JsonEnum()
enum TodoPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium') 
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

// Enhanced query with type conversion
Future<List<Todo>> getTodosTyped() async {
  final response = await supabase
      .from('todos')
      .select('''
        id, title, user_id, is_complete, created_at, updated_at,
        completed_at, deleted_at, is_deleted, description,
        priority_level, due_date, tags
      ''')
      .eq('user_id', currentUserId!)
      .eq('is_deleted', false)
      .order('created_at', ascending: false);

  return (response as List)
      .map((json) => Todo.fromJson(json))
      .toList();
}

// Type-safe upsert operation
Future<Todo> upsertTodo(Todo todo) async {
  final response = await supabase
      .from('todos')
      .upsert(todo.toJson())
      .select()
      .single();
  
  return Todo.fromJson(response);
}
```

## Row Level Security (RLS)

### Modern RLS Policies with Enhanced Security

```sql
-- Enable RLS on todos table
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- Modern policy with role-based access and time-based restrictions
CREATE POLICY "Users can view their own active todos" 
ON todos FOR SELECT 
USING (
  auth.uid() = user_id 
  AND (deleted_at IS NULL OR deleted_at > NOW() - INTERVAL '30 days')
);

-- Policy with data validation for inserts
CREATE POLICY "Users can insert valid todos" 
ON todos FOR INSERT 
WITH CHECK (
  auth.uid() = user_id 
  AND title IS NOT NULL 
  AND LENGTH(TRIM(title)) > 0
  AND LENGTH(title) <= 500
  AND (due_date IS NULL OR due_date >= CURRENT_DATE)
);

-- Policy with ownership verification and audit trail
CREATE POLICY "Users can update their own todos with audit" 
ON todos FOR UPDATE 
USING (auth.uid() = user_id AND deleted_at IS NULL)
WITH CHECK (
  auth.uid() = user_id 
  AND updated_at >= created_at
  AND (completed_at IS NULL OR completed_at >= created_at)
);

-- Soft delete policy
CREATE POLICY "Users can soft delete their own todos" 
ON todos FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (
  auth.uid() = user_id 
  AND (deleted_at IS NULL OR deleted_at >= created_at)
);

-- Admin policy for service role (server-side only)
CREATE POLICY "Service role full access" 
ON todos FOR ALL 
USING (auth.role() = 'service_role');

-- Project scoped roles (new in 2.8.4)
CREATE POLICY "Project managers can view team todos"
ON todos FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'project_manager'
    AND ur.project_id = todos.project_id
  )
);

-- Time-based access policy
CREATE POLICY "Business hours access only"
ON sensitive_todos FOR ALL
USING (
  auth.uid() = user_id
  AND EXTRACT(hour FROM NOW() AT TIME ZONE 'UTC') BETWEEN 9 AND 17
  AND EXTRACT(dow FROM NOW()) BETWEEN 1 AND 5
);

-- Rate limiting policy using custom function
CREATE OR REPLACE FUNCTION check_rate_limit(user_id UUID, action_type TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  action_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO action_count
  FROM audit_log
  WHERE user_id = $1
    AND action = $2
    AND created_at > NOW() - INTERVAL '1 hour';
  
  RETURN action_count < 100; -- Max 100 actions per hour
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE POLICY "Rate limited operations"
ON todos FOR INSERT
WITH CHECK (
  auth.uid() = user_id
  AND check_rate_limit(auth.uid(), 'create_todo')
);
```

### Advanced RLS with Functions

```sql
-- Create helper functions for complex policies
CREATE OR REPLACE FUNCTION auth.user_has_permission(permission_name TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_permissions up
    JOIN permissions p ON up.permission_id = p.id
    WHERE up.user_id = auth.uid()
    AND p.name = permission_name
    AND up.granted_at <= NOW()
    AND (up.expires_at IS NULL OR up.expires_at > NOW())
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Use function in policy
CREATE POLICY "Permission based access"
ON todos FOR ALL
USING (auth.user_has_permission('manage_todos'));
```

### Using RLS with Service Role Key
For admin operations, you can use the service role key (server-side only):

```dart
final adminClient = SupabaseClient(
  'YOUR_SUPABASE_URL',
  'YOUR_SERVICE_ROLE_KEY', // Never expose this client-side!
);
```

## Realtime Subscriptions

### Enhanced Realtime Subscriptions

```dart
// Stream-based subscriptions with error handling
Stream<List<Todo>> watchTodos() {
  return supabase
      .from('todos')
      .stream(primaryKey: ['id'])
      .eq('user_id', currentUserId!)
      .eq('is_deleted', false)
      .order('created_at', ascending: false)
      .map((data) => (data as List)
          .map((json) => Todo.fromJson(json))
          .toList())
      .handleError((error) {
        print('Realtime error: $error');
        // Optionally emit cached data or empty list
        return <Todo>[];
      });
}

// Advanced channel-based subscriptions with heartbeat monitoring
class TodoRealtimeService {
  RealtimeChannel? _channel;
  Timer? _heartbeatTimer;
  
  void initializeRealtime() {
    _channel = supabase.channel('todos-${currentUserId}')
      .on(
        'postgres_changes',
        const RealtimePostgresChangesOptions(
          event: RealtimeListenTypes.all,
          schema: 'public',
          table: 'todos',
          filter: 'user_id=eq.${currentUserId}',
        ),
        _handleRealtimeEvent,
      )
      .on(
        'presence',
        const RealtimePresenceOptions(key: 'user_id'),
        _handlePresenceEvent,
      )
      .subscribe((status, [error]) {
        print('Subscription status: $status');
        if (error != null) {
          print('Subscription error: $error');
          _handleSubscriptionError(error);
        }
      });
    
    // Monitor connection health with custom heartbeat
    _startHeartbeatMonitoring();
  }

  void _handleRealtimeEvent(RealtimePostgresChangesPayload payload, [RealtimeChannel? ref]) {
    switch (payload.eventType) {
      case 'INSERT':
        final newTodo = Todo.fromJson(payload.new_);
        _onTodoInserted(newTodo);
        break;
      case 'UPDATE':
        final updatedTodo = Todo.fromJson(payload.new_);
        final oldTodo = Todo.fromJson(payload.old_);
        _onTodoUpdated(updatedTodo, oldTodo);
        break;
      case 'DELETE':
        final deletedTodo = Todo.fromJson(payload.old_);
        _onTodoDeleted(deletedTodo);
        break;
    }
  }

  void _handlePresenceEvent(RealtimePresencePayload payload, [RealtimeChannel? ref]) {
    // Handle user presence for collaborative features
    switch (payload.event) {
      case 'join':
        print('User joined: ${payload.key}');
        break;
      case 'leave':
        print('User left: ${payload.key}');
        break;
    }
  }

  void _startHeartbeatMonitoring() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel?.state == RealtimeChannelStates.closed) {
        print('Channel closed, attempting reconnection...');
        _reconnectChannel();
      }
    });
  }

  void _reconnectChannel() {
    _channel?.unsubscribe();
    Future.delayed(const Duration(seconds: 2), initializeRealtime);
  }

  void _handleSubscriptionError(dynamic error) {
    // Implement exponential backoff for reconnection
    final backoffDelay = Duration(seconds: math.min(30, math.pow(2, _reconnectAttempts).toInt()));
    Future.delayed(backoffDelay, _reconnectChannel);
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _channel?.unsubscribe();
  }
}

// Presence tracking for collaborative features
class CollaborativePresence {
  void trackUserPresence() {
    final channel = supabase.channel('room-1')
      .on(
        'presence',
        const RealtimePresenceOptions(key: 'user_id'),
        (payload, [ref]) {
          // Handle presence changes
        },
      )
      .subscribe();

    // Track current user
    channel.track({
      'user_id': currentUserId,
      'username': currentUser?.userMetadata?['username'] ?? 'Anonymous',
      'last_seen': DateTime.now().toIso8601String(),
      'status': 'online',
    });
  }
}

// Broadcast for real-time collaboration
void sendBroadcastMessage(String message) {
  supabase.channel('room-1').send(
    type: 'broadcast',
    event: 'message',
    payload: {
      'message': message,
      'user_id': currentUserId,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
```

## Storage

### Enhanced Storage Operations

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static const String avatarsBucket = 'avatars';
  static const String attachmentsBucket = 'attachments';
  
  // Upload with progress tracking and validation
  Future<String> uploadFile({
    required File file,
    required String bucket,
    String? customPath,
    Function(double)? onProgress,
  }) async {
    // Validate file
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) { // 10MB limit
      throw Exception('File size exceeds 10MB limit');
    }

    final mimeType = lookupMimeType(file.path);
    if (mimeType == null || !_isAllowedMimeType(mimeType)) {
      throw Exception('File type not allowed');
    }

    // Generate secure file path
    final fileExt = path.extension(file.path);
    final fileName = customPath ?? 
        '${currentUserId}/${DateTime.now().millisecondsSinceEpoch}$fileExt';
    
    try {
      // Upload with retry mechanism
      await _uploadWithRetry(
        bucket: bucket,
        path: fileName,
        file: file,
        onProgress: onProgress,
      );

      return fileName;
    } catch (error) {
      throw Exception('Upload failed: $error');
    }
  }

  Future<void> _uploadWithRetry({
    required String bucket,
    required String path,
    required File file,
    Function(double)? onProgress,
    int maxRetries = 3,
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await supabase.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false,
            contentType: lookupMimeType(file.path),
          ),
        );
        return;
      } catch (error) {
        if (attempt == maxRetries - 1) rethrow;
        await Future.delayed(Duration(seconds: math.pow(2, attempt).toInt()));
      }
    }
  }

  bool _isAllowedMimeType(String mimeType) {
    const allowedTypes = [
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
      'application/pdf',
      'text/plain',
    ];
    return allowedTypes.contains(mimeType);
  }

  // Enhanced download with caching
  Future<Uint8List> downloadFile(String bucket, String path) async {
    try {
      return await supabase.storage.from(bucket).download(path);
    } on StorageException catch (error) {
      if (error.statusCode == '404') {
        throw Exception('File not found');
      }
      rethrow;
    }
  }

  // Get optimized public URL with transformations
  String getPublicUrl(
    String bucket,
    String path, {
    int? width,
    int? height,
    String? quality,
    String? format,
  }) {
    var url = supabase.storage.from(bucket).getPublicUrl(path);
    
    // Add image transformations for optimization
    if (width != null || height != null || quality != null || format != null) {
      final params = <String>[];
      if (width != null) params.add('width=$width');
      if (height != null) params.add('height=$height');
      if (quality != null) params.add('quality=$quality');
      if (format != null) params.add('format=$format');
      
      url += '?${params.join('&')}';
    }
    
    return url;
  }

  // Create signed URL with enhanced options
  Future<String> createSignedUrl(
    String bucket,
    String path, {
    int expiresInSeconds = 3600,
    String? download,
  }) async {
    return await supabase.storage.from(bucket).createSignedUrl(
      path,
      expiresInSeconds,
      options: SignedUrlOptions(
        download: download,
      ),
    );
  }

  // Batch operations for multiple files
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String bucket,
    Function(int, int)? onProgress,
  }) async {
    final uploadedPaths = <String>[];
    
    for (int i = 0; i < files.length; i++) {
      try {
        final path = await uploadFile(
          file: files[i],
          bucket: bucket,
          onProgress: (progress) => onProgress?.call(i, files.length),
        );
        uploadedPaths.add(path);
      } catch (error) {
        print('Failed to upload file ${files[i].path}: $error');
        // Continue with other files
      }
    }
    
    return uploadedPaths;
  }

  // Delete file with verification
  Future<void> deleteFile(String bucket, String path) async {
    // Verify user owns the file (path should start with user ID)
    if (!path.startsWith(currentUserId!)) {
      throw Exception('Unauthorized: Cannot delete file');
    }

    await supabase.storage.from(bucket).remove([path]);
  }

  // List files with pagination
  Future<List<FileObject>> listFiles(
    String bucket, {
    String? folder,
    int limit = 100,
    int offset = 0,
    String? search,
  }) async {
    final options = SearchOptions(
      limit: limit,
      offset: offset,
      sortBy: const SortBy(column: 'created_at', order: 'desc'),
    );

    if (search != null) {
      options.search = search;
    }

    return await supabase.storage
        .from(bucket)
        .list(path: folder ?? currentUserId, searchOptions: options);
  }
}
```

## Edge Functions

### Enhanced Edge Functions Integration

```dart
class EdgeFunctionsService {
  // Invoke function with enhanced error handling and typing
  Future<T> invokeFunction<T>({
    required String functionName,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        functionName,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${currentAccessToken}',
          ...?headers,
        },
      ).timeout(timeout);

      if (response.status >= 400) {
        throw EdgeFunctionException(
          'Function $functionName failed with status ${response.status}',
          response.status,
          response.data,
        );
      }

      if (fromJson != null && response.data is Map<String, dynamic>) {
        return fromJson(response.data);
      }

      return response.data as T;
    } on TimeoutException {
      throw EdgeFunctionException(
        'Function $functionName timed out after ${timeout.inSeconds}s',
        408,
        null,
      );
    } catch (error) {
      if (error is EdgeFunctionException) rethrow;
      throw EdgeFunctionException(
        'Unexpected error calling $functionName: $error',
        500,
        null,
      );
    }
  }

  // Specific function implementations
  Future<EmailResult> sendEmail({
    required String to,
    required String subject,
    required String body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    return await invokeFunction<EmailResult>(
      functionName: 'send-email',
      body: {
        'to': to,
        'subject': subject,
        'body': body,
        'cc': cc,
        'bcc': bcc,
        'user_id': currentUserId,
      },
      fromJson: (json) => EmailResult.fromJson(json),
    );
  }

  Future<AnalyticsData> getAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? metrics,
  }) async {
    return await invokeFunction<AnalyticsData>(
      functionName: 'analytics',
      body: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'metrics': metrics ?? ['todos_created', 'todos_completed'],
        'user_id': currentUserId,
      },
      fromJson: (json) => AnalyticsData.fromJson(json),
    );
  }

  Future<ProcessingResult> processDocument({
    required String documentUrl,
    String? processingType,
  }) async {
    return await invokeFunction<ProcessingResult>(
      functionName: 'process-document',
      body: {
        'document_url': documentUrl,
        'processing_type': processingType ?? 'extract_text',
        'user_id': currentUserId,
      },
      timeout: const Duration(minutes: 5), // Longer timeout for processing
      fromJson: (json) => ProcessingResult.fromJson(json),
    );
  }

  // Streaming function calls for real-time processing
  Stream<ProcessingUpdate> processDocumentStream(String documentUrl) async* {
    // This would require WebSocket support in edge functions
    // For now, we can poll for updates
    final jobId = await invokeFunction<String>(
      functionName: 'start-document-processing',
      body: {
        'document_url': documentUrl,
        'user_id': currentUserId,
      },
    );

    while (true) {
      final update = await invokeFunction<ProcessingUpdate>(
        functionName: 'get-processing-status',
        body: {'job_id': jobId},
        fromJson: (json) => ProcessingUpdate.fromJson(json),
      );

      yield update;

      if (update.isComplete) break;
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  // Batch function calls
  Future<List<T>> invokeBatch<T>({
    required String functionName,
    required List<Map<String, dynamic>> requests,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return await invokeFunction<List<T>>(
      functionName: 'batch-processor',
      body: {
        'function_name': functionName,
        'requests': requests,
        'user_id': currentUserId,
      },
      fromJson: (json) {
        final results = json['results'] as List;
        return results
            .map((item) => fromJson?.call(item) ?? item as T)
            .toList();
      },
    );
  }
}

// Custom exception for edge function errors
class EdgeFunctionException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  const EdgeFunctionException(this.message, this.statusCode, this.data);

  @override
  String toString() => 'EdgeFunctionException: $message (Status: $statusCode)';
}

// Response models
@freezed
class EmailResult with _$EmailResult {
  const factory EmailResult({
    required String messageId,
    required bool sent,
    String? error,
  }) = _EmailResult;

  factory EmailResult.fromJson(Map<String, dynamic> json) =>
      _$EmailResultFromJson(json);
}

@freezed
class AnalyticsData with _$AnalyticsData {
  const factory AnalyticsData({
    required Map<String, int> metrics,
    required DateTime generatedAt,
    @JsonKey(name: 'time_range') required DateRange timeRange,
  }) = _AnalyticsData;

  factory AnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataFromJson(json);
}

@freezed
class ProcessingResult with _$ProcessingResult {
  const factory ProcessingResult({
    required String jobId,
    required String status,
    Map<String, dynamic>? result,
    String? error,
    @JsonKey(name: 'processed_at') DateTime? processedAt,
  }) = _ProcessingResult;

  factory ProcessingResult.fromJson(Map<String, dynamic> json) =>
      _$ProcessingResultFromJson(json);
}

@freezed
class ProcessingUpdate with _$ProcessingUpdate {
  const factory ProcessingUpdate({
    required String jobId,
    required String status,
    @Default(0) int progress,
    String? message,
    Map<String, dynamic>? partialResult,
  }) = _ProcessingUpdate;

  const ProcessingUpdate._();

  factory ProcessingUpdate.fromJson(Map<String, dynamic> json) =>
      _$ProcessingUpdateFromJson(json);

  bool get isComplete => status == 'completed' || status == 'failed';
}
```

## Riverpod Integration

### Supabase Providers

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

// Supabase client provider
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}

// Auth state provider
@Riverpod(keepAlive: true)
Stream<AuthState> authState(AuthStateRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
}

// Current user provider
@Riverpod(keepAlive: true)
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
}

// Authentication service provider
@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
}
```

### Data Providers with Caching

```dart
// Todos provider with automatic refresh
@Riverpod()
Future<List<Todo>> todos(TodosRef ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return [];

  // Auto-refresh when auth state changes
  ref.watch(authStateProvider);
  
  final response = await client
      .from('todos')
      .select('*')
      .eq('user_id', user.id)
      .eq('is_deleted', false)
      .order('created_at', ascending: false);

  return (response as List).map((json) => Todo.fromJson(json)).toList();
}

// Realtime todos provider
@Riverpod()
Stream<List<Todo>> todosStream(TodosStreamRef ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return Stream.value([]);

  return client
      .from('todos')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .eq('is_deleted', false)
      .order('created_at', ascending: false)
      .map((data) => (data as List)
          .map((json) => Todo.fromJson(json))
          .toList());
}

// Filtered todos provider
@Riverpod()
Future<List<Todo>> filteredTodos(
  FilteredTodosRef ref, {
  bool? isComplete,
  String? searchQuery,
  TodoPriority? priority,
}) async {
  final allTodos = await ref.watch(todosProvider.future);
  
  return allTodos.where((todo) {
    if (isComplete != null && todo.isComplete != isComplete) return false;
    if (searchQuery != null && 
        !todo.title.toLowerCase().contains(searchQuery.toLowerCase())) {
      return false;
    }
    if (priority != null && todo.priority != priority) return false;
    return true;
  }).toList();
}

// Todo mutations provider
@Riverpod()
class TodoMutations extends _$TodoMutations {
  @override
  void build() {}

  Future<Todo> createTodo(String title) async {
    final client = ref.read(supabaseClientProvider);
    final user = ref.read(currentUserProvider);
    
    if (user == null) throw Exception('User not authenticated');

    final response = await client
        .from('todos')
        .insert({
          'title': title,
          'user_id': user.id,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final todo = Todo.fromJson(response);
    
    // Invalidate todos to trigger refresh
    ref.invalidate(todosProvider);
    
    return todo;
  }

  Future<Todo> updateTodo(String id, Map<String, dynamic> updates) async {
    final client = ref.read(supabaseClientProvider);
    
    final response = await client
        .from('todos')
        .update({
          ...updates,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    final todo = Todo.fromJson(response);
    
    // Invalidate todos to trigger refresh
    ref.invalidate(todosProvider);
    
    return todo;
  }

  Future<void> deleteTodo(String id) async {
    final client = ref.read(supabaseClientProvider);
    
    await client
        .from('todos')
        .update({
          'deleted_at': DateTime.now().toIso8601String(),
          'is_deleted': true,
        })
        .eq('id', id);

    // Invalidate todos to trigger refresh
    ref.invalidate(todosProvider);
  }
}
```

### Error Handling with Riverpod

```dart
// Error state provider
@Riverpod()
class ErrorState extends _$ErrorState {
  @override
  String? build() => null;

  void setError(String error) {
    state = error;
  }

  void clearError() {
    state = null;
  }
}

// Loading state provider
@Riverpod()
class LoadingState extends _$LoadingState {
  @override
  Set<String> build() => {};

  void setLoading(String key) {
    state = {...state, key};
  }

  void clearLoading(String key) {
    state = state.where((k) => k != key).toSet();
  }

  bool isLoading(String key) => state.contains(key);
}

// Enhanced todos provider with error handling
@Riverpod()
Future<List<Todo>> todosWithErrorHandling(TodosWithErrorHandlingRef ref) async {
  try {
    ref.read(loadingStateProvider.notifier).setLoading('todos');
    ref.read(errorStateProvider.notifier).clearError();
    
    final todos = await ref.watch(todosProvider.future);
    
    ref.read(loadingStateProvider.notifier).clearLoading('todos');
    return todos;
  } catch (error) {
    ref.read(loadingStateProvider.notifier).clearLoading('todos');
    ref.read(errorStateProvider.notifier).setError(error.toString());
    rethrow;
  }
}
```

## Performance Optimization

### Query Optimization

```dart
// Efficient pagination with Riverpod
@Riverpod()
class TodosPagination extends _$TodosPagination {
  @override
  Future<PaginatedTodos> build({
    int page = 0,
    int limit = 20,
  }) async {
    final client = ref.watch(supabaseClientProvider);
    final user = ref.watch(currentUserProvider);
    
    if (user == null) return const PaginatedTodos(todos: [], hasMore: false);

    final offset = page * limit;
    
    // Fetch one extra item to check if there are more
    final response = await client
        .from('todos')
        .select('*')
        .eq('user_id', user.id)
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit); // Fetch limit + 1

    final todos = (response as List)
        .take(limit) // Take only the requested amount
        .map((json) => Todo.fromJson(json))
        .toList();

    final hasMore = (response as List).length > limit;

    return PaginatedTodos(todos: todos, hasMore: hasMore);
  }

  Future<void> loadMore() async {
    final current = await future;
    if (!current.hasMore) return;

    final nextPage = await ref.read(todosPaginationProvider(
      page: (state.value?.todos.length ?? 0) ~/ 20 + 1,
    ).future);

    state = AsyncValue.data(PaginatedTodos(
      todos: [...current.todos, ...nextPage.todos],
      hasMore: nextPage.hasMore,
    ));
  }
}

@freezed
class PaginatedTodos with _$PaginatedTodos {
  const factory PaginatedTodos({
    required List<Todo> todos,
    required bool hasMore,
  }) = _PaginatedTodos;
}
```

### Caching Strategies

```dart
// Cache provider with TTL
@Riverpod()
class CacheManager extends _$CacheManager {
  @override
  Map<String, CacheEntry> build() => {};

  T? get<T>(String key) {
    final entry = state[key];
    if (entry == null) return null;
    
    if (DateTime.now().isAfter(entry.expiresAt)) {
      // Remove expired entry
      state = Map.from(state)..remove(key);
      return null;
    }
    
    return entry.value as T?;
  }

  void set<T>(String key, T value, {Duration ttl = const Duration(minutes: 5)}) {
    state = {
      ...state,
      key: CacheEntry(
        value: value,
        expiresAt: DateTime.now().add(ttl),
      ),
    };
  }

  void invalidate(String key) {
    state = Map.from(state)..remove(key);
  }

  void clear() {
    state = {};
  }
}

@freezed
class CacheEntry with _$CacheEntry {
  const factory CacheEntry({
    required dynamic value,
    required DateTime expiresAt,
  }) = _CacheEntry;
}

// Cached todos provider
@Riverpod()
Future<List<Todo>> cachedTodos(CachedTodosRef ref) async {
  final cache = ref.watch(cacheManagerProvider);
  const cacheKey = 'todos';
  
  // Try to get from cache first
  final cached = cache.get<List<Todo>>(cacheKey);
  if (cached != null) return cached;
  
  // Fetch from database
  final todos = await ref.watch(todosProvider.future);
  
  // Cache the result
  ref.read(cacheManagerProvider.notifier).set(cacheKey, todos);
  
  return todos;
}
```

### Connection Pooling and Optimization

```dart
// Optimized Supabase client configuration
@Riverpod(keepAlive: true)
SupabaseClient optimizedSupabaseClient(OptimizedSupabaseClientRef ref) {
  return SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_ANON_KEY']!,
    realtimeClientOptions: const RealtimeClientOptions(
      heartbeatIntervalMs: 25000, // Optimized heartbeat
      reconnectAfterMs: (tries) => [1000, 2000, 5000, 10000][tries - 1] ?? 10000,
      logger: (kind, msg, data) {
        // Custom logging for debugging
        if (kDebugMode) {
          print('Realtime [$kind]: $msg');
        }
      },
    ),
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      detectSessionInUri: true,
      persistSession: true,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 3,
    ),
    httpOptions: const HttpOptions(
      timeout: Duration(seconds: 30),
    ),
  );
}

// Batch operations for better performance
@Riverpod()
class BatchOperations extends _$BatchOperations {
  @override
  void build() {}

  Future<List<Todo>> createMultipleTodos(List<String> titles) async {
    final client = ref.read(supabaseClientProvider);
    final user = ref.read(currentUserProvider);
    
    if (user == null) throw Exception('User not authenticated');

    final inserts = titles.map((title) => {
      'title': title,
      'user_id': user.id,
      'created_at': DateTime.now().toIso8601String(),
    }).toList();

    final response = await client
        .from('todos')
        .insert(inserts)
        .select();

    final todos = (response as List)
        .map((json) => Todo.fromJson(json))
        .toList();

    // Invalidate cache
    ref.invalidate(todosProvider);
    
    return todos;
  }

  Future<void> batchUpdateTodos(Map<String, Map<String, dynamic>> updates) async {
    final client = ref.read(supabaseClientProvider);
    
    // Use RPC for batch updates
    await client.rpc('batch_update_todos', params: {
      'updates': updates,
      'user_id': ref.read(currentUserProvider)?.id,
    });

    // Invalidate cache
    ref.invalidate(todosProvider);
  }
}
```

## Error Handling

### Enhanced Error Handling

```dart
// Custom error types for better error handling
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);
  
  final String message;
  final String? code;
  
  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.code]);
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code]);
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

// Enhanced error handling service
class ErrorHandlingService {
  static AppException handleSupabaseError(dynamic error) {
    if (error is PostgrestException) {
      return _handlePostgrestError(error);
    } else if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is StorageException) {
      return _handleStorageError(error);
    } else if (error is SocketException) {
      return const NetworkException('No internet connection');
    } else if (error is TimeoutException) {
      return const NetworkException('Request timed out');
    } else {
      return AppException('Unexpected error: ${error.toString()}');
    }
  }

  static DatabaseException _handlePostgrestError(PostgrestException error) {
    switch (error.code) {
      case '23505': // Unique violation
        return const DatabaseException('This item already exists', '23505');
      case '23503': // Foreign key violation
        return const DatabaseException('Referenced item does not exist', '23503');
      case '42501': // Insufficient privilege
        return const DatabaseException('You do not have permission to perform this action', '42501');
      case 'PGRST116': // No rows found
        return const DatabaseException('Item not found', 'PGRST116');
      default:
        return DatabaseException(error.message, error.code);
    }
  }

  static AuthenticationException _handleAuthError(AuthException error) {
    switch (error.message) {
      case 'Invalid login credentials':
        return const AuthenticationException('Invalid email or password');
      case 'Email not confirmed':
        return const AuthenticationException('Please verify your email address');
      case 'User not found':
        return const AuthenticationException('No account found with this email');
      case 'Password should be at least 6 characters':
        return const AuthenticationException('Password must be at least 6 characters');
      case 'User already registered':
        return const AuthenticationException('An account with this email already exists');
      default:
        return AuthenticationException(error.message);
    }
  }

  static AppException _handleStorageError(StorageException error) {
    switch (error.statusCode) {
      case '404':
        return const AppException('File not found');
      case '413':
        return const AppException('File too large');
      case '415':
        return const AppException('File type not supported');
      default:
        return AppException('Storage error: ${error.message}');
    }
  }
}

// Error handling wrapper for async operations
Future<T> handleSupabaseOperation<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } catch (error) {
    throw ErrorHandlingService.handleSupabaseError(error);
  }
}

// Usage example with proper error handling
Future<Todo> createTodoSafely(String title) async {
  return await handleSupabaseOperation(() async {
    if (title.trim().isEmpty) {
      throw const ValidationException('Title cannot be empty');
    }
    
    if (title.length > 500) {
      throw const ValidationException('Title cannot exceed 500 characters');
    }

    final response = await supabase
        .from('todos')
        .insert({
          'title': title.trim(),
          'user_id': currentUserId!,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return Todo.fromJson(response);
  });
}

// Error handling in UI with Riverpod
@Riverpod()
class ErrorNotifier extends _$ErrorNotifier {
  @override
  String? build() => null;

  void handleError(dynamic error) {
    if (error is AppException) {
      state = error.message;
    } else {
      state = 'An unexpected error occurred';
    }
    
    // Auto-clear error after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) state = null;
    });
  }

  void clearError() {
    state = null;
  }
}

// Retry mechanism for failed operations
class RetryableOperation<T> {
  final Future<T> Function() operation;
  final int maxRetries;
  final Duration delay;
  final bool Function(dynamic error)? shouldRetry;

  const RetryableOperation({
    required this.operation,
    this.maxRetries = 3,
    this.delay = const Duration(seconds: 1),
    this.shouldRetry,
  });

  Future<T> execute() async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        if (attempts >= maxRetries) rethrow;
        
        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry!(error)) rethrow;
        
        // Don't retry auth errors or validation errors
        if (error is AuthenticationException || error is ValidationException) {
          rethrow;
        }
        
        // Exponential backoff
        final backoffDelay = Duration(
          milliseconds: delay.inMilliseconds * math.pow(2, attempts - 1).toInt(),
        );
        
        await Future.delayed(backoffDelay);
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}

// Usage example
Future<List<Todo>> getTodosWithRetry() async {
  final operation = RetryableOperation<List<Todo>>(
    operation: () => getTodos(),
    maxRetries: 3,
    shouldRetry: (error) => error is NetworkException || error is DatabaseException,
  );
  
  return await operation.execute();
}
```

## Testing

### Mock Supabase Client

```dart
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseAuth extends Mock implements GoTrueClient {}
class MockSupabaseStorage extends Mock implements SupabaseStorage {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockSupabaseAuth mockAuth;
  late MockSupabaseStorage mockStorage;
  
  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockSupabaseAuth();
    mockStorage = MockSupabaseStorage();
    
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockSupabase.storage).thenReturn(mockStorage);
  });
  
  test('sign in with email and password', () async {
    // Arrange
    when(() => mockAuth.signInWithPassword(
      email: 'test@example.com',
      password: 'password',
    )).thenAnswer((_) async => AuthResponse(
      session: Session(
        accessToken: 'access_token',
        tokenType: 'bearer',
        user: User(
          id: 'user1',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ),
    ));
    
    // Act
    final result = await mockSupabase.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'password',
    );
    
    // Assert
    expect(result.session?.user.id, 'user1');
  });
}
```

## Best Practices

### Security
1. **Always enable RLS** on your database tables
2. **Never expose service role keys** in client-side code
3. **Validate all user input** before sending to Supabase
4. **Use SSL** for all database connections
5. **Limit permissions** to the minimum required

### Performance Best Practices

1. **Optimize Queries**
   - Use `select()` to fetch only required columns
   - Implement proper pagination with `range()`
   - Use database indexes for frequently queried columns
   - Leverage RLS policies for automatic filtering

2. **Caching Strategies**
   - Implement client-side caching with TTL
   - Use Riverpod for automatic cache invalidation
   - Cache static data like user preferences
   - Implement offline-first patterns where appropriate

3. **Realtime Optimization**
   - Use realtime subscriptions sparingly
   - Implement proper connection management
   - Use heartbeat monitoring for connection health
   - Batch realtime updates to reduce UI thrashing

4. **Network Optimization**
   - Implement retry mechanisms with exponential backoff
   - Use connection pooling for multiple requests
   - Compress large payloads when possible
   - Implement request deduplication

5. **Storage Optimization**
   - Use image transformations for optimized delivery
   - Implement progressive image loading
   - Use signed URLs for secure access
   - Implement file compression before upload

### Architecture Best Practices

1. **Service Layer Architecture**
   - Abstract Supabase calls behind service interfaces
   - Use dependency injection with Riverpod
   - Implement repository pattern for data access
   - Separate business logic from data access

2. **Error Handling**
   - Implement comprehensive error handling
   - Use custom exception types for different error categories
   - Provide user-friendly error messages
   - Implement retry mechanisms for transient failures

3. **Security**
   - Always enable RLS on database tables
   - Never expose service role keys client-side
   - Validate all user input before database operations
   - Use HTTPS for all connections
   - Implement proper authentication flows

4. **Testing**
   - Mock Supabase clients for unit tests
   - Test RLS policies thoroughly
   - Implement integration tests for critical flows
   - Use golden tests for UI components

5. **Monitoring and Observability**
   - Monitor API usage and performance
   - Set up alerts for unusual activity
   - Log errors and performance metrics
   - Implement health checks for critical services

### Code Organization

1. **Project Structure**
   ```
   lib/
   ├── core/
   │   ├── supabase_client.dart
   │   ├── error_handling.dart
   │   └── constants.dart
   ├── models/
   │   ├── todo.dart
   │   └── user.dart
   ├── providers/
   │   ├── auth_providers.dart
   │   ├── todo_providers.dart
   │   └── cache_providers.dart
   ├── services/
   │   ├── auth_service.dart
   │   ├── todo_service.dart
   │   └── storage_service.dart
   └── ui/
       ├── screens/
       ├── widgets/
       └── themes/
   ```

2. **Naming Conventions**
   - Use descriptive names for providers and services
   - Follow Dart naming conventions consistently
   - Use enums for fixed sets of values
   - Document complex business logic

3. **Code Quality**
   - Follow the single responsibility principle
   - Keep functions small and focused
   - Use const constructors where possible
   - Implement proper null safety patterns

4. **Documentation**
   - Document public APIs thoroughly
   - Include usage examples in documentation
   - Maintain up-to-date README files
   - Document database schema and RLS policies

5. **Version Management**
   - Keep Supabase client libraries up to date
   - Test thoroughly before upgrading dependencies
   - Maintain compatibility with older app versions
   - Document breaking changes and migration paths
