import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'providers/auth_provider.dart';
import 'package:password_manager/core/utils/bento_constants.dart';

class OtpIsland extends StatefulWidget {
  final TextEditingController controller;

  const OtpIsland({super.key, required this.controller});

  @override
  State<OtpIsland> createState() => _OtpIslandState();
}

class _OtpIslandState extends State<OtpIsland> {
  bool _isLoading = false;
  int _timeLeft = 30;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchOTP() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final otp = await authProvider.fetchOTP();

      if (mounted) {
        if (otp != null) {
          widget.controller.text = otp;
          Clipboard.setData(ClipboardData(text: otp));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('OTP found and copied!'),
              backgroundColor: BentoColors.of(context).otpIsland,
            ),
          );
          _startTimer();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No OTP found in recent emails'),
              backgroundColor: BentoColors.of(context).error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error fetching OTP';
         if (e.toString().contains('Gmail API is not enabled')) {
          errorMessage = 'Gmail API not enabled. Check console.';
        } else if (e.toString().contains('Not signed in')) {
          errorMessage = 'Not signed in to Gmail.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: BentoColors.of(context).error,
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
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: BentoColors.of(context).otpIsland,
        gradient: LinearGradient(
          colors: [
            BentoColors.of(context).otpIsland.withValues(alpha: 0.8),
            BentoColors.of(context).otpIsland.withValues(alpha: 0.6)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BentoStyles.borderRadius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: BentoColors.of(context).otpIsland.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ONE-TIME PASSWORD',
                style: BentoStyles.body.copyWith(
                  color: BentoColors.of(context).onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (_isLoading)
                 SizedBox(
                    width: 12, height: 12, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: BentoColors.of(context).onPrimary)
                 )
              else 
                Stack(
                  alignment: Alignment.center,
                  children: [
                     Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Code
          AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              return Text(
                widget.controller.text.isEmpty ? '--- ---' : widget.controller.text,
                style: BentoStyles.mono.copyWith(
                  color: BentoColors.of(context).onPrimary,
                  fontSize: 36, // Adjusted for space
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: _timeLeft / 30,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        color: BentoColors.of(context).onPrimary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_timeLeft}s left',
                      style: BentoStyles.body.copyWith(color: BentoColors.of(context).onPrimary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                   if (widget.controller.text.isEmpty) {
                     _fetchOTP();
                   } else {
                     Clipboard.setData(ClipboardData(text: widget.controller.text));
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: BentoColors.of(context).otpIsland,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  textStyle: BentoStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                child: Text(widget.controller.text.isEmpty ? 'Fetch' : 'Copy Code'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
