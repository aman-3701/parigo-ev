import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import 'report_issue_screen.dart';

class RideDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> ride;
  final bool isAdmin;

  const RideDetailsScreen({super.key, required this.ride, this.isAdmin = false});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  Map<String, dynamic>? _parseLocation(dynamic locData) {
    if (locData == null) return null;
    if (locData is Map) return Map<String, dynamic>.from(locData);
    if (locData is String) {
      try {
        final map = jsonDecode(locData);
        if (map is Map) return Map<String, dynamic>.from(map);
      } catch (_) {
        return {'address': locData, 'description': locData};
      }
    }
    return null;
  }

  Map<String, dynamic>? get _pickup => _parseLocation(widget.ride['pickupLocation'] ?? widget.ride['pickup']);
  Map<String, dynamic>? get _dropoff => _parseLocation(widget.ride['dropoffLocation'] ?? widget.ride['destination']);

  List<Map<String, dynamic>> get _stops {
    final raw = widget.ride['stops'];
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        if (e is String) {
          try {
            final m = jsonDecode(e);
            if (m is Map) return Map<String, dynamic>.from(m);
          } catch (_) {
            return {'description': e, 'address': e};
          }
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  void _setupMap() {
    final p = _pickup;
    final d = _dropoff;
    final stopsList = _stops;

    final List<LatLng> polylinePoints = [];

    if (p != null && p['lat'] != null) {
      final pLat = double.tryParse(p['lat'].toString());
      final pLng = double.tryParse(p['lng'].toString());
      if (pLat != null && pLng != null) {
        final pLatLng = LatLng(pLat, pLng);
        polylinePoints.add(pLatLng);
        _markers.add(Marker(
          markerId: const MarkerId('pickup'),
          position: pLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Pickup', snippet: p['description'] ?? p['address']),
        ));
      }
    }

    int stopIdx = 1;
    for (var stop in stopsList) {
      if (stop['lat'] != null && stop['lng'] != null) {
        final sLat = double.tryParse(stop['lat'].toString());
        final sLng = double.tryParse(stop['lng'].toString());
        if (sLat != null && sLng != null) {
          final sLatLng = LatLng(sLat, sLng);
          polylinePoints.add(sLatLng);
          _markers.add(Marker(
            markerId: MarkerId('stop_$stopIdx'),
            position: sLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
            infoWindow: InfoWindow(title: 'Stop $stopIdx', snippet: stop['description'] ?? stop['address']),
          ));
          stopIdx++;
        }
      }
    }

    if (d != null && d['lat'] != null) {
      final dLat = double.tryParse(d['lat'].toString());
      final dLng = double.tryParse(d['lng'].toString());
      if (dLat != null && dLng != null) {
        final dLatLng = LatLng(dLat, dLng);
        polylinePoints.add(dLatLng);
        _markers.add(Marker(
          markerId: const MarkerId('dropoff'),
          position: dLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Dropoff', snippet: d['description'] ?? d['address']),
        ));
      }
    }

    if (polylinePoints.length >= 2) {
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: polylinePoints,
        color: AppTheme.primary,
        width: 4,
      ));
    }
  }

  void _launchPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  String _formatDate(dynamic dateData) {
    if (dateData == null) return 'N/A';
    try {
      if (dateData is Map && dateData['_seconds'] != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(dateData['_seconds'] * 1000);
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      }
      if (dateData is int) {
        final dt = DateTime.fromMillisecondsSinceEpoch(dateData);
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      }
      final dt = DateTime.parse(dateData.toString()).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateData.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _pickup;
    final d = _dropoff;
    final stopsList = _stops;

    LatLng initialPos = const LatLng(20.5937, 78.9629); // Center of India fallback
    if (p != null && p['lat'] != null && p['lng'] != null) {
      final lat = double.tryParse(p['lat'].toString());
      final lng = double.tryParse(p['lng'].toString());
      if (lat != null && lng != null) {
        initialPos = LatLng(lat, lng);
      }
    }

    final double distance = double.tryParse(widget.ride['distanceKm']?.toString() ?? '0') ?? 0.0;
    final double co2Saved = distance * 0.15; // Rough estimate: 150g CO2 per km saved vs petrol

    String durationText = '';
    final rawDuration = widget.ride['durationMins'] ?? widget.ride['duration'] ?? widget.ride['estimatedDuration'];
    if (rawDuration != null) {
      final mins = int.tryParse(rawDuration.toString()) ?? (double.tryParse(rawDuration.toString())?.round());
      if (mins != null && mins > 0) {
        if (mins >= 60) {
          final hrs = mins ~/ 60;
          final remMins = mins % 60;
          durationText = remMins > 0 ? '$hrs hr $remMins mins' : '$hrs hr';
        } else {
          durationText = '$mins mins';
        }
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Ride Details', style: GoogleFonts.audiowide(color: AppTheme.primaryContainer)),
        iconTheme: const IconThemeData(color: AppTheme.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Map View
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: initialPos, zoom: 12),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick Stats & Eco Impact
                    if (distance > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.eco, color: Colors.green, size: 24),
                            const SizedBox(width: 8),
                            Text('You saved ${co2Saved.toStringAsFixed(2)} kg of CO2!', 
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Route details
                    Text('Route Details', style: GoogleFonts.nunito(color: AppTheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pickup
                            Row(
                              children: [
                                const Icon(Icons.my_location, color: Colors.green, size: 20),
                                const SizedBox(width: 12),
                                Expanded(child: Text(p?['description'] ?? p?['address'] ?? 'Unknown Pickup', style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold))),
                              ],
                            ),
                            // Stops
                            for (int i = 0; i < stopsList.length; i++) ...[
                              Padding(
                                padding: const EdgeInsets.only(left: 9.0, top: 4, bottom: 4),
                                child: Container(width: 2, height: 20, color: AppTheme.surfaceContainerHighest),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.amber, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('Stop ${i + 1}: ${stopsList[i]['description'] ?? stopsList[i]['address'] ?? 'Intermediate Stop'}', style: const TextStyle(color: AppTheme.onSurface))),
                                ],
                              ),
                            ],
                            // Dropoff
                            Padding(
                              padding: const EdgeInsets.only(left: 9.0, top: 4, bottom: 4),
                              child: Container(width: 2, height: 20, color: AppTheme.surfaceContainerHighest),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red, size: 20),
                                const SizedBox(width: 12),
                                Expanded(child: Text(d?['description'] ?? d?['address'] ?? 'Unknown Dropoff', style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Participants (Admin sees both, Customer sees driver)
                    Text('Participants', style: GoogleFonts.nunito(color: AppTheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (widget.isAdmin) ...[
                      _buildParticipantRow('Customer', widget.ride['customerDetails']?['name'] ?? widget.ride['customerName'] ?? 'Unknown Customer', widget.ride['customerDetails']?['phone'] ?? widget.ride['customerPhone']),
                      const Divider(color: AppTheme.surfaceContainerHighest),
                    ],
                    _buildParticipantRow('Driver', widget.ride['driverDetails']?['name'] ?? widget.ride['driverName'] ?? 'Parigo EV Driver', widget.ride['driverDetails']?['phone'] ?? widget.ride['driverPhone'], vehicle: widget.ride['driverDetails']?['vehicle_type']),

                    const SizedBox(height: 24),

                    // Timeline & Trip Info
                    Text('Timeline & Trip Info', style: GoogleFonts.nunito(color: AppTheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildTimelineRow('Booked At', _formatDate(widget.ride['createdAt'] ?? widget.ride['created_at'] ?? widget.ride['bookingTime'] ?? widget.ride['scheduledTime'])),
                            const Divider(color: AppTheme.surfaceContainerHighest),
                            _buildTimelineRow('Picked Up', _formatDate(widget.ride['rideStartTime'] ?? widget.ride['ride_start_time'] ?? widget.ride['pickupTime'] ?? widget.ride['createdAt'] ?? widget.ride['created_at'])),
                            const Divider(color: AppTheme.surfaceContainerHighest),
                            _buildTimelineRow('Dropped Off', _formatDate(widget.ride['completedAt'] ?? widget.ride['completed_at'] ?? widget.ride['dropoffTime'] ?? widget.ride['updatedAt'] ?? widget.ride['createdAt'] ?? widget.ride['created_at'])),
                            if (durationText.isNotEmpty) ...[
                              const Divider(color: AppTheme.surfaceContainerHighest),
                              _buildTimelineRow('Trip Duration', durationText),
                            ],
                            if (distance > 0) ...[
                              const Divider(color: AppTheme.surfaceContainerHighest),
                              _buildTimelineRow('Distance', '${distance.toStringAsFixed(1)} km'),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Billing
                    Text('Billing & Payment', style: GoogleFonts.nunito(color: AppTheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildTimelineRow('Total Fare', '₹${widget.ride['finalFare'] ?? widget.ride['fare'] ?? widget.ride['estimatedFare'] ?? '0.00'}'),
                            const Divider(color: AppTheme.surfaceContainerHighest),
                            _buildTimelineRow('Payment Mode', widget.ride['paymentMethod'] ?? 'CASH'),
                            if (widget.ride['transactionId'] != null) ...[
                              const Divider(color: AppTheme.surfaceContainerHighest),
                              _buildTimelineRow('Transaction ID', widget.ride['transactionId']),
                            ],
                            const Divider(color: AppTheme.surfaceContainerHighest),
                            _buildTimelineRow('Ride ID', widget.ride['displayId'] ?? widget.ride['id'] ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (!widget.isAdmin) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primaryContainer),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.help_outline, color: AppTheme.primaryContainer),
                        label: const Text('Need Help with this Ride?', style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ReportIssueScreen(preSelectedRideId: widget.ride['id'])));
                        },
                      ),
                    ]
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantRow(String role, String name, String? phone, {String? vehicle}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryContainer.withOpacity(0.2),
        child: Icon(role == 'Driver' ? Icons.drive_eta : Icons.person, color: AppTheme.primaryContainer),
      ),
      title: Text(name, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (phone != null) Text(phone, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
          if (vehicle != null) Text('Vehicle: $vehicle', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
        ],
      ),
      trailing: widget.isAdmin || role == 'Driver' 
        ? IconButton(
            icon: const Icon(Icons.phone, color: AppTheme.primaryContainer),
            onPressed: () => _launchPhone(phone),
          )
        : null,
    );
  }

  Widget _buildTimelineRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
          Flexible(
            child: Text(
              value, 
              style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
