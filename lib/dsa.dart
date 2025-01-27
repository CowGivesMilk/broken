import 'dart:math';
import 'dart:collection';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
const int intMaxValue = 9223372036854775807;
class Node {
  final int id;
  final double lat, lon;
  Set<Way> ways;

  Node({
    required this.id,
    required this.lat,
    required this.lon,
    Set<Way>? ways,
  }) : ways = ways ?? {};
  @override
  String toString() {
    final str = 'id: $id, lat: $lat, lon: $lon';
    return str;
  }
}

class Tags {
  int? maxSpeed;
  String? name, nameEn, nameNe;

  Tags({this.maxSpeed, this.name, this.nameEn, this.nameNe});
}

class Way {
  final int id;
  final Tags tag;
  final List<Node> nodes;

  Way({required this.id, required this.tag, required this.nodes});
}
class PathWithFareAndDistance {
  List<Object> path;
  List<int> fares;
  double distance;
  PathWithFareAndDistance({required this.path, required this.fares, required this.distance});
} 
Node findNearestNode(double lat, double long, Map<int, Node> allNodes) {
  double minDistance = double.infinity;
  Node res = Node(id: -42, lat: 0.0, lon: 0.0);

  allNodes.forEach((key, value) {
    // Assuming `value` has `latitude` and `longitude` properties
    double latN = value.lat;
    double longN = value.lon;

    double distance = haversine(lat, long, latN, longN);
    if (distance < minDistance) {
      minDistance = distance; // Update the minimum distance
      res = value; // Update the result node
    }
  });
  print('Nearest node is ${minDistance/1000} Km far.');
  return res;
}
double haversine(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadiusKm = 6371.0088; // Radius of Earth in kilometers

  // Convert degrees to radians
  double toRadians(double degree) => degree * pi / 180;

  double dLat = toRadians(lat2 - lat1);
  double dLon = toRadians(lon2 - lon1);

  double a = pow(sin(dLat / 2), 2) +
      cos(toRadians(lat1)) * cos(toRadians(lat2)) * pow(sin(dLon / 2), 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c * 1000;
}
PathWithFareAndDistance findCheapest(Node start, Node end, Set<Node> allNodes) {
  List<Object> path = findPath(start, end, allNodes);
  return PathWithFareAndDistance(path: path, fares: calculateFare(path), distance: distance(path));
}
double haversineNode(Node a, Node b) {
  return haversine(a.lat, a.lon, b.lat, b.lon);
}
List<Object> findPath(Node start, Node end, Set<Node> allNodes) {
  Map<Node, List<Object>> visited = {}; // Store visited nodes with paths.
  Queue<List<Object>> queue = Queue(); // Queue for BFS traversal.

  // Initialize the queue with the start node.
  queue.add([start]);
  visited[start] = [start];

  while (queue.isNotEmpty) {
    List<Object> path = queue.removeFirst();
    Node currentNode = path.last as Node;

    // If we reach the end node, return the path.
    if (currentNode == end) {
      return path;
    }

    // Iterate through all ways connected to the current node.
    for (Way way in currentNode.ways) {
      for (Node neighbor in way.nodes) {
        if (!visited.containsKey(neighbor)) {
          // Create a new path including the way and the neighbor.
          List<Object> newPath = List.from(path)
            ..add(way)
            ..add(neighbor);

          // Mark the neighbor as visited and add it to the queue.
          visited[neighbor] = newPath;
          queue.add(newPath);
        }
      }
    }
  }

  // If no path is found, return an empty list.
  return [];
}
Set<Node> mapToSet(Map<int, Node> allNodes) {
  Set<Node> allNodesSet = {};
  allNodes.forEach((key, value) => allNodesSet.add(value));
  return allNodesSet;
} 
List<int> calculateFare(List<dynamic> path) {
  List<int> fares = [];
  int totalFare = 0;
  for(int i = 1; i < path.length - 1; i += 2) {
    double kmDist = haversineNode(path[i-1], path[i+1]) / 1000;
    double d = 5;
    int price = 20;
    while(price < 40 && d < kmDist) {
      price += 5;
      d += 5;
    }
    fares.add(price);
    totalFare += price;
  }
  fares.add(totalFare);
  return fares;
}
Future<List<LatLng>> getDrivingRoute(LatLng start, LatLng end) async {
  final url = Uri.parse(
    'https://router.project-osrm.org/route/v1/bus/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List coordinates = data['routes'][0]['geometry']['coordinates'];

    // Convert coordinates to LatLng
    return coordinates.map((coord) {
      return LatLng(coord[1], coord[0]);
    }).toList();
  } else {
    throw Exception('Failed to fetch route');
  }
}
Future<List<LatLng>> osmPolylines(List<dynamic> path) async {
  // List of futures for route segments
  List<Future<List<LatLng>>> futures = [];
  
  for (int i = 1; i < path.length - 1; i += 2) {
    LatLng start = LatLng(path[i - 1].lat, path[i - 1].lon);
    LatLng end = LatLng(path[i + 1].lat, path[i + 1].lon);
    
    futures.add(getDrivingRoute(start, end));
  }
  
  // Wait for all futures to complete
  try {
    final results = await Future.wait(futures);
    return results.expand((segment) => segment).toList();
  } catch (e) {
    print('Error fetching polylines: $e');
    return [];
  }
}
void printPath(List<dynamic> path) {
  if(path.isEmpty) {
    print('Empty Path');
  }
  for(var item in path) {
    if(item.runtimeType == Node) {
      print(item.toString());
    }else {
      print(item.tag.name);
    }
  }
}

List<LatLng> pathToPolyLine(List<dynamic> path) {
  print('Running function path to polyline from from path of size ${path.length}');
  List<LatLng> polylinePoints = [];
  for(int i = 0; i < path.length; i++) {
    if(path[i].runtimeType == Node) {
      polylinePoints.add(LatLng(path[i].lat, path[i].lon));
    }else {
      Node nextNode = path[i+1];
      Node currentNode = path[i-1];
      for(int j = path[i].nodes.indexOf(currentNode) + 1; j < path[i].nodes.length; j++) {
        Node nodeOfWay =  path[i].nodes[j];
        if(nodeOfWay == nextNode) break;
        polylinePoints.add(LatLng(nodeOfWay.lat, nodeOfWay.lon));
      }
    }
  }
  print('polylines array size = ${polylinePoints.length}');
  return polylinePoints;
}


Future<void> parseJson(Map<int, Node> allNodes, Set<Way> allWays) async {
  // Read the JSON file
  final file = File('assets/osmData.json');
  final jsonString = await file.readAsString();

  // Parse JSON data
  final Map<String, dynamic> data = jsonDecode(jsonString);

  // Access elements
  final elements = data['elements'] as List<dynamic>;

  for (var element in elements) {
    final type = element['type'];
    final id = element['id'];

    if (type == 'node') {
      // Parse node
      final lat = element['lat'];
      final lon = element['lon'];
      Node node = Node(
        id: id,
        lat: lat,
        lon: lon,
      );
      allNodes[id] = node;
    } else if (type == 'way') {
      // Parse way
      final tags = element['tags'] ?? {};
      Tags tag = Tags(
        maxSpeed: tags['maxspeed'] != null ? int.tryParse(tags['maxspeed']) : null,
        name: tags['name'],
        nameEn: tags['name:en'],
        nameNe: tags['name:ne'],
      );

      // Parse way nodes
      final nodesId = element['nodes'] as List<dynamic>;
      List<Node> nodes = [];
      for (var nodeId in nodesId) {
        Node? node = allNodes[nodeId];
        if (node != null) {
          nodes.add(node);
        }
      }

      // Create Way object
      Way way = Way(id: id, tag: tag, nodes: nodes);
      allWays.add(way);

      // Link nodes to the way
      for (var node in nodes) {
        node.ways.add(way);
      }
    }
  }
  print('Total Nodes: ${allNodes.length}');
  print('Total Ways: ${allWays.length}');
}
void removeRedundantNodes(Map<int, Node> allNodes, Set<Way> allWays) {
  // Collect all nodes referenced by all ways
  Set<Node> allNodesInWays = {};
  for (Way way in allWays) {
    allNodesInWays.addAll(way.nodes);
  }

  // Identify and remove redundant nodes
  List<int> keysToRemove = [];
  for (var entry in allNodes.entries) {
    if (!allNodesInWays.contains(entry.value)) {
      keysToRemove.add(entry.key);
    }
  }

  for (int key in keysToRemove) {
    allNodes.remove(key);
  }

  //print('Removed ${keysToRemove.length} redundant nodes.');
}
List<List<Object>> findAllPaths(Node start, Node end) {
  List<List<Object>> allPaths = []; // To store all found paths.
  Queue<List<Object>> queue = Queue(); // Queue for BFS traversal.

  // Initialize the queue with the start node.
  queue.add([start]);

  while (queue.isNotEmpty) {
    List<Object> path = queue.removeFirst();
    Node currentNode = path.last as Node;

    // If we reach the end node, store the path.
    if (currentNode == end) {
      allPaths.add(path);
      continue; // Continue to explore other paths.
    }

    // Iterate through all ways connected to the current node.
    for (Way way in currentNode.ways) {
      for (Node neighbor in way.nodes) {
        // Avoid revisiting nodes already in the current path.
        if (!path.contains(neighbor)) {
          // Create a new path including the way and the neighbor.
          List<Object> newPath = List.from(path)
            ..add(way)
            ..add(neighbor);

          // Add the new path to the queue for further exploration.
          queue.add(newPath);
        }
      }
    }
  }

  return allPaths; // Return all found paths.
}

PathWithFareAndDistance selectShortest(List<List<Object>> allPaths) {
  PathWithFareAndDistance res = PathWithFareAndDistance(path: [], fares: [intMaxValue], distance: double.maxFinite);
  for(var path in allPaths) {
    double distance = 0;
    for(int i = 1; i < path.length - 1; i += 2) {
      Node prevNode = path[i-1] as Node;
      Node nextNode = path[i+1] as Node;
      distance += haversineNode(prevNode, nextNode);
    }
    if(distance < res.distance) {
      res = PathWithFareAndDistance(path: path, fares: calculateFare(path), distance: distance);
    }
  }
  return res;
}
double distance(List<Object> path) {
  double dist = 0;
  for(int i = 1; i < path.length - 1; i += 2) {
    Node left = path[i-1] as Node;
    Node right = path[i+1] as Node;
    dist += haversineNode(left, right);
  }
  return dist;
}
PathWithFareAndDistance findShortest(Node start, Node end, Set<Node> allNodes) {
  List<Object> path = findPath(start, end, allNodes);
  return PathWithFareAndDistance(path: path, fares: calculateFare(path), distance: distance(path));
}
PathWithFareAndDistance selectCheapest(List<List<Object>> allPaths) {
  // Initialize result with a dummy high-cost path.
  PathWithFareAndDistance res = PathWithFareAndDistance(
    path: [],
    fares: [intMaxValue],
    distance: double.maxFinite,
  );

  for (var path in allPaths) {
    double distance = 0;
    List<int> fares = calculateFare(path);

    // Check if the current path has a cheaper fare.
    if (res.fares.last > fares.last) {
      // Calculate the distance for the path.
      for (int i = 1; i < path.length - 1; i += 2) {
        Node prevNode = path[i - 1] as Node;
        Node nextNode = path[i + 1] as Node;

        distance += haversineNode(prevNode, nextNode);
      }

      // Update the result with the current path.
      res = PathWithFareAndDistance(path: path, fares: fares, distance: distance);
    }
  }

  return res;
}