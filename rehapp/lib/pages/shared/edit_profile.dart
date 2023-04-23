import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:rehapp/ProgressHUD.dart';
import 'package:rehapp/api/api_service.dart';
import 'package:rehapp/model/users/user.dart';
import 'package:rehapp/model/users/user_request.dart';

class EditProfilePage extends StatefulWidget {
  final RehappUser user;
  const EditProfilePage({Key? key, required this.user}) : super(key: key);
  @override State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  GlobalKey<NavigatorState> editProfileNavigatorKey = GlobalKey<NavigatorState>();
  bool isApiCallProcess = false;
  APIService apiService = APIService();
  RehappUserRequest userRequest = RehappUserRequest();
  TextEditingController emailController = TextEditingController();

  File? selectedImage;
  CroppedFile? profileImage;

  Future<void> selectImage(ImageSource src) async {
    final image = await ImagePicker().pickImage(source: src);
    if (image == null) throw Exception("Please select a valid image");
    final imageTemp = File(image.path);
    setState(() => selectedImage = imageTemp);
  }

  Future<void> cropImage() async {
    if (selectedImage != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: selectedImage!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 30,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        cropStyle: CropStyle.circle,
        uiSettings: [
          IOSUiSettings(
            aspectRatioLockEnabled: true,
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort: const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) setState(() => profileImage = croppedFile);
    }
  }

  Future<void> uploadImage() async {
    Reference storageRef = FirebaseStorage.instance.ref();
    final ref = storageRef.child("profileImages/${widget.user.id}");
    TaskSnapshot snapshot = await ref.putFile(File(profileImage!.path).absolute);
    userRequest.profileImage = await snapshot.ref.getDownloadURL();
  }

  @override
  void initState() {
    emailController.text = widget.user.email;
    userRequest = widget.user.toRehappUserRequest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _displayImageSelectDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          titlePadding: EdgeInsets.zero,
          title: Stack(
            children: <Widget>[
              IconButton(
                onPressed: () => Navigator.pop(context),
                splashRadius: 20,
                icon: const Icon(Icons.close, size: 20)
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: const Text(
                  "Add Profile Picture",
                  textAlign: TextAlign.center,
                ),
              ),
            ]
          ),
          alignment: Alignment.center,
          contentPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: Container(
            height: 180,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextButton(
                    child: Column(
                      children: <Widget>[
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 80,
                          color: Colors.black,
                        ),
                        Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: const Text(
                            'Select from\nGallery',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      try {
                        await selectImage(ImageSource.gallery);
                        await cropImage().then((_) => Navigator.pop(context));
                      } on PlatformException catch(_) {
                        SnackBar snackBar = const SnackBar(content: Text("Error selecting an image"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                  TextButton(
                    child: Column(
                      children: <Widget>[
                        const Icon(
                          Icons.add_a_photo_outlined,
                          size: 80,
                          color: Colors.black,
                        ),
                        Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: const Text(
                            'Take a Photo',
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    ),
                    onPressed: () async {
                      try {
                        await selectImage(ImageSource.camera);
                        await cropImage().then((_) => Navigator.pop(context));
                      } on PlatformException catch(_) {
                        SnackBar snackBar = const SnackBar(content: Text("Error selecting an image"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                ]
              ),
            )
          )
        );
      }
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: globalFormKey,
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 60),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Text(
                        '${widget.user.firstName} ${widget.user.lastName}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        )
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color.fromARGB(188, 185, 185, 185),
                            child: (profileImage != null) ? ClipRRect(
                              borderRadius: BorderRadius.circular(115),
                              child: Image.file(
                                File(profileImage!.path),
                                width: 115,
                                height: 115,
                                fit: BoxFit.fill,
                              ),
                            ) : (widget.user.profileImage != null && widget.user.profileImage!.isNotEmpty) ? ClipRRect(
                              borderRadius: BorderRadius.circular(115),
                              child: Image.network(
                                widget.user.profileImage!,
                                width: 115,
                                height: 115,
                                fit: BoxFit.fill,
                              ),
                            ) : const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 57.5,
                              child: Icon(
                                Icons.person,
                                color: Color.fromRGBO(100, 181, 246, 1),
                                size: 85,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 85, left: 85),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color.fromARGB(188, 185, 185, 185),
                              child: CircleAvatar(
                                radius: 17.5,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  onPressed: () => _displayImageSelectDialog(context),
                                  icon: (profileImage != null || widget.user.profileImage != null && widget.user.profileImage!.isNotEmpty) ? const Icon(Icons.edit, size: 17.5,) : const Icon(Icons.add, size: 17.5,),
                                  splashRadius: 17.5,
                                )
                              )
                            )
                          )
                        ]
                      )
                    ),
                  ]
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10),
                  Container(
                    width: 150,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: TextFormField(
                      initialValue: widget.user.firstName,
                      validator: (input) => input!.isNotEmpty ? null : "First name cannot be empty",
                      onSaved: (input) => userRequest.firstName = input!,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        labelText: "First Name",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2)
                            ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 150,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: TextFormField(
                      initialValue: widget.user.lastName,
                      validator: (input) => input!.isNotEmpty ? null : "Last name cannot be empty",
                      onSaved: (input) => userRequest.lastName = input!,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2)
                            ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ]
              ),
              Container(
                width: 330,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: emailController,
                  readOnly: true,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(
                      color: Colors.grey
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2)
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2)
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(189, 189, 189, 1)
                  ),
                ),
              ),
              Container(
                width: 330,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: widget.user.phoneNumber,
                  validator: (input) => input!.isNotEmpty && input.length != 14 ? "Please input a valid phone number" : null,
                  onSaved: (input) => userRequest.phoneNumber = input!,
                  inputFormatters: [
                    MaskedInputFormatter('(###) ###-####', allowedCharMatcher: RegExp(r'[0-9.,]+'))
                  ],
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "(123) 456-7890",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2)
                        ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.all(15),
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() => isApiCallProcess = true);
                        if (validateAndSave()) {
                          if (profileImage != null) await uploadImage();
                          await apiService.updateUser(userRequest)
                            .then((_) {
                              setState(() => isApiCallProcess = true);
                              Navigator.pop(context);
                            });
                        }
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.all(15),
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ]
              )
            ]
          )
        )
      )
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    setState(() => isApiCallProcess = false);
    return false;
  }
}
