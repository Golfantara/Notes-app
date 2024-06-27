// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:mobile/model/model_signin.dart';
import '../utils/utils.dart';

class SignInService {
  final Dio _dio = Dio();

  Future<ModelSignIn?> signInAccount({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        Urls.baseUrl + Urls.signIn,
        data: {
          'username': username,
          'password': password,
        },
      );

      final Map<String, dynamic> jsonData = response.data;
      final ModelSignIn modelSignIn = modelSignInFromJson(jsonData);
      return modelSignIn;
    } catch (error) {
      print('Terjadi kesalahan saat melakukan permintaan: $error');
      return null;
    }
  }
}
