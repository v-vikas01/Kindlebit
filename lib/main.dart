import 'dart:convert';
import 'dart:io';

import 'package:assign/user%20list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';


import 'component/size_config.dart';

import 'package:http/http.dart' as http;
import 'dart:io' as io;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  final picker = ImagePicker();
  late File? _image;
  String uploadImage = '';

  imgFromCamera() async {
    final selectedImage = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 900);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
        uploadImage = selectedImage.name;
      });
    } else {
      print('No image selected.');
    }
  }

  ///Image Picker Function from Gallery

  imgFromGallery() async {
    final selectedImage = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 900);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
        uploadImage = selectedImage.name;
      });
    } else {
      print('No image selected.');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<String> convertToUrl(String filePath) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child('image').child(imageName);
      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error converting file to URL: $e');
      throw e;
    }
  }

  Future<String?> uploadImageAndGetUrl(File imageFile) async {
    try {
      // Create a reference to the Firebase Storage bucket
      var storage = FirebaseStorage.instance;

      // Create a reference to the location you want to upload to
      var ref = storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      var uploadTask = ref.putFile(imageFile);

      // Wait for the upload to complete and get the download URL
      var snapshot = await uploadTask;
      var downloadUrl = await snapshot.ref.getDownloadURL();
      print(downloadUrl);

      return downloadUrl.toString();
    } catch (e) {
      print('Error uploading image: $e');
      return null; // or throw an exception if you prefer
    }
  }


  Future<void> Register(String email, String name) async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child('driver_images/$imageName.jpg');
    UploadTask uploadTask = storageRef.putFile(_image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    print('Download URL: $downloadUrl');

    try {
      final _fireStore = FirebaseFirestore.instance;
      _fireStore.collection('todo').add({'name': name, 'email': email,"image":downloadUrl});
    } catch (e) {
      print('error$e');
    }
  }



  Future<String> uploadImageConvert(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child('images').child(imageName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }


  void _submitForm() {
    String name = _nameController.text;
    String email = _emailController.text;
    Register(email, name);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      showImagePicker(context, imgFromGallery, imgFromCamera);
                    },
                    child: Container(
                      margin: EdgeInsets.all(SizeConfig.blockWidth*10),
                      child: uploadImage.isEmpty
                          ? Container(
                        height: SizeConfig.blockHeight * 30,
                        width: SizeConfig.screenWidth,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(SizeConfig.blockWidth*3)
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 1.5),
                        child: Icon(Icons.image),
                      )
                          : Container(
                        height: SizeConfig.blockHeight * 40,
                        width: SizeConfig.screenWidth,
                        color:Colors.white,
                        padding:
                        EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 1.5),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*5),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(label: Text("Name")),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*5),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(label: Text("Email")),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(onPressed: _submitForm, child: Text("save")),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _nameController.clear();
                      _emailController.clear();
                      setState(() {
                        _image = File('');
                        uploadImage= "";
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserList()),
                      );
                    },
                    child: Text('View User'),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


void showImagePicker(BuildContext context, VoidCallback imgFromGallery, VoidCallback imgFromCamera) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                  leading:  const Icon(Icons.photo_library),
                  title:  const Text('Gallery'),
                  onTap: () {
                    imgFromGallery();
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading:  const Icon(Icons.photo_camera),
                title:  const Text('Camera'),
                onTap: () {
                  imgFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      });
}