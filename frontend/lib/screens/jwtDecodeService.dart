import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Retrieve and decode JWT token
  Future<Map<String, dynamic>?> getDecodedToken() async {
    String? token = await storage.read(key: "jwt_token");
    if (token != null && !JwtDecoder.isExpired(token)) {
      return JwtDecoder.decode(token); // Decode JWT
    }
    return null; // Return null if token is expired or not found
  }

  // Retrieve user ID from token
  Future<int?> getUserID() async {
    Map<String, dynamic>? decodedToken = await getDecodedToken();
    return decodedToken?['id']; // Extract user ID
  }

  // Check if user is logged in (valid JWT exists)
  Future<bool> isLoggedIn() async {
    String? token = await storage.read(key: "jwt_token");
    return token != null && !JwtDecoder.isExpired(token);
  }

  // Logout user by deleting the token
  Future<void> logout() async {
    await storage.delete(key: "jwt_token");
  }
}
