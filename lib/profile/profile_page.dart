import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final TextEditingController statusController = TextEditingController();
  final Color primaryColor = const Color(0xFF1976D2);
  final Color accentColor = const Color(0xFFFFC107);
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      statusController.text = controller.status.value;
      return Scaffold(
        appBar: AppBar(
          title: Text('My Profile'),
          centerTitle: true,

        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.deepPurple[100],
                        backgroundImage: controller.profilePicture.value.isNotEmpty
                            ? NetworkImage(controller.profilePicture.value)
                            : null,
                        child: controller.profilePicture.value.isEmpty
                            ? Icon(Icons.person, size: 60, color: Colors.grey[700])
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            final source = await showDialog<ImageSource>(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: Text('Select Image Source'),
                                children: [
                                  SimpleDialogOption(
                                    child: Text('📷 Camera'),
                                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                                  ),
                                  SimpleDialogOption(
                                    child: Text('🖼️ Gallery'),
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
                            radius: 20,
                            backgroundColor: primaryColor,
                            child: Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  controller.userName.value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  controller.userEmail.value,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(
                    labelText: 'Update Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                SizedBox(height: 40),
                Card(
                  color: Colors.yellow[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '🧾 Yeh screen abhi baaki hai bava...\nlekin agar app ko 💥 jhakaas response mila,\ntoh yahan bhi kuch solid 🔥 content gira hi denge! 😄',
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
