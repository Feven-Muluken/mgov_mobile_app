# Survey & Poll Submission Integration Guide

## Overview
Successfully integrated survey response submission and poll voting endpoints into `survey_detail_page.dart`.

## API Endpoints Integrated

### Survey Submission
- **Endpoint**: `/api/feedback/surveys/{surveyId}/respond/`
- **Method**: POST
- **Authentication**: Bearer Token required
- **Request Body**:
  ```json
  {
    "responses": {
      "1": "Very Satisfied",
      "2": "5",
      "3": "Free text answer"
    },
    "app_name": "my_gov_connect",
    "is_complete": true
  }
  ```

### Poll Voting
- **Endpoint**: `/api/feedback/polls/{pollId}/vote/`
- **Method**: POST
- **Authentication**: Bearer Token required
- **Request Body**:
  ```json
  {
    "selected_option": 0,
    "app_name": "my_gov_connect"
  }
  ```

## Files Modified

### 1. API Constants (`lib/features/gov_connect/constants/api_constants.dart`)
- Added dynamic endpoint methods:
  - `surveyRespondEndpoint(int surveyId)` - Returns `/feedback/surveys/{id}/respond/`
  - `pollVoteEndpoint(int pollId)` - Returns `/feedback/polls/{id}/vote/`

### 2. API Service (`lib/features/gov_connect/core/api_service.dart`)

#### New Methods:

**submitSurveyResponse()**
```dart
Future<ApiResponse> submitSurveyResponse({
  required int surveyId,
  required Map<String, String> responses,
  required String appName,
  required bool isComplete,
  String? token,
})
```

**votePoll()**
```dart
Future<ApiResponse> votePoll({
  required int pollId,
  required int selectedOption,
  required String appName,
  String? token,
})
```

### 3. Survey Detail Page (`lib/features/gov_connect/pages/survey_detail_page.dart`)

#### Key Features Implemented:

**State Management:**
- Added `_isSubmitting` flag to prevent double submissions
- Added `ApiService` instance for API calls

**Submission Handler (`_handleSubmission`):**
- Validates user authentication (checks for token)
- Determines if it's a poll or survey
- Shows loading state during submission
- Handles success/error responses
- Navigates back on success with refresh flag
- Displays appropriate error messages

**Poll Voting (`_submitPollVote`):**
- Gets selected option from user input
- Finds option index in options array
- Calls API with option index (0-based)
- Returns API response

**Survey Submission (`_submitSurveyResponse`):**
- Collects all answers (radio, text, rating)
- Maps answers to question IDs (1-based)
- Sends as key-value pairs
- Returns API response

**Submit Button:**
- Validates all questions are answered
- Shows loading spinner during submission
- Disabled state when incomplete or submitting
- Success feedback with auto-navigation

### 4. Surveys Polls Page (`lib/features/gov_connect/pages/surveys_polls_page.dart`)

**Auto-refresh on Return:**
- Modified `SurveyPollCard` to be StatefulWidget
- Added `onRefresh` callback parameter
- Listens for successful submission result
- Automatically refreshes data when returning from detail page

## User Flow

### For Surveys:
1. User opens survey from list
2. Fills out all questions (radio/text/rating)
3. Taps Submit button
4. Loading indicator appears
5. Success message shown
6. Auto-navigates back to list
7. List refreshes to show updated status

### For Polls:
1. User opens poll from list
2. Selects one option
3. Taps Submit button
4. Loading indicator appears
5. Success message shown
6. Auto-navigates back to list
7. List refreshes to show vote counted

## Error Handling

### Authentication Errors:
- Missing token → "Please login to continue"
- Invalid token → Shows API error message

### Validation Errors:
- Already voted → "You have already voted on this poll"
- Invalid option → "Invalid option selected"
- Network error → Shows error with details

### User Experience:
- All errors shown in red SnackBar
- Success messages in green SnackBar
- Loading spinner during submission
- Button disabled during submission
- Auto-dismisses on success

## Response Mapping

### Survey Responses:
- Question IDs are generated as string indices: "1", "2", "3", etc.
- Radio/rating answers: Store selected option text
- Text answers: Store user-entered text

### Poll Votes:
- Option index: 0-based index from options array
- First option = 0, Second option = 1, etc.

## Key Implementation Details

1. **Token Management**: Token retrieved from SharedPreferences on each submission
2. **App Name**: Hardcoded as "my_gov_connect" for all submissions
3. **Completion Flag**: Always set to `true` for survey submissions
4. **Navigation**: Returns `true` on success to trigger parent refresh
5. **Loading State**: Prevents multiple submissions while processing

## Testing Checklist

- [x] Submit survey with all question types
- [x] Submit poll vote
- [x] Test already voted error
- [x] Test invalid option error
- [x] Test without authentication
- [x] Test network error handling
- [x] Verify data refresh after submission
- [x] Verify loading states
- [x] Verify success messages
- [x] Verify error messages

## API Response Handling

### Success Response:
```json
{
  "success": true,
  "data": { ... },
  "message": "Survey response submitted successfully"
}
```
- Extracts message from `data.message`
- Shows success SnackBar
- Navigates back with refresh flag

### Error Response:
```json
{
  "success": false,
  "errors": {
    "non_field_errors": ["You have already voted on this poll."]
  },
  "message": "Failed to submit vote"
}
```
- Extracts first error from `errors` object
- Shows error SnackBar
- Stays on page for user to review

## Notes

- All submissions require authentication
- Users can only vote once per poll (enforced by backend)
- Survey responses are saved with completion status
- IP address and user agent are captured by backend
- Question IDs in responses use 1-based indexing
- Poll options use 0-based indexing


