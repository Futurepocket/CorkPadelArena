import 'package:cork_padel_arena/main.dart';
import 'package:flutter/material.dart';

class Menu_Item extends StatelessWidget {
  final IconData ikon;
  final String title;
  Color? color;
  final double iconSize;
  final Function(BuildContext ctx) fun;

  Menu_Item(
      {required this.ikon, required this.title, this.color, required this.fun, this.iconSize = 80});

  // void selectMenu(BuildContext ctx) {
  //   // Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
  //   //   return
  //   // },),);
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => fun(context),
      splashColor: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        color: ElevationOverlay.applySurfaceTint(
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceTint,
            3),
        child: GridTile(
          footer: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
          ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Icon(ikon, size: iconSize, color: Theme.of(context).colorScheme.onSurfaceVariant,),
        ),),
      )
      // Container(
      //   padding: const EdgeInsets.all(5),
      //   child: Column(
      //     children: [
      //       Flexible(
      //         flex: 5,
      //           child: Icon(ikon, size: iconSize, color: color,)),
      //         Flexible(
      //           flex: 1,
      //           child: FittedBox(
      //             child: Text(
      //               title,
      //               style: TextStyle(fontSize: 16, color: color),
      //             ),
      //           ),
      //         ),
      //     ],
      //   ),
      //
      // ),
    );
  }
}
