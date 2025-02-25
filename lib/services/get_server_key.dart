import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getSErverKey() async {
    final String credentialsJson =
        await rootBundle.loadString('/assets/firebase_service_key.json');

    final credentials = ServiceAccountCredentials.fromJson(
      jsonDecode(credentialsJson),
    );

    final scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final client = await clientViaServiceAccount(credentials, scopes);

    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
