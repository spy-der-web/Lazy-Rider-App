import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lazy_rider/Assistants/requestAssistant.dart';
import 'package:lazy_rider/DataHandler/appData.dart';
import 'package:lazy_rider/Models/address.dart';
import 'package:lazy_rider/Models/allUsers.dart';
import 'package:lazy_rider/Models/directionDetails.dart';
import 'package:lazy_rider/configMaps.dart';
import 'package:provider/provider.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(Position position,
      context) async
  {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
        .latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);

    if (response != "failed") {
      st1 = response["results"][0]["address_components"][3]["long_name"];
      st2 = response["results"][0]["address_components"][4]["long_name"];
      st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

      Address userPickUpAddress = new Address(longitude: position.longitude,
          latitude: position.latitude,
          placeName: placeAddress,
          placeFormattedAddress: placeAddress,
          placeId: "asf");
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(
          userPickUpAddress);
    }

    return placeAddress;
  }


  static Future<DirectionDetails> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async
  {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

     print(res["routes"][0]);

     if(res == "failed")
       {
         return null;
       }

    DirectionDetails directionDetails = DirectionDetails(distanceValue: 0, durationValue: 0, distanceText: "", durationText: "", encodedPoints: "");
 if ((res["routes"] ?? []).isNotEmpty) {
       directionDetails.encodedPoints =
           res["routes"][0]["overview_polyline"]["points"];

       directionDetails.distanceText =
          res["routes"][0]["legs"][0]["distance"]["text"];
       directionDetails.distanceValue =
           res["routes"][0]["legs"][0]["distance"]["text"];

      directionDetails.durationText =
           res["routes"][0]["legs"][0]["distance"]["text"];
       directionDetails.durationValue =
           res["routes"][0]["legs"][0]["distance"]["text"];
     }
    return directionDetails;
  }

  static int calculatefares(DirectionDetails directionDetails)
  {
    //in terms Naira
    double timeTraveledFare = (directionDetails.durationValue / 60) * 0.60;
    double distanceTraveledFare = (directionDetails.distanceValue / 1000) * 0.60;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    return totalFareAmount.truncate();
  }

  static void getCurrentOnlineUserInfo() async
  {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapShot)
        {
          if(dataSnapShot.value != null)
            {
              userCurrentInfo = Users.fromSnapshot(dataSnapShot);
            }
        });

  }

  static double createRandomNumber(int num)
  {
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }
}