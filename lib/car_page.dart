import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
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
  final PlacemarkMapObject startPlacemark = PlacemarkMapObject(
    mapId: const MapObjectId('start_placemark'),
    point: const Point(
      latitude: 41.3488976,
      longitude: 69.3373859,
    ),
    icon: PlacemarkIcon.single(
      PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/route_start.png'),
          scale: 0.3),
    ),
  );

  final PlacemarkMapObject endPlacemark = PlacemarkMapObject(
    mapId: const MapObjectId('end_placemark'),
    icon: PlacemarkIcon.single(PlacemarkIconStyle(
        image: BitmapDescriptor.fromAssetImage('assets/route_end.png'),
        scale: 0.3)),
    point: const Point(
      latitude: 41.311081,
      longitude: 69.240562,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: YandexMap(mapObjects: mapObjects)),
          const SizedBox(height: 20),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: [
            ElevatedButton(
              onPressed: _requestRoutes,
              child: const Text('Build route'),
            ),
          ])))
        ]);
  }

  Future<void> _requestRoutes() async {
    print('Points: ${startPlacemark.point},${endPlacemark.point}');

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
  bool _progress = true;
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
                          onMapCreated: (controller) async {
                            controller.moveCamera(
                              CameraUpdate.newCameraPosition(
                                const CameraPosition(
                                    target: Point(
                                      latitude: 41.3488976,
                                      longitude: 69.3373859,
                                    ),
                                    zoom: 15),
                              ),
                            );
                          },
                          onCameraPositionChanged:
                              (cameraPosition, reason, finished) {
                            zoom = cameraPosition.zoom;
                            print(zoom);
                          },
                          mapObjects: mapObjects,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(children: <Widget>[
                    SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            !_progress
                                ? Container()
                                : TextButton.icon(
                                    icon: const CircularProgressIndicator(),
                                    label: const Text('Cancel'),
                                    onPressed: _cancel)
                          ],
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _getList(),
                              )),
                        ),
                      ],
                    ),
                  ])))
                ])));
  }

  List<Widget> _getList() {
    final list = <Widget>[];

    if (results.isEmpty) {
      list.add((const Text('Nothing found')));
    }

    for (var r in results) {
      list.add(Container(height: 20));

      r.routes!.asMap().forEach((i, route) {
        list.add(
            Text('Route $i: ${route.metadata.weight.timeWithTraffic.text}'));
      });

      list.add(Container(height: 20));
    }

    return list;
  }

  Future<void> _cancel() async {
    await widget.session.cancel();

    setState(() {
      _progress = false;
    });
  }

  Future<void> _close() async {
    await widget.session.close();
  }

  Future<void> _init() async {
    await _handleResult(await widget.result);
  }

  Future<void> _handleResult(DrivingSessionResult result) async {
    setState(() {
      _progress = false;
    });

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
        mapId: MapObjectId('route_${result.routes?.first}_polyline'),
        polyline: Polyline(points: result.routes?.first.geometry ?? []),
        strokeColor: Colors.green,
        strokeWidth: 2,
      ),
    );
    driveCar(result.routes?.first.geometry ?? [], result);
  }

  driveCar(List<Point> points, DrivingSessionResult result) async {
    // List<Point> pointsRemove = [];
    // pointsRemove.addAll(points);

    for (int i = 0; i < points.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));

      final PlacemarkMapObject carPlaceMark = PlacemarkMapObject(
        mapId: const MapObjectId('car_placemark'),
        point: points[i],
        direction: 90 -
            calculateInitialBearing(
              points[i],
              points[i + 1],
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

      mapObjects.add(carPlaceMark);
      setState(() {});

      // if (kDebugMode) {
      //   print(pointsRemove.length);
      // }

      // mapObjects.add(
      //   PolylineMapObject(
      //     mapId: MapObjectId('route_${result.routes?.first}_polyline'),
      //     polyline: Polyline(points: pointsRemove),
      //     strokeColor: Colors.green,
      //     strokeWidth: 2,
      //   ),
      // );
    }
  }
}
