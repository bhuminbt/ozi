import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import '../../../../../core/appExports/app_export.dart';
import '../../../../../data/repository/repository.dart';
import '../../save address/model/user_address_model.dart';

class EditUserAddressProvider extends ChangeNotifier {
  final _repository = Repository();

  TextEditingController streetController = TextEditingController();
  TextEditingController apartmentController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  TextEditingController receiverNameController = TextEditingController();
  TextEditingController receiverMobileController = TextEditingController();

  Country? _receiverCountry = Country.parse('IN');
  Country? get receiverCountry => _receiverCountry;

  void updateReceiverCountry(Country country) {
    if (_receiverCountry?.phoneCode != country.phoneCode) {
      _receiverCountry = country;
    }

    // Strip redundant country code if present in the mobile number
    String currentMobile = receiverMobileController.text.trim().replaceAll(
      RegExp(r'\D'),
      '',
    );
    String phoneCode = country.phoneCode;
    int expectedLength = getExpectedPhoneLength(phoneCode);

    if (currentMobile.startsWith(phoneCode) &&
        currentMobile.length == phoneCode.length + expectedLength) {
      receiverMobileController.text = currentMobile.substring(phoneCode.length);
    }
    notifyListeners();
  }

  int selectedType = 0;
  bool _initialized = false;
  bool get initialized => _initialized;

  bool _isInitialMapMove = true;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _addressId;
  String? _lat;
  String? _lng;
  bool _disposed = false;
  void safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    streetController.dispose();
    apartmentController.dispose();
    cityController.dispose();
    zipController.dispose();
    countryController.dispose();
    receiverNameController.dispose();
    receiverMobileController.dispose();
    super.dispose();
  }

  bool _isDefaultAddress = false;
  bool get isDefaultAddress => _isDefaultAddress;

  void toggleDefaultAddress(bool? value) {
    _isDefaultAddress = value ?? false;
    safeNotifyListeners();
  }

  // Map related state
  GoogleMapController? mapController;
  LatLng? selectedLatLng;
  final Set<Marker> markers = {};
  bool _isFetchingAddress = false;
  final LatLng initialLocation = const LatLng(26.9124, 75.7873);

  void setMapController(GoogleMapController ctrl) {
    mapController = ctrl;
  }

  void init(
    Data? address, {
    String? lat,
    String? lng,
    String? receiverName,
    String? receiverMobile,
    String? countryCode,
  }) {
    if (kDebugMode) {
      print(
        "Init called with address ID: ${address?.id}, already initialized: $_initialized",
      );
    }

    // If already initialized with the same address, skip
    if (_initialized && _addressId == address?.id) {
      if (kDebugMode) {
        print("Skipping init - same address");
      }
      return;
    }

    if (_initialized && kDebugMode) {
      print("Re-initializing with different address");
    }

    _addressId = address?.id;
    _lat = lat ?? address?.latitude;
    _lng = lng ?? address?.longitude;
    if (kDebugMode) {
      print("Setting _addressId to: $_addressId, lat: $_lat, lng: $_lng");
    }

    try {
      if (_lat != null &&
          _lng != null &&
          _lat != "null" &&
          _lng != "null" &&
          _lat!.isNotEmpty &&
          _lng!.isNotEmpty) {
        selectedLatLng = LatLng(double.parse(_lat!), double.parse(_lng!));
        // Set marker without calling notifyListeners (init will do it at the end)
        markers.clear();
        markers.add(
          Marker(
            markerId: const MarkerId("selected"),
            position: selectedLatLng!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueCyan,
            ),
          ),
        );
      } else {
        selectedLatLng = initialLocation;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error parsing lat/lng: $e");
      }
      selectedLatLng = initialLocation;
    }

    streetController.text = address?.streetAddress ?? '';
    apartmentController.text = address?.apartment ?? '';
    cityController.text = address?.city ?? '';
    zipController.text = address?.zipCode ?? '';
    countryController.text = address?.country ?? '';

    receiverNameController.text = receiverName ?? address?.receiverName ?? '';
    String rawMobile = receiverMobile ?? address?.receiverMobile ?? '';

    final effectiveCountryCode = countryCode ?? address?.receiverCountryCode;
    String phoneCode = '';

    if (effectiveCountryCode != null && effectiveCountryCode.isNotEmpty) {
      try {
        // 1. Try passing as ISO code (like 'IN')
        _receiverCountry = Country.parse(effectiveCountryCode);
        phoneCode = _receiverCountry?.phoneCode ?? '';
      } catch (e) {
        // 2. If it's a phone code (like '91'), find the country
        final countries = CountryService().getAll();
        try {
          _receiverCountry = countries.firstWhere(
            (c) =>
                c.phoneCode == effectiveCountryCode ||
                c.phoneCode == effectiveCountryCode.replaceAll('+', ''),
          );
          phoneCode = _receiverCountry?.phoneCode ?? '';
        } catch (_) {
          _receiverCountry = Country.parse('IN');
          phoneCode = '91';
        }
      }
    } else {
      _receiverCountry = Country.parse('IN');
      phoneCode = '91';
    }

    // Strip redundant country code from initial mobile number
    String cleanMobile = rawMobile.replaceAll(RegExp(r'\D'), '');
    int expectedLength = getExpectedPhoneLength(phoneCode);

    if (cleanMobile.startsWith(phoneCode) &&
        cleanMobile.length == phoneCode.length + expectedLength) {
      receiverMobileController.text = cleanMobile.substring(phoneCode.length);
    } else {
      receiverMobileController.text = rawMobile;
    }

    _isDefaultAddress = address?.isDefault ?? false;
    selectedType = _getTypeIndex(address?.addressType);

    _initialized = true;
    notifyListeners();
  }

  int _getTypeIndex(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return 0;
      case 'work':
        return 1;
      default:
        return 2;
    }
  }

  String _getTypeString(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'work';
      default:
        return 'other';
    }
  }

  void updateType(int index) {
    selectedType = index;
    notifyListeners();
  }

  // Map Interaction Methods
  Future<void> onMapTap(LatLng latLng) async {
    _updateMarker(latLng);
    await mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  Future<void> onCameraIdle(LatLng latLng) async {
    if (_isFetchingAddress) return;
    _updateMarker(latLng);

    // Skip the very first geocoding fetch if we just initialized with address details
    if (_isInitialMapMove) {
      if (kDebugMode)
        print(
          "Skipping initial map reverse-geocode to preserve passed address",
        );
      _isInitialMapMove = false;
      return;
    }

    await _updateLocationAndAddress(latLng);
  }

  Future<void> selectManualPlace(Prediction prediction) async {
    if (prediction.placeId == null) return;

    final places = GoogleMapsPlaces(
      apiKey: "AIzaSyApdA5sIEfZoPmhlWuAr5wTgyOXvhl9jsQ",
    );
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(
      prediction.placeId!,
      fields: ["address_components", "geometry", "formatted_address"],
    );
    if (!detail.isOkay || detail.result.geometry == null) return;

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    final newLatLng = LatLng(lat, lng);

    // Update marker (if you have one)
    _updateMarker(newLatLng);
    try {
      final detail = await places.getDetailsByPlaceId(
        prediction.placeId!,
        fields: ["address_components", "geometry", "formatted_address"],
      );

      if (!detail.isOkay || detail.result.geometry == null) return;

      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;
      final newLatLng = LatLng(lat, lng);

      // Update map
      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newLatLng, zoom: 17),
        ),
      );

      _updateMarker(newLatLng);

      // Fill fields
      String street = "",
          subLocality = "",
          city = "",
          postal = "",
          country = "";

      for (var comp in detail.result.addressComponents) {
        final types = comp.types;
        if (types.contains("street_number") || types.contains("route")) {
          street += "${comp.longName} ";
        }
        if (types.contains("sublocality")) subLocality = comp.longName;
        if (types.contains("locality")) city = comp.longName;
        if (types.contains("postal_code")) postal = comp.longName;
        if (types.contains("country")) country = comp.longName;
      }

      streetController.text =
          detail.result.formattedAddress ??
          "${street.trim()} ${subLocality.trim()}".trim();
      cityController.text = city;
      zipController.text = postal;
      countryController.text = country;

      apartmentController.text =
          prediction.description?.split(', ').skip(1).take(2).join(', ') ?? "";

      safeNotifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error in selectManualPlace: $e");
      }
    }
  }

  static const String kGoogleApiKey = "AIzaSyApdA5sIEfZoPmhlWuAr5wTgyOXvhl9jsQ";

  Future<void> showLocationSearch(BuildContext context) async {
    Prediction? prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "in")],
      hint: "Search area, street name, landmark...",
      location: selectedLatLng != null
          ? Location(
              lat: selectedLatLng!.latitude,
              lng: selectedLatLng!.longitude,
            )
          : null,
      radius: 50000, // suggestions nearby bias
      offset: 0,
    );

    if (prediction != null && prediction.placeId != null) {
      await _processSelectedPlace(prediction, context);
    }
  }

  Future<void> _processSelectedPlace(
    Prediction prediction,
    BuildContext context,
  ) async {
    final places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(
      prediction.placeId!,
      fields: ["address_components", "geometry", "formatted_address"],
    );

    if (!detail.isOkay || detail.result.geometry == null) {
      // Optional: show error toast
      return;
    }

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    final newLatLng = LatLng(lat, lng);

    // Map update (existing map safe rahega)
    await mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: newLatLng, zoom: 17),
      ),
    );

    // Marker if needed (central pin already handle kar raha hai)
    _updateMarker(newLatLng);

    // Fields fill
    String street = "";
    String subLocality = "";
    String city = "";
    String postal = "";
    String country = "";

    for (var comp in detail.result.addressComponents) {
      final types = comp.types;
      if (types.contains("street_number") || types.contains("route")) {
        street += "${comp.longName} ";
      }
      if (types.contains("sublocality")) subLocality = comp.longName;
      if (types.contains("locality")) city = comp.longName;
      if (types.contains("postal_code")) postal = comp.longName;
      if (types.contains("country")) country = comp.longName;
    }

    streetController.text =
        detail.result.formattedAddress ??
        "${street.trim()} ${subLocality.trim()}".trim();
    cityController.text = city;
    zipController.text = postal;
    countryController.text = country;

    // Landmark / extra info
    apartmentController.text =
        prediction.description ??
        prediction.description?.split(', ').skip(1).take(2).join(', ') ??
        "";

    safeNotifyListeners();
  }

  void _updateMarker(LatLng latLng) {
    selectedLatLng = latLng;
    _lat = latLng.latitude.toString();
    _lng = latLng.longitude.toString();
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId("selected"),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      ),
    );
    notifyListeners();
  }

  Future<void> _updateLocationAndAddress(LatLng latLng) async {
    if (_disposed || _isFetchingAddress) return;

    _isFetchingAddress = true;
    safeNotifyListeners();

    try {
      // Optional: Set desired locale once (you can also call this in initState or earlier)
      // Best place: call it once when provider initializes or app starts
      // await setLocaleIdentifier("en_IN");   // Uncomment if you want India-English style

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty && !_disposed) {
        // Pick the most useful placemark (first is usually good, but we try to improve)
        Placemark? bestPlace;
        for (var place in placemarks) {
          if ((place.thoroughfare?.isNotEmpty ?? false) ||
              (place.subThoroughfare?.isNotEmpty ?? false)) {
            bestPlace = place;
            break;
          }
        }
        bestPlace ??= placemarks.first;

        String fullStreetAddress =
            [
                  bestPlace.name,
                  bestPlace.subThoroughfare,
                  bestPlace.thoroughfare,
                  bestPlace.subLocality,
                  bestPlace.locality,
                  bestPlace.subAdministrativeArea,
                ]
                .where((s) => s != null && s.isNotEmpty)
                .cast<String>()
                .fold<List<String>>([], (acc, s) {
                  if (acc.every(
                    (existing) =>
                        !existing.contains(s) && !s.contains(existing),
                  )) {
                    acc.add(s);
                  }
                  return acc;
                })
                .join(', ')
                .trim();

        if (fullStreetAddress.isEmpty) {
          fullStreetAddress = bestPlace.name ?? 'Unknown location';
        }

        // Update controllers (no 'mounted' check needed here)
        streetController.text = fullStreetAddress;
        cityController.text =
            bestPlace.locality ?? bestPlace.subAdministrativeArea ?? '';
        zipController.text = bestPlace.postalCode ?? '';
        countryController.text = bestPlace.country ?? 'India';

        // Optional: you can also fill apartment / landmark if useful
        // apartmentController.text = bestPlace.name ?? '';
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
      // Optionally show toast / error to user
    } finally {
      _isFetchingAddress = false;
      if (!_disposed) {
        safeNotifyListeners();
      }
    }
  }

  Future<void> moveToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng latLng = LatLng(position.latitude, position.longitude);

      _updateMarker(latLng);
      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 17),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Location permission denied: $e");
      }
    }
  }

  int getExpectedPhoneLength(String countryCode) {
    final config = countryPhoneConfig[countryCode];
    return config?['length'] ?? 10;
  }

  String getCountryName(String countryCode) {
    final config = countryPhoneConfig[countryCode];
    return config?['name'] ?? 'This country';
  }

  String? validatePhoneNumber(String phoneNumber, String countryCode) {
    if (phoneNumber.trim().isEmpty) {
      return 'Please enter receiver mobile number';
    }
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.isEmpty) {
      return 'Please enter a valid mobile number';
    }
    final expectedLength = getExpectedPhoneLength(countryCode);
    final countryName = getCountryName(countryCode);

    if (cleanNumber.length < expectedLength) {
      return '$countryName requires $expectedLength digits. You entered ${cleanNumber.length}';
    }
    if (cleanNumber.length > expectedLength) {
      return '$countryName allows only $expectedLength digits.';
    }
    return null;
  }

  Future<bool> updateAddress(BuildContext context) async {
    if (kDebugMode) {
      print("Address ID : $_addressId");
    }
    if (_addressId == null) {
      Get.showToast("Address ID not found", type: ToastType.error);
      // _showSnackBar(context, "Address ID not found", Colors.red);
      return false;
    }

    // Validation
    if (streetController.text.trim().isEmpty) {
      Get.showToast("Please enter street address", type: ToastType.error);
      // _showSnackBar(context, "Please enter street address", Colors.red);
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      Get.showToast("Please enter city", type: ToastType.error);
      // _showSnackBar(context, "Please enter city", Colors.red);
      return false;
    }
    if (zipController.text.trim().isEmpty) {
      Get.showToast("Please enter ZIP code", type: ToastType.error);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = {
        "address_type": _getTypeString(selectedType),
        "street_address": streetController.text.trim(),
        "apartment": apartmentController.text.trim(),
        "city": cityController.text.trim(),
        "zip_code": zipController.text.trim(),
        "latitude": _lat,
        "longitude": _lng,
        "country": countryController.text.trim(),
        "is_default": _isDefaultAddress ? true : false,
        "extra_name": receiverNameController.text.trim(),
        "mobile": receiverMobileController.text.trim(),
        "country_code": _receiverCountry?.phoneCode,
      };

      final response = await _repository.editUserAddressApi(_addressId!, data);

      _isLoading = false;
      notifyListeners();

      if (response.status == true) {
        Get.showToast(
          " ${response.message ?? "Address updated Sucessfully"}",
          type: ToastType.success,
        );
        return true;
      } else {
        Get.showToast(
          " ${response.message ?? "Failed to update address"}",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print("Error updating address: $e");
      }
      _showSnackBar(context, "Failed to update address", Colors.red);
      return false;
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    }
  }

  static const Map<String, Map<String, dynamic>> countryPhoneConfig = {
    '1': {'length': 10, 'name': 'USA'}, // USA, Canada
    '7': {'length': 10, 'name': 'Russia'}, // Russia
    '20': {'length': 10, 'name': 'Egypt'}, // Egypt
    '27': {'length': 9, 'name': 'South Africa'}, // South Africa
    '30': {'length': 10, 'name': 'Greece'}, // Greece
    '31': {'length': 9, 'name': 'Netherlands'}, // Netherlands
    '32': {'length': 9, 'name': 'Belgium'}, // Belgium
    '33': {'length': 9, 'name': 'France'}, // France
    '34': {'length': 9, 'name': 'Spain'}, // Spain
    '36': {'length': 9, 'name': 'Hungary'}, // Hungary
    '39': {'length': 10, 'name': 'Italy'}, // Italy
    '40': {'length': 10, 'name': 'Romania'}, // Romania
    '41': {'length': 9, 'name': 'Switzerland'}, // Switzerland
    '43': {'length': 10, 'name': 'Austria'}, // Austria
    '44': {'length': 10, 'name': 'UK'}, // United Kingdom
    '45': {'length': 8, 'name': 'Denmark'}, // Denmark
    '46': {'length': 9, 'name': 'Sweden'}, // Sweden
    '47': {'length': 8, 'name': 'Norway'}, // Norway
    '48': {'length': 9, 'name': 'Poland'}, // Poland
    '49': {'length': 10, 'name': 'Germany'}, // Germany
    '51': {'length': 9, 'name': 'Peru'}, // Peru
    '52': {'length': 10, 'name': 'Mexico'}, // Mexico
    '53': {'length': 8, 'name': 'Cuba'}, // Cuba
    '54': {'length': 10, 'name': 'Argentina'}, // Argentina
    '55': {'length': 11, 'name': 'Brazil'}, // Brazil
    '56': {'length': 9, 'name': 'Chile'}, // Chile
    '57': {'length': 10, 'name': 'Colombia'}, // Colombia
    '58': {'length': 10, 'name': 'Venezuela'}, // Venezuela
    '60': {'length': 9, 'name': 'Malaysia'}, // Malaysia (9-10)
    '61': {'length': 9, 'name': 'Australia'}, // Australia
    '62': {'length': 10, 'name': 'Indonesia'}, // Indonesia (9-12)
    '63': {'length': 10, 'name': 'Philippines'}, // Philippines
    '64': {'length': 9, 'name': 'New Zealand'}, // New Zealand
    '65': {'length': 8, 'name': 'Singapore'}, // Singapore
    '66': {'length': 9, 'name': 'Thailand'}, // Thailand
    '81': {'length': 10, 'name': 'Japan'}, // Japan
    '82': {'length': 10, 'name': 'South Korea'}, // South Korea
    '84': {'length': 9, 'name': 'Vietnam'}, // Vietnam
    '86': {'length': 11, 'name': 'China'}, // China
    '90': {'length': 10, 'name': 'Turkey'}, // Turkey
    '91': {'length': 10, 'name': 'India'}, // India
    '92': {'length': 10, 'name': 'Pakistan'}, // Pakistan
    '93': {'length': 9, 'name': 'Afghanistan'}, // Afghanistan
    '94': {'length': 9, 'name': 'Sri Lanka'}, // Sri Lanka
    '95': {'length': 9, 'name': 'Myanmar'}, // Myanmar
    '98': {'length': 10, 'name': 'Iran'}, // Iran
    '212': {'length': 9, 'name': 'Morocco'}, // Morocco
    '213': {'length': 9, 'name': 'Algeria'}, // Algeria
    '216': {'length': 8, 'name': 'Tunisia'}, // Tunisia
    '218': {'length': 10, 'name': 'Libya'}, // Libya
    '220': {'length': 7, 'name': 'Gambia'}, // Gambia
    '221': {'length': 9, 'name': 'Senegal'}, // Senegal
    '222': {'length': 8, 'name': 'Mauritania'}, // Mauritania
    '223': {'length': 8, 'name': 'Mali'}, // Mali
    '224': {'length': 9, 'name': 'Guinea'}, // Guinea
    '225': {'length': 10, 'name': 'Ivory Coast'}, // Ivory Coast
    '226': {'length': 8, 'name': 'Burkina Faso'}, // Burkina Faso
    '227': {'length': 8, 'name': 'Niger'}, // Niger
    '228': {'length': 8, 'name': 'Togo'}, // Togo
    '229': {'length': 8, 'name': 'Benin'}, // Benin
    '230': {'length': 8, 'name': 'Mauritius'}, // Mauritius
    '231': {'length': 9, 'name': 'Liberia'}, // Liberia
    '232': {'length': 8, 'name': 'Sierra Leone'}, // Sierra Leone
    '233': {'length': 9, 'name': 'Ghana'}, // Ghana
    '234': {'length': 10, 'name': 'Nigeria'}, // Nigeria
    '235': {'length': 8, 'name': 'Chad'}, // Chad
    '236': {
      'length': 8,
      'name': 'Central African Republic',
    }, // Central African Republic
    '237': {'length': 9, 'name': 'Cameroon'}, // Cameroon
    '238': {'length': 7, 'name': 'Cape Verde'}, // Cape Verde
    '239': {
      'length': 7,
      'name': 'Sao Tome and Principe',
    }, // Sao Tome and Principe
    '240': {'length': 9, 'name': 'Equatorial Guinea'}, // Equatorial Guinea
    '241': {'length': 7, 'name': 'Gabon'}, // Gabon
    '242': {'length': 9, 'name': 'Congo'}, // Congo
    '243': {'length': 9, 'name': 'DR Congo'}, // DR Congo
    '244': {'length': 9, 'name': 'Angola'}, // Angola
    '245': {'length': 9, 'name': 'Guinea-Bissau'}, // Guinea-Bissau
    '246': {
      'length': 7,
      'name': 'British Indian Ocean Territory',
    }, // British Indian Ocean Territory
    '247': {'length': 4, 'name': 'Ascension Island'}, // Ascension Island
    '248': {'length': 7, 'name': 'Seychelles'}, // Seychelles
    '249': {'length': 9, 'name': 'Sudan'}, // Sudan
    '250': {'length': 9, 'name': 'Rwanda'}, // Rwanda
    '251': {'length': 9, 'name': 'Ethiopia'}, // Ethiopia
    '252': {'length': 8, 'name': 'Somalia'}, // Somalia
    '253': {'length': 8, 'name': 'Djibouti'}, // Djibouti
    '254': {'length': 10, 'name': 'Kenya'}, // Kenya
    '255': {'length': 9, 'name': 'Tanzania'}, // Tanzania
    '256': {'length': 9, 'name': 'Uganda'}, // Uganda
    '257': {'length': 8, 'name': 'Burundi'}, // Burundi
    '258': {'length': 9, 'name': 'Mozambique'}, // Mozambique
    '260': {'length': 9, 'name': 'Zambia'}, // Zambia
    '261': {'length': 9, 'name': 'Madagascar'}, // Madagascar
    '262': {'length': 10, 'name': 'Reunion'}, // Reunion
    '263': {'length': 9, 'name': 'Zimbabwe'}, // Zimbabwe
    '264': {'length': 9, 'name': 'Namibia'}, // Namibia
    '265': {'length': 9, 'name': 'Malawi'}, // Malawi
    '266': {'length': 8, 'name': 'Lesotho'}, // Lesotho
    '267': {'length': 8, 'name': 'Botswana'}, // Botswana
    '268': {'length': 8, 'name': 'Swaziland'}, // Swaziland
    '269': {'length': 7, 'name': 'Comoros'}, // Comoros
    '290': {'length': 4, 'name': 'Saint Helena'}, // Saint Helena
    '291': {'length': 7, 'name': 'Eritrea'}, // Eritrea
    '297': {'length': 7, 'name': 'Aruba'}, // Aruba
    '298': {'length': 6, 'name': 'Faroe Islands'}, // Faroe Islands
    '299': {'length': 6, 'name': 'Greenland'}, // Greenland
    '350': {'length': 8, 'name': 'Gibraltar'}, // Gibraltar
    '351': {'length': 9, 'name': 'Portugal'}, // Portugal
    '352': {'length': 9, 'name': 'Luxembourg'}, // Luxembourg
    '353': {'length': 9, 'name': 'Ireland'}, // Ireland
    '354': {'length': 7, 'name': 'Iceland'}, // Iceland
    '355': {'length': 9, 'name': 'Albania'}, // Albania
    '356': {'length': 8, 'name': 'Malta'}, // Malta
    '357': {'length': 8, 'name': 'Cyprus'}, // Cyprus
    '358': {'length': 9, 'name': 'Finland'}, // Finland
    '359': {'length': 9, 'name': 'Bulgaria'}, // Bulgaria
    '370': {'length': 8, 'name': 'Lithuania'}, // Lithuania
    '371': {'length': 8, 'name': 'Latvia'}, // Latvia
    '372': {'length': 8, 'name': 'Estonia'}, // Estonia
    '373': {'length': 8, 'name': 'Moldova'}, // Moldova
    '374': {'length': 8, 'name': 'Armenia'}, // Armenia
    '375': {'length': 9, 'name': 'Belarus'}, // Belarus
    '376': {'length': 6, 'name': 'Andorra'}, // Andorra
    '377': {'length': 8, 'name': 'Monaco'}, // Monaco
    '378': {'length': 10, 'name': 'San Marino'}, // San Marino
    '380': {'length': 9, 'name': 'Ukraine'}, // Ukraine
    '381': {'length': 9, 'name': 'Serbia'}, // Serbia
    '382': {'length': 8, 'name': 'Montenegro'}, // Montenegro
    '383': {'length': 8, 'name': 'Kosovo'}, // Kosovo
    '385': {'length': 9, 'name': 'Croatia'}, // Croatia
    '386': {'length': 8, 'name': 'Slovenia'}, // Slovenia
    '387': {
      'length': 8,
      'name': 'Bosnia and Herzegovina',
    }, // Bosnia and Herzegovina
    '389': {'length': 8, 'name': 'Macedonia'}, // Macedonia
    '420': {'length': 9, 'name': 'Czech Republic'}, // Czech Republic
    '421': {'length': 9, 'name': 'Slovakia'}, // Slovakia
    '423': {'length': 7, 'name': 'Liechtenstein'}, // Liechtenstein
    '500': {'length': 5, 'name': 'Falkland Islands'}, // Falkland Islands
    '501': {'length': 7, 'name': 'Belize'}, // Belize
    '502': {'length': 8, 'name': 'Guatemala'}, // Guatemala
    '503': {'length': 8, 'name': 'El Salvador'}, // El Salvador
    '504': {'length': 8, 'name': 'Honduras'}, // Honduras
    '505': {'length': 8, 'name': 'Nicaragua'}, // Nicaragua
    '506': {'length': 8, 'name': 'Costa Rica'}, // Costa Rica
    '507': {'length': 8, 'name': 'Panama'}, // Panama
    '508': {
      'length': 6,
      'name': 'Saint Pierre and Miquelon',
    }, // Saint Pierre and Miquelon
    '509': {'length': 8, 'name': 'Haiti'}, // Haiti
    '590': {'length': 9, 'name': 'Guadeloupe'}, // Guadeloupe
    '591': {'length': 8, 'name': 'Bolivia'}, // Bolivia
    '592': {'length': 7, 'name': 'Guyana'}, // Guyana
    '593': {'length': 9, 'name': 'Ecuador'}, // Ecuador
    '594': {'length': 9, 'name': 'French Guiana'}, // French Guiana
    '595': {'length': 9, 'name': 'Paraguay'}, // Paraguay
    '596': {'length': 9, 'name': 'Martinique'}, // Martinique
    '597': {'length': 7, 'name': 'Suriname'}, // Suriname
    '598': {'length': 8, 'name': 'Uruguay'}, // Uruguay
    '599': {
      'length': 7,
      'name': 'Netherlands Antilles',
    }, // Netherlands Antilles
    '670': {'length': 8, 'name': 'East Timor'}, // East Timor
    '672': {'length': 6, 'name': 'Antarctica'}, // Antarctica
    '673': {'length': 7, 'name': 'Brunei'}, // Brunei
    '674': {'length': 7, 'name': 'Nauru'}, // Nauru
    '675': {'length': 8, 'name': 'Papua New Guinea'}, // Papua New Guinea
    '676': {'length': 5, 'name': 'Tonga'}, // Tonga
    '677': {'length': 7, 'name': 'Solomon Islands'}, // Solomon Islands
    '678': {'length': 7, 'name': 'Vanuatu'}, // Vanuatu
    '679': {'length': 7, 'name': 'Fiji'}, // Fiji
    '680': {'length': 7, 'name': 'Palau'}, // Palau
    '681': {'length': 6, 'name': 'Wallis and Futuna'}, // Wallis and Futuna
    '682': {'length': 5, 'name': 'Cook Islands'}, // Cook Islands
    '683': {'length': 4, 'name': 'Niue'}, // Niue
    '685': {'length': 7, 'name': 'Samoa'}, // Samoa
    '686': {'length': 5, 'name': 'Kiribati'}, // Kiribati
    '687': {'length': 6, 'name': 'New Caledonia'}, // New Caledonia
    '688': {'length': 6, 'name': 'Tuvalu'}, // Tuvalu
    '689': {'length': 8, 'name': 'French Polynesia'}, // French Polynesia
    '690': {'length': 4, 'name': 'Tokelau'}, // Tokelau
    '691': {'length': 7, 'name': 'Micronesia'}, // Micronesia
    '692': {'length': 7, 'name': 'Marshall Islands'}, // Marshall Islands
    '850': {'length': 10, 'name': 'North Korea'}, // North Korea
    '852': {'length': 8, 'name': 'Hong Kong'}, // Hong Kong
    '853': {'length': 8, 'name': 'Macau'}, // Macau
    '855': {'length': 9, 'name': 'Cambodia'}, // Cambodia
    '856': {'length': 10, 'name': 'Laos'}, // Laos
    '880': {'length': 10, 'name': 'Bangladesh'}, // Bangladesh
    '886': {'length': 9, 'name': 'Taiwan'}, // Taiwan
    '960': {'length': 7, 'name': 'Maldives'}, // Maldives
    '961': {'length': 8, 'name': 'Lebanon'}, // Lebanon
    '962': {'length': 9, 'name': 'Jordan'}, // Jordan
    '963': {'length': 9, 'name': 'Syria'}, // Syria
    '964': {'length': 10, 'name': 'Iraq'}, // Iraq
    '965': {'length': 8, 'name': 'Kuwait'}, // Kuwait
    '966': {'length': 9, 'name': 'Saudi Arabia'}, // Saudi Arabia
    '967': {'length': 9, 'name': 'Yemen'}, // Yemen
    '968': {'length': 8, 'name': 'Oman'}, // Oman
    '970': {'length': 9, 'name': 'Palestine'}, // Palestine
    '971': {'length': 9, 'name': 'UAE'}, // UAE
    '972': {'length': 9, 'name': 'Israel'}, // Israel
    '973': {'length': 8, 'name': 'Bahrain'}, // Bahrain
    '974': {'length': 8, 'name': 'Qatar'}, // Qatar
    '975': {'length': 8, 'name': 'Bhutan'}, // Bhutan
    '976': {'length': 8, 'name': 'Mongolia'}, // Mongolia
    '977': {'length': 10, 'name': 'Nepal'}, // Nepal
    '992': {'length': 9, 'name': 'Tajikistan'}, // Tajikistan
    '993': {'length': 8, 'name': 'Turkmenistan'}, // Turkmenistan
    '994': {'length': 9, 'name': 'Azerbaijan'}, // Azerbaijan
    '995': {'length': 9, 'name': 'Georgia'}, // Georgia
    '996': {'length': 9, 'name': 'Kyrgyzstan'}, // Kyrgyzstan
    '998': {'length': 9, 'name': 'Uzbekistan'}, // Uzbekistan
  };

  void reset() {
    _initialized = false;
    _addressId = null;
    _isLoading = false;
    selectedLatLng = null;
    markers.clear();
    _isInitialMapMove = true;
    streetController.clear();
    apartmentController.clear();
    cityController.clear();
    zipController.clear();
    receiverNameController.clear();
    receiverMobileController.clear();
    _receiverCountry = Country.parse('IN');
  }
}
