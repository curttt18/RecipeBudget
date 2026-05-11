import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'loading_screen.dart';
import 'login.dart';

const _black = Color(0xFF1A1A1A);
const _charcoal = Color(0xFF2C2C2C);
const _walnut = Color(0xFF8B5A2B);
const _white = Colors.white;
const _grey = Color(0xFF9E9E9E);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  late final AnimationController _slashController;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final error = await AuthService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      budget: double.parse(_budgetController.text),
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoadingScreen()),
        (_) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _slashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat();
  }

  @override
  void dispose() {
    _slashController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _slashController,
            builder: (context, _) => SizedBox.expand(
              child: CustomPaint(
                painter: _SlashPainter(_slashController.value),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _LogoImage(),
                  const SizedBox(height: 18),
                  
                  const SizedBox(height: 10),
                  const Text(
                    '"Empowering home cooks to eat well and spend wisely."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _grey,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const _SectionDivider(),
                  const SizedBox(height: 28),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: _white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Join Savr and start saving today.',
                      style: TextStyle(color: _grey, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _Field(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscurePass,
                          suffixIcon: _VisibilityToggle(
                            obscure: _obscurePass,
                            onTap: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Password must be at least 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          controller: _confirmController,
                          label: 'Confirm Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscureConfirm,
                          suffixIcon: _VisibilityToggle(
                            obscure: _obscureConfirm,
                            onTap: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) => v != _passwordController.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          controller: _budgetController,
                          label: 'Starting Meal Budget',
                          icon: Icons.attach_money_rounded,
                          keyboardType: TextInputType.number,
                          prefix: const Text(
                            '\$ ',
                            style: TextStyle(
                                color: _walnut,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Budget is required';
                            }
                            final n = double.tryParse(v);
                            if (n == null || n < 0) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0x33E57373),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0x88E57373), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Color(0xFFE57373), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                        color: Color(0xFFE57373), fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ] else
                          const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _walnut,
                              disabledBackgroundColor:
                                  const Color(0xFF6B4420),
                              foregroundColor: _white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: _white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?  ',
                              style: TextStyle(color: _grey, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                              ),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  color: _walnut,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slash background painter ──────────────────────────────────────────────────

class _SlashPainter extends CustomPainter {
  _SlashPainter(this.progress);
  final double progress;

  // Each entry: [phase, duration, x1r, y1r, x2r, y2r, strokeWidth]
  // 10 individual slashes — all angles, varied thickness, some overlap.
  static const _defs = [
    // 1. Horizontal, thin — upper band. Overlaps with #2.
    [0.00, 0.17, -0.10, 0.18,  1.10, 0.18, 0.9],
    // 2. ~38° right diagonal, thick — left edge to center. Overlaps with #1.
    [0.10, 0.18, -0.10, 0.05,  0.80, 0.75, 3.2],
    // 3. Vertical, medium — left-center column. Overlaps with #4.
    [0.28, 0.17,  0.22, -0.05, 0.22, 1.05, 1.5],
    // 4. ~35° left diagonal, thin — upper-right to lower-left. Overlaps with #3.
    [0.35, 0.17,  1.10, 0.10,  0.15, 0.75, 1.0],
    // 5. Nearly horizontal, thick — lower band, slight tilt. Overlaps with #6.
    [0.50, 0.17, -0.10, 0.65,  1.10, 0.70, 2.5],
    // 6. ~33° left diagonal, medium — top-right to mid-left. Overlaps with #5.
    [0.55, 0.17,  1.10, 0.08,  0.30, 0.60, 1.6],
    // 7. Near-vertical (~83°), thin — right side. Overlaps with #8.
    [0.65, 0.17,  0.75, -0.05, 0.82, 1.05, 0.8],
    // 8. Vertical, thick — center-right column. Overlaps with #7.
    [0.72, 0.17,  0.60, -0.05, 0.60, 1.05, 3.0],
    // 9. ~12° shallow right diagonal, medium — sweeps low. Overlaps with #10.
    [0.83, 0.17, -0.10, 0.82,  1.10, 0.55, 1.4],
    // 10. ~80° steep right diagonal, thin — far-right edge. Overlaps with #9.
    [0.90, 0.17,  0.88, -0.05, 1.05, 0.90, 1.1],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in _defs) {
      final phase = d[0];
      final dur   = d[1];
      final x1    = d[2] * size.width;
      final y1    = d[3] * size.height;
      final x2    = d[4] * size.width;
      final y2    = d[5] * size.height;
      final sw    = d[6];

      var local = (progress - phase) % 1.0;
      if (local < 0) local += 1.0;
      final t = local / dur;
      if (t > 1.0) continue;

      final double drawP;
      final double alpha;
      if (t < 0.55) {
        drawP = t / 0.55;
        alpha = drawP * 0.38;
      } else {
        drawP = 1.0;
        alpha = (1.0 - (t - 0.55) / 0.45) * 0.38;
      }

      final ex = x1 + (x2 - x1) * drawP;
      final ey = y1 + (y2 - y1) * drawP;

      // Soft glow behind the slash
      canvas.drawLine(
        Offset(x1, y1),
        Offset(ex, ey),
        Paint()
          ..color = Color.fromRGBO(139, 90, 43, alpha * 0.45)
          ..strokeWidth = sw * 5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Sharp slash line
      canvas.drawLine(
        Offset(x1, y1),
        Offset(ex, ey),
        Paint()
          ..color = Color.fromRGBO(139, 90, 43, alpha)
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_SlashPainter old) => old.progress != progress;
}

// ── Logo ──────────────────────────────────────────────────────────────────────

class _LogoImage extends StatelessWidget {
  const _LogoImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _walnut, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x408B5A2B),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/mainlogo.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefix,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _grey, fontSize: 13),
        prefixIcon: Icon(icon, color: _walnut, size: 20),
        prefix: prefix,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _charcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _walnut, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscure, required this.onTap});
  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: _grey,
        size: 20,
      ),
      onPressed: onTap,
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: _charcoal, thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.restaurant, color: _walnut, size: 14),
        ),
        Expanded(child: Divider(color: _charcoal, thickness: 1)),
      ],
    );
  }
}
