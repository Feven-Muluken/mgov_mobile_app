# Directory Listings API Integration Guide

## Overview
Successfully integrated the Directory Listings API (`/api/directory/listings/`) into `emergency_contacts_page.dart` to display government agencies, ministries, restaurants, hotels, and attractions.

## API Endpoint Integrated

### Directory Listings
- **Endpoint**: `/api/directory/listings/`
- **Method**: GET
- **Authentication**: Bearer Token (optional)
- **Response**: Returns paginated list of directory listings with full details

## Files Created/Modified

### 1. New Model File (`lib/features/gov_connect/models/directory_listing_model.dart`)

#### DirectoryListing Class:
- Complete model matching API response structure
- All fields: id, name, slug, description, listingType, category, contact info, location, etc.
- JSON serialization methods

#### Category Class:
- Nested category information
- Color coding, icons, target apps
- Parent-child relationships

### 2. API Constants (`lib/features/gov_connect/constants/api_constants.dart`)
- Added `directoryListingsEndpoint = '/directory/listings/'`

### 3. API Service (`lib/features/gov_connect/core/api_service.dart`)

#### New Method:
```dart
Future<ApiResponse> getDirectoryListings({
  String? category,
  String? listingType,
  String? region,
  String? search,
  String? token,
})
```

### 4. Emergency Contacts Page (`lib/features/gov_connect/pages/emergency_contacts_page.dart`)

#### Key Features Implemented:

**Enhanced Contact Types:**
- Added new types: ministry, agency, restaurant, hotel, attraction
- Color-coded categories with unique icons
- Smart mapping from API listing types

**API Integration:**
- Fetches real data on page load
- Token authentication support
- Error handling with retry functionality
- Loading states with spinner
- Pull-to-refresh capability

**Enhanced Filtering:**
- All, Ministries, Agencies, Hospitals, Police, Fire Department, Restaurants, Hotels, Attractions
- Real-time filtering based on contact type
- Dynamic result counts

**Rich Contact Cards:**
- Phone numbers (with call button)
- Email addresses (with email icon)
- Website links (with website button)
- GPS coordinates (with map button)
- Address information
- Conditional display (only show available info)

**Smart Factory Method:**
- `EmergencyContact.fromDirectoryListing()` converts API data
- Maps listing types to contact types
- Handles missing data gracefully

## Data Mapping

### API Response → Contact Display:
- `name` → Contact name
- `phone_primary` → Phone number
- `email_primary` → Email address
- `website` → Website URL
- `address` → Full address
- `city` → Location
- `latitude/longitude` → GPS coordinates
- `listing_type` → Contact type (ministry, agency, etc.)

### Contact Type Mapping:
```dart
'ministry' → ContactType.ministry
'agency' → ContactType.agency
'hospital' → ContactType.hospital
'police' → ContactType.police
'fire_department' → ContactType.fireDepartment
'restaurant' → ContactType.restaurant
'hotel' → ContactType.hotel
'attraction' → ContactType.attraction
```

## UI Enhancements

### Category Chips:
- 9 categories: All, Ministries, Agencies, Hospitals, Police, Fire Department, Restaurants, Hotels, Attractions
- Color-coded selection
- Real-time filtering

### Contact Cards:
- **Type Tags**: Color-coded with icons
- **Contact Info**: Phone, email, address (conditional display)
- **Action Buttons**: Call, View on Map, Website (conditional)
- **Smart Layout**: Only shows available information

### Visual Design:
- **Ministries**: Purple with government icon
- **Agencies**: Orange with business icon
- **Hospitals**: Green with hospital icon
- **Police**: Blue with security icon
- **Fire Department**: Red with fire truck icon
- **Restaurants**: Red with restaurant icon
- **Hotels**: Indigo with hotel icon
- **Attractions**: Teal with place icon

## Error Handling

- **Network Errors**: Shows error message with retry button
- **Empty States**: "No listings available" with icon
- **Loading States**: Spinner during data fetch
- **Parse Errors**: Logged to console, skipped gracefully

## User Experience Features

1. **Pull to Refresh**: Swipe down to reload data
2. **Real-time Filtering**: Instant category filtering
3. **Conditional Actions**: Buttons only appear when data is available
4. **Loading Feedback**: Clear loading and error states
5. **Result Counts**: Dynamic count display
6. **Empty States**: Helpful messages when no data

## API Response Structure

```json
{
  "count": 11,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "Ministry of Health",
      "slug": "ministry-of-health",
      "description": "Federal Ministry of Health...",
      "listing_type": "ministry",
      "category": { ... },
      "phone_primary": "+251115517011",
      "email_primary": "info@moh.gov.et",
      "website": "https://www.moh.gov.et",
      "address": "Algeria Street, Addis Ababa",
      "city": "Addis Ababa",
      "region": "Addis Ababa",
      "latitude": 9.0323,
      "longitude": 38.747,
      "status": "active",
      "verification_status": "verified",
      "created_at": "2025-08-15T15:25:28.470130+03:00"
    }
  ]
}
```

## Testing Checklist

- [x] Load directory listings on page open
- [x] Display all contact types correctly
- [x] Filter by category (All, Ministries, etc.)
- [x] Show phone numbers with call buttons
- [x] Show email addresses
- [x] Show website links
- [x] Show addresses
- [x] Handle missing data gracefully
- [x] Pull-to-refresh functionality
- [x] Error handling with retry
- [x] Loading states
- [x] Empty states
- [x] Result counts

## Notes

- All listings are displayed as "Emergency Contacts" for consistency
- Contact types are mapped from API `listing_type` field
- Missing contact information is handled gracefully
- Action buttons only appear when relevant data is available
- The page maintains the original emergency contacts design while showing directory data

## Future Enhancements

1. **Search Functionality**: Implement search by name/description
2. **Map Integration**: Open actual maps with coordinates
3. **Call Integration**: Implement actual phone calling
4. **Website Integration**: Open websites in browser
5. **Favorites**: Allow users to bookmark contacts
6. **Distance Calculation**: Show distance from user location
7. **Rating Display**: Show average ratings when available
8. **Pagination**: Handle large datasets with pagination

