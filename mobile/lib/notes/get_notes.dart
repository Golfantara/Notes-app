import 'package:flutter/material.dart';
import 'package:mobile/notes/create_notes.dart';
import 'package:mobile/notes/update_notes.dart';
import 'package:mobile/services/services_get_profile.dart';
import 'package:mobile/services/services_notes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class GetNoteScreen extends StatefulWidget {
  const GetNoteScreen({super.key});

  @override
  _GetNoteScreenState createState() => _GetNoteScreenState();
}

class _GetNoteScreenState extends State<GetNoteScreen> {
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  final NotesService _notesService = NotesService();
  final ProfileService _profileService = ProfileService();

  String? accessToken;
  String? profile;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    _loadAccessToken();
  }

  void _loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('accessToken') ?? '';
    });

    // Fetch profile only if accessToken is available
    if (accessToken != null && accessToken!.isNotEmpty) {
      _fetchProfile(accessToken!);
    }
  }

  void deleteNote(dynamic id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await _notesService.deleteNote(id, prefs.getString('accessToken')!);
      _pagingController.refresh();
    } catch (error) {
      print('Terjadi kesalahan saat melakukan permintaan: $error');
    }
  }

  Future<void> _fetchProfile(String accessToken) async {
    final data = await _profileService.getProfile(accessToken);

    if (data != null) {
      setState(() {
        profile = data['data']['fullname'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Catatan, $profile!', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Center(
            heightFactor: 2,
            child: FractionallySizedBox(
              widthFactor: 0.75,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateNoteScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  child: Text(
                    'Buat Catatan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const FractionallySizedBox(
            widthFactor: 0.75,
            child: Text('Daftar Catatan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 67, 57, 57))),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() => _pagingController.refresh()),
              child: PagedListView<int, dynamic>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<dynamic>(
                  itemBuilder: (context, item, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: FractionallySizedBox(
                        widthFactor: 0.75,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text('Nama'),
                                        const SizedBox(width: 75),
                                        const Text(':'),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            item['name'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(children: [
                                      const Text('Deskripsi'),
                                      const SizedBox(width: 63),
                                      const Text(':'),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Text(
                                        item['description'],
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                    ]),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              FractionallySizedBox(
                                widthFactor: 0.8,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => UpdateNoteScreen(
                                          noteId: item['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 12),
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              FractionallySizedBox(
                                widthFactor: 0.8,
                                child: OutlinedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Konfirmasi'),
                                          content: const Text(
                                              'Apakah Anda yakin ingin menghapus catatan ini?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                deleteNote(item['id']);
                                              },
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: BorderSide(
                                        color: Colors.redAccent[400]!),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 36, vertical: 12),
                                    child: Text(
                                      'Hapus',
                                      style: TextStyle(
                                          color: Colors.redAccent[400]),
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
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final dio = Dio();
      final url = 'http://localhost:8000/notes?page=$pageKey&size=5';
      final response = await dio.get(url,
          options: Options(headers: {
            'Authorization': 'Bearer ${prefs.getString('accessToken')}'
          }));
      final List<dynamic> data = response.data['data'];
      final isLastPage = data.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage(data);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(data, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
      if (error is DioException && error.response?.statusCode == 404) {
        _pagingController.appendLastPage([]);
      }
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
