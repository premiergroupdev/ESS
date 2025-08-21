import 'package:ess/360_survey_App/Components/Custom_App_bar.dart';
import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final wrappedUrl = _getWrappedUrl(widget.url);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(wrappedUrl));
  }

  /// 📄 Wrap files like PDF, Excel, Word to open via Google Docs Viewer
  String _getWrappedUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.pdf') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.pptx')) {
      return 'https://docs.google.com/gview?embedded=true&url=$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Document Viewer'),
      //   actions: [
      //     if (isLoading)
      //       const Padding(
      //         padding: EdgeInsets.only(right: 16),
      //         child: Center(
      //           child: SizedBox(
      //             height: 18,
      //             width: 18,
      //             child: CircularProgressIndicator(strokeWidth: 2),
      //           ),
      //         ),
      //       ),
      //   ],
      // ),
      body: Column(
        children: [
          SizedBox(height: 10,),
          notiAppBar(title: "Document Viewer", onMenuTap: (){}, onNotificationTap: (){}),
        //  notiAppBar(title: "title"),
       //   GenenralBar(title: "Document Viewer", context: context),
       //   GeneralAppBar(title: "Document Viewer", onMenuTap: (), onNotificationTap: onNotificationTap)
          Expanded(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: WebViewWidget(controller: _controller),
          )),
        ],
      ),
    );
  }
}
