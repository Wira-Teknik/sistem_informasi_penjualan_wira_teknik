import 'dart:convert';

class JwtUtils {
  JwtUtils._();

  // Decode payload JWT tanpa verifikasi signature
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Base64 padding
      var payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Cek apakah token sudah expired
  static bool isExpired(String token) {
    final payload = decodePayload(token);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return false; // tidak ada exp = tidak expired

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiry);
  }

  // Sisa waktu token
  static Duration? remainingTime(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    final exp = payload['exp'];
    if (exp == null) return null;

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
