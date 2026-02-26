import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class PurchaseCoinsPage extends StatefulWidget {
  const PurchaseCoinsPage({super.key});

  @override
  State<PurchaseCoinsPage> createState() => _PurchaseCoinsPageState();
}

class _PurchaseCoinsPageState extends State<PurchaseCoinsPage> {
  int _selectedIndex = 2;
  final RxBool _isProcessing = false.obs;

  static const List<Map<String, dynamic>> _packages = [
    {'id': 'pkg_100', 'coins': 100, 'bonus': 0, 'price': '\$0.99', 'popular': false},
    {'id': 'pkg_500', 'coins': 500, 'bonus': 0, 'price': '\$4.99', 'popular': false},
    {'id': 'pkg_1000', 'coins': 1000, 'bonus': 100, 'price': '\$9.99', 'popular': true},
    {'id': 'pkg_2500', 'coins': 2500, 'bonus': 300, 'price': '\$24.99', 'popular': false},
    {'id': 'pkg_5000', 'coins': 5000, 'bonus': 800, 'price': '\$49.99', 'popular': false},
    {'id': 'pkg_10000', 'coins': 10000, 'bonus': 2000, 'price': '\$99.99', 'popular': false},
  ];

  Future<void> _purchase() async {
    _isProcessing.value = true;
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Get.snackbar('Purchase Successful!', '${_packages[_selectedIndex]['coins']} coins added to your wallet', backgroundColor: AppTheme.successColor.withOpacity(0.9));
        context.pop();
      }
    } catch (e) {
      Get.snackbar('Purchase Failed', 'Please try again', backgroundColor: AppTheme.errorColor.withOpacity(0.9));
    } finally {
      _isProcessing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Buy Coins'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.toll, color: AppTheme.goldColor, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tango Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          const Text('Use coins to send gifts and support creators', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Select a Package', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _packages.length,
                  itemBuilder: (_, i) => _buildPackageTile(i),
                ),
              ],
            ),
          ),
          _buildPurchaseButton(),
        ],
      ),
    );
  }

  Widget _buildPackageTile(int index) {
    final pkg = _packages[index];
    final isSelected = _selectedIndex == index;
    final hasBonus = (pkg['bonus'] as int) > 0;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (pkg['popular'] as bool)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(8)),
                  child: const Text('BEST', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.toll, color: AppTheme.goldColor, size: 28),
                const SizedBox(height: 8),
                Text('${pkg['coins']}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                if (hasBonus) ...[
                  const SizedBox(height: 2),
                  Text('+${pkg['bonus']} bonus', style: const TextStyle(color: AppTheme.successColor, fontSize: 11)),
                ],
                const SizedBox(height: 6),
                Text(pkg['price'] as String, style: TextStyle(color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    final pkg = _packages[_selectedIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.dividerDark)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${pkg['coins']} Coins${(pkg['bonus'] as int) > 0 ? ' + ${pkg['bonus']} Bonus' : ''}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text(pkg['price'] as String, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => GradientButton(
            onPressed: _isProcessing.value ? null : _purchase,
            isLoading: _isProcessing.value,
            child: Text('Purchase ${pkg['price']}'),
          )),
        ],
      ),
    );
  }
}
