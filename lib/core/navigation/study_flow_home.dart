import 'package:flutter/material.dart';

class StudyFlowHome extends StatefulWidget {
  final Widget dashboard;
  final Widget subjects;
  final VoidCallback onDashboardSelected;
  final VoidCallback onSubjectsSelected;

  const StudyFlowHome({
    super.key,
    required this.dashboard,
    required this.subjects,
    required this.onDashboardSelected,
    required this.onSubjectsSelected,
  });

  @override
  State<StudyFlowHome> createState() => _StudyFlowHomeState();
}

class _StudyFlowHomeState extends State<StudyFlowHome> {
  var _selectedIndex = 0;

  void _selectDestination(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      widget.onDashboardSelected();
      return;
    }

    widget.onSubjectsSelected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [widget.dashboard, widget.subjects],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Matérias',
          ),
        ],
      ),
    );
  }
}
