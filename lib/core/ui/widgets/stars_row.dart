import 'package:flutter/material.dart';

class StarsRow extends StatelessWidget {
  final int stars;
  final double size;
  const StarsRow({super.key, required this.stars, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal:2.0), child: Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.amber, size: size))));
  }
}
