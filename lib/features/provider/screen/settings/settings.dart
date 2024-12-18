import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pet/constants/sizes.dart';
import 'package:pet/common/widgets/section_heading/section_heading.dart';
import 'package:pet/data/repositories/authentication_repository.dart';
import 'package:pet/features/personalization/screens/profile/profile.dart';
import 'package:pet/features/personalization/screens/settings/widgets/settings_menu_tile.dart';
import 'package:pet/features/personalization/screens/settings/widgets/user_profile_card.dart';
import 'package:pet/features/provider/screen/settings/widgets/certificates.dart';
import 'package:pet/features/provider/screen/settings/widgets/my_reviews.dart';
import 'package:pet/features/provider/screen/settings/widgets/my_services.dart';
import 'package:pet/features/provider/screen/settings/widgets/privacy_policy.dart';
import 'package:pet/features/provider/screen/settings/widgets/term_and_conditions.dart';
import 'package:pet/utils/helpers/helpers.dart';
import '../../../../constants/colors.dart';
import '../../../personalization/controller/user_controller.dart';
import '../Provider shop/Provider_ShopScreen.dart';
import '../home/appointment/appointment.dart';
import '../order/order screen.dart';

class ProviderSettingScreen extends StatelessWidget {
  const ProviderSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());
    return Scaffold(
      backgroundColor: logoPurple,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // AppBar
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              title: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Account", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),),
              ),
            ),

            // Profile Card
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: UserProfileCard(onPressed: () => Get.to(()=> const ProfileScreen())),
            ),
            SizedBox(height: Sizes.s,),

            // Body
            Container(
              constraints: BoxConstraints(
                minHeight: HelpFunctions.screenHeight() - 70,
              ),
              width: HelpFunctions.screenWidth(),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(Sizes.defaultPadding),
                child: Column(
                  children: [
                    // Account Settings
                    const SectionHeading(title: "Account Settings", showActionButton: false,),
                    SizedBox(height: Sizes.s,),
                    SettingsMenuTile(icon: Iconsax.calendar_1, title: 'My Appointments',onTap:() => Get.to(() => AppointmentsScreen())),
                    SettingsMenuTile(icon: Iconsax.receipt, title: 'My Orders', onTap:() => Get.to(() => OrdersScreen())),
                    SettingsMenuTile(icon: Iconsax.star, title: 'My Reviews', onTap: () => Get.to(() => MyReviews()),),
                    SettingsMenuTile(icon: Iconsax.document, title: 'My Certificates', onTap:() => Get.to(() => CertificatePage())),
                    SettingsMenuTile(icon: Iconsax.task, title: 'My Listings', onTap: () => Get.to(() => ServicePage())),
                    const SettingsMenuTile(icon: Iconsax.book, title: 'My Blogs', ),
                    SettingsMenuTile(icon: Iconsax.box, title: 'My Products', onTap: () => Get.to(() => ProviderShopScreen())),
                    SettingsMenuTile(icon: Iconsax.lock, title: 'Privacy Policy', onTap: () => Get.to(() => PrivacyPolicyPage()),),
                    SettingsMenuTile(icon: Iconsax.document_code, title: 'Terms and Conditions', onTap: () => Get.to(() => TermsAndConditionsPage())),
                    const SettingsMenuTile(icon: Iconsax.star, title: 'Rate App', ),
                    const SettingsMenuTile(icon: Icons.contacts, title: 'Contact Us', ),
                    SettingsMenuTile(icon: Iconsax.logout, title: 'Logout', onTap: AuthenticationRepository.instance.logout),
                  ],
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}

