import 'package:flutter/material.dart';
import 'package:mobile/notes/create_notes.dart';
import 'package:mobile/notes/profile.dart';
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
      print('Error during request: $error');
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 1,
        title: const Text('Explore', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GetProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.grey[850],
                    title: const Text("Confirm Logout",
                        style: TextStyle(color: Colors.white)),
                    content: const Text("Are you sure you want to log out?",
                        style: TextStyle(color: Colors.white)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No',
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateNoteScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  child: Text(
                    'Create Note',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Notes',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateNoteScreen(
                                                  noteId: item['id']),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Edit',
                                      style:
                                          TextStyle(color: Colors.blueAccent),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.grey[850],
                                            title: const Text('Confirmation',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            content: const Text(
                                                'Are you sure you want to delete this note?',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  deleteNote(item['id']);
                                                },
                                                child: const Text('Delete',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.redAccent)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
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
