import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widget/AppSize.dart';
import 'package:greenlife/widget/AppText.dart';

class AppDropList<T> extends StatelessWidget {
  final List<T>? items;
  final String? Function(T?)? validator;
  final String hintText;
  final bool? friezeText;
  final Color? fillColor;
  final Widget? prefixIcon;
  final Widget? icon;
  final List<DropdownMenuItem<T>>? customItem;
  final void Function(T?)? onChanged;
  final T? value;
  const AppDropList({
    super.key,
    this.items,
    required this.validator,
    required this.hintText,
    required this.onChanged,
    this.friezeText,
    this.fillColor,
    this.prefixIcon,
    this.icon,
    this.customItem,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
        alignment: AlignmentDirectional.centerStart,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        menuItemStyleData:
            MenuItemStyleData(padding: EdgeInsets.only(right: 10)),
        validator: validator,
        value: value,
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.all(Radius.circular(4))),
        ),
        buttonStyleData: ButtonStyleData(
          height: 20,
        ),
        hint: AppText(
          fontSize: AppSize.smallSubText + 2,
          text: hintText,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          filled: true,
          errorStyle: TextStyle(
              color: Colors.black,
              fontSize: AppSize.smallSubText,
              fontFamily: GoogleFonts.tajawal().fontFamily),
          errorMaxLines: 4,
          fillColor: Colors.grey.shade300,
          hintText: hintText,
          contentPadding: EdgeInsets.all(AppSize.contentPadding),
        ),
        onChanged: onChanged,
        items: customItem ??
            items!
                .map((e) => DropdownMenuItem(
                      alignment: AlignmentDirectional.centerEnd,
                      value: e,
                      child: AppText(
                        fontSize: AppSize.smallSubText + 2,
                        text: '$e',
                        color: Colors.black,
                      ),
                    ))
                .toList());
  }
}
