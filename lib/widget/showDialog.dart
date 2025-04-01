import 'package:flutter/material.dart';
import 'package:greenlife/widget/AppSize.dart';
import 'package:greenlife/widget/AppText.dart';
import 'package:greenlife/widget/app_color.dart';

showAlert(
    {required BuildContext context,
    required String title,
    required String content}) {
  return showDialog(
    context: context,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
            height: 70,
            decoration: BoxDecoration(
                color: AppColor.mainColor,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            alignment: Alignment.center,
            child: AppText(
              color: AppColor.white,
              text: title,
              fontSize: AppSize.textFieldsSize,
            )),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(content),
        ),
      ),
    ),
  );
}
