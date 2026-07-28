import '../../../../core/appExports/app_export.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../shared/widgets/custom_text_form_field.dart';
import '../provider/create_account_provider.dart';

class CreateAccountScreen extends StatefulWidget {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final bool isMobileVerified;

  const CreateAccountScreen({
    super.key,
    required this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.isMobileVerified = false,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late final CreateAccountProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CreateAccountProvider();
    // Pre-fill from Google login data
    if (widget.firstName != null) {
      _provider.firstNameController.text = widget.firstName!;
    }
    if (widget.lastName != null) {
      _provider.lastNameController.text = widget.lastName!;
    }
    if (widget.email != null && widget.email!.isNotEmpty) {
      _provider.emailController.text = widget.email!;
      _provider.setEmailVerifiedFromGoogle();
    }
    if (widget.phoneNumber != null) {
      _provider.setMobileData(
        mobile: widget.phoneNumber!,
        isVerified: widget.isMobileVerified,
      );
    }
  }

  bool get isGoogleSignUp =>
      widget.email != null &&
      widget.email!.isNotEmpty &&
      widget.firstName != null &&
      widget.firstName!.isNotEmpty;

  int _maxLen(CreateAccountProvider value) {
    return value.getExpectedPhoneLength(value.selectedCountry.phoneCode);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<CreateAccountProvider>(
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 50,
                ),
                child: Form(
                  key: value.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hBox(30),

                      // Title
                      Text(
                        "Create Account",
                        style: AppFontStyle.text_28_600(
                          AppColors.darkText,
                          fontFamily: AppFontFamily.extraBold,
                        ),
                      ),

                      hBox(10),

                      /// Subtitle
                      Text(
                        maxLines: 2,
                        "Create an account to continue.",
                        style: AppFontStyle.text_16_400(AppColors.grey),
                      ),

                      hBox(30),

                      /// FIRST NAME
                      CustomTextFormField(
                        controller: value.firstNameController,
                        label: "First Name",
                        hintText: "Enter first name",
                        onChanged: (val) => value.updateUI(),
                        prefix: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomImage(
                            path: ImageConstants.userIcon,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        borderRadius: 40,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "First name is required";
                          }
                          // if (!RegExp(r'^[a-zA-Z]+$').hasMatch(val.trim())) {
                          //   return "First name should contain only alphabets";
                          // }
                          return null;
                        },
                      ),

                      hBox(16),

                      /// LAST NAME
                      CustomTextFormField(
                        controller: value.lastNameController,
                        label: "Last Name",
                        hintText: "Enter last name",
                        onChanged: (val) => value.updateUI(),
                        prefix: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomImage(
                            path: ImageConstants.userIcon,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        borderRadius: 40,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Last name is required";
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(val.trim())) {
                            return "Last name should contain only alphabets";
                          }
                          return null;
                        },
                      ),

                      hBox(16),

                      /// EMAIL
                      CustomTextFormField(
                        controller: value.emailController,
                        label: "Email Address",
                        hintText: "Enter email address",
                        textInputType: TextInputType.emailAddress,
                        enabled: !isGoogleSignUp,
                        prefix: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomImage(
                            path: ImageConstants.mail,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        onChanged: isGoogleSignUp
                            ? null
                            : (val) {
                                value.validateEmail(val);
                              },
                        suffix: isGoogleSignUp
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.green,
                                  size: 20,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(12),
                                child: GestureDetector(
                                  onTap:
                                      (value.isEmailValid &&
                                          !value.isEmailVerified &&
                                          !value.isloading)
                                      ? () async {
                                          try {
                                            final response = await value
                                                .emailSendApi({
                                                  "email": value
                                                      .emailController
                                                      .text
                                                      .trim(),
                                                  "user_id": widget.userId,
                                                });
                                            if (response['status'] == true ||
                                                response['status'] == 200) {
                                              _showOtpDialog(
                                                context,
                                                value,
                                                widget.userId,
                                              );
                                            } else {
                                              Get.showToast(
                                                response['message'] ??
                                                    "Something went wrong",
                                                type: ToastType.warning,
                                              );
                                            }
                                          } catch (e) {
                                            Get.showToast(
                                              e.toString(),
                                              type: ToastType.error,
                                            );
                                          }
                                        }
                                      : null,
                                  child: value.isloading
                                      ? SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : value.isEmailVerified
                                      ? Icon(
                                          Icons.check_circle,
                                          color: AppColors.green,
                                          size: 20,
                                        )
                                      : value.isEmailValid
                                      ? Text(
                                          "Verify",
                                          style: AppFontStyle.text_14_400(
                                            AppColors.primary,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                        borderRadius: 60,
                        validator: (val) {
                          final text = (val == null || val.isEmpty)
                              ? value.emailController.text
                              : val;

                          if (text.trim().isEmpty) {
                            return "Email is required";
                          }
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(text.trim())) {
                            return "Please enter a valid email (e.g., abc@gmail.com)";
                          }
                          if (!value.isEmailVerified) {
                            return "Please verify your email address";
                          }
                          return null;
                        },
                      ),

                      hBox(16),

                      /// MOBILE NUMBER
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextFormField(
                            controller: value.mobileController,
                            label: "Mobile Number",
                            hintText: "Enter ${_maxLen(value)} digits",
                            textInputType: TextInputType.phone,
                            enabled: !value.isMobileVerified,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(_maxLen(value)),
                            ],
                            prefix: Padding(
                              padding: const EdgeInsets.only(
                                left: 14,
                                right: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // wBox(8),
                                  Row(
                                    children: [
                                      Text(
                                        "+1",
                                        style: AppFontStyle.text_16_600(
                                          AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: AppColors.grey,
                                  ),
                                  wBox(8),
                                  Container(
                                    height: 20,
                                    width: 1,
                                    color: AppColors.grey.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (val) {
                              if (value.mobileError != null) {
                                value.setMobileError(null);
                              }
                              value.updateUI();
                            },
                            suffix: value.isMobileVerified
                                ? Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: AppColors.green,
                                      size: 20,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: GestureDetector(
                                      onTap:
                                          (value.mobileController.text.length ==
                                                  _maxLen(value) &&
                                              !value.isloading)
                                          ? () async {
                                              final isAvailable = await value
                                                  .checkMobileExists();
                                              if (isAvailable) {
                                                final phone = value
                                                    .mobileController
                                                    .text
                                                    .trim();
                                                final fullPhone =
                                                    "+${value.selectedCountry.phoneCode}$phone";
                                                final verificationId =
                                                    await value.sendMobileOtp(
                                                      fullPhone,
                                                    );
                                                print(
                                                  "Verification id : $verificationId",
                                                );
                                                if (verificationId != '') {
                                                  print(
                                                    "Verification id : $verificationId",
                                                  );
                                                  value.updateOtpLoading(false);
                                                  _showMobileOtpDialog(
                                                    context,
                                                    value,
                                                    widget.userId,
                                                    verificationId,
                                                    fullPhone,
                                                  );
                                                }
                                              }
                                            }
                                          : null,
                                      child: value.isloading
                                          ? SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            )
                                          : Text(
                                              "Verify",
                                              style: AppFontStyle.text_14_400(
                                                value
                                                            .mobileController
                                                            .text
                                                            .length ==
                                                        _maxLen(value)
                                                    ? AppColors.primary
                                                    : AppColors.grey,
                                              ),
                                            ),
                                    ),
                                  ),
                            borderRadius: 60,
                            errorText: value.mobileError,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Mobile number is required";
                              }
                              if (val.trim().length != _maxLen(value)) {
                                return "Enter exactly ${_maxLen(value)} digits";
                              }
                              // Add this check for the server-side existence error
                              if (value.mobileError != null) {
                                return value.mobileError;
                              }
                              if (!value.isMobileVerified) {
                                return "Please verify your mobile number";
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text(
                              "Required: ${_maxLen(value)} digits for ${value.getCountryName(value.selectedCountry.phoneCode)}",
                              style: AppFontStyle.text_12_400(AppColors.grey),
                            ),
                          ),
                        ],
                      ),

                      hBox(30),

                      CustomButton(
                        isLoading: value.loading,
                        onPressed: value.loading
                            ? null
                            : () {
                                if (value.formKey.currentState?.validate() ??
                                    false) {
                                  value.createAccount(widget.userId, context);
                                }
                              },
                        color: AppColors.primary,
                        text: "Create Account",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOtpDialog(
    BuildContext context,
    CreateAccountProvider provider,
    String userId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _OtpDialogContent(provider: provider, userId: userId);
      },
    );
  }

  void _showMobileOtpDialog(
    BuildContext context,
    CreateAccountProvider provider,
    String userId,
    String verificationID,
    String mobileNumber,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _MobileOtpDialogContent(
          provider: provider,
          userId: userId,
          verificationID: verificationID,
          mobileNumber: mobileNumber,
        );
      },
    );
  }
}

class _OtpDialogContent extends StatefulWidget {
  final CreateAccountProvider provider;
  final String userId;

  const _OtpDialogContent({required this.provider, required this.userId});

  @override
  State<_OtpDialogContent> createState() => _OtpDialogContentState();
}

class _OtpDialogContentState extends State<_OtpDialogContent> {
  TextEditingController otpController = TextEditingController();
  String otpCode = "";
  String? errorMessage;
  String? successMessage;
  bool isResending = false;
  int secondsRemaining = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer({bool clearSuccess = true}) {
    timer?.cancel();
    setState(() {
      secondsRemaining = 60;
      errorMessage = null;
      if (clearSuccess) successMessage = null;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  String get timerText {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, child) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "OTP Verification",
            textAlign: TextAlign.center,
            style: AppFontStyle.text_20_600(AppColors.darkText),
          ),
          content: SizedBox(
            width: Get.width(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter the 6-digit OTP sent to your email.",
                  textAlign: TextAlign.center,
                  style: AppFontStyle.text_14_400(AppColors.grey),
                ),
                hBox(30),
                PinCodeTextField(
                  controller: otpController,
                  appContext: context,
                  length: 6,
                  onChanged: (value) {
                    otpCode = value;
                    if (errorMessage != null || successMessage != null) {
                      setState(() {
                        errorMessage = null;
                        successMessage = null;
                      });
                    }
                  },
                  keyboardType: TextInputType.number,
                  enableActiveFill: true,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.circle,
                    fieldHeight: 48,
                    fieldWidth: 48,
                    activeFillColor: AppColors.fieldBgColor,
                    inactiveFillColor: AppColors.fieldBgColor,
                    selectedFillColor: AppColors.fieldBgColor,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.transparent,
                    selectedColor: AppColors.primary,
                    borderWidth: 0,
                  ),
                ),
                if (errorMessage != null) ...[
                  hBox(8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      errorMessage!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.text_12_400(AppColors.red),
                    ),
                  ),
                ],
                hBox(10),
                if (secondsRemaining > 0)
                  Center(
                    child: Text(
                      "Resend OTP in $timerText",
                      style: AppFontStyle.text_12_400(AppColors.grey),
                    ),
                  )
                else
                  Center(
                    child: isResending
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.primary,
                            ),
                          )
                        : GestureDetector(
                            onTap: () async {
                              try {
                                setState(() => isResending = true);
                                final response = await widget.provider
                                    .emailSendApi({
                                      "email": widget
                                          .provider
                                          .emailController
                                          .text
                                          .trim(),
                                      "user_id": widget.userId,
                                    });

                                if (response['status'] == true ||
                                    response['status'] == 200) {
                                  startTimer(clearSuccess: false);
                                  setState(() {
                                    otpCode = "";
                                    otpController.clear();
                                    successMessage = "OTP resent successfully";
                                  });
                                } else {
                                  setState(() {
                                    errorMessage =
                                        response['message'] ??
                                        "Failed to resend OTP";
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  errorMessage = e.toString();
                                });
                              } finally {
                                setState(() => isResending = false);
                              }
                            },
                            child: Text(
                              "Resend OTP",
                              style: AppFontStyle.text_14_600(
                                AppColors.primary,
                              ).copyWith(decoration: TextDecoration.underline),
                            ),
                          ),
                  ),
                if (successMessage != null) ...[
                  hBox(8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      successMessage!,
                      style: AppFontStyle.text_12_400(AppColors.green),
                    ),
                  ),
                ],
                hBox(20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Cancel",
                          style: AppFontStyle.text_16_600(AppColors.red),
                        ),
                      ),
                    ),
                    wBox(12),
                    Expanded(
                      child: CustomButton(
                        height: 50,
                        onPressed: () async {
                          if (otpCode.length == 6) {
                            try {
                              final response = await widget.provider
                                  .verifyEmailApi({
                                    "email": widget
                                        .provider
                                        .emailController
                                        .text
                                        .trim(),
                                    "otp": otpCode,
                                    "user_id": widget.userId,
                                  });
                              if (response['status'] == true ||
                                  response['status'] == 200) {
                                Navigator.pop(context);
                                Get.showToast(
                                  "Email verified successfully",
                                  type: ToastType.success,
                                );
                              } else {
                                setState(() {
                                  errorMessage =
                                      response['message'] ?? "Invalid OTP";
                                });
                              }
                            } catch (e) {
                              setState(() {
                                errorMessage = e.toString();
                              });
                            }
                          } else {
                            setState(() {
                              errorMessage = "Please enter a 6-digit OTP";
                            });
                          }
                        },
                        isLoading: widget.provider.otpLoading,
                        text: "Verify",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MobileOtpDialogContent extends StatefulWidget {
  final CreateAccountProvider provider;
  final String userId;
  final String verificationID;

  String? mobileNumber;

  _MobileOtpDialogContent({
    required this.provider,
    required this.userId,
    required this.verificationID,
    required this.mobileNumber,
  });

  @override
  State<_MobileOtpDialogContent> createState() =>
      _MobileOtpDialogContentState();
}

class _MobileOtpDialogContentState extends State<_MobileOtpDialogContent> {
  TextEditingController otpController = TextEditingController();
  String otpCode = "";
  String? errorMessage;
  int _resendSeconds = 60;
  Timer? _timer;
  String? mobileNumber;
  bool isResending = false;
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Mobile OTP",
            textAlign: TextAlign.center,
            style: AppFontStyle.text_20_600(AppColors.darkText),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter the 6-digit OTP sent to your phone number.",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFontStyle.text_14_400(AppColors.grey),
              ),
              hBox(30),
              PinCodeTextField(
                controller: otpController,
                appContext: context,
                length: 6,
                onChanged: (v) {
                  otpCode = v;
                  if (errorMessage != null) {
                    setState(() => errorMessage = null);
                  }
                },
                keyboardType: TextInputType.number,
                enableActiveFill: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.circle,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 45,
                  fieldWidth: 40,
                  activeFillColor: AppColors.fieldBgColor,
                  inactiveFillColor: AppColors.fieldBgColor,
                  selectedFillColor: AppColors.fieldBgColor,
                  activeColor: AppColors.primary,
                  inactiveColor: Colors.transparent,
                  selectedColor: AppColors.primary,
                  borderWidth: 0,
                ),
              ),
              if (errorMessage != null) ...[
                hBox(12),
                Text(
                  errorMessage!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.text_12_400(AppColors.red),
                ),
              ],
              hBox(12),
              // Timer / Resend row
              if (_resendSeconds > 0)
                Text(
                  "Resend OTP in ${_resendSeconds}s",
                  textAlign: TextAlign.center,
                  style: AppFontStyle.text_12_400(AppColors.grey),
                )
              else
                isResending
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.primary,
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          setState(() {
                            errorMessage = null;
                            otpCode = "";
                            otpController.clear();
                            isResending = true;
                          });
                          try {
                            await widget.provider.sendMobileOtp(
                              widget.mobileNumber!,
                            );
                            _startTimer();
                          } finally {
                            if (mounted) {
                              setState(() => isResending = false);
                            }
                          }
                        },
                        child: Text(
                          "Resend OTP",
                          textAlign: TextAlign.center,
                          style: AppFontStyle.text_12_400(AppColors.primary),
                        ),
                      ),
              hBox(30),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      height: 45,
                      text: "Cancel",
                      textStyle: AppFontStyle.text_16_600(AppColors.black),
                      color: AppColors.lightGrey,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  wBox(10),
                  Expanded(
                    child: CustomButton(
                      height: 45,
                      text: "Verify",
                      isLoading: widget.provider.otpLoading,
                      onPressed: () async {
                        if (_resendSeconds == 0) {
                          setState(() {
                            errorMessage = "OTP Expired. Please resend OTP.";
                          });
                          return;
                        }

                        if (otpCode.length != 6) {
                          setState(() {
                            errorMessage = "Please enter 6-digit OTP";
                          });
                          return;
                        }

                        final error = await widget.provider.verifyMobileOtp(
                          otpCode,
                        );

                        if (error == null) {
                          // Only pop and show success if there's NO error
                          Navigator.pop(context);
                          Get.showToast(
                            "Mobile number verified successfully",
                            type: ToastType.success,
                          );
                        } else {
                          // Show error message if verification failed
                          setState(() {
                            errorMessage = error;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
