import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ozi/app/modules/user/booking/provider/booking_provider.dart';
import 'package:ozi/app/modules/user/cart/change%20address/provider/ChangeAddressProvider.dart';
import 'package:ozi/app/modules/user/profile/add%20new%20address/provider/add_address_provider.dart';
import 'package:ozi/app/modules/user/profile/edit%20address/provider/edit_user_address_provider.dart';
import 'package:ozi/app/modules/user/profile/setting/provider/settingprovider.dart';
import 'package:ozi/app/modules/user/profile/vendor%20reviews/provider/vendor_review_provider.dart';
import 'package:ozi/app/modules/vendor/navigation%20tab/provider/navigation_provider.dart';
import 'package:ozi/app/shared/widgets/auth_guard.dart';
import 'package:ozi/app/view/auth/login/provider/login_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'app/core/appExports/app_export.dart';
import 'app/core/push notification/push_notification.dart';
import 'app/data/network/web_socket_connection_service.dart';
import 'app/modules/auth/vendor/signup/provider/ready_to_go_livescreen_provider.dart';
import 'app/modules/user/home/provider/HomeScreenProvider.dart';
import 'app/modules/user/navigation tab/provider/navigation_provider.dart';
import 'app/modules/user/profile/address map/provider/location_picker_provider.dart';
import 'app/modules/user/profile/login details/provider/login_details_provider.dart';
import 'app/modules/user/profile/save address/provider/saved_address_provider.dart';
import 'app/modules/user/profile/view/profile_provider/profile_provider.dart';
import 'app/modules/vendor/home/new requests/provider/new_requests_provider.dart';
import 'app/modules/vendor/home/notification/provider/vendor_ notification_provider.dart';
import 'app/modules/vendor/home/provider/vendor_home_provider.dart';
import 'app/modules/vendor/services/provider/service_provider.dart';
import 'app/routes/app_routes.dart';
import 'app/view/message/provider/message_provider.dart';
import 'app/view/splash/provider/splash_provider.dart';
import 'app/modules/user/cart/view/cupponprovider.dart';
import 'app/modules/user/cart/view/provider/cart_provider.dart';
import 'app/data/repository/repository.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Core Flutter setup - very fast
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Set orientations - fast
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. Launch the app immediately - this shows the Splash Screen
  runApp(const MyApp());

  // 4. Initialize services in the background without blocking the UI
  _initServicesInBackground();
}

/// Initializes services like Firebase, Stripe, etc. in the background.
/// This runs after the app has already started showing its first frame.
Future<void> _initServicesInBackground() async {
  try {
    // WebView setup
    if (WebViewPlatform.instance == null) {
      if (Platform.isAndroid) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      } else if (Platform.isIOS) {
        WebViewPlatform.instance = WebKitWebViewPlatform();
      }
    }

    // ChuckerFlutter.showOnRelease = true;
    // ChuckerFlutter.isDebugMode = true;

    // Heavy initializations
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      await GoogleSignIn.instance.initialize(
        clientId:
            '102047141140-1shi7k7q400fr90snrpalk9a21foq3fj.apps.googleusercontent.com',
        serverClientId:
            '102047141140-maig6m3qtbl17h9h8d39r14tr1d7qgb4.apps.googleusercontent.com',
      );
      debugPrint('Google Sign-In initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Google Sign-In: $e');
    }

    // Push notifications setup
    await PushNotificationService.firebaseNotification();
    // Stripe.publishableKey =
    //     "pk_test_51T1KB9DSmK2YlVb0zz4kEhEobZjMs9aQKpL9pQJQT79Ja4HsVM9QFW9XPirqeIDOAMsBC3vtFtPlXPDmFaH1tmGy00IQqXiz82";

    // Stripe setup Client's account
    Stripe.publishableKey =
        'pk_test_51TEIe2FM9DdUZjLy6H4W3vT89rhMqXNGdfKSL3KQMpdumCCTgraowHn3Ay0Dobni9rFqbRw1uE0tWKVLDhcqZF2g00QXNRm1ap';
    await Stripe.instance.applySettings();

    debugPrint('Background services initialized successfully');
  } catch (e, stack) {
    debugPrint('Error initializing services in background: $e');
    debugPrint(stack.toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => VendorHomeProvider()),
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => VendorNavigationProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SavedAddressProvider()),
        ChangeNotifierProvider(create: (_) => AddAddressProvider()),
        ChangeNotifierProvider(create: (_) => EditUserAddressProvider()),
        ChangeNotifierProvider(create: (_) => CupponProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => SocketController()),
        ChangeNotifierProvider(create: (_) => VendorServicesProvider()),
        ChangeNotifierProvider(create: (_) => ChangeAddressProvider()),
        ChangeNotifierProvider(create: (_) => LocationPickerProvider()),
        ChangeNotifierProvider(create: (_) => VendorNotificationProvider()),
        ChangeNotifierProvider(create: (_) => VendorReviewProvider()),
        ChangeNotifierProvider(
          create: (_) => ReadyToGoLivescreenProvider()..getDocumentStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthGuestProvider()..loadStatus(),
        ),
        ChangeNotifierProvider(create: (_) => NewRequestsProvider()),
        ChangeNotifierProvider(create: (_) => Settingprovider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),

        ChangeNotifierProvider(
          create: (_) => CartProvider(repository: Repository()),
        ),
        ChangeNotifierProvider(create: (_) => LoginDetailsProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) {
          return SafeArea(
            top: false,
            child: MaterialApp(
              title: 'Ozi Salon Services',
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: AppColors.primary,
                scaffoldBackgroundColor: AppColors.white,
                colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
                useMaterial3: false,
              ),
              initialRoute: AppRoutes.splashScreen,
              // navigatorObservers: [ChuckerFlutter.navigatorObserver],
              onGenerateRoute: AppRoutes.generateRoute,
            ),
          );
        },
      ),
    );
  }
}
