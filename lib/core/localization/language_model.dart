/// Language Model
///
/// Defines supported languages for the Abay Remittance app
enum AppLanguage { English, Amharic }

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.English:
        return 'en';
      case AppLanguage.Amharic:
        return 'am';
    }
  }

  String get name {
    switch (this) {
      case AppLanguage.English:
        return 'English';
      case AppLanguage.Amharic:
        return 'አማርኛ';
    }
  }

  String get flag {
    switch (this) {
      case AppLanguage.English:
        return '🇺🇸';
      case AppLanguage.Amharic:
        return '🇪🇹';
    }
  }
}

/// Base class for language strings
abstract class LanguageStrings {
  // App Info
  String get appName;
  String get appTagline;

  // Onboarding
  String get loading;
  String get skip;
  String get continue_;
  String get start;
  String get welcome;
  String get next;
  String get footerText;

  // Onboarding Pages
  String get onboardingTitle1;
  String get onboardingDesc1;
  String get onboardingTitle2;
  String get onboardingDesc2;
  String get onboardingTitle3;
  String get onboardingDesc3;

  // Sign Up and Sign In page
  String get signin;
  String get signup;
  String get pleaseLogin;
  String get phoneNumber;
  String get password;
  String get donothaveAccount;
  String get forgotPassword;
  String get createAccount;
  String get fullName;
  String get emailAddress;
  String get repeatPassword;
  String get accountAgreement;
  String get phone;
  String get email;
  String get confirmPhoneNumber;
  String get otpCodeMessage;
  String get verify;
  String get resendCode;
  String get continueAsGuest;
  String get orContinueWithLimitedFeatures;
  
  // Additional login page strings
  String get username;
  String get enterUsername;
  String get usernameRequired;

  // Additional register page strings
  String get userName;
  String get enterUserName;
  String get firstName;
  String get enterFirstName;
  String get lastName;
  String get enterLastName;
  String get enterPhoneNumber;
  String get emailAddressOptional;
  String get enterEmailAddress;
  String get gender;
  String get chooseGender;
  String get male;
  String get female;
  String get haveAnAccount;
  String get signUp;
  String get resendCodeIn30s;
  String get fullNameRequired;
  String get firstNameRequired;
  String get lastNameRequired;
  String get phoneNumberRequired;
  String get validEmailAddress;
  String get passwordsDoNotMatch;
  String get passwordMin8Characters;
  String get passwordMustContainUppercase;
  String get passwordMustContainLowercase;
  String get passwordMustContainDigit;
  String get passwordMustContainSpecialCharacter;
  String get footerTextRegister;

  // Home Screen
  String get welcomeTo;
  String get availableBalance;
  String get sendMoney;
  String get features;
  String get mygovConnect;
  String get searchMygovConnect;
  String get viewAll;
  String get latestNews;
  String get browseMoreNews;
  String get browseAllNews;
  String get lookingForEmergencyContacts;
  String get emergencyContactsList;
  String get newAlertMessage;
  String get postedDaysAgo;

  // Alerts Page
  String get alerts;
  String get searchForAlert;
  String get results;
  String get all;
  String get emergencies;
  String get weather;
  String get services;
  
  // Alert Detail Page
  String get alert;
  String get details;
  String get noAdditionalDetails;
  String get noEvacuationCenters;
  String get authoritiesOnHighAlert;
  String get affectedAreas;
  String get viewAffectedAreasOnMap;
  String get share;
  String get callEmergencyContact;
  String get issued;

  // News Page
  String get news;
  String get health;
  String get community;
  String get technology;
  String get governance;
  String get jobs;
  String get publicHealth;
  String get searchForNews;

  // News Detail Page
  String get headline;
  String get article;
  String get similarNews;

  // Surveys & Polls Page
  String get surveysPolls;
  String get searchForSurveyPoll;
  String get surveys;
  String get polls;
  String get transport;
  String get myParticipations;
  String get noActiveParticipations;

  // Survey Detail Page
  String get survey;
  String get description;
  String get questions;
  String get confidentialMessage;
  String get typeAnswerHere;
  String get submit;
  String get surveySubmittedSuccess;

  // Profile Page
  String get profile;
  String get resolutionSummary;
  String get averageResolutionTime;
  String get days;
  String get casesInProgress;
  String get overallCompliance;
  String get totalCasesResolved;
  String get resolved;
  String get pending;
  String get rejected;
  String get settings;
  String get language;
  String get english;
  String get changePassword;
  String get rateApp;
  String get logout;
  String get appVersion;

  // Filter Search Modal
  String get whatAreYouLookingFor;
  String get filterNews;
  String get region;
  String get selectRegion;
  String get category;
  String get selectCategory;
  String get date;
  String get from;
  String get to;
  String get sortBy;
  String get chooseSortOrder;
  String get newestFirst;
  String get oldestFirst;
  String get mostRelevant;
  String get rememberMyPreference;
  String get clearFilters;
  String get apply;
  String get addisAbaba;
  String get bahirDar;
  String get direDawa;
  String get mekelle;
  String get hawassa;

  // Affected Areas Map Page
  String get affectedAreasByEmergency;
  String get highlyAffected;
  String get slightlyAffected;

  // Form Fields
  String get recipientName;
  String get enterRecipientName;
  String get amount;
  String get transactionPin;
  String get recipientNameRequired;
  String get validPhoneNumber;
  String get amountRequired;
  String get validAmount;
  String get passwordRequired;
  String get passwordMinLength;

  // Features
  String get instantTransfer;
  String get instantTransferDesc;
  String get secure;
  String get secureDesc;
  String get lowFees;
  String get lowFeesDesc;
  String get support24;
  String get support24Desc;

  // Buttons & Actions
  String get send;
  String get cancel;
  String get confirm;
  String get ok;
  String get yes;
  String get no;

  // Dialogs
  String get success;
  String get error;
  String get warning;
  String get confirmTransfer;
  String get transferSuccessful;
  String get transferSuccessMessage;
  String get successDialogMessage;
  String get errorDialogMessage;
  String get processingRequest;
  String get done;
  String get loadingComplete;

  // Navigation
  String get home;
  String get gifts;
  String get history;

  // Homepage
  String get todayExchangeRate;
  String get usdToBirr;
  String get birrBonus;
  String get ifSentWith;
  String get expressMoney;
  String get cashPickup;
  String get giftYourLovedOnce;
  String get viewMore;

  // Validation Messages
  String confirmTransferMessage(String amount, String recipient);
}

/// English Language Strings
class EnglishStrings extends LanguageStrings {
  @override
  String get appName => 'MyGov Connect';

  @override
  String get appTagline => 'Your Trusted Source For Government Updates and Emergency Alerts,';

  @override
  String get loading => 'Loading...';

  @override
  String get skip => 'Skip';

  @override
  String get continue_ => 'Continue';

  @override
  String get start => 'Start';

  @override
  String get welcome => 'Welcome';

  @override
  String get next => 'Next';

  @override
  String get footerText => 'Powered by Ministry of innovation and technology (MINT) \nand Developed by 360ground';

  @override
  String get onboardingTitle1 => 'Welcome';

  @override
  String get onboardingDesc1 =>
      'To MyGov Connect. your trusted source for government updates and emergency alerts,';

  @override
  String get onboardingTitle2 => 'Tailored To You';

  @override
  String get onboardingDesc2 =>
      'Personalized alerts and local emergency contacts at your fingertips.';

  @override
  String get onboardingTitle3 => 'Participation & Feedback';

  @override
  String get onboardingDesc3 =>
      'Have your voice heard, join surveys and shape services';

  
  @override
  String get signin => 'Sign In';

  @override
  String get signup => 'Sign Up';

  @override
  String get pleaseLogin => 'Please login to continue';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get password => 'Password';

  @override
  String get donothaveAccount => 'Don\'t have an account';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email address';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get accountAgreement => 'Account Agreement';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get confirmPhoneNumber => 'Confirm Phone Number';

  @override
  String get otpCodeMessage => 'We\'ve sent a 6 digit code to your phone number, please enter the code below.';

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend Code in 30s';

  @override
  String get continueAsGuest => 'Continue As Guest';

  @override
  String get orContinueWithLimitedFeatures => 'or continued with limited features';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get userName => 'User Name';

  @override
  String get enterUserName => 'Enter your user name';

  @override
  String get firstName => 'First Name';

  @override
  String get enterFirstName => 'Enter your first name';

  @override
  String get lastName => 'Last Name';

  @override
  String get enterLastName => 'Enter your last name';

  @override
  String get enterPhoneNumber => '900000000';

  @override
  String get emailAddressOptional => 'Email Address(Optional)';

  @override
  String get enterEmailAddress => 'Enter your email address';

  @override
  String get gender => 'Gender';

  @override
  String get chooseGender => 'Choose Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get haveAnAccount => 'Have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get resendCodeIn30s => 'Resend Code';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get validEmailAddress => 'Enter a valid email address';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordMin8Characters => 'Password must be at least 8 characters';

  @override
  String get passwordMustContainUppercase => 'Password must contain at least one uppercase letter';

  @override
  String get passwordMustContainLowercase => 'Password must contain at least one lowercase letter';

  @override
  String get passwordMustContainDigit => 'Password must contain at least one digit';

  @override
  String get passwordMustContainSpecialCharacter => 'Password must contain at least one special character';

  @override
  String get footerTextRegister => 'Designed & developed by 360ground\nand Ministry of innovation and technology (MINT)';

  @override
  String get welcomeTo => 'Welcome To';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get sendMoney => 'Send Money';

  @override
  String get features => 'Features';

  @override
  String get mygovConnect => 'MYGOV CONNECT';

  @override
  String get searchMygovConnect => 'Search MyGov Connect';

  @override
  String get viewAll => 'View All';

  @override
  String get latestNews => 'Latest News';

  @override
  String get browseMoreNews => 'Browse More News';

  @override
  String get browseAllNews => 'Browse All News';

  @override
  String get lookingForEmergencyContacts => 'Looking For\nEmergency Contacts ?';

  @override
  String get emergencyContactsList => 'Emergency Contacts List';

  @override
  String get newAlertMessage => 'New Alert: There is a new alert in your area, click here to view details.';

  @override
  String get postedDaysAgo => 'Posted 1 day ago';

  @override
  String get recipientName => 'Recipient Name';

  @override
  String get enterRecipientName => 'Enter recipient\'s full name';

  @override
  String get amount => 'Amount';

  @override
  String get transactionPin => 'Transaction PIN';

  @override
  String get recipientNameRequired => 'Recipient name is required';

  @override
  String get validPhoneNumber => 'Please enter a valid phone number';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get validAmount => 'Please enter a valid amount';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get instantTransfer => 'Instant Transfer';

  @override
  String get instantTransferDesc => 'Send money in seconds';

  @override
  String get secure => 'Secure';

  @override
  String get secureDesc => 'Bank-level security';

  @override
  String get lowFees => 'Low Fees';

  @override
  String get lowFeesDesc => 'Competitive rates';

  @override
  String get support24 => '24/7 Support';

  @override
  String get support24Desc => 'Always here to help';

  @override
  String get send => 'Send';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get success => 'Success!';

  @override
  String get error => 'Error!';

  @override
  String get warning => 'Warning';

  @override
  String get confirmTransfer => 'Confirm Transfer';

  @override
  String get transferSuccessful => 'Transfer Successful!';

  @override
  String get transferSuccessMessage => 'Your money has been sent successfully.';

  @override
  String get successDialogMessage =>
      'This is a beautiful success dialog with the Abay design system.';

  @override
  String get errorDialogMessage =>
      'This is a beautiful error dialog with the Abay design system.';

  @override
  String get processingRequest => 'Processing your request...';

  @override
  String get done => 'Done!';

  @override
  String get loadingComplete => 'The loading demo is complete.';

  // Alerts Page
  @override
  String get alerts => 'Alerts';

  @override
  String get searchForAlert => 'Search for an alert';

  @override
  String get results => 'Results';

  @override
  String get all => 'All';

  @override
  String get emergencies => 'Emergencies';

  @override
  String get weather => 'Weather';

  @override
  String get services => 'Services';

  // Alert Detail Page
  @override
  String get alert => 'Alert';

  @override
  String get details => 'Details';

  @override
  String get noAdditionalDetails => 'No additional details available.';

  @override
  String get noEvacuationCenters => 'No evacuation centers listed.';

  @override
  String get authoritiesOnHighAlert => 'Local authorities and emergency services are on high alert and assisting with evacuation efforts. Please follow official guidelines...';

  @override
  String get affectedAreas => 'Affected Areas';

  @override
  String get viewAffectedAreasOnMap => 'View Affected Areas On Map';

  @override
  String get share => 'Share';

  @override
  String get callEmergencyContact => 'Call Emergency Contact';

  @override
  String get issued => 'Issued';

  // News Page
  @override
  String get news => 'News';

  @override
  String get health => 'Health';

  @override
  String get community => 'Community';

  @override
  String get technology => 'Technology';

  @override
  String get governance => 'Governance';

  @override
  String get jobs => 'Jobs';

  @override
  String get publicHealth => 'Public Health';

  @override
  String get searchForNews => 'Search for a news';

  // News Detail Page
  @override
  String get headline => 'Headline';

  @override
  String get article => 'Article';

  @override
  String get similarNews => 'Similar News';

  // Surveys & Polls Page
  @override
  String get surveysPolls => 'Surveys & Polls';

  @override
  String get searchForSurveyPoll => 'Search for a survey or poll';

  @override
  String get surveys => 'Surveys';

  @override
  String get polls => 'Polls';

  @override
  String get transport => 'Transport';

  @override
  String get myParticipations => 'My participations';

  @override
  String get noActiveParticipations => 'You have no active participations.';

  // Survey Detail Page
  @override
  String get survey => 'Survey';

  @override
  String get description => 'Description';

  @override
  String get questions => 'Questions';

  @override
  String get confidentialMessage => 'Your responses are confidential and anonymous.';

  @override
  String get typeAnswerHere => 'Type your answer here...';

  @override
  String get submit => 'Submit';

  @override
  String get surveySubmittedSuccess => 'Survey submitted successfully!';

  // Profile Page
  @override
  String get profile => 'Profile';

  @override
  String get resolutionSummary => 'Resolution Summary';

  @override
  String get averageResolutionTime => 'Average Resolution Time';

  @override
  String get days => 'Days';

  @override
  String get casesInProgress => 'Cases in Progress';

  @override
  String get overallCompliance => 'Overall Compliance';

  @override
  String get totalCasesResolved => 'Total Cases Resolved';

  @override
  String get resolved => 'Resolved';

  @override
  String get pending => 'Pending';

  @override
  String get rejected => 'Rejected';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get changePassword => 'Change Password';

  @override
  String get rateApp => 'Rate App';

  @override
  String get logout => 'Logout';

  @override
  String get appVersion => 'App version';

  // Filter Search Modal
  @override
  String get whatAreYouLookingFor => 'What Are You\nLooking For?';

  @override
  String get filterNews => 'Filter news';

  @override
  String get region => 'Region';

  @override
  String get selectRegion => 'Select region';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select category';

  @override
  String get date => 'Date';

  @override
  String get from => 'from';

  @override
  String get to => 'to';

  @override
  String get sortBy => 'Sort By';

  @override
  String get chooseSortOrder => 'Choose sort order';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get oldestFirst => 'Oldest First';

  @override
  String get mostRelevant => 'Most Relevant';

  @override
  String get rememberMyPreference => 'Remember my preference';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get apply => 'Apply';

  @override
  String get addisAbaba => 'Addis Ababa';

  @override
  String get bahirDar => 'Bahir Dar';

  @override
  String get direDawa => 'Dire Dawa';

  @override
  String get mekelle => 'Mekelle';

  @override
  String get hawassa => 'Hawassa';

  // Affected Areas Map Page
  @override
  String get affectedAreasByEmergency => 'Affected Areas By Emergency';

  @override
  String get highlyAffected => 'Highly affected';

  @override
  String get slightlyAffected => 'Slightly affected';

  @override
  String get home => 'Home';

  @override
  String get gifts => 'Gifts';

  @override
  String get history => 'History';

  @override
  String get todayExchangeRate => 'Today\'s exchange rate';

  @override
  String get usdToBirr => '1 USD = 143 BIRR';

  @override
  String get birrBonus => '+ 10 BIRR bonus';

  @override
  String get ifSentWith => 'If sent with';

  @override
  String get expressMoney => 'Express Money';

  @override
  String get cashPickup => 'Cash Pickup';

  @override
  String get giftYourLovedOnce => 'Gift your loved once';

  @override
  String get viewMore => 'View More';

  @override
  String confirmTransferMessage(String amount, String recipient) {
    return 'Are you sure you want to send ETB $amount to $recipient?';
  }
}

/// Amharic Language Strings
class AmharicStrings extends LanguageStrings {
  @override
  String get appName => 'አባይ ገንዘብ ማስተላለፊያ';

  @override
  String get appTagline => 'የእርስዎ የታመነ የገንዘብ ማስተላለፊያ አጋር';

  @override
  String get loading => 'እየጫን ነው...';

  @override
  String get skip => 'ዝለል';

  @override
  String get continue_ => 'ቀጥል';

  @override
  String get start => 'ጀምር';

  @override
  String get welcome => 'እንኳን ደህና መጣህ';

  @override
  String get next => 'ቀጣይ';

  @override
  String get footerText => 'በኢኖቬሽንና ቴክኖሎጂ ሚኒስቴር (ሚንት) በ360ground እና የተነደፈ እና የተገነባ';

  @override
  String get onboardingTitle1 => 'ፈጣን እና ደህንነቱ የተጠበቀ\nገንዘብ ማስተላለፊያ';

  @override
  String get onboardingDesc1 =>
      'እንኳን ወደ ማይገቨ ኮኔክት በደህና መጡ። ለመንግሥት መረጃዎችና የአደጋ ማስጠንቀቂያዎች የታመነ ምንጭዎ፣';

  @override
  String get onboardingTitle2 => 'ዝቅተኛ ክፍያ እና\nምርጥ ተመን';

  @override
  String get onboardingDesc2 =>
      'ለእርስዎ የተበጁ ማስጠንቀቂያዎችና የአካባቢ የድንገተኛ አደጋ የእውቂያ ዝርዝሮች በእጅዎ ጫፍ አሉ።';

  @override
  String get onboardingTitle3 => '24/7 ድጋፍ እና\nአስተማማኝ አገልግሎት';

  @override
  String get onboardingDesc3 =>
      'ድምፅዎ ይሰማ፣ የዳሰሳ ጥናቶችን ይቀላቀሉ እንዲሁም አገልግሎቶችን ይቀርጹ';

  @override
  String get signin => 'ግባ';

  @override
  String get signup => 'ተመዝግብ';

  @override
  String get pleaseLogin => 'እባክዎ ለመቀጠል ይግቡ';

  @override
  String get phoneNumber => 'ስልክ ቁጥር';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get donothaveAccount => 'መለያ የለዎትም';

  @override
  String get forgotPassword => 'የይለፍ ቃል ረሱ';

  @override
  String get createAccount => 'መለያ ይፍጠሩ';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get emailAddress => 'የኢሜል አድራሻ';

  @override
  String get repeatPassword => 'የይለፍ ቃል ድገም';

  @override
  String get accountAgreement => 'የመለያ ስምምነት';

  @override
  String get phone => 'ስልክ';

  @override
  String get email => 'ኢሜይል';

  @override
  String get confirmPhoneNumber => 'ስልክ ቁጥር ያረጋግጡ';

  @override
  String get otpCodeMessage => 'ወደ ስልክ ቁጥርዎ የተላከውን 6-አሃዝ ኮድ ያስገቡ።';

  @override
  String get verify => 'አረጋግጥ';

  @override
  String get resendCode => 'ኮድ በ30ሰከንድ ውስጥ እንደገና ይላኩ';

  @override
  String get continueAsGuest => 'እንደ እንግዳ ይቀጥሉ';

  @override
  String get orContinueWithLimitedFeatures => 'ወይም በውስን ባህሪያት ይቀጥሉ';

  @override
  String get username => 'የተጠቃሚ ስም';

  @override
  String get enterUsername => 'የተጠቃሚ ስምዎን ያስገቡ';

  @override
  String get usernameRequired => 'የተጠቃሚ ስም ያስፈልጋል';

  @override
  String get userName => 'የተጠቃሚ ስም';

  @override
  String get enterUserName => 'የተጠቃሚ ስምዎን ያስገቡ';

  @override
  String get firstName => 'የመጀመሪያ ስም';

  @override
  String get enterFirstName => 'የመጀመሪያ ስምዎን ያስገቡ';

  @override
  String get lastName => 'የመጨረሻ ስም';

  @override
  String get enterLastName => 'የመጨረሻ ስምዎን ያስገቡ';

  @override
  String get enterPhoneNumber => '900000000';

  @override
  String get emailAddressOptional => 'የኢሜል አድራሻ (አማራጭ)';

  @override
  String get enterEmailAddress => 'የኢሜል አድራሻዎን ያስገቡ';

  @override
  String get gender => 'ጾታ';

  @override
  String get chooseGender => 'ጾታ ይምረጡ';

  @override
  String get male => 'ወንድ';

  @override
  String get female => 'ሴት';

  @override
  String get haveAnAccount => 'መለያ አሎት?';

  @override
  String get signUp => 'ተመዝግብ';

  @override
  String get resendCodeIn30s => 'ኮድ በ30ሰከንድ ውስጥ እንደገና ይላኩ';

  @override
  String get fullNameRequired => 'ሙሉ ስም ያስፈልጋል';

  @override
  String get firstNameRequired => 'የመጀመሪያ ስም ያስፈልጋል';

  @override
  String get lastNameRequired => 'የመጨረሻ ስም ያስፈልጋል';

  @override
  String get phoneNumberRequired => 'ስልክ ቁጥር ያስፈልጋል';

  @override
  String get validEmailAddress => 'ትክክለኛ የኢሜል አድራሻ ያስገቡ';

  @override
  String get passwordsDoNotMatch => 'የይለፍ ቃላት አይዛመዱም';

  @override
  String get passwordMin8Characters => 'የይለፍ ቃል ቢያንስ 8 ቁምፊዎች መሆን አለበት';

  @override
  String get passwordMustContainUppercase => 'የይለፍ ቃል ቢያንስ አንድ የላይኛው ሁሉ ፊደል መያዝ አለበት';

  @override
  String get passwordMustContainLowercase => 'የይለፍ ቃል ቢያንስ አንድ የታችኛው ሁሉ ፊደል መያዝ አለበት';

  @override
  String get passwordMustContainDigit => 'የይለፍ ቃል ቢያንስ አንድ ቁጥር መያዝ አለበት';

  @override
  String get passwordMustContainSpecialCharacter => 'የይለፍ ቃል ቢያንስ አንድ ልዩ ቁምፊ መያዝ አለበት';

  @override
  String get footerTextRegister => 'በ360ground እና የኢኖቬሽንና ቴክኖሎጂ ሚኒስቴር (ሚንት) የተነደፈ እና የተገነባ';

  @override
  String get welcomeTo => 'እንኳን ወደ';

  @override
  String get availableBalance => 'የሚገኝ ሂሳብ';

  @override
  String get sendMoney => 'ገንዘብ ላክ';

  @override
  String get features => 'ባህሪያት';

  @override
  String get mygovConnect => 'የእኔ መንግስት ግንኙነት';

  @override
  String get searchMygovConnect => 'የእኔ መንግስት ግንኙነትን ይፈልጉ';

  @override
  String get viewAll => 'ሁሉንም ይመልከቱ';

  @override
  String get latestNews => 'የቅርብ ጊዜ ዜና';

  @override
  String get browseMoreNews => 'ተጨማሪ ዜናዎችን ያስሱ';

  @override
  String get browseAllNews => 'ሁሉንም ዜናዎች ያስሱ';

  @override
  String get lookingForEmergencyContacts => 'የአደጋ ጊዜ ዕውቂያዎችን\nይፈልጋሉ?';

  @override
  String get emergencyContactsList => 'የአደጋ ጊዜ ዕውቂያዎች ዝርዝር';

  @override
  String get newAlertMessage => 'አዲስ ማንቂያ፡ በአካባቢዎ አዲስ ማንቂያ አለ፣ ዝርዝሮችን ለማየት እዚህ ጠቅ ያድርጉ።';

  @override
  String get postedDaysAgo => 'ከ1 ቀን በፊት ተለጥፏል';

  @override
  String get recipientName => 'የተቀባይ ስም';

  @override
  String get enterRecipientName => 'የተቀባይውን ሙሉ ስም ያስገቡ';

  @override
  String get amount => 'መጠን';

  @override
  String get transactionPin => 'የግብይት ፒን';

  @override
  String get recipientNameRequired => 'የተቀባይ ስም ያስፈልጋል';

  @override
  String get validPhoneNumber => 'እባክዎ ትክክለኛ ስልክ ቁጥር ያስገቡ';

  @override
  String get amountRequired => 'መጠን ያስፈልጋል';

  @override
  String get validAmount => 'እባክዎ ትክክለኛ መጠን ያስገቡ';

  @override
  String get passwordRequired => 'የይለፍ ቃል ያስፈልጋል';

  @override
  String get passwordMinLength => 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት';

  @override
  String get instantTransfer => 'ፈጣን ማስተላለፊያ';

  @override
  String get instantTransferDesc => 'በሰከንዶች ውስጥ ገንዘብ ላክ';

  @override
  String get secure => 'ደህንነቱ የተጠበቀ';

  @override
  String get secureDesc => 'የባንክ ደረጃ ደህንነት';

  @override
  String get lowFees => 'ዝቅተኛ ክፍያ';

  @override
  String get lowFeesDesc => 'ተወዳዳሪ ተመኖች';

  @override
  String get support24 => '24/7 ድጋፍ';

  @override
  String get support24Desc => 'ሁልጊዜ እዚህ እንረዳዎታለን';

  @override
  String get send => 'ላክ';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get confirm => 'አረጋግጥ';

  @override
  String get ok => 'እሺ';

  @override
  String get yes => 'አዎ';

  @override
  String get no => 'አይ';

  @override
  String get success => 'ተሳክቷል!';

  @override
  String get error => 'ስህተት!';

  @override
  String get warning => 'ማስጠንቀቂያ';

  @override
  String get confirmTransfer => 'ማስተላለፊያ አረጋግጥ';

  @override
  String get transferSuccessful => 'ማስተላለፊያ ተሳክቷል!';

  @override
  String get transferSuccessMessage => 'ገንዘብዎ በተሳካ ሁኔታ ተልኳል።';

  @override
  String get successDialogMessage =>
      'ይህ በአባይ ዲዛይን ሲስተም የተሰራ ቆንጆ የስኬት መልዕክት ነው።';

  @override
  String get errorDialogMessage => 'ይህ በአባይ ዲዛይን ሲስተም የተሰራ ቆንጆ የስህተት መልዕክት ነው።';

  @override
  String get processingRequest => 'ጥያቄዎን እየሰራን ነው...';

  @override
  String get done => 'ተጠናቋል!';

  @override
  String get loadingComplete => 'የመጫን ማሳያ ተጠናቋል።';

  // Alerts Page
  @override
  String get alerts => 'ማንቂያዎች';

  @override
  String get searchForAlert => 'ማንቂያ ይፈልጉ';

  @override
  String get results => 'ውጤቶች';

  @override
  String get all => 'ሁሉም';

  @override
  String get emergencies => 'አደጋዎች';

  @override
  String get weather => 'የአየር ሁኔታ';

  @override
  String get services => 'አገልግሎቶች';

  // Alert Detail Page
  @override
  String get alert => 'ማንቂያ';

  @override
  String get details => 'ዝርዝሮች';

  @override
  String get noAdditionalDetails => 'ተጨማሪ ዝርዝሮች የሉም።';

  @override
  String get noEvacuationCenters => 'የመውጣት ማእከሎች አልተዘረዘሩም።';

  @override
  String get authoritiesOnHighAlert => 'የአካባቢ ባለስልጣናት እና የአደጋ ጊዜ አገልግሎቶች ከፍተኛ ትኩረት ላይ ናቸው። እባክዎ ኦፊሴላዊ መመሪያዎችን ይከተሉ...';

  @override
  String get affectedAreas => 'የተጎዱ አካባቢዎች';

  @override
  String get viewAffectedAreasOnMap => 'የተጎዱ አካባቢዎችን በካርታ ላይ ይመልከቱ';

  @override
  String get share => 'አጋራ';

  @override
  String get callEmergencyContact => 'የአደጋ ጊዜ ዕውቂያ ደውል';

  @override
  String get issued => 'ተሰጥቷል';

  // News Page
  @override
  String get news => 'ዜና';

  @override
  String get health => 'ጤና';

  @override
  String get community => 'ማህበረሰብ';

  @override
  String get technology => 'ቴክኖሎጂ';

  @override
  String get governance => 'አስተዳደር';

  @override
  String get jobs => 'ሥራዎች';

  @override
  String get publicHealth => 'የህዝብ ጤና';

  @override
  String get searchForNews => 'ዜና ይፈልጉ';

  // News Detail Page
  @override
  String get headline => 'ርዕስ';

  @override
  String get article => 'ጽሁፍ';

  @override
  String get similarNews => 'ተመሳሳይ ዜናዎች';

  // Surveys & Polls Page
  @override
  String get surveysPolls => 'ዳሰሳዎች እና መራጮች';

  @override
  String get searchForSurveyPoll => 'ዳሰሳ ወይም ምርጫ ይፈልጉ';

  @override
  String get surveys => 'ዳሰሳዎች';

  @override
  String get polls => 'መራጮች';

  @override
  String get transport => 'ትራንስፖርት';

  @override
  String get myParticipations => 'የእኔ ተሳትፎዎች';

  @override
  String get noActiveParticipations => 'ንቁ ተሳትፎዎች የሉዎትም።';

  // Survey Detail Page
  @override
  String get survey => 'ዳሰሳ';

  @override
  String get description => 'መግለጫ';

  @override
  String get questions => 'ጥያቄዎች';

  @override
  String get confidentialMessage => 'የእርስዎ ምላሾች ሚስጥራዊ እና ስም-አልባ ናቸው።';

  @override
  String get typeAnswerHere => 'መልስዎን እዚህ ይተይቡ...';

  @override
  String get submit => 'አስገባ';

  @override
  String get surveySubmittedSuccess => 'ዳሰሳው በተሳካ ሁኔታ ቀርቧል!';

  // Profile Page
  @override
  String get profile => 'መገለጫ';

  @override
  String get resolutionSummary => 'የመፍትሄ ማጠቃለያ';

  @override
  String get averageResolutionTime => 'አማካይ የመፍትሄ ጊዜ';

  @override
  String get days => 'ቀናት';

  @override
  String get casesInProgress => 'በሂደት ላይ ያሉ ጉዳዮች';

  @override
  String get overallCompliance => 'አጠቃላይ ተገዥነት';

  @override
  String get totalCasesResolved => 'የተፈቱ አጠቃላይ ጉዳዮች';

  @override
  String get resolved => 'ተፈትቷል';

  @override
  String get pending => 'በመጠባበቅ ላይ';

  @override
  String get rejected => 'ተቀባይነት አላገኘም';

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get language => 'ቋንቋ';

  @override
  String get english => 'እንግሊዝኛ';

  @override
  String get changePassword => 'የይለፍ ቃል ይቀይሩ';

  @override
  String get rateApp => 'መተግበሪያውን ይገምግሙ';

  @override
  String get logout => 'ውጣ';

  @override
  String get appVersion => 'የመተግበሪያ ስሪት';

  // Filter Search Modal
  @override
  String get whatAreYouLookingFor => 'ምን\nይፈልጋሉ?';

  @override
  String get filterNews => 'ዜና ያጣሩ';

  @override
  String get region => 'ክልል';

  @override
  String get selectRegion => 'ክልል ይምረጡ';

  @override
  String get category => 'ምድብ';

  @override
  String get selectCategory => 'ምድብ ይምረጡ';

  @override
  String get date => 'ቀን';

  @override
  String get from => 'ከ';

  @override
  String get to => 'እስከ';

  @override
  String get sortBy => 'ደርድር በ';

  @override
  String get chooseSortOrder => 'የደርድር ቅደም ተከተል ይምረጡ';

  @override
  String get newestFirst => 'አዲሱ በመጀመሪያ';

  @override
  String get oldestFirst => 'አሮጌው በመጀመሪያ';

  @override
  String get mostRelevant => 'በጣም ተዛማጅ';

  @override
  String get rememberMyPreference => 'ምርጫዬን አስታውስ';

  @override
  String get clearFilters => 'ማጣሪያዎችን አጽዳ';

  @override
  String get apply => 'ተግብር';

  @override
  String get addisAbaba => 'አዲስ አበባ';

  @override
  String get bahirDar => 'ባህር ዳር';

  @override
  String get direDawa => 'ድሬ ዳዋ';

  @override
  String get mekelle => 'መቀሌ';

  @override
  String get hawassa => 'ሐዋሳ';

  // Affected Areas Map Page
  @override
  String get affectedAreasByEmergency => 'በአደጋ የተጎዱ አካባቢዎች';

  @override
  String get highlyAffected => 'በከፍተኛ ደረጃ የተጎዱ';

  @override
  String get slightlyAffected => 'በትንሹ የተጎዱ';

  @override
  String get home => 'ቤት';

  @override
  String get gifts => 'ስጦታዎች';

  @override
  String get history => 'ታሪክ';

  @override
  String get todayExchangeRate => 'የዛሬ የምንዛሪ ተመን';

  @override
  String get usdToBirr => '1 USD = 143 ብር';

  @override
  String get birrBonus => '+ 10 ብር ቦነስ';

  @override
  String get ifSentWith => 'የተላከ ከሆነ በ';

  @override
  String get expressMoney => 'ኤክስፕረስ ገንዘብ';

  @override
  String get cashPickup => 'ገንዘብ መውሰድ';

  @override
  String get giftYourLovedOnce => 'ለወዳጆችዎ ስጦታ ይስጡ';

  @override
  String get viewMore => 'ተጨማሪ ይመልከቱ';

  @override
  String confirmTransferMessage(String amount, String recipient) {
    return 'ETB $amount ወደ $recipient መላክ እርግጠኛ ነዎት?';
  }
}