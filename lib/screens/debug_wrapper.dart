import 'package:flutter/material.dart';

class DebugWrapper extends StatelessWidget {
  final Widget child;
  final String screenName;

  const DebugWrapper({
    super.key,
    required this.child,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context) {
    print('🎨 Rendering: $screenName');
    return child;
  }
}
