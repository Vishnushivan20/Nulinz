import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TaskAssignmentApp());
}

class TaskAssignmentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Assignment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Montserrat',
      ),
      home: TaskFormScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskFormScreen extends StatefulWidget {
  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  String? selectedEmployee;
  DateTime? startDate;
  DateTime? endDate;

  Future<void> assignTask() async {
    if (selectedEmployee != null && startDate != null && endDate != null) {
      await FirebaseFirestore.instance.collection('tasks').add({
        'employee': selectedEmployee,
        'title': _taskTitleController.text,
        'description': _taskDescController.text,
        'startDate': startDate,
        'endDate': endDate,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task Assigned!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows background to extend behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        title: Text(
          'Assign Task',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1521737604893-d14cc237f11d',
                  fit: BoxFit.cover,
                ),
              )
            ),
            // Semi-transparent overlay for better readability
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
            // Form content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80), // Offset for AppBar space
                  _buildTextField(_taskTitleController, 'Task Title', Icons.task_alt),
                  SizedBox(height: 15),
                  _buildTextField(_taskDescController, 'Task Description', Icons.description),
                  SizedBox(height: 20),

                  Text("Select Employee", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 5),
                  _buildDropdown(),

                  SizedBox(height: 20),
                  _buildDatePicker('Pick Start Date', startDate, (date) => setState(() => startDate = date)),
                  SizedBox(height: 10),
                  _buildDatePicker('Pick End Date', endDate, (date) => setState(() => endDate = date)),

                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: assignTask,
                      icon: Icon(Icons.send, color: Colors.white),
                      label: Text('Assign Task', style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: Colors.blueAccent,
                        shadowColor: Colors.black26,
                        elevation: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.9), // Make it slightly transparent
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2)],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2)],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: selectedEmployee,
        onChanged: (value) => setState(() => selectedEmployee = value),
        items: ['Employee 1', 'Employee 2', 'Employee 3', 'Employee 4', 'Employee 5']
            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 16))))
            .toList(),
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String text, DateTime? selectedDate, Function(DateTime) onDatePicked) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) onDatePicked(pickedDate);
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.blueAccent,
          shadowColor: Colors.black26,
          elevation: 5,
        ),
        child: Text(
          selectedDate == null ? text : '${selectedDate.toLocal()}'.split(' ')[0],
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
