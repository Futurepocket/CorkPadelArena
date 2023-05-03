import 'package:cork_padel_arena/models/menuItem.dart';
import 'package:cork_padel_arena/src/constants.dart';
import 'package:flutter/material.dart';

class SplitScaffoldBody extends StatelessWidget {
  final Widget rightWidget;
  final Function? settingState;
  const SplitScaffoldBody({Key? key, required this.rightWidget, this.settingState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
            child: Column(children: getDashButtons(context, settingState)
                  .map((menus) =>
                  ListTile( leading: Icon(menus.ikon),
                    title: Text(menus.title),
                    onTap: () => menus.fun,)
              )
                  .toList(),),
        ),
        Flexible(
            flex: 4,
            child: rightWidget)
      ],
    );
  }
}
