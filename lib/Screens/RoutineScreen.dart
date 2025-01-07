import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RoutineScreen extends StatefulWidget {
  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final List<Map<String, dynamic>> routineItems = [
    {'title': 'Cleanser', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
    {'title': 'Toner', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
    {'title': 'Moisturizer', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
    {'title': 'Sunscreen', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
    {'title': 'Lip Balm', 'subtitle': '', 'time': '', 'uploaded': false, 'imageUrl': ''},
  ];

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

      // Update local state to simulate saving to a local database
      setState(() {
        routineItems[index]['uploaded'] = true;
        routineItems[index]['imageUrl'] = file.path;
        routineItems[index]['time'] = DateTime.now().toString();
        routineItems[index]['subtitle'] = productName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: ListTile(
              leading: Icon(
                item['uploaded'] ? Icons.check_circle : Icons.radio_button_unchecked,
                color: Colors.pink,
              ),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['subtitle']!.isNotEmpty ? item['subtitle']! : 'Tap to add details'),
              trailing: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.grey),
                onPressed: () => uploadImage(index),
              ),
              onLongPress: () {
                if (item['imageUrl']!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewScreen(imageUrl: item['imageUrl']),
                    ),
                  );
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
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/streaks');
          }
        },
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
