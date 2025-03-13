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

enum ResultType {
  normal,
  qrCode,
  strCount
}

class _MMStrToolPageState extends MMBaseState<MMStrToolPage> {

  final TextEditingController _inputTextController = TextEditingController();

  final TextEditingController _resultTextController = TextEditingController();

  ResultType _resultType = ResultType.normal;

  var _textLengthStr = "字符串长度:";

  @override
  String get barTitle {
    return "字符串操作";
  }

  @override
  Widget getBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              visible: _resultType == ResultType.qrCode,
                child: QrImage(
                  data: _inputTextController.text,
                )),
            Visibility(
              visible: _resultType == ResultType.normal,
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
            Visibility(
              visible: _resultType == ResultType.strCount,
                child: Container(
                  margin: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  createStrToolWidget(),
                  Text(_textLengthStr)
                ],
              ),
            ))
          ],
        )),
      ],
    );
  }

  ScrollController _toolScrollController = ScrollController();

  Widget createToolWidget() {
    var list = [
      "URL Encode",
      "URL Encode Query",
      "URL Decode",
      "复制结果",
      "清空输入",
      "生成二维码",
      "长度计算"
    ];
    return Container(
      height: 50,
      child: Scrollbar(
        interactive: true,
        controller: _toolScrollController,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
            controller: _toolScrollController,
            itemCount: list.length,
            itemBuilder: (context, i) {
            return createBtn(list[i], () {
              handleClick(i);
            });
        }),
      ),
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
        switchType(ResultType.qrCode);
        break;
      case 6:
        handleStrCount();
        break;
      default:
        print('Unknown');
    }
  }

  void switchType(ResultType type) {
    setState(() {
      _resultType = type;
    });
  }

  void handlerEncode() {
    switchType(ResultType.normal);
    var text = _inputTextController.text;
    var resultText = Uri.encodeComponent(text);
    _resultTextController.text = resultText;
  }

  void handlerQueryEncode() {
    switchType(ResultType.normal);
    var text = _inputTextController.text;
    var resultText = Uri.encodeFull(text);
    _resultTextController.text = resultText;
  }

  void handlerDecode() {
    switchType(ResultType.normal);
    var text = _inputTextController.text;
    var resultText = Uri.decodeComponent(text);
    _resultTextController.text = resultText;
  }

  void handleCopy() {
    Clipboard.setData(ClipboardData(text: _resultTextController.text));
    MMToaster.showToast(context, "已复制到剪切板");
  }

  void handleStrCount() {
    switchType(ResultType.strCount);
  }

  ScrollController _strScrollController = ScrollController();
  Widget createStrToolWidget() {
    var list = [
      "普通长度",
      "带emoji长度",
      "utf8长度",
    ];
    List<Widget> widgetList = [];
    for (int i = 0; i < list.length ; i++) {
      widgetList.add(createBtn(list[i], () {
        handleStrClick(i);
      }));
    }
    return Scrollbar(
      controller: _strScrollController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _strScrollController,
        child: Row(
          children: widgetList,
        ),
      ),
    );
  }

  void handleStrClick(int index) {
    String base = "字符串长度: ";
      switch (index) {
        case 0:
          base += "${_inputTextController.text.length}";
          break;
        case 1:
          // _inputTextController.text
          break;
        case 2:
          break;
      }
    setState(() {
        _textLengthStr = base;
      });


  }
}
