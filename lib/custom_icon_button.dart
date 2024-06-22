import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;
  final String tooltip;
  final String title;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
    required this.tooltip,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          height: MediaQuery.sizeOf(context).height/7,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 35,
                ),
                Text(
                  title,
                  style: TextStyle(color: color,fontWeight: FontWeight.bold,fontSize: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
