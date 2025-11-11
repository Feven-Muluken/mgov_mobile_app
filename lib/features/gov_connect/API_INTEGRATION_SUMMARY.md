# Surveys & Polls API Integration Summary

## Overview
Successfully integrated the Polls and Surveys API endpoints into `surveys_polls_page.dart`.

## API Endpoints Integrated

### Polls
- **Endpoint**: `/api/feedback/polls/`
- **Method**: GET
- **Authentication**: Bearer Token required
- **Response**: Returns list of active polls with voting information

### Surveys
- **Endpoint**: `/api/feedback/surveys/`
- **Method**: GET
- **Authentication**: Bearer Token required
- **Response**: Returns list of active surveys with questions

## Files Modified

### 1. API Constants (`lib/features/gov_connect/constants/api_constants.dart`)
- Updated endpoints to match backend:
  - `surveysEndpoint`: `/feedback/surveys/`
  - `pollsEndpoint`: `/feedback/polls/`

### 2. API Service (`lib/features/gov_connect/core/api_service.dart`)
- Added token parameter to `getSurveys()` and `getPolls()` methods
- Both methods now accept optional Bearer token for authentication

### 3. New Model Files Created

#### Poll Model (`lib/features/gov_connect/models/poll_model.dart`)
- `Poll` class with all fields from API response
- `Author` class for poll author information
- JSON serialization methods

#### Survey Model (`lib/features/gov_connect/models/survey_model.dart`)
- `Survey` class with all fields from API response
- `SurveyAuthor` class for survey author information
- `SurveyQuestion` class for survey questions
- JSON serialization methods

### 4. Surveys Polls Page (`lib/features/gov_connect/pages/surveys_polls_page.dart`)

#### Key Features:
- **API Integration**: Fetches real data from backend on page load
- **Token Authentication**: Retrieves access token from SharedPreferences
- **Parallel Loading**: Fetches surveys and polls simultaneously using `Future.wait`
- **Error Handling**: Shows error messages with retry button
- **Loading States**: Displays loading indicator while fetching data
- **Pull to Refresh**: Swipe down to refresh data
- **Empty States**: Shows appropriate messages when no data available
- **Filtering**: 
  - Filter by type (All/Surveys/Polls)
  - Filter by category (Transport, Health, etc.)
- **My Participations Tab**: Shows surveys/polls user has voted on
- **Days Remaining Calculation**: Automatically calculates remaining days from end_date

## Data Flow

1. **Page Initialization**: 
   - `initState()` calls `_fetchSurveysAndPolls()`
   
2. **Token Retrieval**: 
   - Gets access token from SharedPreferences using `getFromLocalStorage('access_token')`
   
3. **API Calls**: 
   - Calls both `getSurveys()` and `getPolls()` in parallel
   - Passes Bearer token for authentication
   
4. **Data Processing**: 
   - Parses JSON responses into `Survey` and `Poll` models
   - Converts to `SurveyOrPoll` display model
   - Combines both lists into single list
   
5. **State Updates**: 
   - Updates `_allSurveysPolls` with combined data
   - Applies filters based on selected category
   - Updates `_filteredSurveysPolls` for display

## Authentication

The integration uses Bearer Token authentication:
- Token is stored in SharedPreferences with key `'access_token'`
- Token is automatically retrieved and passed to API calls
- Example token format: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## Error Handling

- Network errors are caught and displayed to user
- JSON parsing errors are logged to console
- Retry button available on error screen
- Empty states for no data scenarios

## Testing

To test the integration:

1. Ensure you're logged in (access token is stored)
2. Navigate to Surveys & Polls page
3. Verify data loads from API
4. Test filters (All, Surveys, Polls, categories)
5. Test pull-to-refresh
6. Check "My Participations" tab

## Next Steps (Optional Enhancements)

1. Implement voting functionality for polls
2. Implement survey submission
3. Add search functionality
4. Cache data for offline access
5. Add pagination for large datasets
6. Implement real-time updates
7. Add analytics tracking

## Notes

- The page uses responsive design with proper loading and error states
- All API calls are authenticated using stored access token
- Data refreshes on pull-down gesture
- Days remaining are calculated from API's `end_date` field
- The integration maintains backward compatibility with existing UI components


