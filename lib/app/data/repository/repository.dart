import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as dio;
import 'package:ozi/app/data/models/vendorservicedetailmodel.dart';
import 'package:ozi/app/modules/auth/vendor/signup/model/document_verify_check_model.dart';
import 'package:ozi/app/modules/user/Reviews%20Section/model/reviewmodel.dart';
import 'package:ozi/app/modules/user/booking/model/bookingdetailsmodel.dart'
    as details;
import 'package:ozi/app/modules/user/booking/model/bookingmodel.dart';
import 'package:ozi/app/modules/user/cart/schedule_service/Model/bookservicemodel.dart';
import 'package:ozi/app/modules/user/cart/view/model/couponmodel.dart';
import 'package:ozi/app/modules/user/home/model/category_model.dart';
import 'package:ozi/app/modules/user/home/service%20details/model/ServiceDetailsModel.dart';
import 'package:ozi/app/modules/user/home/service%20details/model/vendordetaiulmodel.dart';
import 'package:ozi/app/modules/user/profile/address%20map/model/saved_latlong_model.dart';
import 'package:ozi/app/modules/user/profile/setting/model/settingsmodel.dart';
import 'package:ozi/app/modules/user/profile/vendor%20reviews/model/vendor_review_model.dart';
import 'package:ozi/app/modules/user/profile/view/model/logout_model.dart';
import 'package:ozi/app/modules/vendor/home/model/readNotification_model.dart';
import 'package:ozi/app/modules/vendor/home/notification/model/get_notification_model.dart';
import 'package:ozi/app/modules/vendor/profile/help/model/helpsupportmodel.dart';
import 'package:ozi/app/modules/vendor/wallet/model/wallet_detail_model.dart';
import 'package:ozi/app/modules/vendor/wallet/transaction_history/model/transaction_history_model.dart';
import 'package:ozi/app/view/user_role/choose_your_role/model/choose_role_model.dart';
import '../../core/appExports/app_export.dart';
import '../../core/constants/app_urls.dart';
import '../../modules/user/cart/view/model/cart_items_model.dart';
import '../../modules/user/cart/view/model/decrease_cart_quantity_model.dart';
import '../../modules/user/cart/view/model/increase_cart_quantity_model.dart';
import '../../modules/user/home/service details/model/add_to_cart.dart';
import '../../modules/user/profile/edit address/model/edit_address_model.dart';
import '../../modules/user/profile/edit profile/model/update_profile_model.dart';
import '../../modules/user/profile/login details/model/login_detail_model.dart';
import '../../modules/user/profile/login details/model/logout_user_model.dart';
import '../../modules/user/profile/save address/model/delete_address_model.dart';
import '../../modules/vendor/services/service_details/model/service_detail_model.dart';
import '../../view/auth/login/model/gues_user_model.dart';
import '../../view/auth/login/model/login_model.dart';
import '../../view/auth/verification_screen/model/verify_otp.dart';
import '../network/network_api_services.dart';

class Repository {
  final _apiService = NetworkApiServices();

  //**************************************************** Login API *****************************************************************//
  Future<LoginModel> accountChecker(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postApiWithoutToken(
        data,
        AppUrls.login,
      );
      return LoginModel.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  //**************************************************** Skip user API *****************************************************************//

  Future<GuestUser> guestUser(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postApiWithoutToken(
        data,
        AppUrls.guestUser,
      );
      return GuestUser.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<DocumentStatusModel> documentStatusCheck() async {
    try {
      final url = AppUrls.documentStatusCheck;
      dynamic response = await _apiService.getApi(url);
      return DocumentStatusModel.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  //************************************************** Verification API **************************************************//
  Future<VerifyOtp> verificationUser(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postApiWithoutToken(
        data,
        AppUrls.verification,
      );
      return VerifyOtp.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  //****************************** Choose role API **********************************//
  Future<ChooseRoleModel> chooseRoleApi(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postApiWithoutToken(
        data,
        AppUrls.chooseRole,
      );
      return ChooseRoleModel.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  // ********************************** Category Api ****************************//

  Future<CategoryModel> homePageCategoryApi(
    // Map<String, dynamic> data,
    String lat,
    String lng,
  ) async {
    final url = "${AppUrls.getHomeCategories}?longitude=$lng&latitude=$lat";
    try {
      dynamic response = await _apiService.getApi(url);
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  // *********************************  logout Api *********************************//

  Future<LogoutModel> logoutApi() async {
    try {
      dynamic response = await _apiService.postApi({}, AppUrls.logout);
      return LogoutModel.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  // *********************************** ServiceDetails Api ***************************************//
  Future<ServiceDetailsModel> serviceDetailsApi(
    int categoryId,
    int subcategoryId, {
    String? latitude,
    String? longitude,
  }) async {
    try {
      String url =
          '${AppUrls.getServiceDetailsApi}?category_id=$categoryId&subcategory_id=$subcategoryId';

      if (latitude != null && longitude != null) {
        url += '&latitude=$latitude&longitude=$longitude';
      }

      dev.log('Service Details API URL: $url');

      dynamic response = await _apiService.getApi(url);

      dev.log('Service Details Raw Response: $response');

      return ServiceDetailsModel.fromJson(response);
    } catch (e) {
      dev.log('Error in serviceDetailsApi: $e');
      throw Exception(e);
    }
  }

  // *********************************** HelpCenter Api ***************************************//
  Future<helpSupportModel> helpCenterApi(String type) async {
    try {
      final url = '${AppUrls.helpSupportUrl}?type=$type';

      dev.log('helpCenterApi URL: $url');

      dynamic response = await _apiService.getApi(url);

      dev.log('helpCenterApi Response: $response');

      return helpSupportModel.fromJson(response);
    } catch (e) {
      dev.log('Error in helpCenterApi: $e');
      throw Exception(e);
    }
  }

  // *********************************** VendorDetails Api ***************************************//
  Future<vendorDetailModel> vendorDetailsApi(String vendorId) async {
    try {
      final url = '${AppUrls.vendorServiceUrl}?vendor_id=$vendorId';

      dev.log('vendorDetailsApi URL: $url');

      dynamic response = await _apiService.getApi(url);

      dev.log('vendorDetailsApi Response: $response');

      return vendorDetailModel.fromJson(response);
    } catch (e) {
      dev.log('Error in vendorDetailsApi: $e');
      throw Exception(e);
    }
  }

  // ********************************** getServiceDetail Api ****************************//

  Future<vendorServiceDetailModel> getservicedetailApi(
    // Map<String, dynamic> data,
    String serviceId,
  ) async {
    final url = "${AppUrls.vendorServiceDetails}?service_id=$serviceId";
    try {
      dynamic response = await _apiService.getApi(url);
      return vendorServiceDetailModel.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  // **************************  AddToCart Api **************************//
  Future<AddToCartModel> addToCartApi(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.addToCartApi}');
      }
      if (kDebugMode) {
        print('API Request Data: $data');
      }

      dynamic response = await _apiService.postApi(data, AppUrls.addToCartApi);

      if (kDebugMode) {
        print('API Response: $response');
      }
      if (kDebugMode) {
        print('API Response Type: ${response.runtimeType}');
      }

      // Return raw response, let the provider parse it
      return AddToCartModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('addToCartApi Error: $e');
      }
      rethrow;
    }
  }

  // **************************  email Send Api **************************//
  Future<dynamic> emailSendApi(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.sendEmail}');
      }
      if (kDebugMode) {
        print('API Request Data: $data');
      }

      dynamic response = await _apiService.postApi(data, AppUrls.sendEmail);

      if (kDebugMode) {
        print('API Response: $response');
      }
      if (kDebugMode) {
        print('API Response Type: ${response.runtimeType}');
      }

      // Return raw response, let the provider parse it
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('addToCartApi Error: $e');
      }
      rethrow;
    }
  }

  // **************************  verifyEmail Api **************************//
  Future<dynamic> verifyEmailApi(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.verifyEmail}');
      }
      if (kDebugMode) {
        print('API Request Data: $data');
      }

      dynamic response = await _apiService.postApi(data, AppUrls.verifyEmail);

      if (kDebugMode) {
        print('API Response: $response');
      }
      if (kDebugMode) {
        print('API Response Type: ${response.runtimeType}');
      }

      // Return raw response, let the provider parse it
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('addToCartApi Error: $e');
      }
      rethrow;
    }
  }

  // **************************  cancelBooking Api **************************//
  Future<dynamic> cancelBookingApi(int bookingId) async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.cancelBooking}');
      }
      if (kDebugMode) {
        print('API Request Data: $bookingId');
      }

      dynamic response = await _apiService.postApi({
        "booking_id": bookingId,
      }, AppUrls.cancelBooking);

      if (kDebugMode) {
        print('API Response: $response');
      }
      if (kDebugMode) {
        print('API Response Type: ${response.runtimeType}');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('cancelBookingApi: $e');
      }
      rethrow;
    }
  }

  // **************************  Get Cart Items Api **************************//
  Future<CartItemsModel> getCartItemsApi() async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.getCartItemsApi}');
      }

      dynamic response = await _apiService.getApi(AppUrls.getCartItemsApi);
      if (kDebugMode) {
        print('API Response: $response');
      }
      return CartItemsModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('getCartItemsApi Error: $e');
      }
      rethrow;
    }
  }

  // **************************  Get vendorReview Api **************************//
  Future<getVendorReviewsModel> getvendorReviewApi(
    String vendorId, {
    int page = 1,
  }) async {
    try {
      final url = "${AppUrls.vendorReview}?vendor_id=$vendorId&page=$page";
      if (kDebugMode) {
        print('API Request URL: $url');
      }

      dynamic response = await _apiService.getApi(url);
      if (kDebugMode) {
        print('API Response: $response');
      }
      return getVendorReviewsModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('getvendorReviewApi Error: $e');
      }
      rethrow;
    }
  }

  // **************************  Submit Review Api **************************//
  Future<dynamic> submitReviewApi(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.addReview}');
      }
      if (kDebugMode) {
        print('API Request Data: $data');
      }

      dynamic response = await _apiService.postApi(data, AppUrls.addReview);
      if (kDebugMode) {
        print('API Response: $response');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('submitReviewApi Error: $e');
      }
      rethrow;
    }
  }

  Future<settingsModel> settingsApi() async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.settingsUrl}');
      }

      dynamic response = await _apiService.getApi(AppUrls.settingsUrl);
      if (kDebugMode) {
        print('API Response: $response');
      }
      return settingsModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('settingsApi Error: $e');
      }
      rethrow;
    }
  }

  // **************************  GetBookingDetails Api **************************//
  Future<details.bookingDetailsModel> getBookingDetailsApi(
    int bookingId,
  ) async {
    try {
      final url = "${AppUrls.getBookingDetails}booking_id=$bookingId";
      if (kDebugMode) {
        print('API Request URL: $url');
      }

      dynamic response = await _apiService.getApi(url);
      if (kDebugMode) {
        print('API Response: $response');
      }
      return details.bookingDetailsModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('getBookingDetailsApi Error: $e');
      }
      rethrow;
    }
  }

  // **************************  GetCouponsDetails Api **************************//
  // **************************  GetCouponsDetails Api **************************//
  Future<getCupponsModel> getCouponsApi({
    required String search,
    required int page,
    required int limit,
  }) async {
    try {
      final Map<String, dynamic> params = {"page": page, "limit": limit};

      // Only send search if not empty
      if (search.isNotEmpty) {
        params["search"] = search;
      }

      final response = await _apiService.getApiWithPerms(
        params,
        AppUrls.getCoupons,
      );

      return getCupponsModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  // Future<getCupponsModel> getCouponsApi() async {
  //   try {
  //     final url = AppUrls.getCoupons;
  //     if (kDebugMode) {
  //       print('API Request URL: $url');
  //     }

  //     dynamic response = await _apiService.getApi(url);
  //     if (kDebugMode) {
  //       print('API Response: $response');
  //     }
  //     return getCupponsModel.fromJson(response);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('getBookingDetailsApi Error: $e');
  //     }
  //     rethrow;
  //   }
  // }

  // **************************  GetAllBookings Api **************************//
  Future<bookingModel> getAllBookings(
    String status,
    int limit,
    int page,
  ) async {
    try {
      final url =
          '${AppUrls.getAllBookings}?status=$status&limit=$limit&page=$page';
      if (kDebugMode) {
        print('API Request URL: $url');
      }

      dynamic response = await _apiService.getApi(url);
      if (kDebugMode) {
        print('API Response: $response');
      }
      return bookingModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('getAllBookings Error: $e');
      }
      rethrow;
    }
  }

  // **************************  Remove Cart Item Api **************************//
  Future<dynamic> removeCartItemApi(int cartId) async {
    try {
      final url = AppUrls.deleteCartItem;
      final data = {'cart_id': cartId};

      dev.log('Remove Cart Item API URL: $url');
      dev.log('Remove Cart Item Data: $data');

      dynamic response = await _apiService.postApi(data, url);

      dev.log('Remove Cart Item Raw Response: $response');

      return response;
    } catch (e) {
      dev.log('Error in removeCartItemApi: $e');
      throw Exception(e);
    }
  }

  //********************************* increaseCartQuantity Api ********************************//
  Future<IncreaseCartQuantityModel> increaseCartItemApi(int cartId) async {
    try {
      final url = AppUrls.increaseCartQuantity;
      final data = {'cart_id': cartId};

      dev.log('Increase Cart Item API URL: $url');
      dev.log('Increase Cart Item Data: $data');

      dynamic response = await _apiService.postApi(data, url);

      dev.log('Increase Cart Item Raw Response: $response');

      return IncreaseCartQuantityModel.fromJson(response);
    } catch (e) {
      dev.log('Error in increaseCartItemApi: $e');
      throw Exception(e);
    }
  }

  Future<dynamic> checkMobileExistsApi(
    String mobile,
    String countryCode,
  ) async {
    try {
      final url = AppUrls.checkMobileExists;
      final data = {'mobile': mobile, 'country_code': countryCode};

      dev.log('Check Mobile Exists API URL: $url');
      dev.log('Check Mobile Exists Data: $data');

      dynamic response = await _apiService.postApi(data, url);

      dev.log('Check Mobile Exists Raw Response: $response');

      return response;
    } catch (e) {
      // Get.snackbar("Error", e.toString());
      throw Exception(e);
    }
  }

  //********************************* decreaseCartQuantity Api ********************************//
  Future<DecreaseCartQuantityModel> decreaseCartItemApi(int cartId) async {
    try {
      final url = AppUrls.decreaseCartQuantity;
      final data = {'cart_id': cartId};

      dev.log('Decrease Cart Item API URL: $url');
      dev.log('Decrease Cart Item Data: $data');

      dynamic response = await _apiService.postApi(data, url);

      dev.log('Decrease Cart Item Raw Response: $response');

      return DecreaseCartQuantityModel.fromJson(response);
    } catch (e) {
      dev.log('Error in decreaseCartItemApi: $e');
      throw Exception(e);
    }
  }

  //********************************* bookAgain Api ********************************//
  Future<dynamic> bookAgainApi(int bookingId) async {
    try {
      final url = AppUrls.bookAgainUrl;

      dev.log('Decrease Cart Item API URL: $url');

      dynamic response = await _apiService.postApi({
        "booking_id": bookingId,
      }, url);

      dev.log('Decrease Cart Item Raw Response: $response');

      return response;
    } catch (e) {
      dev.log('Error in decreaseCartItemApi: $e');
      throw Exception(e);
    }
  }

  Future<dynamic> sendToAdminApi(Map<String, String> fields) async {
    try {
      final url = AppUrls.admindltApi;

      dev.log('sendToAdminApi URL: $url');

      dynamic response = await _apiService.postApi(fields, url);

      dev.log('sendToAdminApi Raw Response: $response');

      return response;
    } catch (e) {
      dev.log('Error in sendToAdminApi: $e');
      throw Exception(e);
    }
  }

  Future<dynamic> locationSendToBackend(Map<String, String> fields) async {
    try {
      final url = AppUrls.updateDeviceLoginLocation;

      dev.log('locationSendToBackend URL: $url');

      dynamic response = await _apiService.postApi(fields, url);

      dev.log('locationSendToBackend Raw Response: $response');

      return response;
    } catch (e) {
      dev.log('Error in locationSendToBackend: $e');
      throw Exception(e);
    }
  }

  Future<dynamic> checkSocialUser(String googleId, String email) async {
    try {
      final url = AppUrls.checkSocialUser;

      dev.log('Check Social User API URL: $url');

      dynamic response = await _apiService.postApi({
        "google_id": googleId,
        "email": email,
      }, url);

      dev.log('Check Social User Raw Response: $response');

      return response;
    } catch (e) {
      dev.log('Error in checkSocialUser: $e');
      throw Exception(e);
    }
  }

  Future<dynamic> checkFacebookSocialUserApi(String fbId, String email) async {
    try {
      final url = AppUrls.checkFbSocialUser;

      dev.log('Check Facebook Social User API URL: $url');

      dynamic response = await _apiService.postApi({
        "facebook_id": fbId,
        "email": email,
      }, url);

      dev.log('Check Facebook Social User Raw Response: $response');

      return response;
    } catch (e) {
      dev.log('Error in checkSocialUser: $e');
      throw Exception(e);
    }
  }

  // ********************************************* GetProfile Api ***********************************************//
  Future<dynamic> getProfileApi() async {
    try {
      dynamic response = await _apiService.getApi(AppUrls.getUserProfile);
      if (kDebugMode) {
        print('Profile API Response: $response');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Profile API Error: $e');
      }
      throw Exception(e);
    }
  }

  // ********************************************* UpdateProfile Api ***********************************************//
  Future<UpdateProfileModel> updateProfileApi(
    Map<String, String> fields,
    File? image,
  ) async {
    Map<String, File> fileMap = {};

    if (image != null) {
      fileMap["pro_img"] = image;
    }
    dynamic response = await _apiService.postApiMultiPart(
      AppUrls.updateUserProfile,
      fields,
      fileMap,
    );
    return UpdateProfileModel.fromJson(response);
  }

  // ********************************************* getUserAddress Api ***********************************************//
  Future<dynamic> getUserAddressApi() async {
    try {
      dynamic response = await _apiService.getApi(AppUrls.getUserAddress);
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> socialLoginApi(Map<String, dynamic> data) async {
    dynamic response = await _apiService.postApiWithoutToken(
      data,
      AppUrls.socialLogin,
    );
    return response;
  }

  Future<dynamic> facebookSocialLoginApi(Map<String, dynamic> data) async {
    dynamic response = await _apiService.postApiWithoutToken(
      data,
      AppUrls.socialLoginFacebookApi,
    );
    return response;
  }

  // ********************************************* getSingleService Api ***********************************************//
  Future<dynamic> getSingleServiceApi(int serviceId) async {
    try {
      dynamic response = await _apiService.getApi(
        "${AppUrls.singleServiceUrl}/$serviceId",
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  // ********************************************* AddNewUserAddress Api ***********************************************//
  Future<dynamic> addNewUserAddressApi(Map<String, dynamic> data) async {
    try {
      dev.log("Add New User Address API URL: ${AppUrls.addUserAddress}");
      dev.log("Request Data: $data");

      final response = await _apiService.postApi(data, AppUrls.addUserAddress);

      return response;
    } catch (e) {
      dev.log("Error in addNewUserAddressApi: $e");
      throw Exception(e);
    }
  }

  // ********************************************* Support Api ***********************************************//
  Future<dynamic> supportApi(Map<String, dynamic> data) async {
    try {
      dev.log("Support API URL: ${AppUrls.supportUrl}");
      dev.log("Request Data: $data");

      final response = await _apiService.postApi(data, AppUrls.supportUrl);

      return response;
    } catch (e) {
      dev.log("Error in supportApi: $e");
      throw Exception(e);
    }
  }

  // ********************************************* scheduleApi ***********************************************//
  Future<dynamic> completescheduleServiceApi(Map<String, dynamic> data) async {
    try {
      dev.log("completescheduleServiceApi API URL: ${AppUrls.bookService}");
      dev.log("Request Data: $data");

      final response = await _apiService.postApi(data, AppUrls.bookService);

      return response;
    } catch (e) {
      dev.log("Error in scheduleServiceApi: $e");
      throw Exception(e);
    }
  }

  // ********************************************* deleteUserAddress Api ***********************************************//
  Future<DeleteAddressModel> deleteUserAddressApi(int addressId) async {
    try {
      dev.log("Delete User Address API URL: ${AppUrls.deleteUserAddress}");
      dev.log("Address ID: $addressId");

      // Use DELETE method with correct parameter name
      final response = await _apiService.deleteApi(
        {"address_id": addressId}, // Changed from "id" to "address_id"
        AppUrls.deleteUserAddress,
      );

      return DeleteAddressModel.fromJson(response);
    } catch (e) {
      dev.log("Error in deleteUserAddressApi: $e");
      throw Exception(e);
    }
  }

  // ********************************************* editUserAddress Api ***********************************************//
  Future<EditAddressModel> editUserAddressApi(
    int addressId,
    Map<String, dynamic> data,
  ) async {
    try {
      dev.log(
        "Edit User Address API URL: ${AppUrls.updateUserAddress}/$addressId",
      );
      dev.log("Request Data: $data");

      // Use PUT method and append addressId to URL
      final response = await _apiService.postApi(
        data,
        "${AppUrls.updateUserAddress}/$addressId",
      );

      return EditAddressModel.fromJson(response);
    } catch (e) {
      dev.log("Error in editUserAddressApi: $e");
      throw Exception(e);
    }
  }

  // ********************************************* scheduleService Api ***********************************************//
  Future<BookServiceModel> scheduleServiceApi() async {
    try {
      dev.log("scheduleServiceApi API URL: ${AppUrls.scheduleService}");

      // Use PUT method and append addressId to URL
      final response = await _apiService.getApi(AppUrls.scheduleService);

      if (response is List) {
        if (response.isEmpty) return BookServiceModel();
        return BookServiceModel.fromJson(response[0]);
      }

      return BookServiceModel.fromJson(response);
    } catch (e) {
      dev.log("Error in scheduleServiceApi: $e");
      throw Exception(e);
    }
  }

  // ********************************** Reschedule Availability Api ********************************** //
  Future<BookServiceModel> fetchRescheduleAvailabilityApi(
    String bookingId,
  ) async {
    try {
      dev.log(
        "fetchRescheduleAvailabilityApi URL: ${AppUrls.rescheduleService}?booking_id=$bookingId",
      );

      // Use PUT method and append addressId to URL
      final response = await _apiService.getApi(
        "${AppUrls.rescheduleService}?booking_id=$bookingId",
      );

      if (response is List) {
        if (response.isEmpty) return BookServiceModel();
        return BookServiceModel.fromJson(response[0]);
      }

      return BookServiceModel.fromJson(response);
    } catch (e) {
      dev.log("Error in fetchRescheduleAvailabilityApi: $e");
      throw Exception(e);
    }
  }

  // ********************************** Reschedule Booking Api ********************************** //
  Future<dynamic> rescheduleBookingApi(Map<String, dynamic> data) async {
    try {
      dev.log(
        "rescheduleBookingApi URL: ${AppUrls.rescheduleServicePostApiUrl}",
      );
      dev.log("Request Data: $data");

      final response = await _apiService.postApi(
        data,
        AppUrls.rescheduleServicePostApiUrl,
      );

      return response;
    } catch (e) {
      dev.log("Error in rescheduleBookingApi: $e");
      throw Exception(e);
    }
  }

  // ********************************** ApplyorRemoveCuppon Api ********************************** //

  Future<dynamic> applyorRemoveCupponApi(String promoId) async {
    try {
      dev.log("applyorRemoveCupponApi URL: ${AppUrls.applyCoupon}");

      final response = await _apiService.postApi({
        "promo_id": promoId,
      }, AppUrls.applyCoupon);

      return response;
    } catch (e) {
      dev.log("Error in applyorRemoveCupponApi: $e");
      throw Exception(e);
    }
  }

  // **************************  Delete Profile Api **************************//
  Future<dynamic> deleteProfile() async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.deleteAccountUrl}');
      }

      dynamic response = await _apiService.deleteApi(
        {},
        AppUrls.deleteAccountUrl,
      );
      if (kDebugMode) {
        print('API Response: $response');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('deleteProfile Error: $e');
      }
      rethrow;
    }
  }

  // **************************  Update Notification Api **************************//
  Future<dynamic> updateNotificationApi(
    int notistatus,
    int emailnotiStatus,
  ) async {
    try {
      final url =
          '${AppUrls.updateNotificationUrl}notification=$notistatus&email_notification=$emailnotiStatus';
      if (kDebugMode) {
        print('API Request URL: $url');
      }

      dynamic response = await _apiService.postApi({
        "notification": notistatus,
        "email_notification": emailnotiStatus,
      }, url);
      if (kDebugMode) {
        print('API Response: $response');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('updateNotificationApi Error: $e');
      }
      rethrow;
    }
  }

  // **************************  Update Email Notification Api **************************//
  Future<dynamic> updateEmailNotificationApi(int status) async {
    try {
      final url = '${AppUrls.updateNotificationUrl}email_notification=$status';
      if (kDebugMode) {
        print('API Request URL: $url');
      }

      dynamic response = await _apiService.postApi({
        "email_notification": status,
      }, url);
      if (kDebugMode) {
        print('API Response: $response');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('updateEmailNotificationApi Error: $e');
      }
      rethrow;
    }
  }

  // ********************************** Current User Login Details ********************************** //

  Future<CurrentUserLoginModel> fetchCurrentUserLoginDetails() async {
    try {
      dev.log(
        "fetchCurrentUserLoginDetails URL: ${AppUrls.getCurrentUserLoginDetails}",
      );

      final response = await _apiService.getApi(
        AppUrls.getCurrentUserLoginDetails,
      );

      return CurrentUserLoginModel.fromJson(response);
    } catch (e) {
      dev.log("Error in fetchCurrentUserLoginDetails: $e");
      throw Exception(e);
    }
  }

  // ********************************** Current User logoutUserFromOtherDevice ********************************** //

  Future<LogoutUsersModel> logoutUserFromOtherDevice(String tokenId) async {
    try {
      dynamic response = await _apiService.postApi({
        "token_id": tokenId,
      }, AppUrls.logoutUserFromOtherDevice);
      return LogoutUsersModel.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  // ********************************** Current User WalletDetail ********************************** //

  Future<WalletDetailModel> fetchWalletDetail() async {
    try {
      dev.log("fetchWalletDetail URL: ${AppUrls.getCurrentUserLoginDetails}");

      final response = await _apiService.getApi(AppUrls.getWalletDetail);

      return WalletDetailModel.fromJson(response);
    } catch (e) {
      dev.log("Error in fetchWalletDetail: $e");
      throw Exception(e);
    }
  }

  // ********************************** Service Card detail ********************************** //

  Future<ServiceCardDetailModel> fetchServiceDetail({
    required String serviceId,
  }) async {
    try {
      dev.log("fetchWalletDetail URL: ${AppUrls.getCurrentUserLoginDetails}");

      final response = await _apiService.getApi(
        "${AppUrls.getServiceDetail}service_id=$serviceId",
      );

      return ServiceCardDetailModel.fromJson(response);
    } catch (e) {
      dev.log("Error in fetchServiceDetail: $e");
      throw Exception(e);
    }
  }

  Future<GetNotificationModel> fetchNotifications({required int page}) async {
    try {
      dev.log("fetchNotifications URL: ${AppUrls.getNotications}, Page: $page");

      final Map<String, dynamic> params = {"page": page};
      final response = await _apiService.getApiWithPerms(
        params,
        AppUrls.getNotications,
      );

      return GetNotificationModel.fromJson(response);
    } catch (e) {
      dev.log("Error in fetchNotifications: $e");
      throw Exception(e);
    }
  }

  Future<ReadnotificationModel> readAllNotifications() async {
    try {
      dev.log("readAllNotifications URL: ${AppUrls.readAllNotificationsApi}");

      final response = await _apiService.postApi(
        {},
        AppUrls.readAllNotificationsApi,
      );

      return ReadnotificationModel.fromJson(response);
    } catch (e) {
      dev.log("Error in readAllNotifications: $e");
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> withDrawMoney({required String amount}) async {
    try {
      dev.log("withDrawMoney URL: ${AppUrls.withDrawMoney}");

      final response = await _apiService.postApi({
        "amount": amount,
      }, AppUrls.withDrawMoney);

      dev.log("Withdraw response: $response");

      return response;
    } catch (e) {
      dev.log("Error in withDrawMoney: $e");

      return {"status": false, "message": "Something went wrong"};
    }
  }

  Future<TransactionHistoryModel> fetchTransactionsHistory({
    String? search,
    int? limit,
    String? period,
    int? page,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (limit != null) {
        queryParams['limit'] = limit;
      }

      if (period != null && period.isNotEmpty) {
        queryParams['period'] = period;
      }

      if (page != null) {
        queryParams['page'] = page;
      }

      final response = await _apiService.getApiWithPerms(
        queryParams,
        AppUrls.walletTransactions,
      );

      return TransactionHistoryModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // **************************  verify Profile Email Api **************************//
  Future<dynamic> verifyUpdateEmailApi(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.updateProfileEmail}');
      }
      if (kDebugMode) {
        print('API Request Data: $data');
      }

      dynamic response = await _apiService.postApi(
        data,
        AppUrls.updateProfileEmail,
      );

      if (kDebugMode) {
        print('API Response: $response');
      }
      if (kDebugMode) {
        print('API Response Type: ${response.runtimeType}');
      }

      // Return raw response, let the provider parse it
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('verifyUpdateEmailApi Error: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> verifyEditProfileEmailApi(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('API Request URL: ${AppUrls.verifyProfileEmail}');
      }
      if (kDebugMode) {
        print('API Request Data: $data');
      }

      dynamic response = await _apiService.postApi(
        data,
        AppUrls.verifyProfileEmail,
      );

      if (kDebugMode) {
        print('API Response: $response');
      }
      if (kDebugMode) {
        print('API Response Type: ${response.runtimeType}');
      }

      // Return raw response, let the provider parse it
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('verifyEditProfileEmailApi Error: $e');
      }
      rethrow;
    }
  }

  Future<SavedLatlongModel> fetchLatLong() async {
    try {
      final response = await _apiService.getApi(AppUrls.fetchLatLong);

      return SavedLatlongModel.fromJson(response);
    } catch (e) {
      dev.log("Error in fetchLatLong: $e");
      throw Exception(e);
    }
  }

  Future<VendorReviewModel> fetchReviewScreen() async {
    try {
      final response = await _apiService.getApi(AppUrls.vendorReviewScreen);

      return VendorReviewModel.fromJson(response);
    } catch (e) {
      dev.log("Error in fetchReviewScreen: $e");
      throw Exception(e);
    }
  }

  Future<Uint8List> downloadInvoice(String bookingId) async {
    try {
      // Step 1: Get URL
      final response = await _apiService.postApi({
        "booking_id": int.parse(bookingId),
      }, AppUrls.pdfInvoiceUrl);

      if (response["status"] != true) {
        throw Exception("Failed to get invoice URL");
      }

      final String url = response["url"];

      // Step 2: Download PDF
      final bytes = await _apiService.getPdfBytes(url);

      return bytes;
    } catch (e) {
      throw Exception(e);
    }
  }
}
