// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:laya/constants.dart';
// import 'package:supabase_auth_ui/supabase_auth_ui.dart';

// class UpdatePassword extends StatefulWidget {
//   const UpdatePassword({super.key});

//   @override
//   State<UpdatePassword> createState() => _UpdatePasswordState();
// }

// class _UpdatePasswordState extends State<UpdatePassword> {
//   // Get screen width and height of viewport.
//   double get screenHeight => MediaQuery.of(context).size.height;
//   double get screenWidth => MediaQuery.of(context).size.width;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(screenHeight, 'Update Password', backButton: true),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
//         child: Column(
//           children: [
//             SupaResetPassword(
//               accessToken:
//                   Supabase.instance.client.auth.currentSession!.accessToken,
//               onSuccess: (response) => context.go('/home'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
