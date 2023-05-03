import 'package:flutter/material.dart';

class Menu_Item extends StatelessWidget {
  final IconData ikon;
  final String title;
  Color? color;
  final double iconSize;
  final Function(BuildContext ctx) fun;

  Menu_Item(
      {required this.ikon, required this.title, this.color, required this.fun, this.iconSize = 120});

  // void selectMenu(BuildContext ctx) {
  //   // Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
  //   //   return
  //   // },),);
  // }

  @override
  Widget build(BuildContext context) {
    color ??= Colors.grey.shade800;
    return InkWell(
      onTap: () => this.fun(context),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Flexible(
              flex: 5,
                child: Icon(ikon, size: iconSize, color: color,)),
              Flexible(
                flex: 1,
                child: FittedBox(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, color: color),
                  ),
                ),
              ),
          ],
        ),

      ),
    );
  }
}
