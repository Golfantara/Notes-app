import 'package:flutter/material.dart';
import 'package:mobile/notes/get_notes.dart';
import 'package:mobile/services/services_notes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  _CreateNoteScreenState createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
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

  void _createNote() async {
    if (!isValid || accessToken == null) return;

    setState(() {
      isLoading = true;
    });

    final data = await _notesService.createNotes(
      nameController.text,
      descriptionController.text,
      accessToken!,
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

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Buat Catatan', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isValid ? _createNote : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isValid ? Colors.black : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
