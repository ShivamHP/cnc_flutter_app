
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  final List<String> list;
  final  String dropDownSelect;
  final String labelText;
  final String hintText;

  const DropdownWidget({Key key, this.list, this.dropDownSelect, this.labelText, this.hintText}) : super(key: key);
  @override
  _DropdownWidget createState() => _DropdownWidget();
}

class _DropdownWidget extends State<DropdownWidget> {
  String _dropDownSelect;

  getDropdownAct(){
    return _dropDownSelect;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
          labelText: widget.labelText,
          border: OutlineInputBorder(),
          hintText:  widget.hintText),
      value: widget.dropDownSelect,
      validator: (value) => value == null ? 'Field Required' : null,
      onChanged: (String Value) {
        setState(() {
          _dropDownSelect = Value;
        });
      },
      items: widget.list
          .map((actLevel) =>
          DropdownMenuItem(value: actLevel, child: Text("$actLevel")))
          .toList(),
    );
  }
}