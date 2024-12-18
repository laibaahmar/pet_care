import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../common/widgets/shimmer/shimmer_effect.dart';
import '../chat/chatController.dart';
import '../chat/chatListScreen.dart';
import '../personalization/controller/user_controller.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
const MyAppBar ({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final _controller = Get.put(ChatController());
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(left: Sizes.s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Hello!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: text2)),
                  ],
                ),
                Obx(() {
                  if(controller.profileLoading.value) {
                    return const ShimmerEffect(width: 80, height: 15);
                  }
                  return Text(controller.user.value.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: text2));
                }),

              ],
            ),
            Row(
              children: [
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Iconsax.message, color: Colors.white),
                      onPressed: () {
                        Get.to(() => ChatListScreen(isProvider: true));
                        // Reset unread count when navigating to chat
                        Get.find<ChatController>().resetUnreadCount();
                      },
                    ),
                    if (Get.find<ChatController>().unreadMessageCount.value > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            '${Get.find<ChatController>().unreadMessageCount.value}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                // Stack(
                //   children: [
                //     IconButton(onPressed: () {}, icon: const Icon(Iconsax.notification), color: text2,),
                //     Positioned(
                //       right: 5,
                //       child: Container(
                //         width: 18,
                //         height: 18,
                //         decoration: BoxDecoration(
                //           color: logoPink,
                //           borderRadius: BorderRadius.circular(100),
                //         ),
                //         child: const Center(
                //           child: Text('2', style: TextStyle(fontSize: 12, color: text2)),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

