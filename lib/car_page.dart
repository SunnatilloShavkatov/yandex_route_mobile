import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_route_mobile/build_variants.dart';
import 'package:yandex_route_mobile/calculate_point.dart';

class DrivingPage extends StatelessWidget {
  const DrivingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _DrivingExample();
  }
}

class _DrivingExample extends StatefulWidget {
  @override
  _DrivingExampleState createState() => _DrivingExampleState();
}

class _DrivingExampleState extends State<_DrivingExample> {
  late final List<MapObject> mapObjects = [
    startPlacemark,
    endPlacemark,
  ];

  late PlacemarkMapObject startPlacemark;
  late PlacemarkMapObject endPlacemark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Expanded(
        //     child: YandexMap(
        //         // mapObjects: mapObjects,
        //         )),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _requestRoutes(0);
          },
          child: const Text('Build route 1'),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            _requestRoutes(1);
          },
          child: const Text('Build route 2'),
        ),
        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () {
            _requestRoutes(2);
          },
          child: const Text('Build route 3'),
        )
      ],
    );
  }

  Future<void> _requestRoutes(int i) async {
    startPlacemark = startPlaces[i];
    endPlacemark = endPlaces[i];
    var resultWithSession = YandexDriving.requestRoutes(
        points: [
          RequestPoint(
              point: startPlacemark.point,
              requestPointType: RequestPointType.wayPoint),
          RequestPoint(
              point: endPlacemark.point,
              requestPointType: RequestPointType.wayPoint),
        ],
        drivingOptions: const DrivingOptions(
            initialAzimuth: 0, routesCount: 5, avoidTolls: true));
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => _SessionPage(startPlacemark,
            endPlacemark, resultWithSession.session, resultWithSession.result),
      ),
    );
  }
}

class _SessionPage extends StatefulWidget {
  final Future<DrivingSessionResult> result;
  final DrivingSession session;
  final PlacemarkMapObject startPlacemark;
  final PlacemarkMapObject endPlacemark;

  const _SessionPage(
      this.startPlacemark, this.endPlacemark, this.session, this.result);

  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<_SessionPage> {
  late final List<MapObject> mapObjects = [
    widget.startPlacemark,
    widget.endPlacemark
  ];

  final List<DrivingSessionResult> results = [];
  double zoom = 16;
  late final YandexMapController mapController;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    super.dispose();

    _close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driving ${widget.session.id}')),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 400,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  YandexMap(
                    zoomGesturesEnabled: false,
                    onMapCreated: (controller) async {
                      mapController = controller;
                      controller.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: widget.startPlacemark.point, zoom: 15),
                        ),
                      );
                    },
                    onCameraPositionChanged:
                        (cameraPosition, reason, finished) {
                      zoom = cameraPosition.zoom;
                    },
                    mapObjects: mapObjects,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _close() async {
    await widget.session.close();
  }

  Future<void> _init() async {
    await _handleResult(await widget.result);
  }

  Future<void> _handleResult(DrivingSessionResult result) async {
    if (result.error != null) {
      debugPrint('Error: ${result.error}');
      return;
    }

    setState(() {
      results.add(result);
    });
    setState(() {
      result.routes!.sort((a, b) => a.metadata.weight.timeWithTraffic.value!
          .compareTo(b.metadata.weight.timeWithTraffic.value ?? 0));
    });
    mapObjects.add(
      PolylineMapObject(
        mapId: const MapObjectId('route_${1}_polyline'),
        polyline: Polyline(points: result.routes?.first.geometry ?? []),
        strokeColor: Colors.green,
        strokeWidth: 2,
      ),
    );
    print('route_${1}_polyline');
    driveCar(result.routes?.first.geometry ?? [], result);
  }

  driveCar(List<Point> points, DrivingSessionResult result) async {
    for (int i = 0; i < points.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 100));

      num distancePoints = distance(
        pointLat: points[i].latitude,
        pointLong: points[i].longitude,
        latLong: points[i + 1],
      );

      List<Point> betweenPoints = generatePointsBetween(
          points[i], points[i + 1], (distancePoints * 1000).toInt());

      for (var j = 0; j < betweenPoints.length - 1; j++) {
        await Future.delayed(
          const Duration(milliseconds: 100),
        );
        final PlacemarkMapObject carPlaceMark = PlacemarkMapObject(
          mapId: const MapObjectId('car_placemark'),
          point: betweenPoints[j],
          direction: 90 -
              calculateInitialBearing(
                betweenPoints[j],
                betweenPoints[j + 1],
              ),
          opacity: 1,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/car.png'),
              scale: zoom < 13 ? zoom / 35 : zoom / 25,
              rotationType: RotationType.rotate,
            ),
          ),
        );
        mapObjects.removeWhere((obj) => obj.mapId.value == 'car_placemark');
        mapObjects.add(carPlaceMark);
        setState(() {
          mapController.moveCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: betweenPoints[j])));
        });
      }

      points.removeAt(i);
      i--;
      setState(() {});
      mapObjects.removeWhere(
          (element) => element.mapId.value == 'route_${1}_polyline');
      mapObjects.add(
        PolylineMapObject(
          mapId: const MapObjectId('route_${1}_polyline'),
          polyline: Polyline(points: [...points]),
          strokeColor: Colors.green,
          strokeWidth: 2,
        ),
      );
    }
  }
}
