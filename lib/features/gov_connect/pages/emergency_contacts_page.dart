import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mgov_apps/features/gov_connect/models/directory_listing_model.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/features/gov_connect/pages/home_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/location_map_page.dart';

// --- Data Model and Enum ---

enum ContactType { hospital, police, fireDepartment, ministry, agency, restaurant, hotel, attraction }

class EmergencyContact {
  final ContactType type;
  final String name;
  final String phone;
  final String address;
  final String location; // e.g., Addis Ababa, Sub-city
  final int? id;
  final String? email;
  final String? website;
  final double? latitude;
  final double? longitude;
  final String? description;

  EmergencyContact({
    required this.type,
    required this.name,
    required this.phone,
    required this.address,
    required this.location,
    this.id,
    this.email,
    this.website,
    this.latitude,
    this.longitude,
    this.description,
  });

  // Factory to create from DirectoryListing
  factory EmergencyContact.fromDirectoryListing(DirectoryListing listing) {
    ContactType type;
    
    // Map listing types to contact types
    switch (listing.listingType.toLowerCase()) {
      case 'ministry':
        type = ContactType.ministry;
        break;
      case 'agency':
        type = ContactType.agency;
        break;
      case 'hospital':
        type = ContactType.hospital;
        break;
      case 'police':
        type = ContactType.police;
        break;
      case 'fire_department':
        type = ContactType.fireDepartment;
        break;
      case 'restaurant':
        type = ContactType.restaurant;
        break;
      case 'hotel':
        type = ContactType.hotel;
        break;
      case 'attraction':
        type = ContactType.attraction;
        break;
      default:
        type = ContactType.agency;
    }

    return EmergencyContact(
      type: type,
      name: listing.name,
      phone: listing.phonePrimary,
      address: listing.address,
      location: listing.city,
      id: listing.id,
      email: listing.emailPrimary.isNotEmpty ? listing.emailPrimary : null,
      website: listing.website.isNotEmpty ? listing.website : null,
      latitude: listing.latitude,
      longitude: listing.longitude,
      description: listing.description,
    );
  }
}


// --- The Main Page Widget ---

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  String _selectedCategory = 'All';
  
  final ApiService _apiService = ApiService();
  List<EmergencyContact> _allContacts = [];
  List<EmergencyContact> _filteredContacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDirectoryListings();
  }

  Future<void> _fetchDirectoryListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get token from storage
      final token = await getFromLocalStorage('access_token');

      final response = await _apiService.getDirectoryListings(
        token: token,
      );

      if (response.success && response.data != null) {
        final listingsData = response.data['results'] as List?;
        if (listingsData != null) {
          List<EmergencyContact> contacts = [];
          for (var listingJson in listingsData) {
            try {
              final listing = DirectoryListing.fromJson(listingJson);
              contacts.add(EmergencyContact.fromDirectoryListing(listing));
            } catch (e) {
              print('Error parsing directory listing: $e');
            }
          }
          
          setState(() {
            _allContacts = contacts;
            _filteredContacts = contacts;
            _isLoading = false;
          });
          
          _applyFilters();
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load directory listings: ${response.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load directory listings: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      if (_selectedCategory == 'All') {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts
            .where((contact) => _getCategoryName(contact.type) == _selectedCategory)
            .toList();
      }
    });
  }

  String _getCategoryName(ContactType type) {
    switch (type) {
      case ContactType.hospital:
        return 'Hospitals';
      case ContactType.police:
        return 'Police';
      case ContactType.fireDepartment:
        return 'Fire Department';
      case ContactType.ministry:
        return 'Ministries';
      case ContactType.agency:
        return 'Agencies';
      case ContactType.restaurant:
        return 'Restaurants';
      case ContactType.hotel:
        return 'Hotels';
      case ContactType.attraction:
        return 'Attractions';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Chips Row
          _buildCategoryChips(),
          
          // Emergency Contacts Title and Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredContacts.length} Results',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Contacts List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchDirectoryListings,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _buildContactsListView(_filteredContacts),
          ),
        ],
      ),
      
    );
  }

  // --- AppBar Widget ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          Expanded(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Emergency Contact List Page")
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
          //   onPressed: () {
          //     // Open filter modal
          //   },
          // ),
        ],
      ),
      toolbarHeight: 60,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  // --- Category Chips Widget ---
  Widget _buildCategoryChips() {
    final List<String> categories = [
      'All',
      'Ministries', 
      'Agencies',
      'Hospitals', 
      'Police', 
      'Fire Department',
      'Restaurants',
      'Hotels',
      'Attractions'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.blue.shade700,
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                ),
              ),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedCategory = category;
                  }
                });
                _applyFilters();
              },
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // --- ListView Builder ---
  Widget _buildContactsListView(List<EmergencyContact> data) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No listings available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchDirectoryListings,
      child: ListView.builder(
        itemCount: data.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return ContactCard(contact: data[index]);
        },
      ),
    );
  }

  
}

// --- Emergency Contact Card Widget (Reusable Component) ---

class ContactCard extends StatefulWidget {
  final EmergencyContact contact;
  
  const ContactCard({required this.contact, super.key});

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {

  Color get _tagColor {
    switch (widget.contact.type) {
      case ContactType.hospital:
        return Colors.green.shade700;
      case ContactType.police:
        return Colors.blue.shade700;
      case ContactType.fireDepartment:
        return Colors.red.shade700;
      case ContactType.ministry:
        return Colors.purple.shade700;
      case ContactType.agency:
        return Colors.orange.shade700;
      case ContactType.restaurant:
        return Colors.red.shade600;
      case ContactType.hotel:
        return Colors.indigo.shade700;
      case ContactType.attraction:
        return Colors.teal.shade700;
    }
  }
  
  Color get _tagBackgroundColor {
    switch (widget.contact.type) {
      case ContactType.hospital:
        return Colors.green.shade50;
      case ContactType.police:
        return Colors.blue.shade50;
      case ContactType.fireDepartment:
        return Colors.red.shade50;
      case ContactType.ministry:
        return Colors.purple.shade50;
      case ContactType.agency:
        return Colors.orange.shade50;
      case ContactType.restaurant:
        return Colors.red.shade50;
      case ContactType.hotel:
        return Colors.indigo.shade50;
      case ContactType.attraction:
        return Colors.teal.shade50;
    }
  }

  IconData get _tagIcon {
    switch (widget.contact.type) {
      case ContactType.hospital:
        return Icons.local_hospital_outlined;
      case ContactType.police:
        return Icons.security_outlined;
      case ContactType.fireDepartment:
        return Icons.fire_truck_outlined;
      case ContactType.ministry:
        return Icons.account_balance_outlined;
      case ContactType.agency:
        return Icons.business_outlined;
      case ContactType.restaurant:
        return Icons.restaurant_outlined;
      case ContactType.hotel:
        return Icons.hotel_outlined;
      case ContactType.attraction:
        return Icons.place_outlined;
    }
  }
  
  String get _tagText {
    switch (widget.contact.type) {
      case ContactType.hospital:
        return 'Hospital';
      case ContactType.police:
        return 'Police';
      case ContactType.fireDepartment:
        return 'Fire Department';
      case ContactType.ministry:
        return 'Ministry';
      case ContactType.agency:
        return 'Agency';
      case ContactType.restaurant:
        return 'Restaurant';
      case ContactType.hotel:
        return 'Hotel';
      case ContactType.attraction:
        return 'Attraction';
    }
  }

  /// Make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot make call to $phoneNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// View location on map
  void _viewOnMap(EmergencyContact contact) {
    if (contact.latitude != null && contact.longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationMapPage(
            locationName: contact.name,
            latitude: contact.latitude!,
            longitude: contact.longitude!,
            address: contact.address.isNotEmpty ? contact.address : null,
          ),
        ),
      );
    }
  }

  /// Open website in browser
  Future<void> _openWebsite(String websiteUrl) async {
    try {
      // Ensure URL has a scheme
      String url = websiteUrl;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      final Uri websiteUri = Uri.parse(url);
      if (await canLaunchUrl(websiteUri)) {
        await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open website: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening website: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Tag (Hospital/Police)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _tagBackgroundColor,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_tagIcon, size: 16, color: _tagColor),
                const SizedBox(width: 4),
                Text(
                  _tagText,
                  style: TextStyle(
                    color: _tagColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          // Name/Title
          Text(
            widget.contact.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          
          // Phone Number
          if (widget.contact.phone.isNotEmpty)
            Row(
              children: [
                Icon(Icons.call_outlined, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  widget.contact.phone,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          if (widget.contact.phone.isNotEmpty) const SizedBox(height: 5),

          // Email
          if (widget.contact.email != null && widget.contact.email!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.contact.email!,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          if (widget.contact.email != null && widget.contact.email!.isNotEmpty) const SizedBox(height: 5),

          // Address
          if (widget.contact.address.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.contact.address,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 15),

          // Action Buttons Row
          Row(
            children: [
              // Call Button (only if phone available)
              if (widget.contact.phone.isNotEmpty)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _makePhoneCall(widget.contact.phone),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Call'),
                  ),
                ),
              if (widget.contact.phone.isNotEmpty) const SizedBox(width: 10),
              // View On Map Button (only if coordinates available)
              if (widget.contact.latitude != null && widget.contact.longitude != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewOnMap(widget.contact),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('View On Map'),
                  ),
                ),
              // Website Button (only if website available)
              if (widget.contact.website != null && widget.contact.website!.isNotEmpty)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openWebsite(widget.contact.website!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Website'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}