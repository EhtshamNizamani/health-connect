import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_event.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // CHANGE THIS: Return Padding instead of SliverToBoxAdapter
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search by doctor name or specialty...",
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.outline),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
        onChanged: (value) {
          context.read<DoctorListBloc>().add(SearchQueryChanged(value));
        },
      ),
    );
  }
}