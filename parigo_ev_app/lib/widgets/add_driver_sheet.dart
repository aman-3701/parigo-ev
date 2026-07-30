import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../core/api_constants.dart';
import 'primary_button.dart';
import 'package:parigo_ev_app/core/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'permission_disclosure_dialog.dart';
class AddDriverSheet extends StatefulWidget {
  final VoidCallback onDriverAdded;

  const AddDriverSheet({Key? key, required this.onDriverAdded}) : super(key: key);

  @override
  State<AddDriverSheet> createState() => _AddDriverSheetState();
}

class _AddDriverSheetState extends State<AddDriverSheet> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  final _rcNumberController = TextEditingController();
  final _addressController = TextEditingController();
  
  final String _selectedVehicleType = 'Tata Xpres-t EV';
  
  bool _isLoading = false;
  
  String? _aadharPhotoBase64;
  String? _licensePhotoBase64;
  String? _panCardPhotoBase64;
  final ImagePicker _picker = ImagePicker();

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    _rcNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/drivers/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'pin': _pinController.text.trim(),
          'vehicleType': _selectedVehicleType,
          'vehicleRcNumber': _rcNumberController.text.trim(),
          'address': _addressController.text.trim(),
          'aadharPhotoBase64': _aadharPhotoBase64,
          'licensePhotoBase64': _licensePhotoBase64,
          'panCardPhotoBase64': _panCardPhotoBase64,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onDriverAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver added successfully!'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception(data['error'] ?? 'Failed to add driver');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int? maxLength, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLength: maxLength,
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
          counterText: '',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.outline,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Text('Add New Driver',
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryContainer)),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField('Full Name', _nameController),
                      _buildTextField('Phone Number (e.g. +91...)', _phoneController),
                      _buildTextField('4-Digit Login PIN', _pinController, isNumber: true, maxLength: 4),
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
                      
                      const SizedBox(height: 16),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                          : PrimaryButton(
                              text: 'Create Driver',
                              onPressed: _submit,
                            ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
}
