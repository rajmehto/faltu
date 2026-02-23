import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'auth_service.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  Future<String?> uploadAvatar(File file) async {
    final userId = Get.find<AuthService>().userId;
    if (userId == null) return null;

    final compressed = await _compressImage(file, quality: 75);
    if (compressed == null) return null;

    final ref = _storage.ref('avatars/$userId.jpg');
    await ref.putFile(File(compressed.path));
    return ref.getDownloadURL();
  }

  Future<String?> uploadCoverImage(File file) async {
    final userId = Get.find<AuthService>().userId;
    if (userId == null) return null;

    final compressed = await _compressImage(file, quality: 80, width: 1080);
    if (compressed == null) return null;

    final ref = _storage.ref('covers/$userId.jpg');
    await ref.putFile(File(compressed.path));
    return ref.getDownloadURL();
  }

  Future<String?> uploadStreamThumbnail(File file, String streamId) async {
    final compressed = await _compressImage(file, quality: 80, width: 1280);
    if (compressed == null) return null;

    final ref = _storage.ref('thumbnails/$streamId.jpg');
    await ref.putFile(File(compressed.path));
    return ref.getDownloadURL();
  }

  Future<String?> uploadChatImage(File file) async {
    final userId = Get.find<AuthService>().userId;
    if (userId == null) return null;

    final fileId = _uuid.v4();
    final compressed = await _compressImage(file, quality: 70, width: 800);
    if (compressed == null) return null;

    final ref = _storage.ref('chat-images/$userId/$fileId.jpg');
    await ref.putFile(File(compressed.path));
    return ref.getDownloadURL();
  }

  Future<String?> uploadPostImage(File file) async {
    final userId = Get.find<AuthService>().userId;
    if (userId == null) return null;

    final fileId = _uuid.v4();
    final compressed = await _compressImage(file, quality: 75, width: 1080);
    if (compressed == null) return null;

    final ref = _storage.ref('posts/$userId/$fileId.jpg');
    await ref.putFile(File(compressed.path));
    return ref.getDownloadURL();
  }

  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    bool crop = false,
    double? aspectRatioX,
    double? aspectRatioY,
  }) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 90,
    );

    if (pickedFile == null) return null;

    if (crop) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: aspectRatioX != null && aspectRatioY != null
            ? CropAspectRatio(
                ratioX: aspectRatioX,
                ratioY: aspectRatioY,
              )
            : null,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFFE91E8C),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );
      if (cropped == null) return null;
      return File(cropped.path);
    }

    return File(pickedFile.path);
  }

  Future<File?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
  }) async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: source,
      maxDuration: maxDuration ?? const Duration(minutes: 10),
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  Future<XFile?> _compressImage(
    File file, {
    int quality = 80,
    int? width,
    int? height,
  }) async {
    final dir = await getTemporaryDirectory();
    final ext = path.extension(file.path);
    final targetPath = '${dir.path}/${_uuid.v4()}${ext.isEmpty ? '.jpg' : ext}';

    return FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: width ?? 1080,
      minHeight: height ?? 1080,
    );
  }

  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {}
  }

  UploadTask uploadWithProgress(File file, String storagePath) {
    final ref = _storage.ref(storagePath);
    return ref.putFile(file);
  }
}
