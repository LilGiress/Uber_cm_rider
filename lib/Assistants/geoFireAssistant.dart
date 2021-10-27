import 'package:uber/Models/nearbyAvailableDrivers.dart';

class GeoFireAssistant {
  static List<NearbyAvailableDrivers> nearByAvailableDriversList = [];

  static void removeDriverFromlist(String key) {
    int index =
        nearByAvailableDriversList.indexWhere((element) => element.key == key);
    nearByAvailableDriversList.removeAt(index);
  }

  static void updateDriverNeabyLocation(NearbyAvailableDrivers driver) {
    int index = nearByAvailableDriversList
        .indexWhere((element) => element.key == driver.key);
    nearByAvailableDriversList[index].latitude = driver.latitude;
     nearByAvailableDriversList[index].longitute = driver.longitute;
  }
}
