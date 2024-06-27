import 'package:dio/dio.dart';
import 'package:mobile/utils/utils.dart';

class NotesService {
  final Dio _dio = Dio();

  Future createNotes(String name, String description, String accesToken) async {
    try {
      FormData formData =
          FormData.fromMap({'name': name, 'description': description});
      final response = await _dio.post(
        Urls.baseUrl + Urls.notes,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $accesToken'}),
      );
      return response.data;
    } catch (error) {
      print('Terjadi kesalahan saat melakukan permintaan: $error');
      return null;
    }
  }

  Future getNoteById(dynamic id, String accessToken) async {
    try {
      final response = await _dio.get(
        '${Urls.baseUrl}${Urls.notes}/$id',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (error) {
      print('Terjadi kesalahan saat melakukan permintaan: $error');
      return null;
    }
  }

  Future updateNote(dynamic id, FormData formData, String? accessToken) async {
    try {
      final response = await _dio.put(
        '${Urls.baseUrl}${Urls.notes}/$id',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (error) {
      print('Terjadi kesalahan saat melakukan permintaan: $error');
      return null;
    }
  }

  Future deleteNote(dynamic id, String accessToken) async {
    try {
      await _dio.delete(
        '${Urls.baseUrl}${Urls.notes}/$id',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } catch (error) {
      print('Terjadi kesalahan saat melakukan permintaan: $error');
    }
  }
}
