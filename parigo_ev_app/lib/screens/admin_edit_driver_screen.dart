import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../core/api_constants.dart';
import '../widgets/primary_button.dart';
import 'package:parigo_ev_app/core/api_client.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/permission_disclosure_dialog.dart';

class AdminEditDriverScreen extends StatefulWidget {
  final String driverId;

  const AdminEditDriverScreen({Key? key, required this.driverId}) : super(key: key);

  @override
  State<AdminEditDriverScreen> createState() => _AdminEditDriverScreenState();
}

class _AdminEditDriverScreenState extends State<AdminEditDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _rcNumberController = TextEditingController();
  final _addressController = TextEditingController();
  
  final String _selectedVehicleType = 'Tata Xpres-t EV';
  
  bool _isLoading = true;
  bool _isSaving = false;

  String? _aadharPhotoBase64;
  String? _licensePhotoBase64;
  String? _panCardPhotoBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchDriverDetails();
  }

  Future<void> _fetchDriverDetails() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/drivers/${widget.driverId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final driver = data['driver'];
        setState(() {
          _nameController.text = driver['name'] ?? '';
          _phoneController.text = driver['phone'] ?? '';
          _emailController.text = driver['email'] ?? '';
          _rcNumberController.text = driver['vehicle_rc_number'] ?? '';
          _addressController.text = driver['address'] ?? '';
          
          _aadharPhotoBase64 = driver['aadhar_photo_url'];
          _licensePhotoBase64 = driver['license_photo_url'];
          _panCardPhotoBase64 = driver['pan_card_photo_url'];
          
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load driver details');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching details: $e'), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickImage(String type) async {
    try {
      final accepted = await PermissionDisclosureDialog.show(
        context,
        title: 'Photo Library Access',
        message: 'Parigo EV requires access to your photo library so you can upload identification documents.',
        icon: Icons.photo_library,
      );

      if (accepted != true) return;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 60,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      setState(() {
        if (type == 'aadhar') {
          _aadharPhotoBase64 = base64Image;
        } else if (type == 'license') {
          _licensePhotoBase64 = base64Image;
        } else if (type == 'pan') {
          _panCardPhotoBase64 = base64Image;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final response = await ApiClient.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/drivers/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': widget.driverId,
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'vehicleType': _selectedVehicleType,
          'vehicleRcNumber': _rcNumberController.text.trim(),
          'address': _addressController.text.trim(),
          'aadharPhotoBase64': _aadharPhotoBase64?.startsWith('data:image') == true ? _aadharPhotoBase64 : null,
          'licensePhotoBase64': _licensePhotoBase64?.startsWith('data:image') == true ? _licensePhotoBase64 : null,
          'panCardPhotoBase64': _panCardPhotoBase64?.startsWith('data:image') == true ? _panCardPhotoBase64 : null,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver updated successfully!'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception(data['error'] ?? 'Failed to update driver');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: AppTheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.onSurfaceVariant),
          filled: true,
          fillColor: AppTheme.surfaceContainerHighest.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: isRequired ? (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        } : null,
      ),
    );
  }

  Widget _buildImagePickerRow(String label, String? base64Data, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(base64Data != null ? Icons.check_circle : Icons.upload_file, 
            color: base64Data != null ? Colors.green : AppTheme.primaryContainer),
          label: Text(base64Data != null ? 'Uploaded' : 'Upload', 
            style: TextStyle(color: base64Data != null ? Colors.green : AppTheme.primaryContainer)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: base64Data != null ? Colors.green : AppTheme.primaryContainer),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Edit Driver Profile',
            style: GoogleFonts.audiowide(color: AppTheme.primaryContainer)),
        iconTheme: const IconThemeData(color: AppTheme.onSurface),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryContainer))
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField('Full Name', _nameController),
                    _buildTextField('Phone Number', _phoneController),
                    _buildTextField('Email (Optional)', _emailController, isRequired: false),
                    
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        initialValue: _selectedVehicleType,
                        readOnly: true,
                        style: const TextStyle(color: AppTheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Vehicle Type',
                          labelStyle: const TextStyle(color: AppTheme.onSurfaceVariant),
                          filled: true,
                          fillColor: AppTheme.surfaceContainerHighest.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    
                    _buildTextField('Vehicle RC Number', _rcNumberController),
                    
                    _buildImagePickerRow('Aadhar Photo', _aadharPhotoBase64, () => _pickImage('aadhar')),
                    const SizedBox(height: 16),
                    
                    _buildImagePickerRow('License Photo', _licensePhotoBase64, () => _pickImage('license')),
                    const SizedBox(height: 16),
                    
                    _buildImagePickerRow('PAN Card Photo', _panCardPhotoBase64, () => _pickImage('pan')),
                    const SizedBox(height: 16),
                    
                    _buildTextField('Address', _addressController),
                    
                    const SizedBox(height: 24),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                        : PrimaryButton(
                            text: 'Save Changes',
                            onPressed: _submit,
                          ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _rcNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
