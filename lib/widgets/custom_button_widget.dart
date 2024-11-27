// shared/custom_button.dart
import 'package:flutter/material.dart';
import 'package:social_media_recorder/widgets/custom_text_widget.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color colorButton;
  final Color colorText;
  final Color colorBorder;
  final double elevation;
  final EdgeInsetsDirectional? padding;
  final double? minimumSizeButton;
  final bool enabled;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.elevation = 1,
    this.colorButton = const Color(0xFFFF5A5F),
    this.colorText = const Color(0xFFFFFFFF),
    this.colorBorder = const Color(0xFFFF5A5F),
    this.padding,
    this.minimumSizeButton,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: elevation,
        side: enabled
            ? BorderSide(
                color: colorBorder,
              )
            : null,
        backgroundColor: enabled ? colorButton : colorButton.withOpacity(0.5),
        padding: padding ?? EdgeInsets.symmetric(vertical: 14),
        minimumSize: Size(double.infinity, minimumSizeButton ?? 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : CustomTextWidget(
              title: text,
              color: colorText,
              size: 16,
              fontWeight: FontWeight.w600,
            ),
    );
  }
}
