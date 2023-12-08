import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

Point getAveragePoint = const Point(
  latitude: 41.311081,
  longitude: 69.240562,
);

Point officePoint = const Point(
  latitude: 41.3488976,
  longitude: 69.3373859,
);

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  late final YandexMapController _controller;
  final List<DrivingSessionResult> results = [];

  List<MapObject> mapObjects = [
    PlacemarkMapObject(
      mapId: const MapObjectId('userId'),
      point: getAveragePoint,
      consumeTapEvents: true,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/car.png'),
          scale: 1,
        ),
      ),
      opacity: 1,
    ),
  ];

  double zoom = 16;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            mapObjects: mapObjects,
            onCameraPositionChanged:
                (cameraPosition, cameraUpdateSource, finished) async {
              if (finished) {
                await _requestRoutes();
                _controller.moveCamera(
                  animation: const MapAnimation(
                    type: MapAnimationType.linear,
                    duration: 1,
                  ),
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      zoom: zoom,
                      target: cameraPosition.target,
                      azimuth: cameraPosition.azimuth,
                    ),
                  ),
                );
              }

              mapObjects[0] = PlacemarkMapObject(
                mapId: const MapObjectId('userId'),
                point: cameraPosition.target,
                zIndex: cameraPosition.zoom,
                direction: cameraPosition.azimuth,
                consumeTapEvents: true,
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    image: BitmapDescriptor.fromAssetImage('assets/car.png'),
                    scale: 1,
                  ),
                ),
                opacity: 1,
              );
            },
            onMapCreated: (controller) async {
              _controller = controller;
              await controller.moveCamera(
                animation: const MapAnimation(
                  type: MapAnimationType.linear,
                  duration: 1,
                ),
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    zoom: zoom,
                    target: getAveragePoint,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: IconButton(
              onPressed: () async {
                zoom++;
                _controller.moveCamera(
                  animation: const MapAnimation(
                    type: MapAnimationType.linear,
                    duration: 1,
                  ),
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      zoom: zoom,
                      target: getAveragePoint,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.zoom_out),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: IconButton(
              onPressed: () async {
                zoom--;
                _controller.moveCamera(
                  animation: const MapAnimation(
                    type: MapAnimationType.linear,
                    duration: 1,
                  ),
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      zoom: zoom,
                      target: getAveragePoint,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.zoom_in),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestRoutes() async {
    var resultWithSession = YandexDriving.requestRoutes(
      points: [
        RequestPoint(
          point: getAveragePoint,
          requestPointType: RequestPointType.wayPoint,
        ),
        RequestPoint(
          point: officePoint,
          requestPointType: RequestPointType.wayPoint,
        ),
      ],
      drivingOptions: const DrivingOptions(
        initialAzimuth: 0,
        routesCount: 5,
        avoidTolls: true,
      ),
    );
    await _handleRouteResult(await resultWithSession.result);
  }

  Future<void> _handleRouteResult(DrivingSessionResult result) async {
    if (result.error != null) {
      print('Error: ${result.error}');
      return;
    }
    setState(() {
      results.add(result);
    });
    setState(
      () {
        result.routes!.asMap().forEach(
          (i, route) {
            mapObjects.add(
              PolylineMapObject(
                mapId: MapObjectId('route_${i}_polyline'),
                polyline: Polyline(points: route.geometry),
                strokeColor:
                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                strokeWidth: 3,
              ),
            );
          },
        );
      },
    );
  }
}
