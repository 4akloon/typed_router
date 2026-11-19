import 'package:flutter/material.dart';

/// A counter that lives in the screen's state: it shows whether a page was
/// kept (the count stays) or built again (it starts at zero).
final class TapCounter extends StatefulWidget {
  const TapCounter({super.key});

  @override
  State<TapCounter> createState() => _TapCounterState();
}

final class _TapCounterState extends State<TapCounter> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: () => setState(() => _taps++),
    child: Text('Screen state: tapped $_taps times'),
  );
}
