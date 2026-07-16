import 'package:ozi/app/modules/user/home/model/category_model.dart';
import 'package:ozi/app/modules/user/navigation%20tab/view/navigation_tab_screen.dart';
import 'package:ozi/app/modules/user/singleService/screen/singleservicescreen.dart';
import 'package:ozi/app/shared/widgets/cutom_nodata_widget.dart';
import '../../../../../core/appExports/app_export.dart';
import '../../../../../core/constants/app_urls.dart';
import '../../../../../shared/widgets/auth_guard.dart';
import '../../../../../shared/widgets/custom_app_bar.dart';
import 'package:ozi/app/modules/user/profile/save address/provider/saved_address_provider.dart';
import '../provider/ServiceDetailProvider.dart';
import '../model/ServiceDetailsModel.dart';
import 'vendordetailscreen.dart';
import '../../../../../shared/widgets/read_more_text.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Subcategories service;
  final int categoryId;

  const ServiceDetailScreen({
    super.key,
    required this.service,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedAddressProvider>(
      builder: (context, addressProvider, child) {
        String? latStr;
        String? lngStr;

        final selectedAddr = addressProvider.selectedAddress;
        if (selectedAddr != null &&
            selectedAddr.latitude != null &&
            selectedAddr.longitude != null) {
          latStr = selectedAddr.latitude;
          lngStr = selectedAddr.longitude;
        } else if (addressProvider.currentLat != null &&
            addressProvider.currentLng != null) {
          latStr = addressProvider.currentLat.toString();
          lngStr = addressProvider.currentLng.toString();
        }

        return ChangeNotifierProvider(
          create: (_) => ServiceDetailProvider(
            service,
            categoryId,
            latitude: latStr,
            longitude: lngStr,
          ),
          child: ServiceDetailView(service: service, categoryId: categoryId),
        );
      },
    );
  }
}

class ServiceDetailView extends StatelessWidget {
  final Subcategories service;
  final int categoryId;
  const ServiceDetailView({
    super.key,
    required this.service,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceDetailProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: CustomAppBar(
                title: service.categoryName ?? 'Service Details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildBody(context, provider),
              ),
            ),
            if (!provider.isLoading && provider.cartItemCount > 0) ...[
              Divider(color: AppColors.dividerColor),
              _buildBottomBar(context, provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext parentContext,
    ServiceDetailProvider provider,
  ) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey),
              hBox(16),
              Text(
                provider.errorMessage!,
                style: AppFontStyle.text_16_400(Colors.grey),
                textAlign: TextAlign.center,
              ),
              hBox(16),
              CustomButton(
                onPressed: provider.refresh,
                text: 'Retry',
                width: 120,
                height: 45,
                color: AppColors.primary,
                textStyle: AppFontStyle.text_14_600(
                  Colors.white,
                  fontFamily: AppFontFamily.semiBold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.serviceProviders.isEmpty) {
      return NoDataFoundWidget(
        message:
            "We currently do not have any service providers available in your area.",
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: provider.serviceProviders.length,
        itemBuilder: (context, index) {
          final serviceData = provider.serviceProviders[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: _buildServiceCard(parentContext, serviceData, provider),
          );
        },
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Divider(thickness: 1, color: AppColors.containerBorder),
        ),
      ),
    );
  }

  String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "${AppUrls.imageBaseUrl}$path";
  }

  Widget _buildServiceCard(
    BuildContext context,
    ServiceData serviceData,
    ServiceDetailProvider provider,
  ) {
    final vendorName =
        '${serviceData.vendor?.firstName ?? ""} ${serviceData.vendor?.lastName ?? ""}'
            .trim();
    final serviceType = serviceData.category?.categoryName ?? 'Tailor Services';
    final duration =
        '${serviceData.durationValue ?? 0} ${serviceData.durationType ?? 'Hours'}';
    final price = (serviceData.servicePrice ?? 0).toDouble();
    final int serviceId = serviceData.id ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vendor Header
        InkWell(
          onTap: () async {
            final bool allowed = await AuthGuard.requireLogin(context);

            if (!allowed) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorDetailScreen(
                  vendorId: serviceData.vendorId.toString(),
                  vendorName:
                      "${serviceData.vendor?.firstName ?? ""} ${serviceData.vendor?.lastName ?? ""}",
                  service: service,
                  categoryId: categoryId,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.lightGrey2,
                backgroundImage: serviceData.vendor?.profileImage != null
                    ? CachedNetworkImageProvider(
                        getFullImageUrl(serviceData.vendor?.profileImage),
                      )
                    : null,
                child: serviceData.vendor?.profileImage == null
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              wBox(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendorName.isEmpty ? 'Unknown Tailor' : vendorName,
                      style: AppFontStyle.text_16_600(
                        AppColors.black,
                        fontFamily: AppFontFamily.semiBold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: AppColors.orange),
                        wBox(4),
                        Text(
                          serviceData.ratings.toString(), // Placeholder rating
                          style: AppFontStyle.text_12_600(
                            AppColors.black,
                            fontFamily: AppFontFamily.bold,
                          ),
                        ),
                        wBox(4),
                        Text(
                          '• $serviceType',
                          style: AppFontStyle.text_12_400(AppColors.lightGrey3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildViewButton(context, serviceData),
            ],
          ),
        ),
        hBox(16),
        // Service Details
        InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    singleServiceScreen(serviceId: serviceId, isCart: true),
              ),
            );
            if (result == true) {
              provider.refresh();
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: getFullImageUrl(serviceData.serviceImage),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 100,
                    height: 100,
                    color: AppColors.lightGrey2,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              wBox(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceData.serviceName ?? 'Service',
                      style: AppFontStyle.text_16_600(
                        AppColors.black,
                        fontFamily: AppFontFamily.semiBold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    hBox(4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.lightGrey3,
                        ),
                        wBox(4),
                        Text(
                          duration,
                          style: AppFontStyle.text_12_400(AppColors.lightGrey3),
                        ),
                      ],
                    ),
                    hBox(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: AppFontStyle.text_18_600(
                            AppColors.primary,
                            fontFamily: AppFontFamily.bold,
                          ),
                        ),
                        provider.isInCart(serviceId)
                            ? _buildCounter(serviceId, provider, context)
                            : _buildAddButton(serviceId, provider, context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        hBox(16),
        // Description
        ReadMoreDescription(
          text: serviceData.description ?? '',
          style: AppFontStyle.text_13_400(AppColors.lightGrey3),
          trimLines: 2,
        ),
      ],
    );
  }

  Widget _buildViewButton(BuildContext context, ServiceData serviceData) {
    return InkWell(
      onTap: () async {
        if (serviceData.vendorId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorDetailScreen(
                vendorId: serviceData.vendorId.toString(),
                vendorName:
                    "${serviceData.vendor?.firstName ?? ""} ${serviceData.vendor?.lastName ?? ""}",
                service: service,
                categoryId: categoryId,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'View',
          style: AppFontStyle.text_12_600(
            AppColors.primary,
            fontFamily: AppFontFamily.semiBold,
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              wBox(10),
              Expanded(
                child: Text(
                  "Exception",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.text_18_600(
                    AppColors.black,
                    fontFamily: AppFontFamily.semiBold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message.replaceAll('Exception: ', ''),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.text_14_400(AppColors.darkText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: AppFontStyle.text_14_600(
                  AppColors.grey,
                  fontFamily: AppFontFamily.semiBold,
                ),
              ),
            ),
            CustomButton(
              width: 100,
              height: 35,
              text: "View Cart",
              color: AppColors.primary,
              textStyle: AppFontStyle.text_12_600(
                Colors.white,
                fontFamily: AppFontFamily.semiBold,
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NavigationTabScreen(initialIndex: 1),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddButton(
    final int serviceId,
    final ServiceDetailProvider provider,
    final BuildContext context,
  ) {
    return CustomButton(
      width: 80,
      height: 35,
      borderRadius: BorderRadius.circular(20),
      color: AppColors.primary,
      onPressed: () async {
        final bool allowed = await AuthGuard.requireLogin(context);

        if (!allowed) return;
        try {
          await provider.addToCart(serviceId);
        } catch (e) {
          if (!context.mounted) return;
          _showErrorDialog(context, e.toString());
        }
      },
      text: "Add",
      textStyle: AppFontStyle.text_14_600(
        Colors.white,
        fontFamily: AppFontFamily.bold,
      ),
    );
  }

  Widget _buildCounter(
    final int serviceId,
    final ServiceDetailProvider provider,
    final BuildContext context,
  ) {
    final quantity = provider.getQuantity(serviceId);

    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              try {
                await provider.decrementQuantity(serviceId);
              } catch (e) {
                Get.showToast(
                  "Failed to update quantity",
                  type: ToastType.error,
                );
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text('Failed to update quantity'),
                //     backgroundColor: Colors.red,
                //   ),
                // );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.remove, size: 16, color: AppColors.primary),
            ),
          ),
          wBox(8),
          Text(
            '$quantity',
            style: AppFontStyle.text_14_600(
              AppColors.primary,
              fontFamily: AppFontFamily.bold,
            ),
          ),
          wBox(8),
          GestureDetector(
            onTap: () async {
              try {
                await provider.incrementQuantity(serviceId);
              } catch (e) {
                Get.showToast(
                  "Failed to update quantity",
                  type: ToastType.error,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.add, size: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ServiceDetailProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${provider.subtotal.toStringAsFixed(2)}',
            style: AppFontStyle.text_28_600(
              AppColors.black,
              fontFamily: AppFontFamily.bold,
            ),
          ),
          CustomButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NavigationTabScreen(initialIndex: 1),
                ),
              );
            },
            width: 150,
            height: 50,
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomImage(
                  path: ImageConstants.cart,
                  height: 20,
                  width: 20,
                  color: AppColors.white,
                ),
                wBox(8),
                Text(
                  'View Cart',
                  style: AppFontStyle.text_14_600(
                    Colors.white,
                    fontFamily: AppFontFamily.semiBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
