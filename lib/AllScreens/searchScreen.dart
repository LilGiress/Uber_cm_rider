import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber/AllWidgets/Divider.dart';
import 'package:uber/AllWidgets/progressDialog.dart';
import 'package:uber/Assistants/requestAssistant.dart';
import 'package:uber/DataHandler/appData.dart';
import 'package:uber/Models/address.dart';
import 'package:uber/Models/placePredictions.dart';
import 'package:uber/configMaps.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];
  @override
  Widget build(BuildContext context) {
    String? placeAddress =
        Provider.of<AppData>(context).pickUpLocation!.placeName;

    pickUpTextEditingController.text = placeAddress;

    return Scaffold(
      //key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 255.0,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                )
              ]),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 25.0, top: 25.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                        Center(
                          child: Text(
                            "Set drop off",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "bolt-regular"),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/pickicon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          height: 18.0,
                        ),
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: InputDecoration(
                                hintText: "PickUp location ",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/desticon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          height: 18.0,
                        ),
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              onChanged: (val) {
                                findPlace(val);
                              },
                              controller: dropOffTextEditingController,
                              decoration: InputDecoration(
                                hintText: "Where to ? ",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // tile for predictions
          SizedBox(
            height: 10.0,
          ),
          (placePredictionList.length > 0)
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0.0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        placePredictions: placePredictionList[index],
                        key: null,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        DividerWidget(),
                    itemCount: placePredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

//place prediction results
  void findPlace(String placeName) async {
    print("demanou" + placeName);
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&components=country:cm";

      var res = await RequestAssistant.getRequest(autoCompleteUrl);

      if (res == "Failed") {
        return;
      }
     
      if (res["status"] == "OK") {
        var predictions = res["predictions"];

        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

// widget to show result of prediction result
class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PredictionTile({required Key? key, required this.placePredictions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      // key: _scaffoldKey,
      padding: EdgeInsets.all(0.0),
      onPressed: () {
        getPlaceAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(
                  height: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        placePredictions.main_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        placePredictions.secondary_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

// to get detaild of address
  void getPlaceAddressDetails(String placeId, context) async {
    print("demanou," + placeId);
    //print(placeId);
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Setting Dropoff, please wait...",
            ));
    print("demanou,////////////" + placeId);
    String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var res = await RequestAssistant.getRequest(placeDetailsUrl);
    Navigator.pop(context);
    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Address address = Address(
          latitude: null,
          longitude: null,
          placeFormattedAddress: '',
          placeId: '',
          placeName: '');
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);

      print("This is Drop Off Location::  //////////////////////////////////////////////////////////////////////////");
      print(address.placeName);
       print("This is Drop Off Location::  //////////////////////////////////////////////////////////////////////////");

      Navigator.pop(context, "obtainDirection");
    }
  }
}
