import 'package:flutter/material.dart';
import 'package:snap_rent/screens/add_property_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dummy flag - replace with your actual logic to check if user image exists
  final bool userImageExists = true;

  // You can replace this with user's actual image URL or local path
  final String userImagePath = 'assets/test/profile_pic.jpg';

  final TextEditingController nameController = TextEditingController(
    text: 'John Doe',
  );
  final TextEditingController emailController = TextEditingController(
    text: 'johndoe@email.com',
  );
  final TextEditingController phoneController = TextEditingController(
    text: '+1234567890',
  );

  String initialName = 'John Doe';
  String initialEmail = 'johndoe@email.com';
  String initialPhone = '+1234567890';

  bool get hasChanges =>
      nameController.text != initialName ||
      emailController.text != initialEmail ||
      phoneController.text != initialPhone;

  void resetInitials() {
    setState(() {
      initialName = nameController.text;
      initialEmail = emailController.text;
      initialPhone = phoneController.text;
    });
  }

  void navigateToAddProperty() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddPropertyScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background: user image or fallback color
          Container(
            decoration: BoxDecoration(
              color: userImageExists ? null : Colors.blue,
              image: userImageExists
                  ? DecorationImage(
                      image: AssetImage(userImagePath),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),

          // Optional overlay to improve contrast when image background exists
          if (userImageExists) Container(color: Colors.black.withOpacity(0.3)),

          // Draggable Bottom Sheet with editable profile info
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pill-shaped drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Your existing fields/content
                      buildTextField("Name", nameController),
                      const SizedBox(height: 16),
                      buildTextField("Email", emailController),
                      const SizedBox(height: 16),
                      buildTextField("Phone", phoneController),
                      const SizedBox(height: 30),

                      if (hasChanges)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              resetInitials();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Profile Updated"),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Update",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddProperty,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}
