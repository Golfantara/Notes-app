import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/notes/get_notes.dart';
import 'package:mobile/services/services_notes.dart';

class UpdateNoteScreen extends StatefulWidget {
  final int noteId;

  const UpdateNoteScreen({super.key, required this.noteId});

  @override
  _UpdateNoteScreenState createState() => _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  final NotesService _notesService = NotesService();
  String? accessToken;
  bool isValid = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccessToken();
    _getNoteById();
  }

  void _loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('accessToken') ?? '';
    });
  }

  void _validateInputs() {
    setState(() {
      isValid = name.text.isNotEmpty && description.text.isNotEmpty;
    });
  }

  void _updateNote(
    String name,
    String description,
  ) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = FormData();

    formData.fields.add(MapEntry('name', name));
    formData.fields.add(MapEntry('description', description));

    final data = await _notesService.updateNote(
      widget.noteId,
      formData,
      prefs.getString('accessToken')!,
    );

    if (data != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GetNoteScreen(),
        ),
      );

      setState(() {
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getNoteById() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final data = await _notesService.getNoteById(
        widget.noteId, prefs.getString('accessToken')!);
    if (data != null) {
      setState(() {
        name = TextEditingController(text: data['data']['name']);
        description = TextEditingController(text: data['data']['description']);
      });
    }
    _validateInputs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Notes', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: TextField(
                  controller: name,
                  onChanged: (_) => _validateInputs(),
                  decoration: const InputDecoration(
                    labelText: 'Masukan nama catatan',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: TextField(
                  controller: description,
                  onChanged: (_) => _validateInputs(),
                  decoration: const InputDecoration(
                    labelText: 'Masukan deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : isValid
                          ? () async {
                              _updateNote(
                                name.text,
                                description.text,
                              );
                            }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 36, vertical: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ))
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Simpan perubahan data',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}
