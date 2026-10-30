import 'package:ess/Ess_App/generated/assets.dart';
import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:ess/Ess_App/src/shared/bottons.dart';
import 'package:ess/Ess_App/src/shared/input_field.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:ess/Ess_App/src/views/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:stacked/stacked.dart';
import '../../services/local/navigation_service.dart';
import 'Login_with_biometric.dart';

class LoginView extends StatefulWidget {
  final String? msg;
  LoginView({Key? key, this.msg}) : super(key: key);
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LocalAuthentication auth = LocalAuthentication();
  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometrics;
  LoginViewModel model = LoginViewModel();

  @override
  void initState() {
    auth.isDeviceSupported().then((bool isSupported) => setState(
            () => supportState = isSupported
            ? SupportState.supported
            : SupportState.unSupported));
    super.initState();
    checkBiometric();
    getAvailableBiometrics();
  }

  Future<void> checkBiometric() async {
    late bool canCheckBiometric;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
      canCheckBiometric = false;
    }
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> biometricTypes;
    try {
      biometricTypes = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      availableBiometrics = biometricTypes;
    });
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate with fingerprint or Face ID',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (!mounted) return;
      if (authenticated) {
        model.LogIn(context);
      }
    } on PlatformException catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: Stack(
          children: [
            // ── Gradient background ─────────────────────────────────────────
            Container(
              height: context.screenSize().height * 0.45,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Back arrow
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () => NavService.appmenu(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Logo
                      Image.asset(
                        Assets.imagesPremierlogo,
                        height: 90,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome Back!',
                        style: TextStyling.bold22.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to continue',
                        style: TextStyling.text14
                            .copyWith(color: Colors.white.withOpacity(0.75)),
                      ),
                      const SizedBox(height: 32),

                      // ── Glass login card ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyling.bold14
                                  .copyWith(color: AppColors.darkGrey),
                            ),
                            const SizedBox(height: 8),
                            MainInputField(
                              hint: 'your@email.com',
                              controller: model.email,
                              inputType: TextInputType.emailAddress,
                              onChanged: (val) =>
                                  model.checkButtonValidate(context),
                              message: 'Please enter email address',
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Password',
                              style: TextStyling.bold14
                                  .copyWith(color: AppColors.darkGrey),
                            ),
                            const SizedBox(height: 8),
                            MainInputField(
                              hint: '••••••••',
                              controller: model.password,
                              isPassword: !model.isShowPassword,
                              onChanged: (val) =>
                                  model.checkButtonValidate(context),
                              message: 'Please enter password',
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: AppColors.primary, size: 20),
                              suffixIcon: InkWell(
                                onTap: () {
                                  model.isShowPassword = !model.isShowPassword;
                                  model.notifyListeners();
                                },
                                child: Icon(
                                  model.isShowPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Biometric toggle
                            if (model.checktabledata == false)
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Enable Touch ID',
                                    style: TextStyling.text12
                                        .copyWith(color: AppColors.darkGrey),
                                  ),
                                  Transform.scale(
                                    scale: 0.85,
                                    child: Switch(
                                      value: model.isSwitched,
                                      onChanged: (value) {
                                        model.isSwitched = value;
                                        model.notifyListeners();
                                      },
                                      activeColor: AppColors.primary,
                                      inactiveThumbColor: AppColors.grey,
                                      inactiveTrackColor:
                                      AppColors.lightGrey,
                                    ),
                                  ),
                                ],
                              ),

                            // Error message
                            if (widget.msg != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.error.withOpacity(0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: AppColors.error, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.msg!,
                                        style: TextStyling.text12.copyWith(
                                            color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Biometric login button
                            if (model.checktabledata == true &&
                                widget.msg == null) ...[
                              const SizedBox(height: 16),
                              Center(
                                child: InkWell(
                                  onTap: authenticateWithBiometrics,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: AppColors.primary
                                              .withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.fingerprint,
                                            color: AppColors.primary, size: 28),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Login with Touch ID',
                                          style: TextStyling.bold14.copyWith(
                                              color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 12),

                            // Login button
                            if (widget.msg == null)
                              MainButton(
                                text: 'Sign In',
                                isEnabled: model.isSignInButtonEnable,
                                isBusy: model.isBusy,
                                onTap: () => model.onLogIn(context),
                                icon: const Icon(Icons.login_rounded,
                                    color: Colors.white, size: 20),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      viewModelBuilder: () => LoginViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}
