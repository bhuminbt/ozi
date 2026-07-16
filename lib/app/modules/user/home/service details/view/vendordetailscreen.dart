import 'package:ozi/app/modules/user/Reviews%20Section/screens/allreviewsscreen.dart';
import 'package:ozi/app/modules/user/home/model/category_model.dart';
import 'package:ozi/app/modules/user/navigation%20tab/view/navigation_tab_screen.dart';
import 'package:ozi/app/modules/user/singleService/screen/singleservicescreen.dart';
import 'package:ozi/app/shared/widgets/cutom_nodata_widget.dart';
import '../../../../../core/appExports/app_export.dart';
import '../../../../../core/constants/app_urls.dart';
import '../../../../../data/response/api_status.dart';
import '../../../../../shared/widgets/auth_guard.dart';
import '../../../../../shared/widgets/custom_app_bar.dart';
import '../provider/ServiceDetailProvider.dart';
import '../model/vendordetaiulmodel.dart' as vdm;
import '../../../../../shared/widgets/read_more_text.dart';

class VendorDetailScreen extends StatelessWidget {
  final String vendorId;
  final String vendorName;
  final Subcategories service;
  final int categoryId;

  const VendorDetailScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
    required this.service,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ServiceDetailProvider(service, categoryId)
            ..vendorDetailsApi(vendorId),
      child: const VendorDetailView(),
    );
  }
}

class VendorDetailView extends StatelessWidget {
  const VendorDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceDetailProvider>();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          provider.clearSearch();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: CustomAppBar(
                  title:
                      (provider.vendorDetailData.data?.data?.isNotEmpty ??
                          false)
                      ? "${provider.vendorDetailData.data?.data?.first.vendor?.firstName ?? ''} ${provider.vendorDetailData.data?.data?.first.vendor?.lastName ?? ''}"
                            .trim()
                      : "Vendor Details",
                ),
              ),
              Expanded(child: _buildBody(context, provider)),
              if (!provider.isLoading && provider.cartItemCount > 0) ...[
                Divider(color: AppColors.dividerColor),
                _buildBottomBar(context, provider),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ServiceDetailProvider provider) {
    if (provider.vendorDetailData.status == ApiStatus.loading) {
      return Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: AppColors.primary,
          size: 40,
        ),
      );
    }

    if (provider.vendorDetailData.status == ApiStatus.error) {
      return Center(
        child: Text(
          provider.vendorDetailData.message ?? "Something went wrong",
          style: AppFontStyle.text_16_400(AppColors.grey),
        ),
      );
    }

    final dataList = provider.vendorDetailData.data?.data;
    if (dataList == null || dataList.isEmpty) {
      return NoDataFoundWidget(message: "No services found for this vendor");
    }

    final vendor = dataList.first.vendor;
    final categoryName = dataList.first.category?.categoryName;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(vendor, categoryName),
          hBox(10.h),
          _buildSearchBar(provider),
          hBox(20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              "Services",
              style: AppFontStyle.text_20_600(
                AppColors.black,
                fontFamily: AppFontFamily.semiBold,
              ),
            ),
          ),
          hBox(16.h),
          provider.filteredVendorServices.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      "No service found",
                      style: AppFontStyle.text_16_400(AppColors.grey),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.filteredVendorServices.length,
                  separatorBuilder: (context, index) => hBox(24.h),
                  itemBuilder: (context, index) {
                    return _buildServiceCard(
                      context,
                      provider.filteredVendorServices[index],
                      provider,
                    );
                  },
                ),
          hBox(20.h),
        ],
      ),
    );
  }

  Widget _buildHeader(vdm.Vendor? vendor, String? categoryName) {
    final name = "${vendor?.firstName ?? ''} ${vendor?.lastName ?? ''}".trim();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 40.w,
              backgroundColor: AppColors.lightGrey,
              backgroundImage: vendor?.proImg != null
                  ? CachedNetworkImageProvider(
                      "${AppUrls.imageBaseUrl}${vendor?.proImg}",
                    )
                  : null,
              child: vendor?.proImg == null
                  ? Icon(Icons.person, size: 40.w, color: AppColors.lightGrey2)
                  : null,
            ),
          ),
          wBox(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? "No Name" : name,
                  style: AppFontStyle.text_20_600(
                    AppColors.black,
                    fontFamily: AppFontFamily.semiBold,
                  ),
                ),
                Text(
                  categoryName ?? "Services",
                  style: AppFontStyle.text_14_400(AppColors.lightGrey3),
                ),
                hBox(4.h),
                Row(
                  children: [
                    Icon(Icons.star, size: 18.w, color: AppColors.orange),
                    wBox(4.w),
                    Text(
                      vendor?.receivedReviewsCount?.toString() ?? '',
                      style: AppFontStyle.text_14_600(
                        AppColors.black,
                        fontFamily: AppFontFamily.bold,
                      ),
                    ),
                    wBox(8.w),
                    InkWell(
                      onTap: () async {
                        final bool allowed = await AuthGuard.requireLogin(
                          navigatorKey.currentContext!,
                        );

                        if (!allowed) return;

                        Navigator.push(
                          navigatorKey.currentContext!,
                          MaterialPageRoute(
                            builder: (context) => AllReviewsScreen(
                              VendorId: vendor?.id?.toString() ?? "",
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "${vendor?.receivedReviewsCount ?? 0} Reviews",
                        style:
                            AppFontStyle.text_14_400(
                              AppColors.primary,
                              fontFamily: AppFontFamily.regular,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ServiceDetailProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(25.h),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.lightGrey3, size: 24.w),
            wBox(10.w),
            Expanded(
              child: TextField(
                controller: provider.searchController,
                onChanged: (value) => provider.updateSearchQuery(value),
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: AppFontStyle.text_16_400(AppColors.lightGrey3),
                  border: InputBorder.none,
                  isDense: true,
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.lightGrey3),
                          onPressed: () => provider.clearSearch(),
                        )
                      : null,
                ),
                style: AppFontStyle.text_16_400(AppColors.black),
              ),
            ),
          ],
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
              Text(
                "Error",
                style: AppFontStyle.text_18_600(
                  AppColors.black,
                  fontFamily: AppFontFamily.semiBold,
                ),
              ),
            ],
          ),
          content: Text(
            maxLines: 4,
            message.replaceAll('Exception: ', ''),
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

  Widget _buildServiceCard(
    BuildContext context,
    vdm.Data service,
    ServiceDetailProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final bool allowed = await AuthGuard.requireLogin(context);

            if (!allowed) return;
            final result = Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    singleServiceScreen(serviceId: service.id!, isCart: true),
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
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: "${AppUrls.imageBaseUrl}${service.serviceImage}",
                  width: 100.w,
                  height: 100.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100.w,
                    height: 100.w,
                    color: AppColors.lightGrey,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100.w,
                    height: 100.w,
                    color: AppColors.lightGrey,
                    child: Icon(Icons.image, color: AppColors.lightGrey2),
                  ),
                ),
              ),
              wBox(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceName ?? "",
                      style: AppFontStyle.text_16_600(
                        AppColors.black,
                        fontFamily: AppFontFamily.semiBold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    hBox(4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16.w,
                          color: AppColors.lightGrey3,
                        ),
                        wBox(4.w),
                        Text(
                          "${service.durationValue} ${service.durationType}",
                          style: AppFontStyle.text_14_400(AppColors.lightGrey3),
                        ),
                      ],
                    ),
                    hBox(12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${service.servicePrice}",
                          style: AppFontStyle.text_18_600(
                            AppColors.primary,
                            fontFamily: AppFontFamily.bold,
                          ),
                        ),
                        provider.isInCart(service.id ?? 0)
                            ? _buildCounter(service.id ?? 0, provider, context)
                            : CustomButton(
                                text: "Add",
                                width: 80.w,
                                height: 35.h,
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.primary,
                                textStyle: AppFontStyle.text_14_600(
                                  Colors.white,
                                  fontFamily: AppFontFamily.bold,
                                ),
                                onPressed: () async {
                                  final bool allowed =
                                      await AuthGuard.requireLogin(context);

                                  if (!allowed) return;
                                  if (service.id != null) {
                                    try {
                                      await provider.addToCart(service.id!);
                                    } catch (e) {
                                      _showErrorDialog(context, e.toString());
                                    }
                                  }
                                },
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        hBox(16.h),
        ReadMoreDescription(
          text: service.description ?? "",
          style: AppFontStyle.text_14_400(AppColors.lightGrey3),
          trimLines: 2,
        ),
      ],
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
            '\$${provider.totalAmount.toStringAsFixed(2)}',
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

  Widget _buildCounter(
    int serviceId,
    ServiceDetailProvider provider,
    BuildContext context,
  ) {
    final quantity = provider.getQuantity(serviceId);

    return Container(
      height: 35.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
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
              }
            },
            child: Padding(
              padding: EdgeInsets.all(4.0.w),
              child: Icon(Icons.remove, size: 16.w, color: AppColors.primary),
            ),
          ),
          wBox(8.w),
          Text(
            '$quantity',
            style: AppFontStyle.text_14_600(
              AppColors.primary,
              fontFamily: AppFontFamily.bold,
            ),
          ),
          wBox(8.w),
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
              padding: EdgeInsets.all(4.0.w),
              child: Icon(Icons.add, size: 16.w, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
