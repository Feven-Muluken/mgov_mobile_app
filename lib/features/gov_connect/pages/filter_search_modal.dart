import 'package:flutter/material.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';
import 'package:mgov_apps/features/gov_connect/pages/home_page.dart';

// --- The Filter Modal Widget ---

class FilterSearchModal extends StatefulWidget {
  const FilterSearchModal({super.key});

  @override
  State<FilterSearchModal> createState() => _FilterSearchModalState();
}

class _FilterSearchModalState extends State<FilterSearchModal> {
  String _contentType = 'News'; // Tracks which content tab is selected
  String? _selectedRegion;
  String? _selectedCategory;
  String? _selectedSortOrder;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _rememberPreference = false;

  // Getters for translated lists
  List<Map<String, String>> get _regionData => [
    {'key': 'Addis Ababa', 'label': context.stringsNoListen.addisAbaba},
    {'key': 'Bahir Dar', 'label': context.stringsNoListen.bahirDar},
    {'key': 'Dire Dawa', 'label': context.stringsNoListen.direDawa},
    {'key': 'Mekelle', 'label': context.stringsNoListen.mekelle},
    {'key': 'Hawassa', 'label': context.stringsNoListen.hawassa},
  ];

  List<Map<String, String>> get _categoryData => [
    {'key': 'Transport', 'label': context.stringsNoListen.transport},
    {'key': 'Health', 'label': context.stringsNoListen.health},
    {'key': 'Emergency', 'label': context.stringsNoListen.emergencies},
    {'key': 'Technology', 'label': context.stringsNoListen.technology},
    {'key': 'Weather', 'label': context.stringsNoListen.weather},
  ];

  List<Map<String, String>> get _sortOptionsData => [
    {'key': 'Newest First', 'label': context.stringsNoListen.newestFirst},
    {'key': 'Oldest First', 'label': context.stringsNoListen.oldestFirst},
    {'key': 'Most Relevant', 'label': context.stringsNoListen.mostRelevant},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // Use a fixed height or min-height to ensure it looks like a modal
      height: MediaQuery.of(context).size.height * 0.9, 
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Material(
      type: MaterialType.transparency,  
      child:Column(
        children: [
          // Header and Tabs
          _buildHeader(),
          SizedBox(height: 10,),
           _buildTabs(),
           SizedBox(height: 20,),
          const Divider(height: 1),

          // Main Filter Content (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 20),

                  Text(context.strings.filterNews, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 15),

                  // Region Dropdown
                  _buildTranslatedDropdown(
                    title: context.strings.region,
                    hint: context.strings.selectRegion,
                    value: _selectedRegion,
                    items: _regionData,
                    onChanged: (value) => setState(() => _selectedRegion = value),
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  _buildTranslatedDropdown(
                    title: context.strings.category,
                    hint: context.strings.selectCategory,
                    value: _selectedCategory,
                    items: _categoryData,
                    onChanged: (value) => setState(() => _selectedCategory = value),
                  ),
                  const SizedBox(height: 20),

                  // Date Range Picker
                  _buildDateRangePicker(),
                  const SizedBox(height: 20),

                  // Sort By Dropdown
                  _buildSortBy(),
                  const SizedBox(height: 20),

                  // Remember Preference Checkbox
                  _buildPreferenceCheckbox(),
                  const SizedBox(height: 80), // Space for bottom buttons
                ],
              ),
            ),
          ),

          // Bottom Action Buttons (Fixed)
          _buildActionButtons(),
        ],
      ),
      )
    );
  }
  
  Widget _closeIndicator(){

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      },
      child:Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.red.shade50, // light red background
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.close,
          color: Colors.red, // red “X”
          size: 20, // adjust to match your design
        ),
      ),
    ),
    );
  }

  // --- Header: Title and Tabs ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.strings.whatAreYouLookingFor,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black45),
          ),
          _closeIndicator()
        ],
      ),
    );
  }

  // --- Tabs: News, Alerts, Surveys ---
  Widget _buildTabs() {
    final strings = context.strings;
    final tabData = [
      {'key': 'News', 'label': strings.news, 'icon': Icons.article_outlined},
      {'key': 'Alerts', 'label': strings.alerts, 'icon': Icons.notifications_active_outlined},
      {'key': 'Surveys', 'label': strings.surveys, 'icon': Icons.poll_outlined},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all( 
          color: Colors.grey.shade300, 
          width: 1.0, 
        ),
      ),
      child: Row(
        children: tabData.map((tab) {
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: _buildTabButton(
              tab['key'] as String, 
              tab['label'] as String, 
              tab['icon'] as IconData
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabButton(String key, String label, IconData icon) {
    bool isSelected = _contentType == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _contentType = key;
            // Optionally clear other filters when switching tabs
          });
        }
      },
      avatar: Icon(icon, size: 18),
      selectedColor: Colors.blue.shade700,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
      ),
    ),
    );
  }

  // --- Search Bar ---
  Widget _buildSearchBar() {
    return Column(
      children: [
        
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: context.strings.searchForNews,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // Handle search action
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Translated Dropdown Builder ---
  Widget _buildTranslatedDropdown({
    required String title,
    required String hint,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(hint),
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['key'],
                  child: Text(item['label']!),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // --- Date Range Picker ---
  Widget _buildDateRangePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.strings.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateInput(
                label: context.strings.from,
                date: _startDate,
                onTap: () => _pickDate(true),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.arrow_forward, color: Colors.grey),
            ),
            Expanded(
              child: _buildDateInput(
                label: context.strings.to,
                date: _endDate,
                onTap: () => _pickDate(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateInput({String? label, DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label ?? '' : '${date.month}/${date.day}/${date.year}',
              style: TextStyle(color: date == null ? Colors.grey : Colors.black),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // --- Sort By Input ---
  Widget _buildSortBy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.strings.sortBy, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(context.strings.chooseSortOrder),
              value: _selectedSortOrder,
              icon: const Icon(Icons.sort),
              onChanged: (value) => setState(() => _selectedSortOrder = value),
              items: _sortOptionsData.map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['key'],
                  child: Text(item['label']!),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // --- Preference Checkbox ---
  Widget _buildPreferenceCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberPreference,
          onChanged: (bool? value) {
            setState(() {
              _rememberPreference = value ?? false;
            });
          },
          activeColor: Colors.blue.shade700,
        ),
        Text(context.strings.rememberMyPreference),
      ],
    );
  }

  // --- Bottom Action Buttons ---
  Widget _buildActionButtons() {
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
          Expanded(
            child: OutlinedButton(
              onPressed: _clearFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade700),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(context.strings.clearFilters),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
          child: ElevatedButton( 
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row( 
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, 
              children: [
                Text(context.strings.apply),
                const SizedBox(width: 8), 
                const Icon(Icons.arrow_right_alt, size: 24), 
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedRegion = null;
      _selectedCategory = null;
      _selectedSortOrder = null;
      _startDate = null;
      _endDate = null;
      _rememberPreference = false;
      // In a real app, you'd also clear the text field controller
    });
  }

  void _applyFilters() {
    // In a real app, you would dismiss the modal and pass the filter state back
    Navigator.of(context).pop({
      'contentType': _contentType,
      'region': _selectedRegion,
      'category': _selectedCategory,
      'startDate': _startDate,
      'endDate': _endDate,
      'sortOrder': _selectedSortOrder,
      'rememberPreference': _rememberPreference,
    });
  }
}

