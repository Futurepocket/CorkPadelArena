import 'package:flutter/material.dart';

class Menu_Item extends StatelessWidget {
  final Icon ikon;
  final String title;
  final Color color;
  final Function(BuildContext ctx) fun;

  const Menu_Item(this.ikon, this.title, this.color, this.fun);

  // void selectMenu(BuildContext ctx) {
  //   // Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
  //   //   return
  //   // },),);
  // }

  @override
  Widget build(BuildContext context) {
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
                child: ikon),
              Flexible(
                flex: 1,
                child: FittedBox(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  ),
                ),
              ),
          ],
        ),

      ),
    );
  }
}
