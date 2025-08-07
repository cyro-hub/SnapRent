import 'package:flutter/material.dart';
import 'package:snap_rent/components/safe_scaffold.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final townController = TextEditingController();
  final quarterController = TextEditingController();
  final streetController = TextEditingController();
  final landmarkController = TextEditingController();
  final floorLevelController = TextEditingController();
  final sizeController = TextEditingController();
  final rentController = TextEditingController();
  final securityDepositController = TextEditingController(text: "0");
  final agentNameController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();

  // Dropdown/default values
  String propertyType = 'studio';
  String paymentFrequency = 'monthly';
  String toiletType = 'private';
  String bathroomType = 'private';
  String kitchenType = 'private';
  String meterType = 'prepaid';
  String quietHours = '10 PM - 6 AM';

  bool furnished = false;
  bool waterAvailable = false;
  bool electricity = false;
  bool internet = false;
  bool parking = false;
  bool balcony = false;
  bool ceilingFan = false;
  bool tiledFloor = false;

  bool smokingAllowed = false;
  bool petsAllowed = false;
  bool visitorsAllowed = true;

  final List<String> quietHoursOptions = [
    '10 PM - 6 AM',
    '9 PM - 7 AM',
    '11 PM - 5 AM',
    'No quiet hours',
  ];

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    final propertyData = {
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "location": {
        "type": "Point",
        "coordinates": [
          0.0,
          0.0,
        ], // Replace with actual coordinates if possible
        "town": townController.text.trim(),
        "quarter": quarterController.text.trim(),
        "street": streetController.text.trim(),
        "landmark": landmarkController.text.trim(),
      },
      "type": propertyType,
      "floorLevel": int.tryParse(floorLevelController.text) ?? 1,
      "size": sizeController.text.trim(),
      "rentAmount": int.tryParse(rentController.text) ?? 0,
      "currency": "FCFA", // fixed, or add dropdown if needed
      "paymentFrequency": paymentFrequency,
      "securityDeposit": int.tryParse(securityDepositController.text) ?? 0,
      "amenities": {
        "toilet": toiletType,
        "bathroom": bathroomType,
        "kitchen": kitchenType,
        "furnished": furnished,
        "waterAvailable": waterAvailable,
        "electricity": electricity,
        "meterType": meterType,
        "internet": internet,
        "parking": parking,
        "balcony": balcony,
        "ceilingFan": ceilingFan,
        "tiledFloor": tiledFloor,
      },
      "houseRules": {
        "smokingAllowed": smokingAllowed,
        "petsAllowed": petsAllowed,
        "quietHours": quietHours,
        "visitorsAllowed": visitorsAllowed,
      },
      "contact": {
        "agentName": agentNameController.text.trim(),
        "phone": phoneController.text.trim(),
        "whatsapp": whatsappController.text.trim(),
      },
      "images": [],
      "videos": [],
      "viewCount": 0,
      "status": true,
      "createdAt": DateTime.now().toIso8601String(),
      "expiresAt": DateTime.now()
          .add(const Duration(days: 30))
          .toIso8601String(),
    };

    print("Submitted Property:");
    print(propertyData);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Property Submitted')));

    Navigator.pop(context, propertyData);
  }

  Widget buildCheckboxItem(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width / 2 -
          32, // subtract padding if needed
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: value, onChanged: onChanged),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const sectionSpacing = SizedBox(height: 24);
    const fieldSpacing = SizedBox(height: 12);

    return SafeScaffold(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Basic Information'),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter a title' : null,
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter description'
                              : null,
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: townController,
                          decoration: const InputDecoration(labelText: 'Town'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter town' : null,
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: quarterController,
                          decoration: const InputDecoration(
                            labelText: 'Quarter',
                          ),
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: streetController,
                          decoration: const InputDecoration(
                            labelText: 'Street',
                          ),
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: landmarkController,
                          decoration: const InputDecoration(
                            labelText: 'Landmark',
                          ),
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: floorLevelController,
                          decoration: const InputDecoration(
                            labelText: 'Floor Level',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Enter floor level';
                            if (int.tryParse(v) == null)
                              return 'Enter valid number';
                            return null;
                          },
                        ),
                        fieldSpacing,
                        DropdownButtonFormField<String>(
                          value: propertyType,
                          decoration: const InputDecoration(
                            labelText: 'Property Type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'studio',
                              child: Text('Studio'),
                            ),
                            DropdownMenuItem(
                              value: 'one-bedroom',
                              child: Text('1 Bedroom'),
                            ),
                            DropdownMenuItem(
                              value: 'two-bedroom',
                              child: Text('2 Bedroom'),
                            ),
                            DropdownMenuItem(
                              value: 'apartment',
                              child: Text('Apartment'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => propertyType = val);
                          },
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: sizeController,
                          decoration: const InputDecoration(
                            labelText: 'Size (e.g. 25m²)',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter size' : null,
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: rentController,
                          decoration: const InputDecoration(
                            labelText: 'Rent Amount',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Enter rent amount';
                            if (int.tryParse(v) == null)
                              return 'Enter valid number';
                            return null;
                          },
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: securityDepositController,
                          decoration: const InputDecoration(
                            labelText: 'Security Deposit',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Enter security deposit';
                            if (int.tryParse(v) == null)
                              return 'Enter valid number';
                            return null;
                          },
                        ),
                        fieldSpacing,
                        DropdownButtonFormField<String>(
                          value: paymentFrequency,
                          decoration: const InputDecoration(
                            labelText: 'Payment Frequency',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'monthly',
                              child: Text('Monthly'),
                            ),
                            DropdownMenuItem(
                              value: 'yearly',
                              child: Text('Yearly'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null)
                              setState(() => paymentFrequency = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                sectionSpacing,

                const SectionTitle('Amenities'),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: toiletType,
                          decoration: const InputDecoration(
                            labelText: 'Toilet Type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'private',
                              child: Text('Private'),
                            ),
                            DropdownMenuItem(
                              value: 'shared',
                              child: Text('Shared'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => toiletType = val);
                          },
                        ),
                        fieldSpacing,
                        DropdownButtonFormField<String>(
                          value: bathroomType,
                          decoration: const InputDecoration(
                            labelText: 'Bathroom Type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'private',
                              child: Text('Private'),
                            ),
                            DropdownMenuItem(
                              value: 'shared',
                              child: Text('Shared'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => bathroomType = val);
                          },
                        ),
                        fieldSpacing,
                        DropdownButtonFormField<String>(
                          value: kitchenType,
                          decoration: const InputDecoration(
                            labelText: 'Kitchen Type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'private',
                              child: Text('Private'),
                            ),
                            DropdownMenuItem(
                              value: 'shared',
                              child: Text('Shared'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => kitchenType = val);
                          },
                        ),
                        fieldSpacing,
                        DropdownButtonFormField<String>(
                          value: meterType,
                          decoration: const InputDecoration(
                            labelText: 'Meter Type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'prepaid',
                              child: Text('Prepaid'),
                            ),
                            DropdownMenuItem(
                              value: 'postpaid',
                              child: Text('Postpaid'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => meterType = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 0,
                          runSpacing: 8,
                          children: [
                            buildCheckboxItem('Furnished', furnished, (val) {
                              if (val != null) setState(() => furnished = val);
                            }),
                            buildCheckboxItem(
                              'Water Available',
                              waterAvailable,
                              (val) {
                                if (val != null)
                                  setState(() => waterAvailable = val);
                              },
                            ),
                            buildCheckboxItem('Electricity', electricity, (
                              val,
                            ) {
                              if (val != null)
                                setState(() => electricity = val);
                            }),
                            buildCheckboxItem('Internet', internet, (val) {
                              if (val != null) setState(() => internet = val);
                            }),
                            buildCheckboxItem('Parking', parking, (val) {
                              if (val != null) setState(() => parking = val);
                            }),
                            buildCheckboxItem('Balcony', balcony, (val) {
                              if (val != null) setState(() => balcony = val);
                            }),
                            buildCheckboxItem('Ceiling Fan', ceilingFan, (val) {
                              if (val != null) setState(() => ceilingFan = val);
                            }),
                            buildCheckboxItem('Tiled Floor', tiledFloor, (val) {
                              if (val != null) setState(() => tiledFloor = val);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                sectionSpacing,

                const SectionTitle('House Rules'),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: quietHours,
                          decoration: const InputDecoration(
                            labelText: 'Quiet Hours',
                          ),
                          items: quietHoursOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => quietHours = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 0,
                          runSpacing: 8,
                          children: [
                            buildCheckboxItem(
                              'Smoking Allowed',
                              smokingAllowed,
                              (val) {
                                if (val != null) {
                                  setState(() => smokingAllowed = val);
                                }
                              },
                            ),
                            buildCheckboxItem('Pets Allowed', petsAllowed, (
                              val,
                            ) {
                              if (val != null) {
                                setState(() => petsAllowed = val);
                              }
                            }),
                            buildCheckboxItem(
                              'Visitors Allowed',
                              visitorsAllowed,
                              (val) {
                                if (val != null) {
                                  setState(() => visitorsAllowed = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                sectionSpacing,

                const SectionTitle('Contact Information'),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: agentNameController,
                          decoration: const InputDecoration(
                            labelText: 'Agent Name',
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter agent name'
                              : null,
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter phone number'
                              : null,
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: whatsappController,
                          decoration: const InputDecoration(
                            labelText: 'WhatsApp Number',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),

                sectionSpacing,

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Property',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?>? onChanged,
  ) {
    return SizedBox(
      width: 140,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: value, onChanged: onChanged),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}
