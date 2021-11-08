import 'package:flutter/material.dart';

class FontSizeSlider extends StatefulWidget {
  const FontSizeSlider({Key? key, required this.callback, required this.value})
      : super(key: key);
  final Function callback;
  final double value;
  @override
  _FontSizeSliderState createState() => _FontSizeSliderState();
}

class _FontSizeSliderState extends State<FontSizeSlider> {
  late double value = widget.value;
  @override
  Widget build(BuildContext context) {
    return Slider(
        value: value,
        min: 10,
        max: 30,
        divisions: 20,
        label: value.toString(),
        onChanged: (newValue) {
          setState(() {
            value = newValue;
          });
          widget.callback(newValue);
        });
  }
}

class ColorChanger extends StatelessWidget {
  const ColorChanger({
    Key? key,
    required this.color,
    required this.callback,
  }) : super(key: key);
  final Function callback;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: InkWell(
        onTap: () {
          callback(color);
        },
      ),
      backgroundColor: color,
    );
  }
}
