import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getSErverKey() async {
    final scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
          {
            "type": "service_account",
            "project_id": "payment-app-ad94a",
            "private_key_id": "6e00f77b6aaf9e1f916977d947f2bd3f77f105d2",
            "private_key":
                "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCevAqHbw7hoJuo\n0bAqJ93U9DgZS5xP5Kb3MjFbcjiMMX6N/hb0d0eUfqgp6YME8z37CGbho3njQ/0r\nCXOPfId2/VVYHF/W8FF13bHhTAkIunwbA2xHN0PNN9ebSB/flexwWoOWBygDETEq\n6aIGnZ6H7qPtJDgpLc5UOK0ocdBdNjclDXWmzgWafvyfzC8GRD3t6pVaoZlVNXtO\n8zp+xDAfU8WfP+UBthed5yf/MHA0iaWzpD8bEtW9UcCqMnuLpkHdqm/cRNTMu+MQ\n37W3GZELJ9Uvj3+PD1bblXMugWam9dkpDwfNO1bmJjryIZnUfIRI/RJFWKboHQwR\nbum5n0HZAgMBAAECggEAIe0AtxeGb7S68Cb45tmkcNpNjyJ44x50jQq+P9Q2v8fo\nS4LN9yvzMYqseGC/LvSp/5g5HOqqp2clmegoObec4FKexfkyhqbQUkeyt/tfRu1M\njx15K/Nk21yfCUIuBcRuR0khLJSU+arX/lr21UEk29qmUI3YLvzqR1fhsm444WLZ\nx9tBORSNDW6ZADSNvEVxylABqM1onFdXFOGItM8lp2qIUkCYv/RtZcQnpMa3j63R\nGpb+hjF8o3A5JTW6O6XKke5ll4Qeg/ZqZqwTei/XSW6MW2sUmfw82idEyOOX5wIw\ni2lBYxwCf5JqEpz+mYf0gplj6mAn4T9j4h0u5LncLQKBgQDQsvWFzsmSrmDAP0VP\nGOT4WcHavvgtyc5gg45Qf1K+jyCgfYWQrT800ey53SRWyeFdQv/G0+uDTDj9ssHD\nwu1uSIV0evJgFSP6/tsZpZZ+1R0ZfzitX12uY6YM8Hzd8jU9wtsJz2XJt4LL4+KA\nlWWmB8xoNNi6gqMh+AYevN4qrwKBgQDCthA9sicGmO31ocz3anQpKcGvpUYnB708\nBGyUWPbosq8suHAgYLmIvpuj8MRbiLclUsIqzNQJ6/RTYVGfETmGsrdw3RP8a1OV\nAHIMC093u4TOZ5cizZaX68nE4B/Aa5ua6b5Gwx9gtGNTec2K2BKJL3IDDrBjY0cx\nzqza0QXd9wKBgCrIdRKwOJxsSQNANToo1U+gPuBUA9aHJ1qbvYH9B/5uovajpMzq\n5ykx28Cid/+etSeEQ6ED8qTg7FH94kD6ZegUz974EVXnH5AlzM6uJnLrx2JhtUG9\nahwE65Z9emuZapa1qmeRb8FxcEvR9K39cnAd6yZ1pvRdMYoWKVMFztmbAoGATUIY\nZ6KMwZ1krhYpUfK3bK3Y4GzfzRTRDUNkIei679IWl9QHCZHXjF61OvOJthglM3YG\n/RyQ9e7d30e6LzeSb9Px3aKbD4k2fOTUW9sRCR0qsQuBeJnCqz0vriKP9rW75Ffi\n3AkIJkLtNm4aFIFvuWdOAdCORKFb2nN7Ose9YDkCgYAKv3rk23hrBH5VUPoaVKEo\nDp3lroZ8Jj/J+3+Xm11hkGPOQ6B8CEMblH7EADC6n6Wbw2UDdVD0v5CPb/RXG7R6\nmKhZiVeTh4+KjZ8DfwDanFZCF1f6UwnMXsSbizaJzre4ArQP4R7X5JPa5T37aByJ\nZVELL+GVc037TmVcZt9J3w==\n-----END PRIVATE KEY-----\n",
            "client_email":
                "firebase-adminsdk-fbsvc@payment-app-ad94a.iam.gserviceaccount.com",
            "client_id": "100869667755327340729",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url":
                "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url":
                "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40payment-app-ad94a.iam.gserviceaccount.com",
            "universe_domain": "googleapis.com"
          },
        ),
        scopes);

    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
