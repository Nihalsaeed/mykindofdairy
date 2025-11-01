import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';

class JournalList extends StatelessWidget {
  final List<JournalEntry> entries;
  final String searchTerm;
  final Function(JournalEntry) onEdit;
  final Function(String) onDelete;

  const JournalList({
    Key? key,
    required this.entries,
    required this.searchTerm,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  List<JournalEntry> _getFilteredEntries() {
    if (searchTerm.isEmpty) {
      return entries;
    }

    final String lowerSearchTerm = searchTerm.toLowerCase();
    return entries.where((entry) {
      // Check if content matches
      bool contentMatch = entry.content.toLowerCase().contains(lowerSearchTerm);
      
      // Check if date matches (formatted or raw)
      bool dateMatch = false;
      try {
        final DateTime entryDate = DateTime.parse(entry.id);
        final String formattedDate = DateFormat('d MMMM yyyy')
            .format(entryDate)
            .toLowerCase();
        dateMatch = formattedDate.contains(lowerSearchTerm) || 
                   entry.id.contains(lowerSearchTerm);
      } catch (e) {
        // If date parsing fails, just check the raw ID
        dateMatch = entry.id.contains(lowerSearchTerm);
      }

      return contentMatch || dateMatch;
    }).toList();
  }

  String _highlightSearchTerm(String text, String searchTerm) {
    if (searchTerm.isEmpty) return text;
    
    // For this implementation, we'll return the text as is
    // In a more advanced implementation, we could use RichText to highlight matches
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final List<JournalEntry> filteredEntries = _getFilteredEntries();

    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'Your journal is empty. Write your first entry!',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    if (filteredEntries.isEmpty) {
      return const Center(
        child: Text(
          'No entries found for your search.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredEntries.length,
      itemBuilder: (context, index) {
        final JournalEntry entry = filteredEntries[index];
        
        // Format the date for display
        String formattedDate = entry.id;
        try {
          final DateTime entryDate = DateTime.parse(entry.id);
          formattedDate = DateFormat('d MMMM yyyy').format(entryDate);
        } catch (e) {
          // If date parsing fails, use the raw ID
          formattedDate = entry.id;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: const Border.fromBorderSide(
              BorderSide(color: Color(0xFF0ea5e9), width: 1), // Neon blue line
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0ea5e9).withOpacity(0.3), // Neon glow
                blurRadius: 15,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete, 
                      color: Colors.grey,
                    ),
                    onPressed: () => onDelete(entry.id),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => onEdit(entry),
                child: Text(
                  _highlightSearchTerm(entry.content, searchTerm),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}