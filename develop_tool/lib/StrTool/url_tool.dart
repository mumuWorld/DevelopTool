import 'package:develop_tool/Base/mm_base_state.dart';
import 'package:develop_tool/components/mm_toast.dart';
import 'package:develop_tool/components/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MMStrToolPage extends StatefulWidget {
  const MMStrToolPage({Key? key}) : super(key: key);

  @override
  State<MMStrToolPage> createState() => _MMStrToolPageState();
}

class _MMStrToolPageState extends MMBaseState<MMStrToolPage> {

  final TextEditingController _inputTextController = TextEditingController();

  final TextEditingController _resultTextController = TextEditingController();

  var _showQRImage = false;

  @override
  String get barTitle {
    return "字符串操作";
  }

  @override
  Widget getBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: TextField(
              cursorColor: MMThemeColors.shared.main_color,
              decoration: InputDecoration(
                hintText: "请输入内容",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MMThemeColors.shared.grey_color),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: _inputTextController,
              maxLines: double.maxFinite.toInt(),
            ),
          ),
        ),
        // TextField(),
        createToolWidget(),
        Expanded(child: Stack(
          children: [
            Visibility(
              visible: _showQRImage,
                child: QrImage(
                  data: _inputTextController.text,
                )),
            Visibility(
              visible: !_showQRImage,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: TextField(
                  cursorColor: MMThemeColors.shared.main_color,
                  controller: _resultTextController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red, width: 10.0),
                      )),
                  maxLines: double.maxFinite.toInt(),
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget createToolWidget() {
    var list = [
      "URL Encode",
      "URL Encode Query",
      "URL Decode",
      "复制结果",
      "清空输入",
      "生成二维码"
    ];
    List<Widget> widgetList = [];
    for (int i = 0; i < list.length ; i++) {
       widgetList.add(createBtn(list[i], () {
         handleClick(i);
       }));
    }
    return Row(
      children: widgetList,
    );
  }

  Widget createBtn(String text, VoidCallback pressed) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8, right: 0, bottom: 8),
      child: ElevatedButton(onPressed: (){
        pressed();
      }, child: Text(text)),
    );
  }

  void handleClick(int index) {
    switch (index) {
      case 0:
        handlerEncode();
        break;
      case 1:
        handlerQueryEncode();
        break;
      case 2:
        handlerDecode();
        break;
      case 3:
        handleCopy();
        break;
      case 4:
        _inputTextController.text = "";
        break;
      case 5:
        showQRImage();
        break;
      default:
        print('Unknown');
    }
  }

  void hideQRImage() {
    if (!_showQRImage) {
      return;
    }
    setState(() {
      _showQRImage = false;
    });
  }

  void showQRImage() {
    if (_showQRImage) {
      return;
    }
    setState(() {
      _showQRImage = true;
    });
  }

  void handlerEncode() {
    hideQRImage();
    var text = _inputTextController.text;
    var resultText = Uri.encodeComponent(text);
    _resultTextController.text = resultText;
  }

  void handlerQueryEncode() {
    hideQRImage();
    var text = _inputTextController.text;
    var resultText = Uri.encodeFull(text);
    _resultTextController.text = resultText;
  }

  void handlerDecode() {
    hideQRImage();
    var text = _inputTextController.text;
    var resultText = Uri.decodeComponent(text);
    _resultTextController.text = resultText;
  }

  void handleCopy() {
    Clipboard.setData(ClipboardData(text: _resultTextController.text));
    MMToaster.showToast(context, "已复制到剪切板");
  }
}
