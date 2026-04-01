import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String? profileUrl;
  final String? defaultPhotoUrl;
  final String? fullName;
  final String? university;
  final bool isLoading;

  final VoidCallback? onEditTab;

  const ProfileHeader({
    super.key,
    this.profileUrl,
    this.defaultPhotoUrl,
    this.fullName,
    this.university,
    required this.isLoading,
    this.onEditTab,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider profileImage;

    if (profileUrl != null && profileUrl!.isNotEmpty) {
      profileImage = CachedNetworkImageProvider(profileUrl!);
    } else if (defaultPhotoUrl != null && defaultPhotoUrl!.isNotEmpty) {
      profileImage = CachedNetworkImageProvider(defaultPhotoUrl!);
    } else {
      profileImage = const AssetImage('assets/images/default_photo.jpg');
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(children: [
            GestureDetector(
              onTap: onEditTab,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: profileImage, fit: BoxFit.cover),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onEditTab,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(width: 16),
          isLoading
              ? const CircularProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName ?? '-',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      university ?? '-',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
