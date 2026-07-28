import 'package:ozi/app/data/models/chat_models/conversion_list_model.dart';
import 'package:ozi/app/modules/user/cart/change%20address/view/ChangeAddressScreen.dart';
import 'package:ozi/app/modules/user/cart/change%20address/provider/ChangeAddressProvider.dart';
import 'package:ozi/app/modules/user/profile/save%20address/provider/saved_address_provider.dart';
import 'package:ozi/app/modules/user/profile/save%20address/view/SavedAddressScreen.dart';
import '../../../../core/utils/location_permission_helper.dart';
import 'package:ozi/app/modules/vendor/home/notification/view/vendor_notifications_screen.dart';

import '../../../../core/appExports/app_export.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../../../shared/widgets/custom_image_path_helper.dart';
import '../../../../shared/widgets/custom_shimmer_box.dart';
import '../../../../shared/widgets/custom_text_form_field.dart';
import '../../../../view/message/provider/message_provider.dart';
import '../../../../view/message/screens/message.dart';
import '../../../vendor/home/notification/provider/vendor_ notification_provider.dart';
import '../../profile/view/profile_provider/profile_provider.dart';
import '../model/category_model.dart';
import '../provider/HomeScreenProvider.dart';
import '../../profile/setting/provider/settingprovider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MessageProvider>().getAllConversions(true);
        context.read<AuthGuestProvider>().loadStatus();
        context.read<ProfileProvider>().fetchUserProfile();
        context.read<Settingprovider>().settingsApi();
        context.read<HomeScreenProvider>().loadOnce(context);
        context.read<VendorNotificationProvider>().getNotifications();
        context.read<HomeScreenProvider>().locationSendToBackend(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-trigger loadOnce which has the 30-min logic
      if (mounted) {
        context.read<HomeScreenProvider>().loadOnce(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenView();
  }
}

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeScreenProvider>();
    // final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.refreshData(context: context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  hBox(10),
                  _buildSearchBar(context, provider),
                  hBox(12),
                  _buildSectionTitle(),
                  hBox(8),
                  _buildServiceGrid(context, provider),
                  hBox(10),
                  Consumer<AuthGuestProvider>(
                    builder: (context, auth, child) {
                      if (auth.isGuest) {
                        return _buildBecomeProviderCard(context, provider);
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  hBox(10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeScreenProvider provider) {
    final auth = context.watch<AuthGuestProvider>();
    final profile = context.watch<ProfileProvider>();
    final firstName = profile.firstName;

    final displayName = auth.isGuest
        ? "Guest"
        : (firstName.trim().isNotEmpty ?? false)
        ? firstName
        : "Guest";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Hello ",
                      style: AppFontStyle.text_24_500(AppColors.black),
                    ),
                    TextSpan(
                      text: displayName,
                      style: AppFontStyle.text_24_600(
                        AppColors.black,
                        fontFamily: AppFontFamily.bold,
                      ),
                    ),
                    TextSpan(
                      text: "!",
                      style: AppFontStyle.text_24_600(
                        AppColors.black,
                        fontFamily: AppFontFamily.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              GestureDetector(
                onTap: () async {
                  final bool allowed = await AuthGuard.requireLogin(context);
                  if (!allowed) return;

                  if (await LocationPermissionHelper.handleLocationPermission(
                    context,
                  )) {
                    if (context.mounted) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedAddressScreen(
                            isservice: false,
                            isHome: true,
                          ),
                        ),
                      );
                      if (result != null) {
                        provider.updateFromSelection(
                          result as int,
                          context.read<SavedAddressProvider>(),
                        );
                      }
                      // final result = await Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         const ChangeAddressScreen(isFromHome: true),
                      //   ),
                      // );
                      // if (result != null) {
                      //   provider.updateFromSelection(
                      //     result as int,
                      //     context.read<ChangeAddressProvider>(),
                      //   );
                      // }
                    }
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                    wBox(6),
                    Flexible(
                      child: Text(
                        provider.selectedLocation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.text_12_400(AppColors.grey),
                      ),
                    ),
                    // wBox(4),
                    Icon(
                      Icons.keyboard_arrow_right,
                      size: 20.sp,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Row(
          children: [
            Consumer<MessageProvider>(
              builder: (context, value, child) {
                final count = value.unreadChatCount;

                return GestureDetector(
                  onTap: () async {
                    final bool allowed = await AuthGuard.requireLogin(context);

                    if (!allowed) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MessageScreen()),
                    );
                  },
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/msgimg.png",
                        height: 40,
                        width: 40,
                      ),

                      if (count > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            wBox(12),

            // GestureDetector(
            //   onTap: () async {
            //     final bool allowed = await AuthGuard.requireLogin(context);
            //
            //     if (!allowed) return;
            //
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => const NotificationsScreen(),
            //       ),
            //     );
            //   },
            //   child: Image.asset(
            //     "assets/images/noti.png",
            //     height: 46,
            //     width: 46,
            //   ),
            // ),
            Consumer<VendorNotificationProvider>(
              builder: (context, provider, _) {
                return InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () async {
                    bool allowed = await AuthGuard.requireLogin(context);

                    if (!allowed) return;
                    context
                        .read<VendorNotificationProvider>()
                        .readNotifications();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomImage(
                            path: ImageConstants.bell,
                            height: 20,
                            width: 20,
                            color: AppColors.black,
                          ),
                        ),
                      ),

                      /// Badge
                      if (provider.unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              provider.unreadCount > 99
                                  ? "99+"
                                  : provider.unreadCount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeScreenProvider provider) {
    return CustomTextFormField(
      controller: provider.searchController,
      onChanged: provider.setSearchQuery,
      hintText: "Search...",
      prefix: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CustomImage(path: ImageConstants.search, height: 20, width: 20),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Text(
      'Select What You Need',
      style: AppFontStyle.text_20_600(
        AppColors.black,
        fontFamily: AppFontFamily.bold,
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context, HomeScreenProvider provider) {
    // Show shimmer when loading (including when requesting permission)
    if (provider.isLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 6, // number of shimmer items
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (_, __) => ShimmerBox(
          width: double.infinity,
          height: double.infinity,
          radius: 12,
        ),
      );
    }

    // Check if location is null ( only show this when not loading)
    if (provider.lat == null || provider.lng == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 60,
              color: AppColors.primary,
            ),
            hBox(16),
            Text(
              'Location Required',
              style: AppFontStyle.text_18_600(
                AppColors.black,
                fontFamily: AppFontFamily.bold,
              ),
            ),
            hBox(8),
            Text(
              'You can\'t view services without adding location. Please enable location permission to continue.',
              textAlign: TextAlign.center,
              style: AppFontStyle.text_14_400(AppColors.grey),
            ),
            hBox(20),
            CustomButton(
              onPressed: () => provider.requestLocationPermission(context),
              text: 'Enable Location',
              textStyle: AppFontStyle.text_14_600(
                AppColors.white,
                fontFamily: AppFontFamily.semiBold,
              ),
              width: double.infinity,
              height: 48,
              color: AppColors.primary,
            ),
          ],
        ),
      );
    }

    if (provider.filteredCategories.isEmpty) {
      if (provider.searchQuery.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "No results found for '${provider.searchQuery}'",
              style: AppFontStyle.text_16_500(AppColors.grey),
            ),
          ),
        );
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset(
            "assets/images/Gemini_Generated_Image_okevaaokevaaokev.png",
            height: 400,
            width: 400,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: provider.filteredCategories.length,
      itemBuilder: (context, index) {
        final category = provider.filteredCategories[index];
        return _buildServiceCard(context, category, provider);
      },
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    Data category,
    HomeScreenProvider provider,
  ) {
    return GestureDetector(
      onTap: () => provider.onCategoryTap(category, context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomImage(
                path: ImagePathHelper.getFullImageUrl(
                  category.icon ?? ImageConstants.homeService,
                  AppUrls.imageBaseUrl,
                ),

                fit: BoxFit.cover,
                shimmerChild: ShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 12,
                ),
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Text(
                category.categoryName ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFontStyle.text_15_500(
                  AppColors.white,
                  fontFamily: AppFontFamily.semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBecomeProviderCard(
    BuildContext context,
    HomeScreenProvider provider,
  ) {
    return GestureDetector(
      onTap: () => provider.onBecomeProviderTap(context),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),

            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Become A Service\nProvider',
                        style: AppFontStyle.text_16_700(
                          AppColors.white,
                          fontFamily: AppFontFamily.bold,
                        ),
                      ),
                      hBox(6),
                      _buildBulletPoint('Get everyday \nexclusive orders'),
                      _buildBulletPoint('Earn more Revenue'),
                      _buildBulletPoint(
                        'Get Rated and tips \nfrom your customers',
                      ),
                      hBox(6),
                      CustomButton(
                        onPressed: () async {
                          final bool allowed = await AuthGuard.requireLogin(
                            context,
                          );
                          if (!allowed) return;
                        },
                        //  => provider.onBecomeProviderTap(context),
                        text: 'Apply Now',
                        textStyle: AppFontStyle.text_12_600(
                          AppColors.black,
                          fontFamily: AppFontFamily.semiBold,
                        ),
                        width: 120,
                        height: 40,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Container(
              width: 150,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(ImageConstants.homeService, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 6, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppFontStyle.text_13_400(AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget profileAvatarStatic({required String imageUrl, double size = 95}) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 3),
        ),
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? CustomImage(
                  path: imageUrl,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                )
              : Icon(Icons.person, size: size * 0.5, color: AppColors.grey),
        ),
      ),
    );
  }
}
