import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'dart:math' as math;

Point calculateNearestPoint({
  required List<Point> points,
  required Point point,
}) {
  final List<Point> pointSort = points;
  pointSort.sort(
    (a, b) => distance(
      pointLat: a.latitude,
      pointLong: a.longitude,
      latLong: point,
    ).compareTo(
      distance(
        pointLat: b.latitude,
        pointLong: b.longitude,
        latLong: point,
      ),
    ),
  );

  return pointSort.first;
}

num distance({
  required double pointLat,
  required double pointLong,
  required Point latLong,
}) {
  double userLocationLat = latLong.latitude;
  double userLocationLong = latLong.longitude;
  const int r = 6371;
  userLocationLong = (userLocationLong * math.pi) / 180;
  pointLong = (pointLong * math.pi) / 180;
  userLocationLat = (userLocationLat * math.pi) / 180;
  pointLat = (pointLat * math.pi) / 180;

  final num nearbyLong = pointLong - userLocationLong;
  final num nearbyLat = pointLat - userLocationLat;

  final num a = math.pow(math.sin(nearbyLat / 2), 2) +
      math.cos(userLocationLat) *
          math.cos(pointLat) *
          math.pow(math.sin(nearbyLong / 2), 2);
  final num c = 2 * math.asin(math.sqrt(a));
  return c * r;
}

double calculateInitialBearing(Point point1, Point point2) {
  double deltaLon = point2.longitude - point1.longitude;

  double x = math.sin(deltaLon) * math.cos(point2.latitude);
  double y = math.cos(point1.latitude) * math.sin(point2.latitude) -
      math.sin(point1.latitude) *
          math.cos(point2.latitude) *
          math.cos(deltaLon);

  double initialBearing = math.atan2(x, y);

  initialBearing = (initialBearing * 180 / math.pi + 360) % 360;

  return initialBearing;
}
