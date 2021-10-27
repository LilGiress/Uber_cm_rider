import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/AllScreens/loginScreen.dart';
import 'package:uber/AllScreens/searchScreen.dart';
import 'package:uber/AllWidgets/Divider.dart';
import 'package:uber/AllWidgets/progressDialog.dart';
import 'package:uber/Assistants/assistantMethods.dart';
import 'package:uber/Assistants/geoFireAssistant.dart';
import 'package:uber/DataHandler/appData.dart';
import 'package:uber/Models/directDetails.dart';
import 'package:uber/Models/nearbyAvailableDrivers.dart';
import 'package:uber/configMaps.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  // google controller
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
// globalkey
  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  // polyline and marker
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
//geolocator instataner
  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;
  // set marker and circle
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  double rideDetailsContainerHeight = 0;
  double searchContainerHeight = 300.0;
  double requestRideContainerHeight = 0;

  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;
  DirectionDetails? tripDirectionDetails;

  late DatabaseReference rideRequestRef;
  BitmapDescriptor? nearByIcon;

// color animation
  List<MaterialColor> colorizeColors = [
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];
  TextStyle colorizeTextStyle = TextStyle(
    fontSize: 55.0,
    fontFamily: 'signatra',
  );
  // initialise the state
  @override
  void initState() {
    //TODO: implement initState
    super.initState();

    AssistantMethods.getCurrentOnlineUserInfo();
  }

  // function to save in to Database firebase
  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUplocMap = {
      "latitude": pickUp!.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOfflocMap = {
      "latitude": dropOff!.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUplocMap,
      "dropoff": dropOfflocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo!.name,
      "rider_phone": userCurrentInfo!.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
    };

    rideRequestRef.set(rideInfoMap);
  }

  // function to remove de request in to database
  void cancelRideRequest() {
    rideRequestRef.remove(); // it delete de request in the database
  }

// to display the request or dissimi
  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });

    saveRideRequest();
  }

  // to reset app
  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }

// details of rider
  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240.0;

      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }

// google map position
  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your Address ::" + address);
    initGeoFireListner();
  }

  //google position
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              // drawer header - entete
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/user_icon.png",
                        height: 65.0,
                        width: 65.0,
                      ),
                      SizedBox(width: 16.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profil Name",
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "bolt-regular"),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text("Visit Profile"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              DividerWidget(),

              SizedBox(
                height: 12.0,
              ),
              //drawer body controller
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScrenn.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    "Sign ut",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            zoomControlsEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.completeError(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });
              locatePosition();
            },
          ),

          //hamburgerButton for Drawer
          Positioned(
            top: 55.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldkey.currentState!.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (drawerOpen) ? Icons.menu : Icons.close,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 6.0,
                      ),
                      Text(
                        "Hi there ",
                        style: TextStyle(fontSize: 12.0),
                      ),
                      Text(
                        "Where to?",
                        style: TextStyle(
                            fontSize: 20.0, fontFamily: "bolt-regular"),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));

                          if (res == "obtainDirection") {
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                )
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                Text("Search Drop Off ")
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ignore: unnecessary_null_comparison
                              Text(Provider.of<AppData>(context)

                                          // ignore: unnecessary_null_comparison
                                          .pickUpLocation !=
                                      null
                                  ? Provider.of<AppData>(context)
                                      .pickUpLocation!
                                      .placeName
                                  : "Add Home"),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your Living Home address",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      DividerWidget(),
                      SizedBox(
                        height: 16.0,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work"),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your Office address",
                                style: TextStyle(
                                    color: Colors.black45, fontSize: 12.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          /////////////////////////////////////////////
          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  height: rideDetailsContainerHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 16.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 17.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.tealAccent[100],
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  "images/taxi.png",
                                  height: 70.0,
                                  width: 80.0,
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Car",
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: "bolt-regular"),
                                      ),
                                      Text(
                                        // ignore: unnecessary_null_comparison
                                        ((tripDirectionDetails != null)
                                            ? tripDirectionDetails!.distanceText
                                            : ''),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ]),
                                Expanded(child: Container()),
                                Text(
                                  // ignore: unnecessary_null_comparison
                                  ((tripDirectionDetails != null)
                                      ? '\$${AssistantMethods.calculateFares(tripDirectionDetails!)}'
                                      : ''),
                                  style: TextStyle(
                                    fontFamily: "bolt-regular",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.moneyCheckAlt,
                                size: 18.0,
                                color: Colors.black54,
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Text("Cash"),
                              SizedBox(
                                width: 6.0,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black54,
                                size: 16.0,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 24.0,
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: RaisedButton(
                              onPressed: () {
                                displayRequestRideContainer();
                              },
                              color: Theme.of(context).accentColor,
                              child: Padding(
                                padding: EdgeInsets.all(17.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Request",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Icon(
                                      FontAwesomeIcons.taxi,
                                      color: Colors.white,
                                      size: 26.0,
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              )),

          Positioned(
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              height: requestRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            'Requesting a Driver',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                          ColorizeAnimatedText(
                            'Please wait ....',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                          ColorizeAnimatedText(
                            'Finding a driver....',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {
                          print("Tap Event");
                        },
                      ),
                    ),
                    SizedBox(
                      height: 22.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(
                              width: 2.0, color: Colors.grey.shade300),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 26.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Cancel Ride",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// to get position exactly distance between initialposition and finalposition
  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;

    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos!.latitude!, finalPos.longitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: " Please wait.....",
            ));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details!;
    });

    Navigator.pop(context);

    print(
        "This is encoded points:: //////////////////////////////////////////////////////////////");
    print("demanou" + details!.encodedPoints);
    //polyline function
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("polylineId"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "My location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "DropOff location"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blue,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

  void initGeoFireListner() {
    Geofire.initialize("availableDrivers");

    //comment
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 15)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            // keysRetrieved.add(map["key"]);
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(
                    key: '', latitude: null, longitute: null);
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitute = map['longitude'];
            GeoFireAssistant.nearByAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearbyAvailableDriverKeysLoaded == true) {
              updateAvailableDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            // keysRetrieved.remove(map["key"]);
            GeoFireAssistant.removeDriverFromlist(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(
                    key: '', latitude: null, longitute: null);
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitute = map['longitude'];
            GeoFireAssistant.updateDriverNeabyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            // print(map['result']);

            updateAvailableDriversOnMap();
            break;
        }
      }

      setState(() {});
    });

    //comment
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });
    Set<Marker> tMarkers = Set<Marker>();

    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearByAvailableDriversList) {
      LatLng driverAvailablePosition =
          LatLng(driver.latitude!, driver.longitute!);

      Marker marker = Marker(
        markerId: MarkerId("driver${driver.key}"),
        position: driverAvailablePosition,
        icon: nearByIcon!,
        rotation: AssistantMethods.createRandomNumber(360),
      );

      tMarkers.add(marker);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }

  void createIconMarker() {
    // ignore: unnecessary_null_comparison
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios.png")
          .then((value) => {nearByIcon = value});
    }
  }
}
