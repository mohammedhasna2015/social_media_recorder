import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget({
    this.title,
    this.keyValue,
    this.color = Colors.black,
    this.size = 14,
    this.fontWeight = FontWeight.w400,
    this.paddingBottom = 0,
    this.decoration = TextDecoration.none,
    this.textOverflow,
    this.paddingStart = 0,
    this.spOff = false,
    this.paddingTop = 0,
    this.decorationThickness,
    this.height = 1.1,
    this.colorDecoration,
    this.fontFamily,
    this.maxLine,
    this.paddingEnd = 0,
    this.textAlign = TextAlign.start,
    this.listShadow,
    this.textDirection,
    this.isRequired = false,
  });
  final String? title;
  final Color color;
  final double size;
  final double paddingStart;
  final double paddingEnd;
  final double paddingTop;
  final Color? colorDecoration;
  final double paddingBottom;
  final List<Shadow>? listShadow;
  final double? height;
  final bool spOff;
  final double? decorationThickness;
  final TextDecoration? decoration;
  final TextOverflow? textOverflow;
  final FontWeight fontWeight;
  final String? fontFamily;
  final Key? keyValue;
  final TextAlign textAlign;
  final int? maxLine;
  final TextDirection? textDirection;
  final bool? isRequired;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Container(
        padding: EdgeInsetsDirectional.only(
            top: paddingTop,
            start: paddingStart,
            bottom: paddingBottom,
            end: paddingEnd),
        child: Visibility(
            visible: isRequired ?? false,
            replacement: Text(
              title.toString(),
              textDirection: textDirection,
              overflow: textOverflow,
              textAlign: textAlign,
              key: keyValue,
              softWrap: true,
              maxLines: maxLine,
              style: TextStyle(
                color: color,
                height: height,
                shadows: listShadow,
                decorationThickness: decorationThickness,
                decorationColor: colorDecoration,
                fontFamily: fontFamily,
                decoration: decoration,
                fontWeight: fontWeight,
                fontSize: size,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title.toString(),
                  textDirection: textDirection,
                  overflow: textOverflow,
                  textAlign: textAlign,
                  key: keyValue,
                  softWrap: true,
                  maxLines: maxLine,
                  style: TextStyle(
                    color: color,
                    height: height,
                    shadows: listShadow,
                    decorationThickness: decorationThickness,
                    decorationColor: colorDecoration,
                    fontFamily: fontFamily,
                    decoration: decoration,
                    fontWeight: fontWeight,
                    fontSize: size,
                  ),
                ),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF5A5F),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
