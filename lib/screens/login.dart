import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import 'register.dart';
import 'loading_screen.dart';

const _black = Color(0xFF1A1A1A);
const _charcoal = Color(0xFF2C2C2C);
const _walnut = Color(0xFF8B5A2B);
const _white = Colors.white;
const _grey = Color(0xFF9E9E9E);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePass = true;
  late final AnimationController _slashController;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordSheet() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    String? errorMsg;
    bool sending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                      color: _white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter your email and we'll send a reset link.",
                    style: TextStyle(color: _grey, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: _white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: _grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.email_outlined, color: _walnut, size: 20),
                    filled: true,
                    fillColor: _charcoal,
                    errorText: errorMsg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _walnut, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                    onPressed: sending
                        ? null
                        : () async {
                            setModalState(() {
                              sending = true;
                              errorMsg = null;
                            });
                            final error = await AuthService.resetPassword(emailCtrl.text);
                            if (ctx.mounted) {
                              if (error == null) {
                                Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Reset link sent — check your inbox.'),
                                    ),
                                  );
                                }
                              } else {
                                setModalState(() {
                                  errorMsg = error;
                                  sending = false;
                                });
                              }
                            }
                          },
                    child: sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: _white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send Reset Link',
                            style: TextStyle(
                              color: _white,
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
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google login successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoadingScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? e.code)),
      );
    }
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
              const Text(
                'Cut costs, not flavor.',
                style: TextStyle(
                  color: _walnut,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 44),
              const _SectionDivider(),
              const SizedBox(height: 28),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome back',
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
                  'Sign in to continue saving.',
                  style: TextStyle(color: _grey, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              _Field(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePass,
                suffixIcon: _VisibilityToggle(
                  obscure: _obscurePass,
                  onTap: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showForgotPasswordSheet,
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: _walnut, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoadingScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _walnut,
                    foregroundColor: _white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFF3A3A3A), thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or',
                      style: TextStyle(color: _grey, fontSize: 12),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFF3A3A3A), thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _charcoal,
                    foregroundColor: _white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Color(0xFF4285F4),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?  ",
                    style: TextStyle(color: _grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: _walnut,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
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

  static const _defs = [
    [0.00, 0.17, -0.10, 0.18,  1.10, 0.18, 0.9],
    [0.10, 0.18, -0.10, 0.05,  0.80, 0.75, 3.2],
    [0.28, 0.17,  0.22, -0.05, 0.22, 1.05, 1.5],
    [0.35, 0.17,  1.10, 0.10,  0.15, 0.75, 1.0],
    [0.50, 0.17, -0.10, 0.65,  1.10, 0.70, 2.5],
    [0.55, 0.17,  1.10, 0.08,  0.30, 0.60, 1.6],
    [0.65, 0.17,  0.75, -0.05, 0.82, 1.05, 0.8],
    [0.72, 0.17,  0.60, -0.05, 0.60, 1.05, 3.0],
    [0.83, 0.17, -0.10, 0.82,  1.10, 0.55, 1.4],
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _grey, fontSize: 13),
        prefixIcon: Icon(icon, color: _walnut, size: 20),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
