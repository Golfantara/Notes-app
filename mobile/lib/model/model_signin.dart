import 'dart:convert';

ModelSignIn modelSignInFromJson(Map<String, dynamic> str) =>
    ModelSignIn.fromJson((str));

String modelSignInToJson(ModelSignIn data) => json.encode(data.toJson());

class ModelSignIn {
  Data data;
  String message;

  ModelSignIn({
    required this.data,
    required this.message,
  });

  factory ModelSignIn.fromJson(Map<String, dynamic> json) => ModelSignIn(
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "message": message,
      };
}

class Data {
  String username;
  String fullname;
  int roleId;
  String accessToken;

  Data({
    required this.username,
    required this.fullname,
    required this.roleId,
    required this.accessToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        fullname: json["fullname"],
        username: json["username"],
        roleId: json["role_id"],
        accessToken: json["access_token"],
      );

  Map<String, dynamic> toJson() => {
        "fullname": fullname,
        "email": username,
        "role_id": roleId,
        "access_token": accessToken,
      };
}
