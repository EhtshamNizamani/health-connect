
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/prescription_item_entity.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/widgets/add_button.dart';

class PrescriptionList extends StatelessWidget {
  final List<PrescriptionItemEntity> items;
  final VoidCallback onAddItem;
  final Function(PrescriptionItemEntity) onDeleteItem; // Now takes the whole entity
  
  const PrescriptionList({
    super.key,
    required this.items,
    required this.onAddItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // If the list is not empty, show the items
        if (items.isNotEmpty)
          ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              // <<< --- THE FIX IS HERE ---
              // 'item' is now a strongly-typed PrescriptionItemEntity
              final PrescriptionItemEntity item = items[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: const Icon(CupertinoIcons.pano_fill, color: Colors.blueGrey),
                  // Access properties using dot notation (item.medicine)
                  title: Text(item.medicine, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.dosage),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.trash, color: Colors.red),
                    // Pass the whole entity object back to the BLoC for removal
                    onPressed: () => onDeleteItem(item),
                  ),
                ),
              );
            },
          ),
        
        // Always show the "Add" button
        const SizedBox(height: 8),
        AddButton(
          label: "Add Medicine",
          onTap: onAddItem,
        ),
      ],
    );
  }
}