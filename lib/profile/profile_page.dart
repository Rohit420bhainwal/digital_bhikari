import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final TextEditingController statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      statusController.text = controller.status.value;
      return Scaffold(
        appBar: AppBar(
          title: Text('My Profile'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final source = await showDialog<ImageSource>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text('Profile Picture'),
                      children: [
                        SimpleDialogOption(
                          child: Text('Camera'),
                          onPressed: () => Navigator.pop(context, ImageSource.camera),
                        ),
                        SimpleDialogOption(
                          child: Text('Gallery'),
                          onPressed: () => Navigator.pop(context, ImageSource.gallery),
                        ),
                      ],
                    ),
                  );
                  if (source != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Center(child: CircularProgressIndicator()),
                    );
                    try {
                      await controller.pickAndUploadImage(source);
                    } catch (e) {
                      Get.snackbar('Error', 'Image upload failed: $e');
                    }
                    Navigator.pop(context); // Always close loader
                  }
                },
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: controller.profilePicture.value.isNotEmpty
                      ? NetworkImage(controller.profilePicture.value)
                      : null,
                  child: controller.profilePicture.value.isEmpty
                      ? Icon(Icons.person, size: 48)
                      : null,
                ),
              ),
              SizedBox(height: 16),
              Text(
                controller.userName.value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                controller.userEmail.value,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      controller.updateProfile(status: statusController.text);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                onSubmitted: (value) {
                  controller.updateProfile(status: value);
                },
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      );
    });
  }
}