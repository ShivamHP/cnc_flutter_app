import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({
    Key? key,
    required this.text,
    required this.icon,
    required this.label,
    required this.press,
  }) : super(key: key);

  final String text, icon;
  final VoidCallback press;
  final label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: FlatButton(
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Theme.of(context).primaryColor,
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              color: Theme.of(context).highlightColor,
              width: 22,
            ),
            SizedBox(width: 20),
            Expanded(
                child: Text(text,
                    style: TextStyle(
                      color: Theme.of(context).highlightColor,
                      fontSize: 16.0,
                    ))),
            Icon(
              Icons.edit,
              color: Theme.of(context).highlightColor,
            )
          ],
        ),
      ),
    );
  }
}
