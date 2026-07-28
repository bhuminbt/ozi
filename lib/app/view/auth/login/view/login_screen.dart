import '../../../../core/appExports/app_export.dart';
import '../../../../modules/user/navigation tab/view/navigation_tab_screen.dart';
import '../../verification_screen/view/verification_screen.dart';
import '../provider/login_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../modules/user/home/provider/HomeScreenProvider.dart';
import '../../../../data/storage/user_preference.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Country? _selectedCountry;
  final TextEditingController _phoneController = TextEditingController();
  int _maxPhoneLength = 10; // Default max length

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('US'); // Set default immediately
    _updateMaxPhoneLength();
  }

  Future<void> _loadInitialCountry() async {
    try {
      // 1. Try to get from device locale first (fast and no permission needed)
      final Locale deviceLocale =
          WidgetsBinding.instance.platformDispatcher.locale;
      final String? deviceCountryCode = deviceLocale.countryCode;

      if (deviceCountryCode != null) {
        try {
          final country = Country.parse(deviceCountryCode);
          setState(() {
            _selectedCountry = country;
            _updateMaxPhoneLength();
          });
        } catch (_) {}
      }

      // 2. Request accurate location from GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();

        // Automatically set consent ONLY if permission was just granted in this session
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          HomeScreenProvider.setSessionConsent('guest', true);
          await UserPreference.saveLocationConsent(true);
        }

        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      // If we have permission, get the actual position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && placemarks.first.isoCountryCode != null) {
        final String? locCountryCode = placemarks.first.isoCountryCode;
        if (locCountryCode != null) {
          try {
            final country = Country.parse(locCountryCode);
            setState(() {
              _selectedCountry = country;
              _updateMaxPhoneLength();
            });
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint("Error detecting country: $e");
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Update max phone length based on selected country
  void _updateMaxPhoneLength() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    setState(() {
      _maxPhoneLength = loginProvider.getExpectedPhoneLength(
        _selectedCountry?.phoneCode ?? '91',
      );
    });
  }

  void _handleContinue() async {
    FocusScope.of(context).unfocus();
    if (kDebugMode) {
      print("Button pressed");
    }
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (loginProvider.isLoading) return;

    loginProvider.clearError();

    // Validate phone number (provider will validate length based on country)
    final phoneNumber = _phoneController.text.trim();
    final countryCode = _selectedCountry?.phoneCode ?? '91';

    final validationError = loginProvider.validatePhoneNumber(
      phoneNumber,
      countryCode,
    );

    if (validationError != null) {
      // _showSnackBar(validationError);
      Get.showToast(validationError, type: ToastType.warning);
      return;
    }

    final success = await loginProvider.handleContinue(
      context,
      phoneNumber,
      countryCode,
    );

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(
            phone: "$phoneNumber",
            countryCode: countryCode,
            verificationId: loginProvider.verificationId,
          ),
        ),
      );
    } else {
      if (!success && mounted) {
        if (kDebugMode) {
          print("object");
        }
        if (loginProvider.restoreCancelled) return;
        Get.showToast(
          loginProvider.errorMessageFirebase ??
              "Failed to send OTP. Please try again.",
          type: ToastType.warning,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, child) {
          final bool showScreenLoader = loginProvider.isLoader ||
              loginProvider.issocialLoader ||
              loginProvider.isLoading;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back!",
                                style: AppFontStyle.text_30_600(
                                  AppColors.darkText,
                                  fontFamily: AppFontFamily.extraBold,
                                ),
                              ),

                              hBox(10),

                              Text(
                                maxLines: 2,
                                "Please enter your mobile number to proceed.",
                                style: AppFontStyle.text_16_400(
                                  AppColors.grey,
                                  fontFamily: AppFontFamily.regular,
                                ),
                              ),

                              hBox(30),

                              Text(
                                "Phone Number",
                                style: AppFontStyle.text_16_600(
                                  AppColors.darkText,
                                  fontFamily: AppFontFamily.semiBold,
                                ),
                              ),

                              hBox(12),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "+1",
                                          style: AppFontStyle.text_16_600(
                                            AppColors.darkText,
                                          ),
                                        ),
                                      ],
                                    ),

                                    wBox(14),

                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        enabled: !loginProvider.isLoading,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly, // Only digits
                                          LengthLimitingTextInputFormatter(
                                            _maxPhoneLength,
                                          ), // Limit length
                                        ],
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText:
                                              "Phone Number ($_maxPhoneLength digits)",
                                          hintStyle: AppFontStyle.text_16_400(
                                            AppColors.grey,
                                          ),
                                          counterText: "", // Hide default counter
                                        ),
                                        style: AppFontStyle.text_16_400(
                                          AppColors.darkText,
                                        ),
                                        onChanged: (value) {
                                          // Optional: Show real-time validation
                                          if (value.length == _maxPhoneLength) {
                                            // Valid length reached
                                            if (kDebugMode) {
                                              print('✅ Valid phone number length');
                                            }
                                          }
                                        },
                                      ),
                                    ),

                                    // Show digit counter
                                    if (_phoneController.text.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                      ),
                                  ],
                                ),
                              ),

                              hBox(8),

                              // Helper text showing expected format
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "Enter exactly 10 digits for United States",
                                  style: AppFontStyle.text_12_400(
                                    AppColors.grey,
                                    fontFamily: AppFontFamily.regular,
                                  ),
                                ),
                              ),

                              hBox(16),

                              CustomButton(
                                text: "Continue",
                                isLoading: loginProvider.isLoading,
                                onPressed: _handleContinue,
                              ),

                              hBox(35),

                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.lightGrey2.withValues(
                                        alpha: 0.5,
                                      ),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      "Or continue with",
                                      style: AppFontStyle.text_14_400(
                                        AppColors.grey,
                                        fontFamily: AppFontFamily.regular,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.lightGrey2.withValues(
                                        alpha: 0.5,
                                      ),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              hBox(35),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _socialButton(
                                    imagePath: "assets/images/Google.png",
                                    onTap: () {
                                      if (kDebugMode) {
                                        print("click on google");
                                      }
                                      loginProvider.signInWithGoogle(context);
                                    },
                                  ),
                                  wBox(20),
                                  _socialButton(
                                    imagePath: "assets/images/gg--facebook 1.png",
                                    isLoading: loginProvider.issocialLoader ||
                                        (loginProvider.isLoader &&
                                            !loginProvider.isLoading),
                                    onTap: () async {
                                      // Handle Facebook login

                                      await loginProvider.socialLoginFacebookApi(
                                        context,
                                      );
                                    },
                                  ),
                                ],
                              ),

                              const Spacer(),
                              CustomButton(
                                text: "Skip",
                                textStyle: AppFontStyle.text_14_600(
                                  AppColors.black,
                                  fontFamily: AppFontFamily.semiBold,
                                ),
                                forGroundColor: AppColors.primary,
                                isLoading: loginProvider.guestLoading,
                                color: AppColors.lightGrey2,
                                isOutlined: true,
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  await loginProvider
                                      .guestLogin(); // Call Guest API first

                                  Navigator.pushReplacement(
                                    navigatorKey.currentContext!,
                                    MaterialPageRoute(
                                      builder: (_) => NavigationTabScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (showScreenLoader)
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _socialButton({
    required String imagePath,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 56.h,
        width: 56.h,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : CustomImage(
                path: imagePath,
                fit: BoxFit.contain,
                height: 20,
                width: 20,
              ),
      ),
    );
  }
}
