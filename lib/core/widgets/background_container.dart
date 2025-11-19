// core/widgets/background_container.dart
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final bool showBackgroundImage;

  const BackgroundContainer({
    Key? key,
    required this.child,
    this.showBackgroundImage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: showBackgroundImage
          ? const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            )
          : null,
      child: child,
    );
  }
}