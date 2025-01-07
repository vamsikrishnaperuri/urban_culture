import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class RoutineScreen extends StatefulWidget {
  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<Map<String, dynamic>> routineItems = [
    {'title': 'Cleanser', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
    {'title': 'Toner', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
    {'title': 'Moisturizer', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
    {'title': 'Sunscreen', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
    {'title': 'Lip Balm', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutineItems();
  }

  Future<void> _loadRoutineItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('routineItems');
    if (savedData != null) {
      setState(() {
        routineItems = List<Map<String, dynamic>>.from(json.decode(savedData));
      });
    }
  }

  Future<void> _saveRoutineItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('routineItems', json.encode(routineItems));
  }

  Future<void> uploadImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      TextEditingController nameController = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Name for ${routineItems[index]['title']}'),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Enter product name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      String productName = nameController.text.trim();
      if (productName.isEmpty) return;

      setState(() {
        routineItems[index]['uploaded'] = true;
        routineItems[index]['imageUrl'] = file.path;
        routineItems[index]['time'] = DateTime.now().toString();
        routineItems[index]['subtitle'] = productName;
      });

      // Save updated data
      await _saveRoutineItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Save data when navigating back
        await _saveRoutineItems();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daily Skincare'),
          centerTitle: true,
          backgroundColor: Colors.pink[50],
          elevation: 0,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: routineItems.length,
          itemBuilder: (context, index) {
            final item = routineItems[index];
            return Card(
              color: item['uploaded'] ? Colors.pink[50] : Colors.white,
              child: ListTile(
                leading: item['imageUrl']!.isNotEmpty && File(item['imageUrl']).existsSync()
                    ? Image.file(
                  File(item['imageUrl']),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['subtitle']!.isNotEmpty ? item['subtitle']! : 'Tap to add details'),
                    if (item['time']!.isNotEmpty)
                      Text(
                        'Uploaded: ${item['time']!}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                onTap: () {
                  if (item['imageUrl']!.isNotEmpty && File(item['imageUrl']).existsSync()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImagePreviewScreen(imageUrl: item['imageUrl']),
                      ),
                    );
                  } else {
                    uploadImage(index);
                  }
                },
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Routine'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Streaks'),
          ],
          onTap: (index) async {
            if (index == 1) {
              await Navigator.pushNamed(context, '/streaks');
            } else if (index == 0) {
              // Reload routine items when revisiting
              await _loadRoutineItems();
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Preview')),
      body: Center(
        child: Image.file(File(imageUrl)),
      ),
    );
  }
}
