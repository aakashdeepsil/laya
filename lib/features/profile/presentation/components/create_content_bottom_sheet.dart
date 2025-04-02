import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/profile/presentation/components/option_tile.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateContentBottomSheet extends StatefulWidget {
  const CreateContentBottomSheet({super.key});

  @override
  State<CreateContentBottomSheet> createState() =>
      _CreateContentBottomSheetState();
}

class _CreateContentBottomSheetState extends State<CreateContentBottomSheet> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenHeight * 0.02,
                vertical: screenHeight * 0.01,
              ),
              child: Text(
                'Share Your Thoughts and Stories',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: screenHeight * 0.022,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(),
            OptionTile(
              icon: LucideIcons.filePlus,
              title: 'Create a new chapter',
              subtitle: 'Add a new chapter to one of your existing series',
              onTap: () => context.push('/create_chapter'),
            ),
            OptionTile(
              icon: LucideIcons.filePlus,
              title: 'Create a new Series',
              subtitle: 'Start your creative journey',
              onTap: () => context.push('/create_series'),
            ),
          ],
        ),
      ),
    );
  }
}
