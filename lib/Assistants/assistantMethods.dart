import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/Assistants/requestAssistant.dart';
import 'package:uber/DataHandler/appData.dart';
import 'package:uber/Models/address.dart';
import 'package:uber/Models/allUsers.dart';
import 'package:uber/Models/directDetails.dart';
import 'package:uber/configMaps.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);

    if (response != "failed") {
      // placeAddress = response["results"][0]["formated_address"];
      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][4]["long_name"];
      st3 = response["results"][0]["address_components"][3]["long_name"];
      st4 = response["results"][0]["address_components"][2]["long_name"];

      placeAddress = st1 + " ," + st2 + " ," + st3 + " ," + st4;

      Address userPickUpAddress = new Address(
          latitude: null,
          longitude: null,
          placeFormattedAddress: '',
          placeId: '',
          placeName: "");
      userPickUpAddress.placeName = placeAddress;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    
   

    return placeAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if (res == "Failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails(distanceText: '', distanceValue: null, durationText: '', durationValue: null, encodedPoints: '');

    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];

    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];

    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];
    

    return directionDetails;
  }

  // request to calculated the fare(distance)
  static int calculateFares(DirectionDetails directionDetails) {
    // in terms in dollar USD
    double timeTraveledFare =
        (directionDetails.distanceValue! / 60) * 0.20; //by time (duration)
    double distanceTraveledFare =
        (directionDetails.distanceValue! / 1000) * 0.20; // by kilometer
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    // 1$ = 550xaf
    double totalLocalAmount = totalFareAmount;

    return totalLocalAmount.truncate();
  }
  // function to get online user information

  static void getCurrentOnlineUserInfo() async {
    
    firebaseUser =  FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapShot) {
      if (dataSnapShot.value != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapShot);
      }
    });
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }
}
