import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatefulWidget {
  final void Function(String text)? onChanged;
  final String? initialText;
  const MyTextField({this.initialText, this.onChanged, Key? key}) : super(key: key);
  @override State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late final TextEditingController _textController = TextEditingController(text: widget.initialText);
  @override Widget build(BuildContext context) {
    _textController.text = widget.initialText ?? "";
    return SizedBox(
      width: 50,
      height: 30,
      child: TextField(
        controller: _textController,
        decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(),
          contentPadding: EdgeInsets.only(left: 5),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: widget.onChanged,
      ),
    );
  }
}
