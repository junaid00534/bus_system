import 'package:flutter/material.dart';
import 'package:bus_ticket_system/admin/models/bus_model.dart';
import 'package:bus_ticket_system/database/db_helper.dart';
import 'package:intl/intl.dart';

class AddEditBusScreen extends StatefulWidget {
  final BusModel? bus;

  const AddEditBusScreen({super.key, this.bus});

  @override
  State<AddEditBusScreen> createState() => _AddEditBusScreenState();
}

class _AddEditBusScreenState extends State<AddEditBusScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController busNameController;
  late final TextEditingController routeNameController;
  late final TextEditingController fromController;
  late final TextEditingController toController;
  late final TextEditingController viaController;
  late final TextEditingController dateController;
  late final TextEditingController timeController;
  late final TextEditingController seatsController;
  late final TextEditingController fareController;
  late final TextEditingController originalFareController;
  late final TextEditingController discountController;
  late final TextEditingController discountLabelController;
  late final TextEditingController busNumberController;
  late final TextEditingController driverController;

  String busClass = "Gold";
  bool refreshment = false;

  @override
  void initState() {
    super.initState();

    busNameController = TextEditingController();
    routeNameController = TextEditingController();
    fromController = TextEditingController();
    toController = TextEditingController();
    viaController = TextEditingController();
    dateController =
        TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    timeController =
        TextEditingController(text: DateFormat('hh:mm a').format(DateTime.now()));
    seatsController = TextEditingController();
   fareController = TextEditingController();
    originalFareController = TextEditingController();
    discountController = TextEditingController();
    discountLabelController = TextEditingController();
    busNumberController = TextEditingController();
    driverController = TextEditingController();

    if (widget.bus != null) {
      final b = widget.bus!;
      busNameController.text = b.busName;
      routeNameController.text = b.routeName;
      fromController.text = b.fromCity;
      toController.text = b.toCity;
      viaController.text = b.routeVia;
      dateController.text = b.date;
      timeController.text = b.time;
      busClass = b.busClass;
      seatsController.text = b.seats.toString();
      fareController.text = b.fare.toString();
      originalFareController.text = b.originalFare.toString();
      discountController.text = b.discount.toString();
      discountLabelController.text = b.discountLabel;
      refreshment = b.refreshment;
      busNumberController.text = b.busNumber;
      driverController.text = b.driverName;
    }
  }

  @override
  void dispose() {
    busNameController.dispose();
    routeNameController.dispose();
    fromController.dispose();
    toController.dispose();
    viaController.dispose();
    dateController.dispose();
    timeController.dispose();
    seatsController.dispose();
    fareController.dispose();
    originalFareController.dispose();
    discountController.dispose();
    discountLabelController.dispose();
    busNumberController.dispose();
    driverController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dateController.text) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      timeController.text = picked.format(context);
    }
  }

  Future<void> _saveBus() async {
    if (!_formKey.currentState!.validate()) return;

    final date = DateTime.tryParse(dateController.text) ?? DateTime.now();
    final dayName = DateFormat('EEEE').format(date);

    final bus = BusModel(
      id: widget.bus?.id,
      busName: busNameController.text.trim(),
      routeName: routeNameController.text.trim(),
      fromCity: fromController.text.trim(),
      toCity: toController.text.trim(),
      routeVia: viaController.text.trim(),
      date: dateController.text.trim(),
      day: dayName,
      time: timeController.text.trim(),
      busClass: busClass,
      seats: int.tryParse(seatsController.text) ?? 40,
      fare: double.tryParse(fareController.text) ?? 0.0,
      originalFare: double.tryParse(originalFareController.text) ?? 0.0,
      discount: int.tryParse(discountController.text) ?? 0,
      discountLabel: discountLabelController.text.trim(),
      refreshment: refreshment,
      busNumber: busNumberController.text.trim(),
      driverName: driverController.text.trim(),
      createdAt: widget.bus?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (widget.bus == null) {
      await DBHelper.instance.insertBus(bus);
    } else {
      // FIXED — Correct function call
      await DBHelper.instance.updateBus(bus.id!, bus);

    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bus != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Bus" : "Add New Bus"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(busNameController, "Bus Name", required: true),
              _buildTextField(routeNameController, "Route Name", required: true),
              _buildTextField(fromController, "From City", required: true),
              _buildTextField(toController, "To City", required: true),
              _buildTextField(viaController, "Via (Route)"),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimeField()),
                ],
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: busClass,
                decoration: const InputDecoration(
                    labelText: "Bus Class", border: OutlineInputBorder()),
                items: ["Gold", "Business", "Executive"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => busClass = v!),
              ),

              const SizedBox(height: 16),
              _buildTextField(seatsController, "Total Seats",
                  keyboardType: TextInputType.number),
              _buildTextField(fareController, "Fare (PKR)",
                  keyboardType: TextInputType.number),
              _buildTextField(originalFareController, "Original Fare",
                  keyboardType: TextInputType.number),
              _buildTextField(discountController, "Discount Amount",
                  keyboardType: TextInputType.number),
              _buildTextField(discountLabelController,
                  "Discount Label (e.g. 20% OFF)"),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Text("Refreshment", style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  Switch(
                      value: refreshment,
                      onChanged: (v) => setState(() => refreshment = v)),
                ],
              ),

              const SizedBox(height: 16),
              _buildTextField(busNumberController, "Bus Number"),
              _buildTextField(driverController, "Driver Name"),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveBus,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                  child: Text(
                    isEdit ? "Update Bus" : "Add Bus",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: required
            ? (value) =>
                value == null || value.trim().isEmpty ? "Please enter $label" : null
            : null,
      ),
    );
  }

  Widget _buildDateField() => TextFormField(
        controller: dateController,
        readOnly: true,
        onTap: _pickDate,
        decoration: const InputDecoration(
          labelText: "Date",
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
      );

  Widget _buildTimeField() => TextFormField(
        controller: timeController,
        readOnly: true,
        onTap: _pickTime,
        decoration: const InputDecoration(
          labelText: "Time",
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time),
        ),
      );
}
