import 'dart:convert';

ModelSignUp modelSignUpFromJson(Map<String, dynamic> str) =>
    ModelSignUp.fromJson(str);

String modelSignUpToJson(ModelSignUp data) => json.encode(data.toJson());

class ModelSignUp {
  Data data;
  String message;

  ModelSignUp({
    required this.data,
    required this.message,
  });

  factory ModelSignUp.fromJson(Map<String, dynamic> json) => ModelSignUp(
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "message": message,
      };
}

class Data {
  int id;
  int roleId;
  String username;
  String fullname;
  String password;

  Data({
    required this.id,
    required this.roleId,
    required this.username,
    required this.fullname,
    required this.password,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        roleId: json["role_id"],
        username: json["username"],
        fullname: json["fullname"] ?? "",
        password: json["password"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "role_id": roleId,
        "username": fullname,
        "fullname": fullname,
        "password": password,
      };
}
