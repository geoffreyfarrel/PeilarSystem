import 'package:flutter/material.dart';

class ItineraryStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ItineraryStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  static const Color darkGreen = Color(0xFF0E9A33);
  static const Color green = Color(0xFF0E9A33);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 283,
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalSteps, (index) {
          final active = index <= currentStep;

          return Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? darkGreen : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? darkGreen : green,
                width: 1,
              ),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: active ? Colors.white : green,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }),
      ),
    );
  }
}