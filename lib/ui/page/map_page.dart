// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:luonnosta_app/constants.dart';
import 'package:luonnosta_app/logic/list_markings_cubit.dart';
import 'package:luonnosta_app/model/map_layer_meta.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:io';

import '../../model/marking.dart';
import '../widget/loading_view.dart';
import '../widget/map_marker.dart';
import 'marking_details_page.dart';

class WMSLayerPage extends StatefulWidget {
  static const String route = 'WMS layer';

  const WMSLayerPage({Key? key}) : super(key: key);

  @override
  State<WMSLayerPage> createState() => _WMSLayerPageState();
}

class _WMSLayerPageState extends State<WMSLayerPage> {
  final MapController _mapController = MapController();
  bool _gpsEnabled = false;
  bool _locateButtonPressed = false;
  LatLng? _currentPos;
  double _initialLat = 62.242, _initialLon = 25.747;
  late Proj4Crs epsg3067CRS;
  bool _selectMode = false;
  late Bounds<double> _bounds;
  var resolutions = <double>[];
  late double maxZoom;
  final List<String> _maps = <String>['maastokartta', 'ortokuva'];
  late String _currentMap;

  List<double> getResolutions(double maxX, double minX, int zoom,
      [double tileSize = 256.0]) {
    var size = (maxX - minX) / tileSize;
    return List.generate(zoom, (z) => size / math.pow(2, z));
  }

  @override
  void initState() {
    context.read<ListMarkingsCubit>().listAll();
    super.initState();
    _currentMap = _maps.first;
    _bounds = Bounds<double>(
      const CustomPoint<double>(43547.78932226647, 6523158.091198515),
      const CustomPoint<double>(764796.7155847414, 7795461.187543589),
    );
    resolutions = getResolutions(764796.7155847414, 43547.78932226647, 14);
    maxZoom = (resolutions.length - 1).toDouble();

    epsg3067CRS = Proj4Crs.fromFactory(
      code: 'EPSG:3067',
      proj4Projection: Constants.projection,
      resolutions: resolutions,
      bounds: _bounds,
    );
  }

  setPosition(LatLng pos, double zoom) {
    if (_initialLat != 0 &&
        _initialLon != 0 &&
        !_selectMode &&
        !_locateButtonPressed) {
      _mapController.move(LatLng(_initialLat, _initialLon), 12);
      return;
    }
    _mapController.move(pos, 12);
    setState(() {
      _currentPos = pos;
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng getCenter() {
    return _mapController.center;
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.name != null &&
        ModalRoute.of(context)!.settings.name == "select_location") {
      _selectMode = true;
    }

    if (ModalRoute.of(context)!.settings.arguments != null) {
      _initialLat = (ModalRoute.of(context)!.settings.arguments as Marking)
          .position["lat"];
      _initialLon = (ModalRoute.of(context)!.settings.arguments as Marking)
          .position["lon"];
    }

    return BlocConsumer<ListMarkingsCubit, ListMarkingsState>(
      listener: (context, state) {
        if (state is ListMarkingsSuccess) {
          _requestPermission();
        }
        if (state is ListMarkingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        List<Marking> markings = [];
        if (!_selectMode) {
          if (state is ListMarkingsLoading || state is ListMarkingsInitial) {
            return const LoadingView();
          }
          if (state is! ListMarkingsLoading && state is! ListMarkingsError) {
            markings = (state as ListMarkingsSuccess).response;
          }
        }
        return Scaffold(
          floatingActionButton: (!_gpsEnabled)
              ? null
              : FloatingActionButton(
                  child: const Icon(Icons.gps_fixed),
                  onPressed: () async {
                    setState(() {
                      _locateButtonPressed = true;
                    });
                    _requestPermission();
                  },
                ),
          appBar: AppBar(
            title: Text(
              (_selectMode)
                  ? AppLocalizations.of(context)!.setLocation
                  : AppLocalizations.of(context)!.landingMap,
            ),
            centerTitle: true,
            backgroundColor: AppColors.inputBorder,
          ),
          extendBody: false,
          extendBodyBehindAppBar: false,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    maxZoom: 20000000,
                    minZoom: 0,
                    enableScrollWheel: false,
                    center: LatLng(_initialLat, _initialLon),
                    crs: epsg3067CRS,
                  ),
                  children: [
                    TileLayer(
                      wmsOptions: WMSTileLayerOptions(
                        styles: ["normal"],
                        format: "image/png",
                        baseUrl:
                            'https://oamkwmsraja:B1od1p1hanke2023@sopimus-karttakuva.maanmittauslaitos.fi/sopimus/service/wms?',
                        layers: [_currentMap],
                        version: "1.3.0",
                        crs: epsg3067CRS,
                        transparent: false,
                      ),
                    ),
                    MarkerLayer(markers: _buildMarkers(markings)),
                  ],
                ),
              ),
              if (_selectMode)
                Center(
                  child: IgnorePointer(
                    child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.3),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(120)),
                        ),
                        child: Center(
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.7),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(120)),
                            ),
                          ),
                        )),
                  ),
                ),
              if (_selectMode) Container(),
              if (_selectMode)
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: AppColors.inputBorder,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white,
                            backgroundColor: AppColors.inputBorder,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  settings: RouteSettings(
                                      name:
                                          "${_mapController.center.latitude},${_mapController.center.longitude}"),
                                  builder: (context) =>
                                      const MarkingDetailsPage()),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.setLocation,
                            style: const TextStyle(fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Transform.translate(
                offset: const Offset(-18, 0),
                child: Transform.scale(
                  scale: 0.7,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<String>(
                      value: _currentMap,
                      elevation: 16,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _currentMap = value;
                          });
                        }
                      },
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 42,
                      underline: const SizedBox(),
                      items:
                          _maps.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _requestPermission() async {
    bool servicestatus = await Geolocator.isLocationServiceEnabled();

    setState(() {
      _gpsEnabled = servicestatus;
    });
    if (servicestatus) {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.errorNoGpsPermission)),
          );
        } else if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    AppLocalizations.of(context)!.errorNoGpsPermissionForever)),
          );
          setState(() {
            _gpsEnabled = false;
          });
        } else {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          setPosition(LatLng(position.latitude, position.longitude), 12);
        }
      } else {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setPosition(LatLng(position.latitude, position.longitude), 12);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.errorGPSNotEnabled)),
      );
    }
  }

  _buildMarkers(List<Marking> markings) {
    List<Marker> result = [];
    // Current location
    if (_currentPos != null) {
      result.add(
        Marker(
          point: _currentPos!,
          width: 30,
          height: 30,
          builder: (context) {
            return const Icon(
              Icons.attribution_rounded,
              color: Colors.red,
            );
          },
        ),
      );
    }
    if (_selectMode) return result;

    // Markings
    for (var marking in markings) {
      result.add(
        Marker(
          point: LatLng(double.parse(marking.position["lat"].toString()),
              double.parse(marking.position["lon"].toString())),
          width: 55,
          height: 55,
          builder: (context) => MapMarker(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  settings: RouteSettings(arguments: marking),
                  builder: (context) => const MarkingDetailsPage()),
            );
          }, marking),
        ),
      );
    }

    return result;
  }
}
