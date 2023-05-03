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

late AppLocalizations localizations;

List<Pages> getAdminDashButtons(BuildContext context){
  return [
    Pages(
      Icons.supervised_user_circle_outlined,
      localizations.users,
      Theme.of(context).primaryColor,
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
      localizations.reservations,
      Theme.of(context).primaryColor,
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
      localizations.payments,
      Theme.of(context).primaryColor,
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
      localizations.adminReservation,
      Theme.of(context).primaryColor,
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
        localizations.openDoor,
        Theme.of(context).primaryColor, (BuildContext ctx) async {
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
  return [
    Pages(
      Icons.person,
      localizations.profile,
      Theme.of(context).primaryColor,
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
      localizations.makeReservation,
      Theme.of(context).primaryColor,
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
      localizations.myReservations,
      Theme.of(context).primaryColor,
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
        localizations.contacts,
        Theme.of(context).primaryColor,
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
      localizations.onlineShop,
      Theme.of(context).primaryColor,
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
    //   localizations.about,
    //   Theme.of(context).primaryColor,
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
          localizations.admin,
          Theme.of(context).primaryColor,
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
        localizations.logout,
        Theme.of(context).primaryColor, (BuildContext ctx) {
      FirebaseAuth.instance.signOut();
      Navigator.of(
        ctx,
      ).pushReplacement(MaterialPageRoute(builder: (ctx) {
        return const MyApp();
      }));
    }),
  ];
}