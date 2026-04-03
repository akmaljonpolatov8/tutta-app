import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlng;

import '../../../../app/theme/app_colors.dart';

Future<String?> pickListingCoordinates(
  BuildContext context, {
  String? initialCoordinates,
  String? cityHint,
}) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute<String>(
      fullscreenDialog: true,
      builder: (_) => _LocationPickerScreen(
        initialCoordinates: initialCoordinates,
        cityHint: cityHint,
      ),
    ),
  );
}

class _LocationPickerScreen extends StatefulWidget {
  const _LocationPickerScreen({this.initialCoordinates, this.cityHint});

  final String? initialCoordinates;
  final String? cityHint;

  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  static const _defaultPoint = (41.311100, 69.279700);
  static const _defaultZoom = 14.5;

  final Completer<gmaps.GoogleMapController> _nativeMapController = Completer();
  final MapController _webMapController = MapController();
  late double _lat;
  late double _lng;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  bool _syncingInputs = false;
  bool _resolvingLocation = false;
  bool _hasLocationPermission = false;
  String? _selectedCityLabel;

  bool get _isNativeGoogleMapSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get _isWebMapSupported => kIsWeb;

  @override
  void initState() {
    super.initState();
    final resolved = _resolveInitialPoint();
    _lat = resolved.$1;
    _lng = resolved.$2;
    _selectedCityLabel = _resolveInitialCityLabel();
    _latController = TextEditingController(text: _format(_lat));
    _lngController = TextEditingController(text: _format(_lng));
    _refreshLocationCapability();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coordinateLabel = '${_format(_lat)}, ${_format(_lng)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          _tr(
            context,
            en: 'Pick location on map',
            ru: 'Выберите местоположение',
            uz: 'Xaritada joylashuvni tanlang',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 12),
            _buildMapCard(context),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: _tr(
                        context,
                        en: 'Latitude',
                        ru: 'Широта',
                        uz: 'Kenglik',
                      ),
                    ),
                    onChanged: (_) => _syncPointFromInputs(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: _tr(
                        context,
                        en: 'Longitude',
                        ru: 'Долгота',
                        uz: 'Uzunlik',
                      ),
                    ),
                    onChanged: (_) => _syncPointFromInputs(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    coordinateLabel,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      _tr(
                        context,
                        en: 'Cancel',
                        ru: 'Отмена',
                        uz: 'Bekor qilish',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(coordinateLabel),
                    child: Text(
                      _tr(
                        context,
                        en: 'Confirm location',
                        ru: 'Подтвердить',
                        uz: 'Joylashuvni tasdiqlash',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primarySoftStrong),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: AppColors.primaryDeep,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _tr(
                    context,
                    en: 'In-app location picker',
                    ru: 'Выбор точки в приложении',
                    uz: 'Ilova ichida joylashuv tanlash',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _tr(
              context,
              en: 'Tap map to place the pin, drag for precision, or use current location.',
              ru: 'Нажмите на карту для установки пина, перетащите для точности или используйте текущее местоположение.',
              uz: 'Nuqtani qo\'yish uchun xaritani bosing, aniq joylashuv uchun pinni suring yoki joriy joylashuvdan foydalaning.',
            ),
            style: const TextStyle(color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedCityLabel ??
                      _tr(
                        context,
                        en: 'City not selected',
                        ru: 'Город не выбран',
                        uz: 'Shahar tanlanmagan',
                      ),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _pickCityFromList,
                icon: const Icon(Icons.location_city_outlined),
                label: Text(
                  _tr(
                    context,
                    en: 'All cities',
                    ru: 'Все города',
                    uz: 'Barcha shaharlar',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _kUzbekistanCityPresets
                  .map(
                    (city) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(city.label),
                        selected: _selectedCityLabel == city.label,
                        onSelected: (_) =>
                            _applyCityPreset(city, animate: true),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: _isNativeGoogleMapSupported
                  ? _buildNativeGoogleMap(context)
                  : (_isWebMapSupported
                        ? _buildWebMap(context)
                        : _buildFallbackMap(context)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resolvingLocation ? null : _moveToCurrentLocation,
                icon: _resolvingLocation
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
                label: Text(
                  _tr(
                    context,
                    en: 'Use my current location',
                    ru: 'Использовать текущее местоположение',
                    uz: 'Mening joriy joylashuvimni olish',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeGoogleMap(BuildContext context) {
    return Stack(
      children: [
        gmaps.GoogleMap(
          initialCameraPosition: gmaps.CameraPosition(
            target: gmaps.LatLng(_lat, _lng),
            zoom: _defaultZoom,
          ),
          onMapCreated: (controller) {
            if (!_nativeMapController.isCompleted) {
              _nativeMapController.complete(controller);
            }
          },
          markers: <gmaps.Marker>{
            gmaps.Marker(
              markerId: const gmaps.MarkerId('selected_listing_point'),
              position: gmaps.LatLng(_lat, _lng),
              draggable: true,
              onDragEnd: (position) =>
                  _setPoint(position.latitude, position.longitude),
            ),
          },
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: _hasLocationPermission,
          onTap: (position) => _setPoint(position.latitude, position.longitude),
        ),
        _mapHintPill(context),
      ],
    );
  }

  Widget _buildWebMap(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _webMapController,
          options: MapOptions(
            initialCenter: latlng.LatLng(_lat, _lng),
            initialZoom: _defaultZoom,
            onTap: (_, point) => _setPoint(point.latitude, point.longitude),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'uz.tutta.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: latlng.LatLng(_lat, _lng),
                  width: 44,
                  height: 44,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryDeep,
                    size: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
        _mapHintPill(context),
      ],
    );
  }

  Widget _buildFallbackMap(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF6FF),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(18),
      child: Text(
        _tr(
          context,
          en: 'Map is unavailable on this platform.',
          ru: 'Карта недоступна на этой платформе.',
          uz: 'Bu platformada xarita mavjud emas.',
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }

  Widget _mapHintPill(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          _tr(
            context,
            en: 'Tap map to set pin',
            ru: 'Нажмите на карту для установки пина',
            uz: 'Pinni qoyish uchun xaritani bosing',
          ),
          style: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _refreshLocationCapability() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    final hasPermission =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    if (!mounted) {
      return;
    }
    setState(() => _hasLocationPermission = serviceEnabled && hasPermission);
  }

  Future<void> _moveToCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showEnableGpsDialog();
      await _refreshLocationCapability();
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (!mounted) {
      return;
    }
    if (permission == LocationPermission.denied) {
      _showSnack(
        _tr(
          context,
          en: 'Location permission denied.',
          ru: 'Доступ к геолокации отклонен.',
          uz: 'Geolokatsiya ruxsati rad etildi.',
        ),
      );
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDeniedForeverDialog();
      return;
    }

    setState(() => _resolvingLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      if (!mounted) {
        return;
      }
      _setPoint(position.latitude, position.longitude, animate: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(
        _tr(
          context,
          en: 'Could not determine current location.',
          ru: 'Не удалось определить текущее местоположение.',
          uz: 'Joriy joylashuvni aniqlab bolmadi.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _resolvingLocation = false);
      }
    }
  }

  Future<void> _pickCityFromList() async {
    final selected = await showModalBottomSheet<_UzCityPreset>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CityPickerSheet(
        cities: _kUzbekistanCityPresets,
        selectedLabel: _selectedCityLabel,
      ),
    );
    if (selected == null) {
      return;
    }
    _applyCityPreset(selected, animate: true);
  }

  void _applyCityPreset(_UzCityPreset city, {required bool animate}) {
    _selectedCityLabel = city.label;
    _setPoint(city.latitude, city.longitude, animate: animate);
  }

  Future<void> _showEnableGpsDialog() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _tr(ctx, en: 'Enable GPS', ru: 'Включите GPS', uz: 'GPS ni yoqing'),
        ),
        content: Text(
          _tr(
            ctx,
            en: 'Location service is off. Please enable GPS.',
            ru: 'Служба геолокации выключена. Включите GPS.',
            uz: 'Geolokatsiya xizmati ochiq emas. GPS ni yoqing.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(_tr(ctx, en: 'Later', ru: 'Позже', uz: 'Keyinroq')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              _tr(
                ctx,
                en: 'Open settings',
                ru: 'Открыть настройки',
                uz: 'Sozlamalarni ochish',
              ),
            ),
          ),
        ],
      ),
    );
    if (openSettings == true) {
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> _showPermissionDeniedForeverDialog() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _tr(
            ctx,
            en: 'Location permission required',
            ru: 'Требуется доступ к геолокации',
            uz: 'Geolokatsiya ruxsati kerak',
          ),
        ),
        content: Text(
          _tr(
            ctx,
            en: 'Permission is permanently denied. Open app settings.',
            ru: 'Доступ отклонен навсегда. Откройте настройки приложения.',
            uz: 'Ruxsat butunlay rad etilgan. Ilova sozlamalarini oching.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              _tr(ctx, en: 'Cancel', ru: 'Отмена', uz: 'Bekor qilish'),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              _tr(
                ctx,
                en: 'Open app settings',
                ru: 'Открыть настройки',
                uz: 'Sozlamalarni ochish',
              ),
            ),
          ),
        ],
      ),
    );
    if (openSettings == true) {
      await Geolocator.openAppSettings();
    }
  }

  void _setPoint(
    double lat,
    double lng, {
    bool animate = false,
    bool updateInputs = true,
  }) {
    setState(() {
      _lat = lat;
      _lng = lng;
      if (updateInputs) {
        _syncingInputs = true;
        _latController.text = _format(lat);
        _lngController.text = _format(lng);
        _syncingInputs = false;
      }
    });
    if (animate) {
      _animateCamera(lat, lng);
    }
  }

  void _syncPointFromInputs() {
    if (_syncingInputs) {
      return;
    }
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) {
      return;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return;
    }
    _setPoint(lat, lng, animate: true, updateInputs: false);
  }

  Future<void> _animateCamera(double lat, double lng) async {
    if (_isNativeGoogleMapSupported && _nativeMapController.isCompleted) {
      final controller = await _nativeMapController.future;
      await controller.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(gmaps.LatLng(lat, lng), _defaultZoom),
      );
      return;
    }
    if (_isWebMapSupported) {
      _webMapController.move(latlng.LatLng(lat, lng), _defaultZoom);
    }
  }

  (double, double) _resolveInitialPoint() {
    final fromCoordinates = _tryParsePoint(widget.initialCoordinates);
    if (fromCoordinates != null) {
      return fromCoordinates;
    }
    return _cityCenter(widget.cityHint) ?? _defaultPoint;
  }

  (double, double)? _tryParsePoint(String? value) {
    final normalized = (value ?? '').trim();
    final match = RegExp(
      r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$',
    ).firstMatch(normalized);
    if (match == null) {
      return null;
    }
    final lat = double.tryParse(match.group(1) ?? '');
    final lng = double.tryParse(match.group(2) ?? '');
    if (lat == null || lng == null) {
      return null;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return null;
    }
    return (lat, lng);
  }

  (double, double)? _cityCenter(String? city) {
    final normalized = _normalizeCityToken(city);
    if (normalized.isEmpty) {
      return null;
    }
    for (final item in _kUzbekistanCityPresets) {
      if (item.matches(normalized)) {
        return (item.latitude, item.longitude);
      }
    }
    return null;
  }

  String? _resolveInitialCityLabel() {
    final normalized = _normalizeCityToken(widget.cityHint);
    if (normalized.isEmpty) {
      return null;
    }
    for (final item in _kUzbekistanCityPresets) {
      if (item.matches(normalized)) {
        return item.label;
      }
    }
    return null;
  }

  String _normalizeCityToken(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.isEmpty) {
      return '';
    }
    return value.replaceAll(RegExp(r'\s+'), ' ');
  }

  String _format(double value) => value.toStringAsFixed(6);

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _UzCityPreset {
  const _UzCityPreset({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.aliases,
  });

  final String label;
  final double latitude;
  final double longitude;
  final List<String> aliases;

  bool matches(String normalized) => aliases.contains(normalized);
}

const List<_UzCityPreset> _kUzbekistanCityPresets = <_UzCityPreset>[
  _UzCityPreset(
    label: 'Tashkent',
    latitude: 41.3111,
    longitude: 69.2797,
    aliases: <String>['tashkent', 'toshkent'],
  ),
  _UzCityPreset(
    label: 'Andijan',
    latitude: 40.7821,
    longitude: 72.3442,
    aliases: <String>['andijan', 'andijon'],
  ),
  _UzCityPreset(
    label: 'Bukhara',
    latitude: 39.7681,
    longitude: 64.4556,
    aliases: <String>['bukhara', 'buxoro'],
  ),
  _UzCityPreset(
    label: 'Fergana',
    latitude: 40.3864,
    longitude: 71.7875,
    aliases: <String>['fergana', 'fargona'],
  ),
  _UzCityPreset(
    label: 'Gulistan',
    latitude: 40.4897,
    longitude: 68.7842,
    aliases: <String>['gulistan'],
  ),
  _UzCityPreset(
    label: 'Jizzakh',
    latitude: 40.1142,
    longitude: 67.8422,
    aliases: <String>['jizzakh', 'jizzax'],
  ),
  _UzCityPreset(
    label: 'Karshi',
    latitude: 38.8606,
    longitude: 65.7891,
    aliases: <String>['karshi', 'qarshi'],
  ),
  _UzCityPreset(
    label: 'Khiva',
    latitude: 41.3783,
    longitude: 60.3639,
    aliases: <String>['khiva', 'xiva'],
  ),
  _UzCityPreset(
    label: 'Namangan',
    latitude: 40.9983,
    longitude: 71.6726,
    aliases: <String>['namangan'],
  ),
  _UzCityPreset(
    label: 'Navoi',
    latitude: 40.1039,
    longitude: 65.3688,
    aliases: <String>['navoi', 'navoiy'],
  ),
  _UzCityPreset(
    label: 'Nukus',
    latitude: 42.4611,
    longitude: 59.6166,
    aliases: <String>['nukus'],
  ),
  _UzCityPreset(
    label: 'Samarkand',
    latitude: 39.6542,
    longitude: 66.9597,
    aliases: <String>['samarkand', 'samarqand'],
  ),
  _UzCityPreset(
    label: 'Termez',
    latitude: 37.2242,
    longitude: 67.2783,
    aliases: <String>['termez', 'termiz'],
  ),
  _UzCityPreset(
    label: 'Urgench',
    latitude: 41.5500,
    longitude: 60.6333,
    aliases: <String>['urgench', 'urganch'],
  ),
];

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({required this.cities, required this.selectedLabel});

  final List<_UzCityPreset> cities;
  final String? selectedLabel;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final filtered = widget.cities
        .where((city) {
          if (normalizedQuery.isEmpty) {
            return true;
          }
          if (city.label.toLowerCase().contains(normalizedQuery)) {
            return true;
          }
          for (final alias in city.aliases) {
            if (alias.contains(normalizedQuery)) {
              return true;
            }
          }
          return false;
        })
        .toList(growable: false);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tr(
                context,
                en: 'Choose city',
                ru: 'Выберите город',
                uz: 'Shaharni tanlang',
              ),
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: _tr(
                  context,
                  en: 'Search city',
                  ru: 'Поиск города',
                  uz: 'Shahar qidirish',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final city = filtered[index];
                  final selected = widget.selectedLabel == city.label;
                  return ListTile(
                    title: Text(city.label),
                    trailing: selected ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(city),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _tr(
  BuildContext context, {
  required String en,
  required String ru,
  required String uz,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'ru':
      return ru;
    case 'uz':
      return uz;
    default:
      return en;
  }
}
