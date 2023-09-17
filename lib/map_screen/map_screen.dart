import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:k_test/map_screen/loading_students_screen.dart';
import 'package:k_test/widget/slide_to_act_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  bool _isLoadingStudent = false;
  bool _driverIsOnline = false;

  final _initialCameraPosition = const CameraPosition(
    target: LatLng(43.653908, -79.384293),
    zoom: 19.151926040649414
  );
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  Set<Marker> _studentLocations = {};

  void _fillStudentPosition() async {
    BitmapDescriptor icon = await _createMarkerImageFromAsset(context);
    _studentLocations = {
      Marker(markerId: const MarkerId("student_1"), position: const LatLng(
        43.653908, -79.384293
      ), icon: icon),
      Marker(markerId: const MarkerId("student_2"), position: const LatLng(
        43.653908, -79.284293
      ), icon: icon),
      Marker(markerId: const MarkerId("student_3"), position: const LatLng(
        43.653908, -79.184293
      ), icon: icon),
      Marker(markerId: const MarkerId("student_4"), position: const LatLng(
        43.653908, -79.084293
      ), icon: icon),
    };
    final _ctr = await _controller.future;
    _ctr.animateCamera(CameraUpdate.newCameraPosition(
      const CameraPosition(target: LatLng(43.653908, -79.084293)),
    ));
    _connectMarkers();
  }

  void zoomMap(double zoom) async {
    final _ctr = await _controller.future;
    _ctr.animateCamera(CameraUpdate.zoomTo(zoom));
  }

  Future<BitmapDescriptor> _createMarkerImageFromAsset(BuildContext context) async {
    final ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size.square(48));
    return await BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/images/student.png');
  }

  void _clearStudentPosition() {
    _studentLocations.clear();
    setState(() {});
  }

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

   addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates
    );
    polylines[id] = polyline;
    setState((){});
 }

  void makeLines(PointLatLng start, PointLatLng end) async {
     await polylinePoints
          .getRouteBetweenCoordinates(
             'AIzaSyDKDgpK0NIRo3ySJ0ldzmorqOyjpA3kqAE',
              start, //Starting LATLANG
              end, //End LATLANG
              travelMode: TravelMode.driving,
    ).then((value) {
        value.points.forEach((PointLatLng point) {
           polylineCoordinates.add(LatLng(point.latitude, point.longitude));
       });
   }).then((value) {
      addPolyLine();
   });
 }

 void _connectMarkers() {
  final l = _studentLocations.toList();
  for (int i = 0; i < l.length; i++) {
    PointLatLng start = PointLatLng(0, 0);
    PointLatLng end = PointLatLng(0, 0);
    if (i == 0) {
      start = PointLatLng(
        _initialCameraPosition.target.latitude, 
        _initialCameraPosition.target.longitude
      );
      end = PointLatLng(
        l[i].position.latitude, 
        l[i].position.longitude
      );
    } else {
      start = PointLatLng(
        l[i].position.latitude, 
        l[i].position.longitude
      );
      if ((i + 1) != l.length) {
        end = PointLatLng(
          l[i + 1].position.latitude, 
          l[i + 1].position.longitude
        );
      } else {
        end = PointLatLng(
          _initialCameraPosition.target.latitude, 
          _initialCameraPosition.target.longitude
        );
      }
    }
    makeLines(start, end);
  }
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _studentLocations,
            ),
          ),

          Positioned(
            top: 100, left: 20, right: 20,
            child: SizedBox(
              height: 50,
              child: SlideAction(
                onSubmit: () {
                  setState(() { _isLoadingStudent = true; });
                  _fillStudentPosition();
                  Future.delayed(const Duration(seconds: 2)).then((value) {
                    _isLoadingStudent = false;
                    _driverIsOnline = true;
                    setState(() { });
                    zoomMap(10);
                  });
                },
                onCancel: () => setState(() {
                  _clearStudentPosition();
                  _driverIsOnline = false;
                }),
                // reversed: _driverIsOnline,
                sliderButtonIconSize: 16,
                sliderButtonIconPadding: 10,
                sliderButtonIcon: CircleAvatar(
                  backgroundColor: _driverIsOnline ? Colors.red : Colors.white,
                  radius: 20,
                  child: const Icon(
                    Icons.keyboard_double_arrow_right_rounded, size: 20,
                  ),
                ),
                sliderRotate: true,
                submittedIcon: const Icon(Icons.arrow_back_ios, color: Colors.red,),
                text: "Hello",
                submittedText: "",
                child: Text(_driverIsOnline ? "Slide to go offline" : "Slide to go online", style: const TextStyle(
                  color: Colors.white
                ),),
              ),
            ),
          ),
          if (_driverIsOnline)
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(onPressed: () {}, child: Text("Drop Students"))),

          if (_isLoadingStudent)
            const Positioned.fill(
              top: 0, left: 0, right: 0, bottom: 0,
              child: LoadingStudentScreen())
        ],
      ),
    );
  }
}