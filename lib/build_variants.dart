import 'package:yandex_mapkit/yandex_mapkit.dart';

List<PlacemarkMapObject> startPlaces = [
  PlacemarkMapObject(
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
  ),
  PlacemarkMapObject(
    mapId: const MapObjectId('start_placemark'),
    point: const Point(
      latitude: 41.356825,
      longitude: 69.227197,
    ),
    icon: PlacemarkIcon.single(
      PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/route_start.png'),
          scale: 0.3),
    ),
  ),
  PlacemarkMapObject(
    mapId: const MapObjectId('start_placemark'),
    point: const Point(
      latitude: 41.387327,
      longitude: 69.463056,
    ),
    icon: PlacemarkIcon.single(
      PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/route_start.png'),
          scale: 0.3),
    ),
  ),
];

List<PlacemarkMapObject> endPlaces = [
  PlacemarkMapObject(
    mapId: const MapObjectId('end_placemark'),
    icon: PlacemarkIcon.single(PlacemarkIconStyle(
        image: BitmapDescriptor.fromAssetImage('assets/route_end.png'),
        scale: 0.3)),
    point: const Point(
      latitude: 41.316435,
      longitude: 69.248385,
    ),
  ),
  PlacemarkMapObject(
    mapId: const MapObjectId('end_placemark'),
    icon: PlacemarkIcon.single(PlacemarkIconStyle(
        image: BitmapDescriptor.fromAssetImage('assets/route_end.png'),
        scale: 0.3)),
    point: const Point(
      latitude: 41.295989,
      longitude: 69.175182,
    ),
  ),
  PlacemarkMapObject(
    mapId: const MapObjectId('end_placemark'),
    icon: PlacemarkIcon.single(PlacemarkIconStyle(
        image: BitmapDescriptor.fromAssetImage('assets/route_end.png'),
        scale: 0.3)),
    point: const Point(
      latitude: 41.226185,
      longitude: 69.372523,
    ),
  ),
];
