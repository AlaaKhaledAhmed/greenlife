import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:greenlife/widget/AppText.dart';

class Volunteering extends StatefulWidget {
  const Volunteering({super.key});

  @override
  State<Volunteering> createState() => _VolunteeringState();
}

class _VolunteeringState extends State<Volunteering> {
  bool isLoading = true;
  late String url;
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    url = "https://nvg.gov.sa/admin/vol-opports";
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('errrror');
          },
          onNavigationRequest: (NavigationRequest request) async {
            print('url: ${request.url}');

            ///we convert any http to https
            String modifiedUrl = request.url;
            if (modifiedUrl.startsWith('http://')) {
              modifiedUrl = modifiedUrl.replaceFirst('http://', 'https://');
              controller.loadRequest(Uri.parse(modifiedUrl));
              return NavigationDecision.prevent;
            }

            ///if click on send email, open Gmail app
            String uri =
                'https://mail.google.com/mail/?view=cm&to=help@atlbha.sa&su=طلب دعم&body=السلام عليكم'
                //'https://mail.google.com/mail/?view=cm&to=help@atlbha.sa'
                ;
            if (request.url.startsWith('mailto:')) {
              final Uri gmailWebUri = Uri.parse(uri);
              if (await canLaunchUrl(gmailWebUri)) {
                await launchUrl(gmailWebUri,
                    mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppText(
          text: "التطوع بذل وعطاء",
          fontSize: 22,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : WebViewWidget(controller: controller),
      ),
    );
  }
}
