// import 'package:flutter/material.dart';
// import 'package:laya/components/bottom_navigation_bar.dart';
// import 'package:laya/constants.dart';
// import 'package:lucide_icons/lucide_icons.dart';

// class Socials extends StatefulWidget {
//   const Socials({super.key});

//   @override
//   State<Socials> createState() => _SocialsState();
// }

// class _SocialsState extends State<Socials> {
//   // Get screen width of viewport.
//   double get screenWidth => MediaQuery.of(context).size.width;
//   double get screenHeight => MediaQuery.of(context).size.height;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(screenHeight, 'Socials'),
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: DefaultTabController(
//         length: 2,
//         child: NestedScrollView(
//             headerSliverBuilder: (BuildContext context, _) {
//               return [
//                 SliverList(delegate: SliverChildListDelegate([])),
//               ];
//             },
//             body: Column(
//               children: [
//                 TabBar(
//                   unselectedLabelColor: Colors.grey[400],
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   indicatorWeight: 1,
//                   tabs: const [
//                     Tab(text: "For You"),
//                     Tab(text: "Following"),
//                   ],
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     children: [
//                       Container(),
//                       Container(),
//                       // ListView.builder(
//                       //   itemCount: 1,
//                       //   itemBuilder: (context, index) {
//                       //     return InkWell(
//                       //       onTap: () => context.go('/socials/post/$index'),
//                       //       child: const Post(
//                       //         avatarUrl: '',
//                       //         postItem: {},
//                       //         username: '',
//                       //       ),
//                       //     );
//                       //   },
//                       // ),
//                       // ListView.builder(
//                       //   itemCount: 10,
//                       //   itemBuilder: (context, index) {
//                       //     return const Post(
//                       //       avatarUrl: '',
//                       //       postItem: {},
//                       //       username: '',
//                       //     );
//                       //   },
//                       // ),
//                     ],
//                   ),
//                 ),
//               ],
//             )),
//       ),
//       bottomNavigationBar: const MyBottomNavigationBar(index: 2),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         child: const Icon(LucideIcons.pencil),
//       ),
//     );
//   }
// }
