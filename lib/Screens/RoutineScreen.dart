import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

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

  final String cloudinaryUploadUrl =
      'https://api.cloudinary.com/v1_1/df6o3ijio/image/upload'; // Replace YOUR_CLOUD_NAME
  final String cloudinaryUploadPreset = 'newurban'; // Replace YOUR_UPLOAD_PRESET

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

  Future<String?> uploadToCloudinary(File file) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUploadUrl));
      request.fields['upload_preset'] = cloudinaryUploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(responseBody);
        return decodedResponse['secure_url']; // Cloudinary image URL
      } else {
        // print('Cloudinary upload failed: ${response.statusCode}');
        // print('Response body: $responseBody');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
    }
    return null;
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
              decoration: const InputDecoration(hintText: 'Enter product name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      String productName = nameController.text.trim();
      if (productName.isEmpty) return;

      String? imageUrl = await uploadToCloudinary(file);
      if (imageUrl == null) return;

      setState(() {
        routineItems[index]['uploaded'] = true;
        routineItems[index]['imageUrl'] = imageUrl;
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
                leading: item['imageUrl']!.isNotEmpty
                    ? Image.network(
                  item['imageUrl'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['subtitle']!.isNotEmpty ? item['subtitle']! : 'Tap to add details'),
                    if (item['time']!.isNotEmpty)
                      Text(
                        'Uploaded: ${item['time']!}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                trailing: item['uploaded']
                    ? IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.blue),
                  onPressed: () => uploadImage(index), // Upload new image
                )
                    : null,
                onTap: () {
                  if (item['imageUrl']!.isNotEmpty) {
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
        child: Image.network(imageUrl),
      ),
    );
  }
}
