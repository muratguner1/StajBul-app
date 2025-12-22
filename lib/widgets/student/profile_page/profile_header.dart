import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/repositories/student_profile_repository.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';

class ProfileHeader extends StatefulWidget {
  final String? currentProfileUrl;
  final String? school;
  const ProfileHeader(
      {super.key, required this.currentProfileUrl, this.school});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  File? _selectedImage;
  bool _isLoading = false;

  String? _defaultPhotoUrl;
  String? _fullName;
  String? _university;
  bool _isLoadingUserInfo = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StudentProfileRepository _repository = StudentProfileRepository();

  @override
  void initState() {
    super.initState();
    _fetchDefaultPhotoUrl();
    _fetchUserInfo();
  }

  Future<void> _fetchDefaultPhotoUrl() async {
    try {
      final url = await _repository.getDefaultPhotoUrl();
      if (url != null) {
        setState(() {
          _defaultPhotoUrl = url;
        });
      }
    } catch (e) {
      print("Varsayılan fotoğraf çekilemedi: $e");
    }
  }

  Future<void> _fetchUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoadingUserInfo = false;
      });
      return;
    }

    try {
      final doc = await _repository.getStudentProfile(user.uid);
      if (doc != null && doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _fullName = data[FirestoreFields.fullName] ?? '-';
          _university = data[FirestoreFields.university] ?? '-';
          _isLoadingUserInfo = false;
        });
      } else {
        setState(() {
          _isLoadingUserInfo = false;
        });
      }
    } catch (e) {
      print('Kullanıcı bilgileri çekilemedi: $e');
      setState(() {
        _isLoadingUserInfo = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isLoading = true;
      });

      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _repository.uploadProfileImage(user.uid, File(image.path));
          AwesomeSnackBar.show(context,
              title: 'Başarılı',
              message: 'Profil fotoğrafı güncellendi!',
              contentType: ContentType.success);
        }
      } catch (e) {
        AwesomeSnackBar.show(context,
            title: 'Başarısız!',
            message: 'Profil fotoğrafı güncellenemedi!',
            contentType: ContentType.failure);

        print('Hata: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removePhoto() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _repository.deleteProfileImage(user.uid);

      setState(() {
        _selectedImage = null;
      });

      AwesomeSnackBar.show(context,
          title: 'Başarılı',
          message: 'Profil fotoğrafı kaldırıldı.',
          contentType: ContentType.success);
    } catch (e) {
      print(e);
      AwesomeSnackBar.show(context,
          title: 'Başarısız!',
          message: 'Profil fotoğrafı kaldırılamadı!',
          contentType: ContentType.failure);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('Fotoğrafı Güncelle'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Fotoğrafı Kaldır'),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _showUserInfo() {
    if (_isLoadingUserInfo) {
      return const CircularProgressIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _fullName ?? '-',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _university ?? '-',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider profileImage;

    if (_selectedImage != null) {
      profileImage = FileImage(_selectedImage!);
    } else if (widget.currentProfileUrl != null &&
        widget.currentProfileUrl!.isNotEmpty) {
      profileImage = CachedNetworkImageProvider(widget.currentProfileUrl!);
    } else if (_defaultPhotoUrl != null) {
      profileImage = CachedNetworkImageProvider(_defaultPhotoUrl!);
    } else {
      profileImage =
          CachedNetworkImageProvider('https://via.placeholder.com/150');
    }

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _showImageOptions,
            onLongPress: () {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              image: DecorationImage(
                                  image: profileImage, fit: BoxFit.cover),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  });
            },
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: DecorationImage(
                      image: profileImage,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 16),
          _showUserInfo(),
        ],
      ),
    );
  }
}
