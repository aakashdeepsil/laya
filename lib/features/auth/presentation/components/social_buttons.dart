import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/features/auth/presentation/login_screen.dart';

class SocialButtons extends ConsumerWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialButton(icon: FontAwesomeIcons.google, onPressed: () {}),
        //   onPressed: () async {
        //     try {
        //       // Set loading state
        //       ref.read(loginProcessProvider.notifier).state =
        //           const AsyncValue.loading();

        //       final user = await authService.signInWithGoogle();

        //       if (user == null) {
        //         // Sign in failed
        //         ref.read(loginProcessProvider.notifier).state =
        //             AsyncValue.error(
        //           'Google sign-in failed',
        //           StackTrace.current,
        //         );
        //       } else {
        //         // Sign in successful
        //         ref.read(loginProcessProvider.notifier).state =
        //             const AsyncValue.data(null);
        //       }
        //     } catch (e) {
        //       // Error during sign in
        //       ref.read(loginProcessProvider.notifier).state =
        //           AsyncValue.error(e.toString(), StackTrace.current);

        //       if (context.mounted) {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           SnackBar(
        //             backgroundColor: Theme.of(context).colorScheme.error,
        //             content: Text(
        //               e.toString(),
        //             ),
        //           ),
        //         );
        //       }
        //     }
        //   },
        // ),

        const SizedBox(width: 16),
        SocialButton(
          icon: FontAwesomeIcons.apple,
          onPressed: () {
            // Implement Apple sign-in when available
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Apple sign in coming soon!'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
