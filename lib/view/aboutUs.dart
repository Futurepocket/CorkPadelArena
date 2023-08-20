import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/common_utils.dart';
import 'dash.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class AboutUs extends StatefulWidget {

  String src = 'https://www.youtube.com/watch?v=nlom7a-UiLA';
  final double height = 200;
  final double width = 600;

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
late WebViewController webViewController;
late final PlatformWebViewControllerCreationParams params;

@override
  void initState() {
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{}
    );
  } else {
    params = const PlatformWebViewControllerCreationParams();
  }
    webViewController = WebViewController.fromPlatformCreationParams(params);
  initiateWebviewController();
    super.initState();
  }

Future<void> initiateWebviewController() async {
  if (webViewController.platform is AndroidWebViewController) {
    AndroidWebViewController.enableDebugging(true);
    (webViewController.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
  }
  webViewController
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
      NavigationDelegate(
   onNavigationRequest: (NavigationRequest request) => NavigationDecision.navigate
      )
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    webViewController.loadHtmlString('https://www.youtube.com/watch?v=nlom7a-UiLA');
  });

}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Cork Padel", style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Cork Padel',
                    style: TextStyle(
                      fontFamily: 'Roboto Condensed',
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Text(
                      AppLocalizations.of(context)!.about,
                      style: const TextStyle(
                        fontFamily: 'Roboto Condensed',
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.shade600,
                            width: 2
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.moreThanRaquets,
                        style: const TextStyle(
                          fontFamily: 'Roboto Condensed',
                          fontSize: 16,
                        ),
                      ),
                      if(!kIsWeb) Container(
                          padding: const EdgeInsets.only(top:10.0),
                          height: 500,
                          child: WebViewWidget(
                            controller: webViewController,
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(AppLocalizations.of(context)!.allAboutUs, style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 16,

                        ),),
                      ),

                    ],
                  )
                ]
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Badge(
        label: Text(reservationsToCheckOut.length.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
        isLabelVisible: reservationsToCheckOut.isEmpty? false : true,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            showShoppingCart(context).then((value) {
              setState(() {

              });
            });
          },
          child: Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.onSecondary),
        ),
      ),
    );
  }
}
