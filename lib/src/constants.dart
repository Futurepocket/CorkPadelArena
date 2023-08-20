import 'package:cork_padel_arena/main.dart';
import 'package:cork_padel_arena/models/userr.dart';
import 'package:cork_padel_arena/utils/common_utils.dart';
import 'package:cork_padel_arena/view/admin_payments.dart';
import 'package:cork_padel_arena/view/admindash.dart';
import 'package:cork_padel_arena/view/contacts.dart';
import 'package:cork_padel_arena/view/dash.dart';
import 'package:cork_padel_arena/view/new_admin_reservations.dart';
import 'package:cork_padel_arena/view/new_my_Reservations.dart';
import 'package:cork_padel_arena/view/permanent_reservation.dart';
import 'package:cork_padel_arena/view/reserve.dart';
import 'package:cork_padel_arena/view/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cork_padel_arena/models/page.dart';
import 'package:flutter/material.dart';
import 'package:http_auth/http_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

List<Pages> getAdminDashButtons(BuildContext context){
  Color color = Theme.of(context).colorScheme.onPrimary;
  return [
    Pages(
      Icons.supervised_user_circle_outlined,
      AppLocalizations.of(context)!.users,
      color,
      (BuildContext ctx) {
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) {
          return const Users();
        }));
      },
    ),
    Pages(
      Icons.calendar_month_outlined,
      AppLocalizations.of(context)!.reservations,
      color,
          (BuildContext ctx) {
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) {
          return NewAdminReservations();
        }));
      },
    ),
    Pages(
      Icons.payments_outlined,
      AppLocalizations.of(context)!.payments,
      color,
          (BuildContext ctx) {
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) {
          return const AdminPayments();
        }));
      },
    ),
    Pages(
      Icons.block,
      AppLocalizations.of(context)!.adminReservation,
      color,
          (BuildContext ctx) {
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) {
          return const PermanentReservation();
        }));
      },
    ),
    Pages(
        Icons.sensor_door_outlined,
        AppLocalizations.of(context)!.openDoor,
        color, (BuildContext ctx) async {
      if (kIsWeb) {
        launchUrlString(openDoorFullUrl);
      } else {
        var client = DigestAuthClient("admin", "cork2021");
        await client.get(Uri.parse(openDoorUrl)).then((response) {
          if(response.statusCode == 200){
            showWebView(context);
          }
        });
      }
    }),
  ];
}

List<Pages> getDashButtons(BuildContext context, Function? settingState){
  Color color = Theme.of(context).colorScheme.onPrimary;
  return [
    Pages(
      Icons.person,
      AppLocalizations.of(context)!.profile,
      color,
          (BuildContext ctx) {
        Navigator.of(
          ctx,
        ).pushNamed("/profile").then((value) {
          if (settingState != null) settingState();
        });
      },
    ),
    Pages(
      Icons.edit_calendar_outlined,
      AppLocalizations.of(context)!.makeReservation,
      color,
          (BuildContext ctx) {
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) {
          return Reserve();
        })).then((value) {
          if (settingState != null) settingState();
        });
      },
    ),
    Pages(
      Icons.calendar_month_outlined,
      AppLocalizations.of(context)!.myReservations,
      color,
          (BuildContext ctx) {
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) {
          return const NewMyReservations();
        })).then((value) {
          if (settingState != null) settingState();
        });
      },
    ),
    Pages(
        Icons.contact_phone,
        AppLocalizations.of(context)!.contacts,
        color,
            (BuildContext ctx) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) {
            return const Contacts();
          })).then((value) {
            if (settingState != null) settingState();
          });
        }),
    Pages(
      Icons.shopping_bag_rounded,
      AppLocalizations.of(context)!.onlineShop,
      color,
          (BuildContext ctx) async {
        if (await canLaunchUrl(Uri.parse('https://www.corkpadel.pt/en/store'))) {
          await launchUrl(
            Uri.parse('https://www.corkpadel.pt/en/store'),
            mode: LaunchMode.platformDefault,
            //headers: <String, String>{'my_header_key': 'my_header_value'},
          );
        } else {
          throw 'Could not launch the store';
        }
      },
    ),
    // Pages(
    //   Icon(
    //     Icons.device_unknown,
    //     color: _menuColor,
    //     size: 120,
    //   ),
    //   AppLocalizations.of(context.!about,
    //   color,
    //         (BuildContext ctx) {
    //       Navigator.of(
    //         ctx,
    //       ).push(MaterialPageRoute(builder: (_) {
    //         return AboutUs();
    //       })).then((value) => settingState());
    //     }
    // ),
    if(Userr().role == "administrador")
      Pages(
          Icons.admin_panel_settings_outlined,
          AppLocalizations.of(context)!.admin,
          color,
              (BuildContext ctx) {
            Navigator.of(
              ctx,
            ).push(MaterialPageRoute(builder: (ctx) {
              return AdminDash();
            }));
          }
      ),
    Pages(
        Icons.exit_to_app_rounded,
        AppLocalizations.of(context)!.logout,
        color, (BuildContext ctx) {
      FirebaseAuth.instance.signOut();
      Navigator.of(
        ctx,
      ).pushReplacement(MaterialPageRoute(builder: (ctx) {
        return const MyApp();
      }));
    }),
  ];
}

InputDecoration inputDecor({
  IconData? prefixIcon, required String label, Widget? sufixIcon, required BuildContext context
}){
  ThemeData theme = Theme.of(context);
  return InputDecoration(
    prefixIcon: prefixIcon != null? Icon(prefixIcon) : null,
    contentPadding: const EdgeInsets.all(10),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: theme
          .colorScheme.primary, width: 1.5),
    ),
    suffixIcon: sufixIcon,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: theme
          .colorScheme.secondary, width: 1.5),
    ),
    labelText: label,
  );
}