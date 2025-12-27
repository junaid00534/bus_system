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

  // Text Controllers
  late final TextEditingController fromController;
  late final TextEditingController toController;
  late final TextEditingController viaController;
  late final TextEditingController dateController;
  late final TextEditingController timeController;
  late final TextEditingController fareController;
  late final TextEditingController discountController;
  late final TextEditingController discountLabelController;
  late final TextEditingController busNumberController;
  late final TextEditingController driverController;

  String busClass = "Gold";
  bool refreshment = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    fromController = TextEditingController();
    toController = TextEditingController();
    viaController = TextEditingController();
    dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    timeController = TextEditingController(
        text: DateFormat('hh:mm a').format(DateTime.now()));
    fareController = TextEditingController();
    discountController = TextEditingController();
    discountLabelController = TextEditingController();
    busNumberController = TextEditingController();
    driverController = TextEditingController();

    // Pre-fill fields if editing existing bus
    if (widget.bus != null) {
      final b = widget.bus!;
      fromController.text = b.fromCity;
      toController.text = b.toCity;
      viaController.text = b.routeVia;
      dateController.text = b.date;
      timeController.text = b.time;
      busClass = b.busClass;
      fareController.text = b.fare > 0 ? b.fare.toStringAsFixed(0) : "";
      discountController.text = b.discount > 0 ? b.discount.toString() : "";
      discountLabelController.text = b.discountLabel;
      refreshment = b.refreshment == true || b.refreshment == 1;
      busNumberController.text = b.busNumber;
      driverController.text = b.driverName;
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    fromController.dispose();
    toController.dispose();
    viaController.dispose();
    dateController.dispose();
    timeController.dispose();
    fareController.dispose();
    discountController.dispose();
    discountLabelController.dispose();
    busNumberController.dispose();
    driverController.dispose();
    super.dispose();
  }

  // Date picker dialog
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dateController.text) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // Time picker dialog
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      timeController.text = picked.format(context);
    }
  }

  // Save or update bus in database
  Future<void> _saveBus() async {
    if (!_formKey.currentState!.validate()) return;

    final date = DateTime.tryParse(dateController.text) ?? DateTime.now();
    final dayName = DateFormat('EEEE').format(date);

    final double fare = double.tryParse(fareController.text.trim()) ?? 0.0;
    final int discount = int.tryParse(discountController.text.trim()) ?? 0;

    final bus = BusModel(
      id: widget.bus?.id,
      busName: "Bus", // Default value
      routeName: "${fromController.text.trim()} to ${toController.text.trim()}",
      fromCity: fromController.text.trim(),
      toCity: toController.text.trim(),
      routeVia: viaController.text.trim(),
      date: dateController.text.trim(),
      day: dayName,
      time: timeController.text.trim(),
      busClass: busClass,
      seats: 40, // Fixed default seats
      fare: fare,
      originalFare: fare > 0 && discount > 0 ? fare + discount : fare,
      discount: discount,
      discountLabel: discountLabelController.text.trim(),
      refreshment: refreshment,
      busNumber: busNumberController.text.trim(),
      driverName: driverController.text.trim(),
      createdAt: widget.bus?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (widget.bus == null) {
      await DBHelper.instance.insertBus(bus);
    } else {
      await DBHelper.instance.updateBus(bus.id!, bus);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.bus == null
              ? "Bus schedule added successfully!"
              : "Bus schedule updated!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bus != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text(isEdit ? "Edit Bus Schedule" : "Add New Bus"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // From & To Cities
              Row(
                children: [
                  Expanded(
                    child: _buildModernField(
                      controller: fromController,
                      label: "From City",
                      icon: Icons.location_on_outlined,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernField(
                      controller: toController,
                      label: "To City",
                      icon: Icons.flag_outlined,
                      required: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Via Route (Optional)
              _buildModernField(
                controller: viaController,
                label: "Via (Route) – Optional",
                icon: Icons.route_outlined,
              ),

              const SizedBox(height: 20),

              // Date & Time
              Row(
                children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimeField()),
                ],
              ),

              const SizedBox(height: 20),

              // Bus Type Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: busClass,
                  decoration: const InputDecoration(
                    labelText: "Bus Type",
                    border: InputBorder.none,
                  ),
                  items: ["Gold", "Business", "Executive"]
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(fontSize: 16)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => busClass = v!),
                ),
              ),

              const SizedBox(height: 20),

              // Fare (Required)
              _buildModernField(
                controller: fareController,
                label: "Fare (PKR)",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                required: true,
              ),

              const SizedBox(height: 16),

              // Discount Amount & Label (Optional)
              Row(
                children: [
                  Expanded(
                    child: _buildModernField(
                      controller: discountController,
                      label: "Discount Amount",
                      icon: Icons.discount_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernField(
                      controller: discountLabelController,
                      label: "Discount Label (e.g. 20% OFF)",
                      icon: Icons.label_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Refreshment Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Colors.green),
                    const SizedBox(width: 12),
                    const Text("Refreshment Included", style: TextStyle(fontSize: 16)),
                    const Spacer(),
                    Switch(
                      value: refreshment,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => refreshment = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Optional: Bus Number & Driver Name
              _buildModernField(
                controller: busNumberController,
                label: "Bus Number (Optional)",
                icon: Icons.directions_bus,
              ),

              const SizedBox(height: 16),

              _buildModernField(
                controller: driverController,
                label: "Driver Name (Optional)",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveBus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    isEdit ? "Update Bus" : "Add Bus",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable modern text field with icon and shadow
  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: required
            ? (value) =>
                value == null || value.trim().isEmpty ? "This field is required" : null
            : null,
      ),
    );
  }

  // Date field with calendar icon
  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: dateController,
        readOnly: true,
        onTap: _pickDate,
        decoration: const InputDecoration(
          labelText: "Date",
          prefixIcon: Icon(Icons.calendar_today, color: Colors.green),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  // Time field with clock icon
  Widget _buildTimeField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: timeController,
        readOnly: true,
        onTap: _pickTime,
        decoration: const InputDecoration(
          labelText: "Time",
          prefixIcon: Icon(Icons.access_time, color: Colors.green),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}