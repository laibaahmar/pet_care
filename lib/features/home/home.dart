import 'package:flutter/material.dart';
import 'package:pet/common/widgets/section_heading/section_heading.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/constants/sizes.dart';
import 'package:pet/features/home/widgets/community.dart';
import 'package:pet/features/home/widgets/consult.dart';
import 'package:pet/features/home/widgets/pet_services.dart';
import 'package:pet/features/home/widgets/searchbar.dart';
import 'package:pet/utils/helpers/helpers.dart';
import 'app_bar.dart';
import 'package:get/get.dart';

import 'appointment/appointmentScreen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logoPurple,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: HelpFunctions.screenWidth(),
              child: const MyAppBar(),
            ),

            // Search Bar
            const Searchbar(),
            SizedBox(height: Sizes.defaultPadding,),

            Container(
              width: HelpFunctions.screenWidth(),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0), // Adjust the radius as needed
                  topRight: Radius.circular(20.0), // Adjust the radius as needed
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(Sizes.defaultPadding),
                child: Column(
                    children: [
                      // Consult
                      SizedBox(height: Sizes.s*1.5,),
                      const SectionHeading(title: "Consult", showActionButton: false,),
                      SizedBox(height: Sizes.s*1.5,),
                      const ConsultSection(),
                      SizedBox(height: Sizes.m,),

                      // Services
                      const SectionHeading(title: "Services", showActionButton: false,),
                      SizedBox(height: Sizes.s*1.5,),
                      const PetServicesSection(),
                      SizedBox(height: Sizes.m,),

                      const SectionHeading(title: "Appointment Details", showActionButton: false,),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), color: logoPurple.withOpacity(0.1)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("See Appointment Details"),
                                // IconButton(onPressed: () => Get.to(AppointmentScreen()), icon: Icon(Icons.arrow_forward, color: textColor)),
                                IconButton(onPressed: () => Get.to(AppointmentScreen()), icon: Icon(Icons.arrow_forward, color: textColor))
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Community
                      const SectionHeading(title: "Community", showActionButton: false,),
                      SizedBox(height: Sizes.s*1.5,),
                      const Community(),
                      SizedBox(height: Sizes.m,),
                    ]
                ),
              ),
            )],
        ),
      ),
    );
  }
}
