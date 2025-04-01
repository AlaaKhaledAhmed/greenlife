import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppText extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final Color? color;
  final TextOverflow? overflow;
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextDecoration? textDecoration;
  final double? textHeight;
  final List<Shadow>? shadow;
  final TextDirection? textDirection;
  const AppText(
      {Key? key,
        required this.text,
        this.align,
        this.color,
        this.overflow,
        this.fontFamily,
        required this.fontSize,
        this.fontWeight,
        this.textDecoration,
        this.textHeight,
        this.shadow,
        this.textDirection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      textDirection: textDirection,
      //   TextStyle englishTextStyle = GoogleFonts.roboto(
      //   fontSize: 16,
      //   fontWeight: FontWeight.normal,
      //   fontStyle: FontStyle.normal,
      // );

      style: TextStyle(
          color: color,
          overflow: overflow ?? TextOverflow.clip,
          fontFamily: fontFamily ?? GoogleFonts.tajawal().fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          decoration: textDecoration,
          decorationColor: color,
          height: textHeight,
          shadows: shadow),
    );
  }
}

