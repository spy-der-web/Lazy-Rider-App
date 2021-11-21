import 'package:flutter/cupertino.dart';
import 'package:lazy_rider/Models/address.dart';


class AppData extends ChangeNotifier
{
  Address pickUpLocation, dropOffLocation;

  void updatePickUpLocationAddress(Address pickUpAddress)
  {
    pickUpLocation = pickUpAddress;
    print(pickUpLocation.placeFormattedAddress);
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress)
  {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

}