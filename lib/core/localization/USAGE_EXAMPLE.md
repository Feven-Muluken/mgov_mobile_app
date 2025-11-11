# Language Provider Usage Guide

## ⚠️ IMPORTANT: `strings` vs `stringsNoListen`

### Use `context.strings` in:
- ✅ `build()` method
- ✅ Widget builder methods called FROM build
- ✅ Any code that should rebuild when language changes

### Use `context.stringsNoListen` in:
- ✅ Event handlers (onPressed, onTap, etc.)
- ✅ Getters that may be called from event handlers
- ✅ initState, dispose, or other lifecycle methods
- ✅ Any code OUTSIDE the build tree

**Why?** `context.strings` uses `watch()` which triggers rebuilds but can ONLY be called during build. Event handlers need `stringsNoListen` with `read()` instead.

## How to Use Translation in Your Pages

### Method 1: Using the BuildContext Extension (Recommended)

```dart
import 'package:flutter/material.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access strings directly from context
    final strings = context.strings;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appName), // Will automatically use current language
      ),
      body: Column(
        children: [
          Text(strings.welcome),
          Text(strings.onboardingTitle1),
          ElevatedButton(
            onPressed: () {},
            child: Text(strings.signin),
          ),
        ],
      ),
    );
  }
}
```

### Method 2: Using Provider.of

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final strings = languageProvider.strings;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.mygovConnect),
      ),
      body: Text(strings.pleaseLogin),
    );
  }
}
```

## Language Switching Examples

### Example 1: Language Selector Dropdown

```dart
Widget buildLanguageSelector(BuildContext context) {
  final languageProvider = context.languageProvider;
  final currentLang = context.currentLanguage;
  
  return DropdownButton<AppLanguage>(
    value: currentLang,
    items: AppLanguage.values.map((lang) {
      return DropdownMenuItem(
        value: lang,
        child: Row(
          children: [
            Text(lang.flag),
            SizedBox(width: 8),
            Text(lang.name),
          ],
        ),
      );
    }).toList(),
    onChanged: (language) {
      if (language != null) {
        languageProvider.changeLanguage(language);
      }
    },
  );
}
```

### Example 2: Language Toggle Button

```dart
Widget buildLanguageToggle(BuildContext context) {
  final languageProvider = context.languageProvider;
  final strings = context.strings;
  
  return IconButton(
    icon: Icon(Icons.language),
    onPressed: () {
      languageProvider.toggleLanguage();
    },
  );
}
```

### Example 3: Language Selector Bottom Sheet

```dart
void showLanguageSelector(BuildContext context) {
  final languageProvider = context.languageProvider;
  
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return ListView(
        shrinkWrap: true,
        children: AppLanguage.values.map((language) {
          return ListTile(
            leading: Text(language.flag, style: TextStyle(fontSize: 24)),
            title: Text(language.name),
            trailing: languageProvider.currentLanguage == language
                ? Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              languageProvider.changeLanguage(language);
              Navigator.pop(context);
            },
          );
        }).toList(),
      );
    },
  );
}
```

## Real Example: Update Onboarding Page Header

Replace the hardcoded "English" text in your onboarding_page.dart:

```dart
// OLD CODE (line 135-139)
Text(
  "English",
  style: TextStyle(color: Colors.black54),
),

// NEW CODE
Text(
  context.currentLanguage.name, // Shows "English" or "አማርኛ"
  style: TextStyle(color: Colors.black54),
),
```

And make the language selector clickable:

```dart
Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            context.languageProvider.toggleLanguage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.language, color: Colors.black54, size: 18),
                const SizedBox(width: 8),
                Text(
                  context.currentLanguage.name,
                  style: const TextStyle(color: Colors.black54),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
```

## Update Text to Use Translations

### Onboarding Page Example:

```dart
// Replace hardcoded text with translations
final List<Map<String, String>> onboardingData = [
  {
    "title": context.strings.onboardingTitle1,
    "subtitle": context.strings.onboardingDesc1,
    "image": "assets/images/gov_con_onboa_img_1.png",
  },
  {
    "title": context.strings.onboardingTitle2,
    "subtitle": context.strings.onboardingDesc2,
    "image": "assets/images/gov_con_onboa_img_2.png",
  },
  {
    "title": context.strings.onboardingTitle3,
    "subtitle": context.strings.onboardingDesc3,
    "image": "assets/images/gov_con_onboa_img_3.png",
  },
];
```

### Login Page Example:

```dart
Text(
  context.strings.signin,  // Instead of "Sign In"
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF003399)
  ),
),

Text(
  context.strings.pleaseLogin,  // Instead of "Please login to continue."
  style: TextStyle(fontSize: 16, color: Color(0xFF003399)),
),
```

## Common Patterns

### ✅ Correct: Using strings in build method
```dart
@override
Widget build(BuildContext context) {
  return Text(context.strings.welcome); // ✅ OK - in build method
}
```

### ✅ Correct: Using stringsNoListen in event handler
```dart
void _onButtonPressed() {
  final message = context.stringsNoListen.welcome; // ✅ OK - event handler
  print(message);
}
```

### ✅ Correct: Using stringsNoListen in getter
```dart
// This getter can be called from event handlers
List<String> get titles => [
  context.stringsNoListen.title1, // ✅ OK - getter
  context.stringsNoListen.title2,
];
```

### ❌ Wrong: Using strings in event handler
```dart
void _onButtonPressed() {
  final message = context.strings.welcome; // ❌ ERROR!
  // Will crash: "Tried to listen to a value exposed with provider, 
  // from outside of the widget tree"
}
```

## Notes

- The app will automatically rebuild when language changes
- Language preference is saved and persists across app restarts
- Use `context.strings` in build methods for automatic rebuilds
- Use `context.stringsNoListen` in event handlers and getters
- Use `context.languageProvider` to access language control methods
- Use `context.currentLanguage` in build, `context.currentLanguageNoListen` in event handlers

