import 'package:flutter/material.dart';

class CostumButton extends StatelessWidget {
  final String title;
  final Color? labelColor;
  final Color? bgColor;
  final Color? borderColor;
  final VoidCallback? onPress;
  final bool isLoading;

  const CostumButton({
    super.key,
    required this.title,
    this.onPress,
    this.labelColor,
    this.bgColor,
    this.borderColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: bgColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isLoading ? null : onPress,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    color: labelColor ?? Colors.white,
                    strokeWidth: 1.5,
                  ),
                ),
              ] else
                Text(
                  title,
                  style: TextStyle(
                    color: labelColor ?? Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Ubuntu",
                    letterSpacing: 1.0,
                    fontSize: 15.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
