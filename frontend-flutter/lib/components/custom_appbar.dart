import 'package:flutter/material.dart';
import 'package:frontend_flutter/components/subscription_dialog.dart';
import 'package:frontend_flutter/pages/manage_sub_page.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'package:frontend_flutter/utils/languages_utils.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? action;

  const MyAppBar({super.key, required this.title, this.action});

  
  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        title: Text(title, style: TextStyle(fontSize: calculateFontSize(title))),
        actions: [
          if (action != null && action!)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3A0CA3), // Deep Purple
                        Color(0xFF4E0D7A), // Dark Violet
                        Color(0xFF2C003E), // Dark Plum
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      subscriptionProvider.isSubscribed
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SubscriptionManagementPage()),
                            )
                          : showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Subscription',
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                              pageBuilder: (context, anim1, anim2) {
                                return const SubscriptionPopup(canRestore: true,);
                              },
                              transitionBuilder:
                                  (context, anim1, anim2, child) {
                                return SlideTransition(
                                  position: Tween(
                                          begin: const Offset(0, -1),
                                          end: const Offset(0, 0.01))
                                      .animate(anim1),
                                  child: child,
                                );
                              },
                            );
                    },
                    child: Container(
                      width: 50,
                      height: 30,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.star_border,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
