import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../core/api_constants.dart';
import 'package:parigo_ev_app/core/api_client.dart';
import '../widgets/glass_card.dart';
import 'admin_edit_driver_screen.dart';

class AdminDriverDetailsScreen extends StatefulWidget {
  final String driverId;

  const AdminDriverDetailsScreen({Key? key, required this.driverId}) : super(key: key);

  @override
  State<AdminDriverDetailsScreen> createState() => _AdminDriverDetailsScreenState();
}

class _AdminDriverDetailsScreenState extends State<AdminDriverDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _driver;

  @override
  void initState() {
    super.initState();
    _fetchDriverDetails();
  }

  Future<void> _fetchDriverDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/drivers/${widget.driverId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _driver = data['driver'];
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
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: AppTheme.onSurface, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String title, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Center(
                child: Text('Not Provided', style: TextStyle(color: AppTheme.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      );
    }

    Widget imageWidget;
    if (imageUrl.startsWith('http')) {
      imageWidget = Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey, size: 50));
    } else if (imageUrl.startsWith('data:image')) {
      final base64String = imageUrl.split(',').last;
      imageWidget = Image.memory(base64Decode(base64String), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey, size: 50));
    } else {
      imageWidget = const Icon(Icons.broken_image, color: Colors.grey, size: 50);
    }

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: Center(child: imageWidget),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Driver Details', style: GoogleFonts.audiowide(color: AppTheme.primaryContainer)),
        iconTheme: const IconThemeData(color: AppTheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryContainer),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminEditDriverScreen(driverId: widget.driverId)),
              );
              if (result == true) {
                _fetchDriverDetails();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryContainer))
          : _driver == null
              ? const Center(child: Text('Driver not found', style: TextStyle(color: AppTheme.onSurfaceVariant)))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Basic Info Card
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: AppTheme.surfaceContainerHighest,
                                      backgroundImage: _driver!['profile_picture_url'] != null && _driver!['profile_picture_url'].toString().startsWith('data:image')
                                          ? MemoryImage(base64Decode(_driver!['profile_picture_url'].split(',').last))
                                          : _driver!['profile_picture_url'] != null
                                              ? NetworkImage(_driver!['profile_picture_url'])
                                              : null as ImageProvider<Object>?,
                                      child: _driver!['profile_picture_url'] == null 
                                          ? const Icon(Icons.person, color: AppTheme.onSurfaceVariant, size: 30) 
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_driver!['name'] ?? 'Unknown', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                                          const SizedBox(height: 4),
                                          Text(_driver!['id'] ?? '', style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(color: AppTheme.surfaceContainerHighest),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.phone, 'Phone Number', _driver!['phone'] ?? 'N/A'),
                                _buildDetailRow(Icons.email, 'Email Address', _driver!['email'] ?? 'N/A'),
                                _buildDetailRow(Icons.electric_car, 'Vehicle Type', _driver!['vehicle_type'] ?? 'N/A'),
                                _buildDetailRow(Icons.pin, 'Vehicle RC Number', _driver!['vehicle_rc_number'] ?? 'N/A'),
                                _buildDetailRow(Icons.location_on, 'Home Address', _driver!['address'] ?? 'N/A'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Document Photos
                        Text('Verification Documents', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                        const SizedBox(height: 16),
                        
                        _buildPhotoCard('Aadhar Card', _driver!['aadhar_photo_url']),
                        const SizedBox(height: 16),
                        
                        _buildPhotoCard('Driver License', _driver!['license_photo_url']),
                        const SizedBox(height: 16),
                        
                        _buildPhotoCard('PAN Card', _driver!['pan_card_photo_url']),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }
}
