import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/drone.dart';
import '../providers/drone_provider.dart';
import '../theme/app_theme.dart';

class AddEditDroneScreen extends StatefulWidget {
  const AddEditDroneScreen({super.key});

  @override
  State<AddEditDroneScreen> createState() => _AddEditDroneScreenState();
}

class _AddEditDroneScreenState extends State<AddEditDroneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  String _selectedType = 'Surveillance';
  double _battery = 80.0;
  bool _isEdit = false;
  Drone? _existingDrone;

  final _types = ['Surveillance', 'Cargo', 'Mapping', 'Rescue'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && !_isEdit) {
      final provider = context.read<DroneProvider>();
      final drone = provider.drones.firstWhere((d) => d.id == args);
      _existingDrone = drone;
      _isEdit = true;
      _nameController.text = drone.name;
      _idController.text = drone.id.toString();
      _selectedType = drone.droneType;
      _battery = drone.batteryLevel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Drone' : 'Add Drone'),
        backgroundColor: AppColors.background,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Drone Name
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Drone Name',
                prefixIcon: Icon(Icons.flight, color: AppColors.accent),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
            ),
            const SizedBox(height: 16),

            // Drone ID (auto-generated, read-only for edit)
            TextFormField(
              controller: _idController,
              readOnly: _isEdit,
              style: TextStyle(
                color: _isEdit ? AppColors.textSecondary : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Drone ID',
                hintText: _isEdit ? '' : 'Leave blank to auto-generate',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.tag, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 16),

            // Drone Type dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  dropdownColor: AppColors.cardColor,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
                  items: _types.map((t) => DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(_iconForType(t), color: AppColors.accent, size: 18),
                        const SizedBox(width: 10),
                        Text(t, style: const TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Battery Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Initial Battery',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                Text(
                  '${_battery.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Slider(
              value: _battery,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (v) => setState(() => _battery = v),
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _save,
              icon: Icon(_isEdit ? Icons.save : Icons.add),
              label: Text(
                _isEdit ? 'Save Changes' : 'Add Drone',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Cargo': return Icons.inventory_2;
      case 'Mapping': return Icons.map;
      case 'Rescue': return Icons.local_hospital;
      default: return Icons.videocam;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<DroneProvider>();
    final now = DateTime.now().toIso8601String();

    if (_isEdit && _existingDrone != null) {
      final updated = _existingDrone!.copyWith(
        name: _nameController.text.trim(),
        droneType: _selectedType,
        batteryLevel: _battery,
      );
      await provider.updateDrone(updated);
    } else {
      const uuid = Uuid();
      final drone = Drone(
        name: _nameController.text.trim(),
        droneType: _selectedType,
        batteryLevel: _battery,
        signalStrength: 75,
        latitude: 12.9716 + (DateTime.now().millisecondsSinceEpoch % 100) * 0.0001,
        longitude: 77.5946 + (DateTime.now().millisecondsSinceEpoch % 100) * 0.0001,
        altitude: 50.0,
        status: _battery < 20 ? 'Critical' : 'Idle',
        missionStatus: 'Standby',
        createdAt: now,
      );
      await provider.addDrone(drone);
    }

    if (mounted) Navigator.pop(context);
  }
}
