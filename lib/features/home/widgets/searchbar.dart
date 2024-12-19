import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet/common/widgets/loaders/loaders.dart';
import 'package:pet/features/home/widgets/pet_shop.dart';
import '../../../constants/colors.dart';
import '../care screen/dental/dental_screen.dart';
import '../care screen/illness_and_injuries/illness_and_injuries.dart';
import '../care screen/litter_training/litter training.dart';
import '../care screen/pet_sitting/pet sitting.dart';
import '../care screen/pet_walking/pet walking.dart';
import '../care screen/routine_checkup/routinecheckup.dart';
import '../care screen/vaccination/vaccinescreen.dart';
import '../grooming screen/bathing_and_brushing/bathing_and_brushing.dart';
import '../grooming screen/deshedding/deshedding_and_haircutting.dart';
import '../grooming screen/styling/styling_and_touches.dart';

// Search Bar Widget with Embedded IconButton
class ServiceSearchBar extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  ServiceSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100.0),
            borderSide: const BorderSide(
              color: textColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100.0),
            borderSide: const BorderSide(
              color: textColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100.0),
            borderSide: const BorderSide(
              color: textColor,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0), // Adjusts height
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              final searchText = controller.text.toLowerCase().trim();
              final targetScreen = keywordToScreen[searchText];
              if (targetScreen != null) {
                // Navigate to the target screen
                Get.to(() => targetScreen);
              } else {
                // Show an error message if the service is not found
                Loaders.warningSnackBar(title: "Service not found", message: "No service matches your search query.");
              }
            },
          ),
        ),
      ),
    );
  }
}

// Keyword-to-Screen Mapping
final Map<String, Widget> keywordToScreen = {
  // Pet Shop
  "pet food": const PetShop(),
  "food": const PetShop(),
  "products": const PetShop(),
  "pet shop": const PetShop(),

  // Grooming Services
  "bathing": const BathingAndBrushing(),
  "brushing": const BathingAndBrushing(),
  "deshedding": const DesheddingAndCutting(),
  "haircutting": const DesheddingAndCutting(),
  "styling": const StylingAndTouches(),
  "finishing touches": const StylingAndTouches(),

  // Care Services
  "vaccination":  VaccinationScreen(),
  "dental care": const DentalCare(),
  "routine checkup": const RoutineCheckup(),
  "illness and injuries": const IllnessAndInjuries(),
  "treatment of illness": const IllnessAndInjuries(),
  "pet sitting": const PetSitting(),
  "pet walking": const PetWalking(),
  "litter training": const LitterTraining(),
  "training": const LitterTraining(),

  // Miscellaneous Keywords
  "checkup": const RoutineCheckup(),
  "illness": const IllnessAndInjuries(),
  "injuries": const IllnessAndInjuries(),
  "walking": const PetWalking(),
  "sitting": const PetSitting(),
  "care": const RoutineCheckup(),
};

