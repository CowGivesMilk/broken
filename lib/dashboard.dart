import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'get_url.dart';
import 'dsa.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  LatLng? currentLocation;
  LatLng? finalDestination;
  final String currentLocationName = "Current Location";
  final String finalDestinationName = "Final Destination";
  late Map<String, LatLng> locationCoordinates = {}; // Map to store locations and their coordinates.
  List<LatLng> polylinesArray = [];
  Map<String, Node> allNodes = {};
  Set<Bus> allBuses = {};


  // Controllers for the TextFields to show the selected location names.
  TextEditingController currentLocationController = TextEditingController();
  TextEditingController finalDestinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLocations(); // Load locations from the CSV file.
  }

  Future<void> loadLocations() async {
    try {
      final csvData = await rootBundle.loadString('assets/Routes.csv');
      final List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvData);

      // Populate the map with location names and their coordinates.
      for (var row in rowsAsListOfValues.skip(1)) {
        final String locationName = row[0].toString().trim();
        final double latitude = double.parse(row[1].toString());
        final double longitude = double.parse(row[2].toString());
        locationCoordinates[locationName] = LatLng(latitude, longitude);
      }

      print("Locations loaded: $locationCoordinates"); // Debug: Print loaded locations
    } catch (error) {
      print('Error loading CSV: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF32CD32),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(27.7172, 85.3240),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: getTransportMapUrl(),
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinesArray,
                      color: Colors.blue,
                      borderStrokeWidth: 10.0,
                    )
                  ]
                ),
                if (currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation!,
                        width: 40.0,
                        height: 40.0,
                        child: const Icon(Icons.location_pin,
                            color: Colors.blue, size: 40),
                      ),
                    ],
                  ),
                if (finalDestination != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: finalDestination!,
                        width: 40.0,
                        height: 40.0,
                        child: const Icon(Icons.location_pin,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showLocationOptions(context, "current"),
                    child: TextField(
                      controller: currentLocationController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: currentLocationName,
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showLocationOptions(context, "final"),
                    child: TextField(
                      controller: finalDestinationController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: finalDestinationName,
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (currentLocation != null && finalDestination != null) {
                        print(
                            "Journey started from (${currentLocation!.latitude}, ${currentLocation!.longitude}) to (${finalDestination!.latitude}, ${finalDestination!.longitude})");
                        parseCSV(allNodes, allBuses);
                        //Node start = Node(name: 'start bus stop', latitude: currentLocation!.latitude, longitude: currentLocation!.longitude);
                        //Node end = Node(name: 'End Bus stop', latitude: finalDestination!.latitude, longitude: finalDestination!.longitude);
                        //Node start = Node(name: 'Aarubari', latitude: 27.7312633, longitude: 85.3757724);
                        //Node end = Node(name: 'Machha Pokhari', latitude: 27.7353111, longitude: 85.3058395);
                        //start = allNodes[start.toString()]?? findNearestNode(start.latitude, start.latitude, allNodes);
                        //end = allNodes[end.toString()]?? findNearestNode(end.latitude, end.latitude, allNodes);

                        //Node start = Node(name: 'start bus stop', latitude: currentLocation!.latitude, longitude: currentLocation!.longitude);
                        //Node end = Node(name: 'End Bus stop', latitude: finalDestination!.latitude, longitude: finalDestination!.longitude);
                        //start = findNearestNode(start.latitude, start.longitude, allNodes);
                        //end = findNearestNode(end.latitude, end.longitude, allNodes);
                        //List<dynamic> path = findPath(start, end, allNodes, allBuses);
                        setState(() {
                          /*
                            final path = findPath(start, end, mapToSet(allNodes));
                            print('Length of path: ${path.length}');
                            polylinesArray = pathToPolyLine(path);
                            print('Length of polylinesArray: ${polylinesArray.length}');
                            */
                            for(var bus in allBuses) {
                              for(var node in bus.nodes) {
                                polylinesArray.add(LatLng(node.latitude, node.longitude));
                              }
                              break;
                            }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select both locations."),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF32CD32),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Start Journey',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationOptions(BuildContext context, String locationType) {
    TextEditingController locationSearchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose ${locationType == "current" ? "Current Location" : "Final Destination"}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Image.asset(
                  'assets/map.png',
                  width: 24,
                  height: 24,
                ),
                title: const Text('Choose on Map'),
                onTap: () async {
                  Navigator.pop(context);
                  final selectedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPicker(
                        currentLocation: currentLocation,
                        finalDestination: finalDestination,
                      ),
                    ),
                  );
                  if (selectedLocation != null) {
                    setState(() {
                      if (locationType == "current") {
                        currentLocation = selectedLocation;
                        currentLocationController.text =
                        "(${selectedLocation.latitude}, ${selectedLocation.longitude})";
                      } else {
                        finalDestination = selectedLocation;
                        finalDestinationController.text =
                        "(${selectedLocation.latitude}, ${selectedLocation.longitude})";
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search Location'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Enter Location Name'),
                        content: TypeAheadFormField<String>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: locationSearchController,
                            decoration: const InputDecoration(
                              hintText: 'Type a location name',
                            ),
                          ),
                          suggestionsCallback: (pattern) {
                            return locationCoordinates.keys
                                .where((location) => location.toLowerCase().contains(pattern.toLowerCase()))
                                .toList();
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            Navigator.pop(context);
                            setState(() {
                              if (locationType == "current") {
                                currentLocation = locationCoordinates[suggestion];
                                currentLocationController.text = suggestion;
                              } else {
                                finalDestination = locationCoordinates[suggestion];
                                finalDestinationController.text = suggestion;
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class MapPicker extends StatelessWidget {
  final LatLng? currentLocation;
  final LatLng? finalDestination;

  const MapPicker({
    Key? key,
    this.currentLocation,
    this.finalDestination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF32CD32),
        title: const Text('Select Location'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: currentLocation ?? finalDestination ?? LatLng(27.7172, 85.3240),
          initialZoom: 15.0,
          onTap: (tapPosition, point) {
            Navigator.pop(context, point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: getTransportMapUrl(),
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
        ],
      ),
    );
  }
}
