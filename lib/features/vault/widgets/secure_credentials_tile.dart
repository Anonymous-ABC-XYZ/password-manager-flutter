import 'package:flutter/material.dart';
import 'package:password_manager/core/utils/bento_constants.dart';

class SecureCredentialsTile extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onAcquireEmail;
  final VoidCallback onGeneratePassword;

  const SecureCredentialsTile({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onAcquireEmail,
    required this.onGeneratePassword,
  });

  @override
  State<SecureCredentialsTile> createState() => _SecureCredentialsTileState();
}

class _SecureCredentialsTileState extends State<SecureCredentialsTile> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: BentoColors.of(context).surfaceDark,
        borderRadius: BentoStyles.borderRadius,
        border: Border.all(
          color: BentoColors.of(context).inputBorder.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Secure Credentials',
                style: BentoStyles.header.copyWith(
                  color: BentoColors.of(context).textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.vpn_key,
                color: BentoColors.of(context).secondary,
              ), // Changed tertiary to secondary for simplicity as tertiary not in bento_of
            ],
          ),
          const SizedBox(height: 24),

          // Email Field
          _buildField(
            label: 'Registered Email',
            controller: widget.emailController,
            inputType: TextInputType.emailAddress,
            iconActions: [
              _buildIconButton(
                Icons.mail,
                'Acquire Alias',
                widget.onAcquireEmail,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Password Field
          _buildField(
            label: 'Password',
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            iconActions: [
              _buildIconButton(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                'Show/Hide',
                () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              _buildIconButton(
                Icons.autorenew,
                'Generate New',
                widget.onGeneratePassword,
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Strength Indicator
          AnimatedBuilder(
            animation: widget.passwordController,
            builder: (context, child) {
              int length = widget.passwordController.text.length;
              int strength = 0;
              if (length > 0) strength = 1;
              if (length > 8) strength = 2;
              if (length > 12) strength = 3;
              if (length > 16) strength = 4;

              return Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index < strength
                            ? BentoColors.of(context).secondary
                            : BentoColors.of(context).surfaceHover,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? inputType,
    required List<Widget> iconActions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: BentoStyles.body.copyWith(
              color: BentoColors.of(context).textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: inputType,
              style: BentoStyles.body.copyWith(
                color: BentoColors.of(context).textWhite,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: BentoColors.of(context).inputBg,
                border: OutlineInputBorder(
                  borderRadius: BentoStyles.inputBorderRadius,
                  borderSide: BorderSide(
                    color: BentoColors.of(context).inputBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BentoStyles.inputBorderRadius,
                  borderSide: BorderSide(
                    color: BentoColors.of(context).inputBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BentoStyles.inputBorderRadius,
                  borderSide: BorderSide(
                    color: BentoColors.of(context).secondary,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 80, 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: iconActions),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        icon: Icon(icon, color: BentoColors.of(context).textMuted, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
        splashRadius: 20,
        hoverColor: BentoColors.of(context).secondary.withValues(alpha: 0.1),
      ),
    );
  }
}
