import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../providers/subscription_provider.dart';

class SubscriptionPopup extends StatefulWidget {
  final bool canRestore;
  const SubscriptionPopup({super.key, required this.canRestore});

  @override
  State<SubscriptionPopup> createState() => _SubscriptionPopupState();
}

class _SubscriptionPopupState extends State<SubscriptionPopup> {
  bool isYearlySelected = false;
  Offerings? _offerings;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();

  }
  Future<void> _initialize() async {
    await _fetchOfferings();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      setState(() {
        _offerings = offerings;
      });
    } catch (e) {
      //
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      backgroundColor: const Color(0xffbaa4f5),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _purchasePackage(Package package) async {
    var localizations = AppLocalizations.of(context)!;
    setState(() {
      _isPurchasing = true;
    });
    try {
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(package);
      bool isPro = purchaserInfo.entitlements.all["Premium"]?.isActive ?? false;
      if (isPro) {
        if (mounted) {
          Provider.of<SubscriptionProvider>(context, listen: false)
              .setIsSubscribed(true);
          Navigator.of(context).pop();
          _showSnackBar(localizations.sub_activated);
        }
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        _showSnackBar(localizations.purchase_cancelled);
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        _showSnackBar(localizations.already_sub);
        } else {
        _showSnackBar(localizations.unknown_error);
      }
    } catch (e) {
      _showSnackBar(localizations.unknown_error);
    } finally {
      setState(() {
        _isPurchasing = false;
      });
    }
  }

  void _restorePurchases() async {
    var localizations = AppLocalizations.of(context)!;
    setState(() {
      _isRestoring = true;
    });
    try {
      CustomerInfo purchaserInfo = await Purchases.restorePurchases();
      bool isPro = purchaserInfo.entitlements.all["Premium"]?.isActive ?? false;
      Provider.of<SubscriptionProvider>(context, listen: false)
          .setIsSubscribed(isPro);
      if (isPro) {
        _showSnackBar(localizations.restored);
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar(localizations.cant_restore);
    } finally {
      setState(() {
        _isRestoring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      elevation: 10,
      child: Stack(
        children: [
          _buildChild(context),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 30, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    Package? monthly;
    Package? annual;
    if (_offerings != null) {
      monthly = _offerings!.getOffering("premium")!.monthly;
      annual = _offerings!.getOffering("premium")!.annual;
    }

    return Container(
      height: localizations.localeName != 'en' ? 690 : 660 ,
      decoration: BoxDecoration(
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
      child: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          const Icon(
            Icons.star_border,
            size: 50,
            color: Color(0xffbaa4f5),
          ),
          const SizedBox(height: 10),
          Text(
            localizations.unlock_premium,
            style: const TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Colors.white,
            indent: 20,
            endIndent: 20,
            height: 10,
            thickness: 2,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        localizations.faster,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.block, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        localizations.ad_free,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SubscriptionOption(
              title: localizations.monthly,
              price:
              _isLoading ? "" : monthly != null ? "${monthly.storeProduct.priceString} / ${localizations.month}" : "€3.99 / ${localizations.month}",
              isSelected: !isYearlySelected,
              onPressed: () {
                setState(() {
                  isYearlySelected = false;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SubscriptionOption(
              title: localizations.yearly,
              price:
                 _isLoading ? "" : annual != null ? "${annual.storeProduct.priceString} / ${localizations.year}" : "€29.99 / ${localizations.year}" ,
              description: "${localizations.save} ~37%",
              isSelected: isYearlySelected,
              onPressed: () {
                setState(() {
                  isYearlySelected = true;
                });
              },
            ),
          ),
          const SizedBox(height: 30,),
          MaterialButton(
            minWidth: 280,
            height: 50,
            color: const Color(0xff7b68ad),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: () {
              if (isYearlySelected) {
                if(annual != null){
                  _purchasePackage(annual);
                } else {
                  Navigator.of(context).pop();
                  _showSnackBar(localizations.error_internet);
                }
              } else {
                if(monthly != null) {
                  _purchasePackage(monthly);
                } else {
                  Navigator.of(context).pop();
                  _showSnackBar(localizations.error_internet);
                }
              }
            },
            child: _isPurchasing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    localizations.continue_,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
          widget.canRestore ? _isRestoring
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : TextButton(
                  onPressed: _restorePurchases,
                  child: Text(
                    localizations.restore,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ) : const SizedBox(height: 30,),
          Text(
            textAlign: TextAlign.center,
            localizations.billing,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              textAlign: TextAlign.center,
              localizations.sub_info,
              style: const TextStyle(color: Colors.white, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionOption extends StatelessWidget {
  final String title;
  final String price;
  final String? description;
  final bool isSelected;
  final VoidCallback onPressed;

  const SubscriptionOption({
    super.key,
    required this.title,
    required this.price,
    this.description,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.black.withOpacity(0.3)
                  : Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          color: isSelected ? Colors.purple.shade100 : Colors.black26,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.black,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.purple : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: TextStyle(
                      color: isSelected ? Colors.purple : Colors.white,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              price,
              style: TextStyle(
                color: isSelected ? Colors.purple : Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
