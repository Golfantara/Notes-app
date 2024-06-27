import 'package:dio/dio.dart';
import 'package:mobile/model/model_signup.dart';
import '../utils/utils.dart';

class SignUpService {
  final Dio _dio = Dio();

  Future<ModelSignUp?> signUpAccount(
      String nameUser, String fullnameUser, String passwordUser) async {
    try {
      final response = await _dio.post(
        Urls.baseUrl + Urls.signUp,
        data: {
          'username': nameUser,
          'fullname': fullnameUser,
          'password': passwordUser,
        },
      );
      final Map<String, dynamic> jsonData = response.data;
      final ModelSignUp modelSignUp = modelSignUpFromJson(jsonData);
      return modelSignUp;
    } catch (error) {
      print('Terjadi kesalahan saat melakukan permintaan: $error');
      return null;
    }
  }
}
