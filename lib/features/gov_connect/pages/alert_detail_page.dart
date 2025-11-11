import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/features/gov_connect/pages/affected_areas_map_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/alert_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/emergency_contacts_page.dart';



class AlertDetailPage extends StatefulWidget {
  final Alert alert;

  const AlertDetailPage({required this.alert, super.key});

  @override
  State<AlertDetailPage> createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarkState();
  }

  /// Load bookmark state from storage
  Future<void> _loadBookmarkState() async {
    try {
      final bookmarksJson = await getFromLocalStorage('bookmarked_alerts');
      if (bookmarksJson != null) {
        final List<dynamic> bookmarks = jsonDecode(bookmarksJson);
        setState(() {
          _isBookmarked = bookmarks.contains(widget.alert.title);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle bookmark state
  Future<void> _toggleBookmark() async {
    try {
      final bookmarksJson = await getFromLocalStorage('bookmarked_alerts');
      List<String> bookmarks = [];
      
      if (bookmarksJson != null) {
        bookmarks = List<String>.from(jsonDecode(bookmarksJson));
      }

      setState(() {
        if (_isBookmarked) {
          // Remove bookmark
          bookmarks.remove(widget.alert.title);
          _isBookmarked = false;
        } else {
          // Add bookmark
          bookmarks.add(widget.alert.title);
          _isBookmarked = true;
        }
      });

      // Save updated bookmarks
      await saveToLocalStorage('bookmarked_alerts', jsonEncode(bookmarks));

      // Show feedback message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBookmarked 
                  ? 'Alert bookmarked' 
                  : 'Bookmark removed',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: _isBookmarked ? Colors.green : Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update bookmark: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // Helper to determine the color scheme based on the alert type
  Color get _alertColor {
    return widget.alert.type == AlertType.emergency
        ? Colors.red.shade400
        : Colors.blue.shade400; // Assuming Red for Emergency
  }

  Color get _alertBackgroundColor {
    return widget.alert.type == AlertType.emergency
        ? Colors.red.shade50
        : Colors.blue.shade50; // Very light background
  }

  /// Share alert details
  Future<void> _shareAlert(BuildContext context) async {
    try {
      // Format alert information for sharing
      final StringBuffer shareText = StringBuffer();
      shareText.writeln('🚨 ${widget.alert.type.name.toUpperCase()} ALERT');
      shareText.writeln('');
      shareText.writeln(widget.alert.title);
      shareText.writeln('');
      
      shareText.writeln('Issued: ${widget.alert.date}${widget.alert.time != null ? ', ${widget.alert.time}' : ''}');
      
      if (widget.alert.location.isNotEmpty) {
        shareText.writeln('Location: ${widget.alert.location}');
      }
      
      if (widget.alert.details != null && widget.alert.details!.isNotEmpty) {
        shareText.writeln('');
        shareText.writeln('Details:');
        shareText.writeln(widget.alert.details);
      }
      
      if (widget.alert.evacuationCenters != null && widget.alert.evacuationCenters!.isNotEmpty) {
        shareText.writeln('');
        shareText.writeln('Evacuation Centers:');
        for (var center in widget.alert.evacuationCenters!) {
          shareText.writeln('• $center');
        }
      }
      
      shareText.writeln('');
      shareText.writeln('Shared via MyGov Connect App');

      // Share the alert
      await Share.share(
        shareText.toString(),
        subject: widget.alert.title,
      );
    } catch (e) {
      // Show error message if sharing fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Header Section
            _buildHeaderSection(context),
            
            // Details Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Main Paragraphs of the Alert
                  Text(
                    widget.alert.details ?? "No additional details available.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  
                  // Evacuation Centers (Bullet Points)
                  //_buildEvacuationCentersList(),
                  if (widget.alert.evacuationCenters != null && widget.alert.evacuationCenters!.isNotEmpty)
                    _buildEvacuationCentersList()
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "No evacuation centers listed.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  Text(
                    'Local authorities and emergency services are on high alert and assisting with evacuation efforts. Please follow official guidelines...',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 20),

                  AffectedAreaCard()
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for the floating buttons
          ],
        ),
      ),
      bottomSheet: _buildFloatingActionButtons(context),
    );
  }

  // --- AppBar Widget ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('Alert', style: TextStyle(color: Colors.black)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: _isBookmarked ? Colors.blue.shade700 : Colors.grey,
          ),
          onPressed: _toggleBookmark,
        ),
      ],
    );
  }

  // --- Header Section (Title, Type, Date, Status) ---
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      color: _alertBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency Tag
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: _alertColor, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.alert.type.name.toUpperCase(),
                style: TextStyle(
                  color: _alertColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            widget.alert.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 15),
          // Issued Date/Time and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Issued',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.alert.date}${widget.alert.time != null ? ', ${widget.alert.time}' : ''}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Status Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _alertColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.alert.status ?? "Unknown",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Bulleted List for Evacuation Centers ---
  Widget _buildEvacuationCentersList() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.alert.evacuationCenters!.map((center) {
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black)),
                Expanded(
                  child: Text(
                    center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Bottom Floating Action Buttons ---
  Widget _buildFloatingActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Share Button
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: () {
                _shareAlert(context);
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade700),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Call Button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle Call action (e.g., using url_launcher package)
                Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyContactsPage()));
              },
              icon: const Icon(Icons.call, size: 18),
              label: const Text('Call Emergency Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AffectedAreaCard extends StatelessWidget {
  const AffectedAreaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 400,
      // padding: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        //color: const Color(0xFFFDFCFB), // light background
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
           // Color(0xFFFFFBF2), // light cream at top
            Color(0xFFFFEFD5),
            Color(0xFFFFFFFF), // white at bottom
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.08),
        //     blurRadius: 8,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Text + Illustration
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Affected Areas",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 10,),
                    Text(
                      "Bahir Dar city center\nlow-lying neighborhoods\nnear Lake Tand",
                      style: TextStyle(
                        fontSize: 16,
                        //fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                  ],
                ),
              ),
              // Illustration (replace with Image.asset or SVG)
              SizedBox(
                height: 100,
                width: 100,
                //child: Icon(Icons.support_agent, size: 80, color: Colors.amber),
                child: Image.asset('assets/images/gov_con_onboa_img_2.png')
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                side: const BorderSide(color: Color(0xFF1A4D9E), width: 1.5),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AffectedAreasMapPage()));
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View Affected Areas On Map",
                    style: TextStyle(
                      //color: Colors.blue,
                      color: Color(0xFF1A4D9E),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // SizedBox(width: 8),
                  // Icon(Icons.arrow_forward, color: Color(0xFF1A4D9E),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    
  }
}

