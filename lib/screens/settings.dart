import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/database.dart';
import '../theme/app_theme.dart';
import 'aboutus.dart';
import 'faq.dart';

const _walnut = Color(0xFF8B5A2B);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _displayName = '';
  String _email = '';
  double _budget = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    themeModeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final data = await DatabaseService.getCurrentUserData();
    if (!mounted) return;
    setState(() {
      _displayName = data?['displayName'] ?? '';
      _email = data?['email'] ?? '';
      _budget = (data?['budget'] ?? 0).toDouble();
      _loading = false;
    });
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _displayName);
    final emailCtrl = TextEditingController(text: _email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: BoxDecoration(
                color: AppColors.of(ctx).modal,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.of(ctx).border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: AppColors.of(ctx).onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: nameCtrl,
                    label: 'Display Name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _walnut,
                        disabledBackgroundColor: _walnut.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: saving
                          ? null
                          : () async {
                              setModalState(() => saving = true);
                              await DatabaseService.updateUserProfile(
                                displayName: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                              );
                              if (mounted) {
                                setState(() {
                                  _displayName = nameCtrl.text.trim();
                                  _email = emailCtrl.text.trim();
                                });
                              }
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    final c = AppColors.of(context);
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: c.onSurface, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: c.subtext, fontSize: 13),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: _walnut, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: c.subtext,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _walnut, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final c = AppColors.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: c.onSurface, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: c.subtext, fontSize: 13),
        prefixIcon: Icon(icon, color: _walnut, size: 20),
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _walnut, width: 1.5),
        ),
      ),
    );
  }

  void _showChangePasswordModal() {
    final user = FirebaseAuth.instance.currentUser;
    final hasPasswordProvider =
        user?.providerData.any((p) => p.providerId == 'password') ?? false;

    if (!hasPasswordProvider) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Password change is not available for Google Sign-In accounts.'),
        ),
      );
      return;
    }

    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool step2 = false;
        bool saving = false;
        String? errorMsg;
        bool obscureCurrent = true;
        bool obscureNew = true;
        bool obscureConfirm = true;

        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: BoxDecoration(
                color: AppColors.of(ctx).modal,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.of(ctx).border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      step2 ? 'Set New Password' : 'Verify Identity',
                      style: TextStyle(
                        color: AppColors.of(ctx).onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      step2
                          ? 'Enter and confirm your new password.'
                          : 'Enter your current password to continue.',
                      style: TextStyle(color: AppColors.of(ctx).subtext, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!step2)
                    _buildPasswordField(
                      controller: currentPassCtrl,
                      label: 'Current Password',
                      obscure: obscureCurrent,
                      onToggle: () =>
                          setModalState(() => obscureCurrent = !obscureCurrent),
                    )
                  else ...[  
                    _buildPasswordField(
                      controller: newPassCtrl,
                      label: 'New Password',
                      obscure: obscureNew,
                      onToggle: () =>
                          setModalState(() => obscureNew = !obscureNew),
                    ),
                    const SizedBox(height: 14),
                    _buildPasswordField(
                      controller: confirmPassCtrl,
                      label: 'Confirm New Password',
                      obscure: obscureConfirm,
                      onToggle: () =>
                          setModalState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ],
                  if (errorMsg != null) ...[  
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                Colors.red.shade800.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: Colors.red.shade400, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMsg!,
                              style: TextStyle(
                                  color: Colors.red.shade300, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _walnut,
                        disabledBackgroundColor:
                            _walnut.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: saving
                          ? null
                          : () async {
                              setModalState(
                                  () { saving = true; errorMsg = null; });

                              if (!step2) {
                                if (currentPassCtrl.text.isEmpty) {
                                  setModalState(() {
                                    errorMsg =
                                        'Please enter your current password.';
                                    saving = false;
                                  });
                                  return;
                                }
                                final err =
                                    await AuthService.verifyCurrentPassword(
                                        currentPassCtrl.text);
                                if (err != null) {
                                  setModalState(() {
                                    errorMsg = err;
                                    saving = false;
                                  });
                                } else {
                                  setModalState(() {
                                    step2 = true;
                                    saving = false;
                                  });
                                }
                              } else {
                                if (newPassCtrl.text.length < 6) {
                                  setModalState(() {
                                    errorMsg =
                                        'Password must be at least 6 characters.';
                                    saving = false;
                                  });
                                  return;
                                }
                                if (newPassCtrl.text !=
                                    confirmPassCtrl.text) {
                                  setModalState(() {
                                    errorMsg = 'Passwords do not match.';
                                    saving = false;
                                  });
                                  return;
                                }
                                final err = await AuthService.applyNewPassword(
                                    newPassCtrl.text);
                                if (err != null) {
                                  setModalState(() {
                                    errorMsg = err;
                                    saving = false;
                                  });
                                } else {
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Password changed successfully.'),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              step2 ? 'Change Password' : 'Continue',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBudgetModal() {
    final budgetCtrl = TextEditingController(
      text: _budget > 0 ? _budget.toStringAsFixed(0) : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool saving = false;
        String? errorMsg;
        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: BoxDecoration(
                color: AppColors.of(ctx).modal,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.of(ctx).border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Budget Settings',
                      style: TextStyle(
                        color: AppColors.of(ctx).onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Set your default budget per meal in Philippine Peso.',
                      style: TextStyle(color: AppColors.of(ctx).subtext, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: budgetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    style: TextStyle(color: AppColors.of(ctx).onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Budget per meal',
                      labelStyle: TextStyle(color: AppColors.of(ctx).subtext, fontSize: 13),
                      prefixIcon: const Icon(Icons.attach_money_rounded, color: _walnut, size: 20),
                      prefixText: '₱ ',
                      prefixStyle: TextStyle(color: AppColors.of(ctx).onSurface, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.of(ctx).surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.of(ctx).border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.of(ctx).border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _walnut, width: 1.5),
                      ),
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade800.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMsg!,
                              style: TextStyle(color: Colors.red.shade300, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _walnut,
                        disabledBackgroundColor: _walnut.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: saving
                          ? null
                          : () async {
                              final parsed = double.tryParse(budgetCtrl.text.trim());
                              if (parsed == null || parsed <= 0) {
                                setModalState(() => errorMsg = 'Please enter a valid budget amount.');
                                return;
                              }
                              setModalState(() { saving = true; errorMsg = null; });
                              await DatabaseService.updateBudget(parsed);
                              budgetNotifier.value = parsed;
                              if (mounted) setState(() => _budget = parsed);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Save Budget',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPrivacyPolicyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.of(ctx).modal,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.of(ctx).border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _walnut.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.privacy_tip_outlined, color: _walnut, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.of(ctx).onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Effective Date: May 11, 2026',
                                style: TextStyle(color: AppColors.of(ctx).subtext, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: AppColors.of(ctx).divider),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  children: const [
                    _PolicySection(
                      number: '1',
                      title: 'Introduction',
                      body:
                          'Welcome to Savr. At Savr, we respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application ("App") and any related services. Please read this Privacy Policy carefully. By using Savr, you consent to the data practices described in this document.',
                    ),
                    _PolicySection(
                      number: '2',
                      title: 'Information We Collect',
                      body:
                          'We collect information to provide better services to our users. The types of information we collect include:',
                      bullets: [
                        _Bullet('Personal Data', 'When you register for an account, we collect personally identifiable information, such as your email address, name, and profile picture (if provided).'),
                        _Bullet('Usage Data', 'We automatically collect information regarding your interactions with the App, including recipes viewed, budgets created, features utilized, and access times.'),
                        _Bullet('Device Data', 'We may collect specific information about your mobile device, including the hardware model, operating system version, unique device identifiers, and mobile network information.'),
                        _Bullet('App Data', 'Any data you input into the app, such as custom recipes, grocery lists, budgetary constraints, and preferences, is stored securely.'),
                      ],
                    ),
                    _PolicySection(
                      number: '3',
                      title: 'How We Use Your Information',
                      body: 'We use the information we collect for various purposes, including to:',
                      bullets: [
                        _Bullet('Provide and Maintain the App', 'To manage your account, authenticate users, and ensure the core functionalities of Savr operate correctly.'),
                        _Bullet('Personalize User Experience', 'To tailor recipes, budget recommendations, and content based on your interactions and preferences.'),
                        _Bullet('Improve Our Services', 'To analyze usage trends, troubleshoot issues, and develop new features to enhance the Savr experience.'),
                        _Bullet('Communicate with You', 'To send you updates, security alerts, support messages, and administrative notifications (such as password reset emails).'),
                        _Bullet('Protect Our Users', 'To deter fraudulent, unauthorized, or illegal activities within the App.'),
                      ],
                    ),
                    _PolicySection(
                      number: '4',
                      title: 'How We Share Your Information',
                      body: 'We do not sell your personal data to third parties. We may share your information only in the following situations:',
                      bullets: [
                        _Bullet('Service Providers', 'We may share data with trusted third-party vendors (such as Google Firebase for database hosting and authentication) who assist us in operating our App and conducting our business, provided those parties agree to keep this information confidential.'),
                        _Bullet('Legal Requirements', 'We may disclose your information if required to do so by law or in response to valid requests by public authorities (e.g., a court or a government agency).'),
                        _Bullet('Business Transfers', 'In the event of a merger, acquisition, or asset sale, your personal data may be transferred. We will provide notice before your personal data is transferred and becomes subject to a different Privacy Policy.'),
                      ],
                    ),
                    _PolicySection(
                      number: '5',
                      title: 'Data Security',
                      body:
                          'We prioritize the security of your data. We implement commercially reasonable technical and organizational measures (including utilizing secure Firebase infrastructure) to protect your personal information against unauthorized access, loss, destruction, or alteration. However, no method of transmission over the internet or method of electronic storage is 100% secure, and we cannot guarantee absolute security.',
                    ),
                    _PolicySection(
                      number: '6',
                      title: 'Data Retention',
                      body:
                          'We will retain your personal information only for as long as is necessary for the purposes set out in this Privacy Policy, or as required by legal obligations. If you request account deletion, we will remove your personal data from our active databases, subject to any legal requirements to retain certain information.',
                    ),
                    _PolicySection(
                      number: '7',
                      title: "Children's Privacy",
                      body:
                          "Savr does not knowingly collect or solicit personal information from anyone under the age of 13. If you are a parent or guardian and believe we have collected information from your child, please contact us. If we learn that we have collected personal information from a child under age 13 without verification of parental consent, we will delete that information as quickly as possible.",
                    ),
                    _PolicySection(
                      number: '8',
                      title: 'Changes to This Privacy Policy',
                      body:
                          'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Effective Date" at the top of this document. You are advised to review this Privacy Policy periodically for any changes.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildSection('Account', [
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              subtitle: 'Name, email',
              onTap: _showEditProfileModal,
            ),
            _SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'Change Password',
              onTap: _showChangePasswordModal,
            ),
            _SettingsTile(
              icon: Icons.attach_money_rounded,
              title: 'Budget Settings',
              subtitle: 'Adjust your default meal budget',
              onTap: _showBudgetModal,
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection('Preferences', [
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: themeModeNotifier.value == ThemeMode.dark ? 'Dark mode' : 'Light mode',
              trailing: Switch(
                value: themeModeNotifier.value == ThemeMode.dark,
                onChanged: (v) => themeModeNotifier.value = v ? ThemeMode.dark : ThemeMode.light,
                activeThumbColor: _walnut,
                inactiveThumbColor: _walnut,
                activeTrackColor: _walnut.withValues(alpha: 0.4),
                inactiveTrackColor: const Color(0xFFDDDDDD),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection('About', [
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'About Savr',
              subtitle: 'Version 1.0.0',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & FAQ',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaqPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: _showPrivacyPolicyModal,
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final initial = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.of(context).border, width: 1),
      ),
      child: _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: _walnut, strokeWidth: 2),
              ),
            )
          : Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _walnut,
                    border: Border.all(color: const Color(0xFFAD7244), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName.isNotEmpty ? _displayName : 'User',
                        style: TextStyle(
                          color: AppColors.of(context).onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _email,
                        style: TextStyle(color: AppColors.of(context).subtext, fontSize: 12),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Budget: ₱${_budget.toStringAsFixed(2)} / meal',
                        style: const TextStyle(
                          color: _walnut,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: _walnut, size: 20),
                  onPressed: _showEditProfileModal,
                ),
              ],
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: _walnut,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.of(context).surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.of(context).border, width: 1),
          ),
          child: Column(
            children: tiles
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < tiles.length - 1)
                          Divider(
                              height: 1,
                              color: AppColors.of(context).divider,
                              indent: 52),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.number,
    required this.title,
    required this.body,
    this.bullets = const [],
  });

  final String number;
  final String title;
  final String body;
  final List<_Bullet> bullets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _walnut.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: _walnut,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.of(context).onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(color: AppColors.of(context).subtext, fontSize: 13, height: 1.6),
          ),
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, color: _walnut, size: 5),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${b.term}: ',
                              style: TextStyle(
                                color: AppColors.of(context).onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: b.description,
                              style: TextStyle(
                                color: AppColors.of(context).subtext,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _Bullet {
  const _Bullet(this.term, this.description);
  final String term;
  final String description;
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.of(context).background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _walnut, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(color: AppColors.of(context).onSurface, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: AppColors.of(context).subtext, fontSize: 12))
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded, color: AppColors.of(context).subtext, size: 20)
              : null),
    );
  }
}
