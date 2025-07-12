import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appwrite_service.g.dart';

class AppwriteService {
  late final Client _client;
  late final Account _account;
  late final Databases _databases;
  late final Storage _storage;

  //getters
  Account get account => _account;
  Databases get databases => _databases;
  Storage get storage => _storage;

  // Configuration
  late final String projectId;
  late final String endpoint;
  late final String databaseId;
  late final String collectionId;

  void getConfig() {
    projectId = dotenv.get('PROJECT_ID');
    endpoint = dotenv.get('ENDPOINT');
    databaseId = dotenv.get('DATABASE_ID');
    collectionId = dotenv.get('COLLECTION_ID');
  }

  void init() {
    getConfig();

    _client = Client().setEndpoint(endpoint).setProject(projectId);
    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
  }

  AppwriteService() {
    init();
  }
}

@Riverpod(keepAlive: true)
AppwriteService appwriteService(Ref ref) {
  return AppwriteService();
}
