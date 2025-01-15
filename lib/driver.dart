import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class DriverSignInPage extends StatefulWidget {
  const DriverSignInPage({super.key});

  @override
  _DriverSignInPageState createState() => _DriverSignInPageState();
}

class _DriverSignInPageState extends State<DriverSignInPage> {
  List<Map<String, String>> yatayatData = [];
  List<String> yatayatNames = [];
  List<String> filteredLicensePlateNumbers = [];

  String? selectedYatayatName;
  String? selectedLicensePlateNumber;

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  Future<void> loadCsvData() async {
    try {
      final csvData = await rootBundle.loadString('assets/Bus.csv');
      List<List<dynamic>> rowsAsList = const CsvToListConverter().convert(csvData);

      yatayatData = rowsAsList.skip(1).map((row) {
        return {"name": row[0].toString(), "plate": row[1].toString()};
      }).toList();

      yatayatNames = yatayatData
          .map((entry) => entry["name"]!)
          .toSet()
          .toList(); // Get unique Yatayat names

      setState(() {}); // Refresh the UI after loading data
    } catch (e) {
      print('Error loading CSV data: $e');
    }
  }

  void updateLicensePlateNumbers(String? yatayatName) {
    if (yatayatName != null) {
      filteredLicensePlateNumbers = yatayatData
          .where((entry) => entry["name"] == yatayatName)
          .map((entry) => entry["plate"]!)
          .toList();
    } else {
      filteredLicensePlateNumbers = [];
    }
    setState(() {
      selectedLicensePlateNumber = null; // Reset license plate number selection
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Sign In'),
        backgroundColor: Colors.green,
      ),
      body: yatayatNames.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF32CD32), // Green gradient start
              Color(0xFFE9FFE9), // Light green gradient end
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Welcome Driver',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please fill in the details below to share your location:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              // Yatayat Name Dropdown
              DropdownButtonFormField<String>(
                value: selectedYatayatName,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Yatayat Name',
                  prefixIcon: const Icon(Icons.directions_bus, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: yatayatNames.map((name) {
                  return DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYatayatName = value;
                    updateLicensePlateNumbers(value);
                  });
                },
              ),
              const SizedBox(height: 20),
              // License Plate Number Dropdown
              DropdownButtonFormField<String>(
                value: selectedLicensePlateNumber,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'License Plate Number',
                  prefixIcon: const Icon(Icons.car_repair, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: filteredLicensePlateNumbers.map((plate) {
                  return DropdownMenuItem(
                    value: plate,
                    child: Text(plate),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLicensePlateNumber = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              // Share Location Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle sharing location logic here
                    print('Yatayat: $selectedYatayatName, Plate: $selectedLicensePlateNumber');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'Share Location',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
