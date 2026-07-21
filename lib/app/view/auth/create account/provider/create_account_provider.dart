import 'package:firebase_auth/firebase_auth.dart';
import 'package:ozi/app/core/device%20info/datainfoservices.dart';
import 'package:ozi/app/core/device%20info/get_device_Info.dart';
import 'package:ozi/app/core/push%20notification/push_notification.dart';
import 'package:ozi/app/data/Exception/app_exceptions.dart';
import 'package:ozi/app/shared/widgets/auth_guard.dart';
import 'package:ozi/app/view/auth/verification_screen/model/verify_otp.dart';

import '../../../../core/appExports/app_export.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../data/network/network_api_services.dart';
import '../../../../data/storage/user_preference.dart';
import '../../../../modules/auth/vendor/signup/view/service_category.dart';
import '../../../../modules/user/navigation tab/view/navigation_tab_screen.dart';
import '../../../../data/repository/repository.dart';

class CreateAccountProvider with ChangeNotifier {
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

  int getExpectedPhoneLength(String countryCode) {
    final config = countryPhoneConfig[countryCode];
    return config?['length'] ?? 10;
  }

  // Get country name for a country code
  String getCountryName(String countryCode) {
    final config = countryPhoneConfig[countryCode];
    return config?['name'] ?? 'Unknown';
  }

  // Validate phone number based on country code
  String? validatePhoneNumber(String phoneNumber, String countryCode) {
    if (phoneNumber.trim().isEmpty) {
      return 'Please enter phone number';
    }

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.isEmpty) {
      return 'Please enter a valid phone number';
    }

    if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) {
      return 'Phone number should contain only digits';
    }

    final expectedLength = getExpectedPhoneLength(countryCode);
    final countryName = getCountryName(countryCode);

    if (cleanNumber.length < expectedLength) {
      return '$countryName requires $expectedLength digits. You entered ${cleanNumber.length}';
    }

    if (cleanNumber.length > expectedLength) {
      return '$countryName allows only $expectedLength digits. You entered ${cleanNumber.length}';
    }

    return null;
  }

  final NetworkApiServices _apiService = NetworkApiServices();

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  CreateAccountProvider() {
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    final bool? savedIsEmailVerified =
        await UserPreference.returnIsEmailVerified();
    final String? savedVerifiedEmail =
        await UserPreference.returnVerifiedEmail();

    final bool? savedIsMobileVerified =
        await UserPreference.returnIsMobileVerified();
    final String? savedMobile = await UserPreference.returnMobile();
    final String? savedCountryCode =
        await UserPreference.returnVerifiedCountryCode();

    if (savedIsEmailVerified == true &&
        savedVerifiedEmail != null &&
        savedVerifiedEmail.isNotEmpty) {
      if (emailController.text.isEmpty ||
          emailController.text == savedVerifiedEmail) {
        emailController.text = savedVerifiedEmail;
        _isEmailValid = true;
        _isEmailVerified = true;
        _verifiedEmail = savedVerifiedEmail;
      }
    }

    if (savedIsMobileVerified == true &&
        savedMobile != null &&
        savedMobile.isNotEmpty &&
        savedCountryCode != null) {
      if (mobileController.text.isEmpty ||
          mobileController.text == savedMobile) {
        mobileController.text = savedMobile;
        _isMobileVerified = true;
        _verifiedMobile = savedMobile;
        _verifiedCountryCode = savedCountryCode;
      }
    }
    notifyListeners();
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  final Repository _repository = Repository();

  bool _isEmailValid = false;
  bool get isEmailValid => _isEmailValid;

  bool _isEmailVerified = false;
  bool get isEmailVerified => _isEmailVerified;

  String? _verifiedEmail;

  bool _isloading = false;
  bool get isloading => _isloading;

  bool _isMobileVerified = false;
  bool get isMobileVerified => _isMobileVerified;

  String? _mobileError;
  String? get mobileError => _mobileError;

  String? _verifiedMobile;
  String? _verifiedCountryCode;

  void setMobileError(String? error) {
    _mobileError = error;
    notifyListeners();
  }

  String _verificationId = '';
  String get verificationId => _verificationId;

  Country _selectedCountry = Country.parse('IN');
  Country get selectedCountry => _selectedCountry;

  void updateCountry(Country country) {
    _selectedCountry = country;
    _checkMobileVerification();
    notifyListeners();
  }

  void _checkMobileVerification() {
    final currentMobile = mobileController.text.trim();
    final currentCountry = _selectedCountry.phoneCode;

    if (_verifiedMobile != null &&
        _verifiedCountryCode != null &&
        currentMobile == _verifiedMobile &&
        currentCountry == _verifiedCountryCode) {
      _isMobileVerified = true;
    } else {
      _isMobileVerified = false;
    }
  }

  void resetMobileVerification() {
    _isMobileVerified = false;
    _verifiedMobile = null;
    _verifiedCountryCode = null;
    UserPreference.saveIsMobileVerified(false);
    notifyListeners();
  }

  updateISLoading(bool value) {
    _isloading = value;
    notifyListeners();
  }

  bool _otpLoading = false;
  bool get otpLoading => _otpLoading;

  updateOtpLoading(bool value) {
    _otpLoading = value;
    notifyListeners();
  }

  void validateEmail(String val) {
    _isEmailValid = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(val.trim());

    // If the current email matches the previously verified email, mark as verified
    if (_verifiedEmail != null && val.trim() == _verifiedEmail) {
      _isEmailVerified = true;
    } else {
      _isEmailVerified = false; // Reset verification on change
    }

    notifyListeners();
  }

  /// Mark email as verified when coming from Google sign-in (no OTP needed)
  void setEmailVerifiedFromGoogle() {
    _isEmailValid = true;
    _isEmailVerified = true;
    _verifiedEmail = emailController.text.trim();
  }

  void setMobileData({required String mobile, required bool isVerified}) {
    mobileController.text = mobile;
    _isMobileVerified = isVerified;
    if (isVerified) {
      _verifiedMobile = mobile;
      _verifiedCountryCode = _selectedCountry.phoneCode;
    }
    notifyListeners();
  }

  Future<void> saveLogin(String? role, String? token) async {
    if (role == null || token == null) {
      return;
    }
    await UserPreference.isLoggedIn(true);
    await UserPreference.saveAccessToken(token);
    await UserPreference.saveRole(role);
  }

  Future<VerifyOtp> verificationUser(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postApiWithoutToken(
        data,
        AppUrls.verificationFirebase,
      );
      return VerifyOtp.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Checks if the mobile number already exists on the server.
  /// Returns `true`  → number is NOT taken (safe to send OTP).
  /// Returns `false` → number IS taken (mobileError is set on the field).
  Future<bool> checkMobileExists() async {
    try {
      updateISLoading(true);
      final mobile = mobileController.text.trim();
      final countryCode = "+${selectedCountry.phoneCode}";

      final response = await _repository.checkMobileExistsApi(
        mobile,
        countryCode,
      );

      updateISLoading(false);

      // status == true  → mobile is available → clear error and return true
      if (response['status'] == true) {
        setMobileError(null);
        return true; // Safe to open popup
      } else {
        // status == false  → mobile already registered → show the server's error message
        // Get.showToast(response['message'], type: ToastType.error);
        setMobileError(
          response['message'] ??
              'This mobile number is already registered. Please use a different number.',
        );
        return false; // Do NOT open popup
      }
    } catch (e) {
      updateISLoading(false);
      setMobileError('${e.toString()}');
      return false;
    }
  }

  Future<String> sendMobileOtp(String phone) async {
    print("Phone number : $phone");
    final Completer<String> completer = Completer();
    updateISLoading(true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("Credentials value :${credential.verificationId}");
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _isMobileVerified = true;
          notifyListeners();
          if (!completer.isCompleted) {
            completer.complete(credential.verificationId ?? "");
          }
        } catch (e) {
          debugPrint("Auto-verification failed: $e");
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        updateISLoading(false);
        if (!completer.isCompleted) {
          completer.complete("");
        }

        String msg = "Phone verification failed.";

        if (e.code == 'invalid-phone-number') {
          msg = "The phone number format is invalid.";
        } else if (e.code == 'too-many-requests') {
          msg = "Too many requests. Please try again later.";
        } else if (e.message != null) {
          msg = e.message!;
        }

        Get.showToast(msg, type: ToastType.error);
      },
      codeSent: (String verId, int? resendToken) {
        updateISLoading(false);
        _verificationId = verId;
        if (!completer.isCompleted) {
          completer.complete(verId);
        }
      },
      codeAutoRetrievalTimeout: (String verId) {
        _verificationId = verId;
        if (!completer.isCompleted) {
          completer.complete(verId);
        }
      },
    );

    return completer.future;
  }

  Future<String?> verifyMobileOtp(String otp) async {
    try {
      _otpLoading = true;
      notifyListeners();

      debugPrint("Verifying OTP: $otp for verificationId: $_verificationId");

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      // Just validate the OTP by signing in temporarily, then sign back out
      final authResult = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (authResult.user == null) {
        throw Exception("OTP validation failed");
      }

      // Sign out immediately — we only needed to verify the OTP
      await FirebaseAuth.instance.signOut();

      _isMobileVerified = true;
      _verifiedMobile = mobileController.text.trim();
      _verifiedCountryCode = _selectedCountry.phoneCode;

      // Persist mobile verification
      await UserPreference.saveIsMobileVerified(true);
      await UserPreference.saveMobile(_verifiedMobile!);
      await UserPreference.saveVerifiedCountryCode(_verifiedCountryCode!);

      _otpLoading = false;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      _otpLoading = false;
      notifyListeners();
      debugPrint(
        "FirebaseAuthException in verifyMobileOtp: ${e.code} - ${e.message}",
      );

      if (e.code == 'invalid-verification-code') {
        return "The OTP entered is incorrect. Please try again.";
      } else if (e.code == 'session-expired') {
        return "The verification session has expired. Please resend the OTP.";
      } else if (e.code == 'too-many-requests') {
        return "Too many attempts. Please try again later.";
      } else if (e.code == 'invalid-verification-id') {
        return "Verification ID has expired. Please resend the OTP.";
      }

      return e.message ?? "Verification failed. Please try again.";
    } catch (e) {
      _otpLoading = false;
      notifyListeners();
      debugPrint("General error in verifyMobileOtp: $e");
      return "Something went wrong. Please try again.";
    }
  }

  Future<dynamic> emailSendApi(Map<String, dynamic> data) async {
    try {
      updateISLoading(true);
      final response = await _repository.emailSendApi(data);
      updateISLoading(false);
      return response;
    } catch (e) {
      updateISLoading(false);
      rethrow;
    }
  }

  Future<dynamic> verifyEmailApi(Map<String, dynamic> data) async {
    try {
      _otpLoading = true;
      notifyListeners();
      final response = await _repository.verifyEmailApi(data);
      _otpLoading = false;
      if (response['status'] == true ||
          response['status'] == 200 ||
          response['message']?.toString().toLowerCase().contains('success') ==
              true) {
        _isEmailVerified = true;
        _verifiedEmail = data['email']?.toString().trim();
        if (_verifiedEmail != null) {
          await UserPreference.saveVerifiedEmail(_verifiedEmail!);
          await UserPreference.saveIsEmailVerified(true);
          await UserPreference.saveEmail(_verifiedEmail!);
        }
      }
      notifyListeners();
      // Navigator.pop(navigatorKey.currentContext!);
      return response;
    } catch (e) {
      _otpLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool _loading = false;
  bool get loading => _loading;

  updateLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void updateUI() {
    _checkMobileVerification();
    notifyListeners();
  }

  Future<void> createAccount(String userId, BuildContext context) async {
    final deviceInfo = await getDeviceInfo();
    // Validate form before API call
    if (!formKey.currentState!.validate()) {
      return;
    }

    updateLoading(true);
    String finalDeviceId = await DeviceIdService.getFinalUniqueId();
    try {
      final response = await _apiService.postApiWithoutToken({
        "user_id": userId,
        "first_name": firstNameController.text.trim(),
        "country_code": "+${selectedCountry.phoneCode}",
        "last_name": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "mobile": mobileController.text.trim(),
        "fcm_token": await PushNotificationService.getToken() ?? "",
        "device_name": deviceInfo["device_name"] ?? "",
        "device_type": deviceInfo["device_type"] ?? "",
        "device_id": finalDeviceId,
      }, AppUrls.completeRegistration);
      updateLoading(false);
      if (kDebugMode) {
        print(response);
      }
      loginWithSaveTokenRedirection(
        response['data']['user_role']?.toString(),
        response['data']['api_token']?.toString(),
        userId,
      );
    } catch (e) {
      Get.showToast(e.toString(), type: ToastType.warning);
      updateLoading(false);
    }
  }

  Future<void> loginWithSaveTokenRedirection(
    String? role,
    String? token,
    String userId,
  ) async {
    if (role == null || token == null) {
      return;
    }
    await UserPreference.isLoggedIn(true);
    await UserPreference.saveAccessToken(token);
    await UserPreference.saveRole(role);
    await UserPreference.saveUserId(userId);
    await UserPreference.saveStep('1');

    // Clear temporary data after successful registration
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('firstName');
    await pref.remove('lastName');
    await pref.remove('email');
    await pref.remove('verifiedEmail');
    await pref.remove('isEmailVerified');
    await pref.remove('mobile');
    await pref.remove('isMobileVerified');
    if (role == 'user') {
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => NavigationTabScreen()),
      );
    } else if (role == 'vendor') {
      // Navigator.push(
      //   navigatorKey.currentContext!,
      //   MaterialPageRoute(
      //     builder: (_) =>   VendorNavigationTabScreen(),
      //   ),
      // );
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => ServiceCategory()),
      );
    }

    // if (role == 'user') {
    //   Navigator.push(
    //     navigatorKey.currentContext!,
    //     MaterialPageRoute(
    //       builder: (_) => NavigationTabScreen(),
    //     ),
    //   );
    // } else if (role == 'vendor') {
    //   Navigator.push(
    //     navigatorKey.currentContext!,
    //     MaterialPageRoute(
    //       builder: (_) => VendorNavigationTabScreen(),
    //     ),
    //   );
    // }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}
