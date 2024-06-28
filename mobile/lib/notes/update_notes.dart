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
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final NotesService _notesService = NotesService();
  String? accessToken;
  bool isValid = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccessToken();
    _getNoteById();
    nameController.addListener(_validateInputs);
    descriptionController.addListener(_validateInputs);
  }

  void _loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('accessToken') ?? '';
    });
  }

  void _validateInputs() {
    setState(() {
      isValid = nameController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty;
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

    setState(() {
      isLoading = false;
    });

    if (data != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GetNoteScreen(),
        ),
      );
      nameController.clear();
      descriptionController.clear();
    }
  }

  Future<void> _getNoteById() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final data = await _notesService.getNoteById(
        widget.noteId, prefs.getString('accessToken')!);
    if (data != null) {
      setState(() {
        nameController = TextEditingController(text: data['data']['name']);
        descriptionController =
            TextEditingController(text: data['data']['description']);
      });
    }
    _validateInputs();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Edit Note',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: TextField(
                    controller: nameController,
                    onChanged: (_) => _validateInputs(),
                    decoration: InputDecoration(
                      labelText: 'Note Name',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: TextField(
                    controller: descriptionController,
                    onChanged: (_) => _validateInputs(),
                    decoration: InputDecoration(
                      labelText: 'Note Description',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    maxLines: 5,
                  ),
                ),
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : isValid
                            ? () async {
                                _updateNote(
                                  nameController.text,
                                  descriptionController.text,
                                );
                              }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isValid ? Colors.blueAccent : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 36, vertical: 12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Save Changes',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
