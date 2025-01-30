import 'package:flutter/material.dart';
import 'package:social_media_recorder/widgets/custom_button_widget.dart';
import 'package:social_media_recorder/widgets/custom_text_widget.dart';

class CustomDialog extends StatefulWidget {
  const CustomDialog({
    Key? key,
    this.title,
    this.sizeTitle,
    this.showCancel = true,
    this.titleYes,
    this.body,
    this.titleNo,
  }) : super(key: key);

  final String? title;
  final String? body;
  final double? sizeTitle;
  final String? titleYes;
  final String? titleNo;

  final bool showCancel;
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  String? _cancelLabel;

  final _borderRadius = 20.0;

  final _internalMargin = 15.0;

  final _buttonHeight = 50.0;
  final _internalBorderWidth = 2.0;
  final _internalBorderRadius = 8.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: _buildShape(),
      content: _buildBody(),
    );
  }

  RoundedRectangleBorder _buildShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    );
  }

  Widget _buildBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _title(),
        if (widget.body != null) SizedBox(height: 5),
        if (widget.body != null) _body(),
        const SizedBox(height: 20),
        _buildButtons(),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        _buildSubmit(),
        if (widget.showCancel) SizedBox(width: _internalMargin),
        if (widget.showCancel) _buildCancel(),
      ],
    );
  }

  Widget _buildSubmit() {
    return Expanded(
      child: SizedBox(
        height: _buttonHeight,
        child: CustomButton(
          colorBorder: Color(0xFF26467A),
          colorButton: Color(0xFF26467A),
          text: widget.titleYes ?? '',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
    );
  }

  Widget _buildCancel() {
    return Expanded(
      child: SizedBox(
        height: _buttonHeight,
        child: _buildCancelButton(),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: _buildCancelButtonShape(),
      ),
      child: _buildCancelButtonLabel(),
      onPressed: () => Navigator.pop(context),
    );
  }

  RoundedRectangleBorder _buildCancelButtonShape() {
    return RoundedRectangleBorder(
      side: _buildCancelButtonBorder(),
      borderRadius: BorderRadius.circular(_internalBorderRadius),
    );
  }

  BorderSide _buildCancelButtonBorder() {
    return BorderSide(
      color: Color(0xFFFF5A5F),
      width: _internalBorderWidth,
    );
  }

  Widget _buildCancelButtonLabel() {
    return CustomTextWidget(
      title: widget.titleNo,
      fontFamily: 'Cairo',
      color: const Color(0xff000000),
    );
  }

  Widget _title() {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_outlined,
          size: 20,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: CustomTextWidget(
            title: widget.title ?? '',
            fontFamily: 'Cairo',
            size: widget.sizeTitle ?? 14,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  Widget _body() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: 25,
            ),
            child: CustomTextWidget(
              title: widget.body ?? '',
              fontFamily: 'Cairo',
              fontWeight: FontWeight.normal,
            ),
          ),
        )
      ],
    );
  }
}
