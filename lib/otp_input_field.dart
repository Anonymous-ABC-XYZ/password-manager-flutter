import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:password_manager/features/auth/auth_provider.dart';

class OTPInputField extends StatefulWidget {
  final TextEditingController controller;

  const OTPInputField({super.key, required this.controller});

  @override
  State<OTPInputField> createState() => _OTPInputFieldState();
}

class _OTPInputFieldState extends State<OTPInputField> {
  bool _isLoading = false;

  Future<void> _fetchOTP() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final otp = await authProvider.fetchOTP();

      print(otp);
      if (mounted) {
        if (otp != null) {
          widget.controller.text = otp;
          Clipboard.setData(ClipboardData(text: otp));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP found: $otp'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No OTP found in recent emails'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      print('_fetchOTP error: $e');
      if (mounted) {
        String errorMessage = 'Error fetching OTP';

        if (e.toString().contains('Gmail API is not enabled')) {
          errorMessage =
              'Gmail API not enabled!\n\n'
              'Please enable it in Google Cloud Console:\n'
              'console.developers.google.com/apis/api/gmail.googleapis.com';
        } else if (e.toString().contains('Not signed in')) {
          errorMessage = 'Not signed in to Gmail. Please sign in first.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
            action: e.toString().contains('Gmail API is not enabled')
                ? SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
      child: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.bricolageGrotesque(color: theme.onSecondary),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5.5),
          ),
          prefixIcon: Icon(Icons.lock, color: theme.onSecondary),
          suffixIcon: _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.email, color: theme.primary),
                  tooltip: 'Fetch OTP from Gmail',
                  onPressed: _fetchOTP,
                ),
          hintText: 'OTP Code',
          hintStyle: GoogleFonts.bricolageGrotesque(
            color: theme.onSecondary,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: theme.secondary,
        ),
      ),
    );
  }
}
