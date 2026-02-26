import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_button.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  String _selectedMethod = 'paypal';
  final RxBool _isSubmitting = false.obs;

  static const _methods = [
    {'id': 'paypal', 'label': 'PayPal', 'icon': Icons.payment},
    {'id': 'bank_transfer', 'label': 'Bank Transfer', 'icon': Icons.account_balance},
    {'id': 'stripe', 'label': 'Stripe', 'icon': Icons.credit_card},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _isSubmitting.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Get.snackbar('Request Submitted', 'Processing within 3-5 business days', backgroundColor: AppTheme.successColor.withOpacity(0.9));
        context.pop();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit withdrawal request', backgroundColor: AppTheme.errorColor.withOpacity(0.9));
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Withdraw'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Icon(Icons.diamond, color: AppTheme.accentLight, size: 28),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Diamonds', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text('0', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Min. 100 diamonds to withdraw', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Select Method', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...(_methods.map((m) => _buildMethodTile(m)).toList()),
              const SizedBox(height: 24),
              AppTextField(
                controller: _amountController,
                label: 'Amount (Diamonds)',
                hint: 'Enter amount (min. 100)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.diamond,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount is required';
                  final n = int.tryParse(v);
                  if (n == null || n < 100) return 'Minimum 100 diamonds';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _accountController,
                label: 'Account Details',
                hint: 'Email / Account number',
                prefixIcon: Icons.account_circle_outlined,
                validator: (v) => (v == null || v.isEmpty) ? 'Account details are required' : null,
              ),
              const SizedBox(height: 12),
              const Text('Exchange rate: 100 Diamonds = \$0.50 USD (approx)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 32),
              Obx(() => GradientButton(
                onPressed: _isSubmitting.value ? null : _submit,
                isLoading: _isSubmitting.value,
                child: const Text('Submit Withdrawal Request'),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTile(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method['id'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.dividerDark),
        ),
        child: Row(
          children: [
            Icon(method['icon'] as IconData, color: isSelected ? AppTheme.primaryColor : Colors.white),
            const SizedBox(width: 12),
            Text(method['label'] as String, style: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.white, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
