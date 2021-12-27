import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:countdown_calendar/constants.dart' as constants;

class BackgroundScreen extends StatefulWidget {
  const BackgroundScreen({Key? key}) : super(key: key);

  @override
  _BackgroundScreenState createState() => _BackgroundScreenState();
}

class _BackgroundScreenState extends State<BackgroundScreen> {
  ImagePicker imagePicker = ImagePicker();
  List<String> images = [];
  List<FileSystemEntity> files = [];
  List<XFile> imageFileList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(constants.textTitleBackgroundScreen),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      backgroundColor: const Color(0xFF24282F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                _selectImgFromGallery();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Text(
                  constants.textBtnSelectImage,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<FileSystemEntity>>(
                future: _getImagesFromLocalStorage(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    final images = snapshot.data!;

                    return GridView.builder(
                      itemCount: images.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final imagePath = images[index].path;

                        return Stack(
                          children: [
                            Container(
                              height: 200,
                              width: 200,
                              padding: const EdgeInsets.all(16),
                              child: Image(
                                image: AssetImage(imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                            FutureBuilder(
                              future: _getCurrentBackground(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data ==
                                      imagePath.split('/').last) {
                                    return Center(
                                      child: Material(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(50),
                                        child: const SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: InkWell(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return Stack(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            _addImageToSF(imagePath);
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 20,
                                        right: 20,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: InkWell(
                                              onTap: () {
                                                _deleteImageFromSP(imagePath);
                                              },
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(50)),
                                              child: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get image from local storage
  Future<List<FileSystemEntity>> _getImagesFromLocalStorage() async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    files = Directory('$directory/')
        .listSync()
        .where((element) => element.path.contains('.jpg'))
        .toList();

    return files;
  }

  /// Save image to local storage
  _saveImageToLocalStorage(String filePath) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    final fileName = filePath.split('/').last;
    File file = await File('$directory/$fileName').create(recursive: true);
    ByteData byteData = await rootBundle.load(filePath);

    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  /// Delete image from local storage
  void _deleteImageFromSP(String name) async {
    await File(name).delete();
    setState(() {});
  }

  /// Add image to shared preferences as background
  _addImageToSF(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('background', name);
    setState(() {});
  }

  /// Get current backgroud from shared preferences
  Future<String> _getCurrentBackground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('background')?.split('/').last ?? '';
  }

  /// Select image from gallery
  Future<void> _selectImgFromGallery() async {
    final selectedImages = await imagePicker.pickMultiImage(
      maxHeight: 1000,
      maxWidth: 1000,
      imageQuality: 70,
    );

    if (selectedImages == null) return;

    imageFileList = selectedImages;
    for (var image in selectedImages) {
      _saveImageToLocalStorage(image.path);
    }

    setState(() {});
  }
}
