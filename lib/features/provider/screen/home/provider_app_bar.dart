import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../chat/chatController.dart';
import '../../../chat/chatListScreen.dart';
import '../../../personalization/controller/user_controller.dart';

class ProviderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProviderAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final _controller = Get.put(ChatController());

    return AppBar(
      toolbarHeight: 70,
      backgroundColor: logoPurple,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(left: Sizes.s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Dashboard",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                // Message Icon with Unread Count
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
                    // Display unread message count if greater than 0
                    Obx(() {
                      return Get.find<ChatController>().unreadMessageCount.value > 0
                          ? Positioned(
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
                      )
                          : Container(); // No badge if no unread messages
                    }),
                  ],
                ),
                // Notification Icon
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.notification),
                      color: Colors.white,
                    ),
                    Positioned(
                      right: 5,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: logoPink,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text('2', style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
