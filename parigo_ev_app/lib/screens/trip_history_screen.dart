import 'dart:convert';
import 'ride_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../core/api_constants.dart';
import '../core/user_session.dart';
import 'package:parigo_ev_app/core/api_client.dart';


class TripHistoryScreen extends StatefulWidget {
  final String role; // 'Driver' or 'Customer'

  const TripHistoryScreen({super.key, required this.role});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _historyRides = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final uid = UserSession().uid;
    if (uid == null || uid.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final endpoint = widget.role == 'Driver' 
          ? '/driver/rides/history?driverId=$uid'
          : '/customer/rides/history?uid=$uid';
          
      final response = await ApiClient.get(Uri.parse('${ApiConstants.baseUrl}$endpoint'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && mounted) {
          setState(() {
            _historyRides = data['rides'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching trip history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown Date';
    try {
      if (timestamp is Map && timestamp['_seconds'] != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
        return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
      }
      if (timestamp is int) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
      }
      final date = DateTime.parse(timestamp.toString());
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return timestamp.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppTheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _historyRides.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchHistory,
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _historyRides.length,
                    itemBuilder: (context, index) {
                      final ride = _historyRides[index];
                      return _buildTripCard(ride);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: AppTheme.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No trips found',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Your past trips will appear here.',
              style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildTripCard(dynamic ride) {
    final status = ride['status'] ?? 'UNKNOWN';
    final isCompleted = status == 'COMPLETED';
    String pickup = 'Unknown Pickup';
    final pData = ride['pickup'] ?? ride['pickupLocation'];
    if (pData is Map) {
      pickup = pData['description'] ?? pData['address'] ?? 'Unknown Pickup';
    } else if (pData is String) {
      try {
        final map = jsonDecode(pData);
        pickup = map['description'] ?? map['address'] ?? pData;
      } catch (_) {
        pickup = pData;
      }
    }

    String dropoff = 'Unknown Dropoff';
    final dData = ride['destination'] ?? ride['dropoffLocation'];
    if (dData is Map) {
      dropoff = dData['description'] ?? dData['address'] ?? 'Unknown Dropoff';
    } else if (dData is String) {
      try {
        final map = jsonDecode(dData);
        dropoff = map['description'] ?? map['address'] ?? dData;
      } catch (_) {
        dropoff = dData;
      }
    }
    final fare = ride['finalFare']?.toString() ?? ride['estimatedFare']?.toString() ?? ride['fare']?.toString() ?? '0.00';
    final waitPenalty = ride['customerWaitPenalty'];
    final latePenalty = ride['driverLatePenalty'];
    final dateStr = _formatDate(ride['createdAt']);

    // Extract other person's details
    String otherName = 'Unknown User';
    if (widget.role == 'Driver') {
      otherName = ride['customerDetails']?['name'] ?? 'Guest Customer';
    } else {
      otherName = ride['driverDetails']?['name'] ?? 'Parigo EV Driver';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RideDetailsScreen(ride: ride, isAdmin: false)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${ride['displayId'] ?? ride['id']}', style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(dateStr, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.green : Colors.red),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, color: AppTheme.primary, size: 24),
                    Text(fare, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                  ],
                ),
                if (latePenalty != null && latePenalty > 0)
                   Padding(
                     padding: const EdgeInsets.only(top: 4.0),
                     child: Text('- ₹$latePenalty Punctuality Guarantee', style: const TextStyle(color: Colors.greenAccent, fontSize: 14)),
                   ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person, color: AppTheme.primaryContainer, size: 16),
                    const SizedBox(width: 8),
                    Text(otherName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppTheme.outline),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 12),
                    const SizedBox(width: 12),
                    Expanded(child: Text(pickup, style: const TextStyle(fontSize: 14))),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 5, top: 4, bottom: 4),
                  child: SizedBox(
                      height: 20,
                      child: VerticalDivider(color: AppTheme.onSurfaceVariant, thickness: 1)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 12),
                    const SizedBox(width: 12),
                    Expanded(child: Text(dropoff, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
