import 'package:appwrite/appwrite.dart';

// Ganti dengan Project ID Anda
        const String appwriteProjectId = '683ed1c70006a0371c78'; 
        // Ganti dengan API Endpoint Anda
        const String appwriteEndpoint = 'http://192.168.143.42/v1'; 

        class AppwriteService {
          static final AppwriteService _instance = AppwriteService._internal();
          factory AppwriteService() => _instance;
          AppwriteService._internal() {
            _client = Client()
              .setEndpoint(appwriteEndpoint)
              .setProject(appwriteProjectId)
              // Untuk development dengan self-hosted Appwrite HTTP (bukan HTTPS)
              // atau jika SSL self-signed. Untuk production HTTPS, ini harus false.
              .setSelfSigned(status: true); 
            account = Account(_client);
            databases = Databases(_client);
            storage = Storage(_client);
            // teams = Teams(_client); // Jika perlu
            // functions = Functions(_client); // Jika perlu
          }

          late final Client _client;
          late final Account account;
          late final Databases databases;
          late final Storage storage;
          // late final Teams teams;
          // late final Functions functions;
        }