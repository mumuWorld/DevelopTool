import 'package:develop_tool/Base/mm_base_state.dart';
import 'package:develop_tool/components/mm_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MMStrToolPage extends StatefulWidget {
  const MMStrToolPage({Key? key}) : super(key: key);

  @override
  State<MMStrToolPage> createState() => _MMStrToolPageState();
}

class _MMStrToolPageState extends MMBaseState<MMStrToolPage> {

  final TextEditingController _inputTextController = TextEditingController();

  final TextEditingController _resultTextController = TextEditingController();

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
              decoration: InputDecoration(
                hintText: "请输入内容",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 10.0),
                )
              ),
              controller: _inputTextController,
              maxLines: double.maxFinite.toInt(),
            ),
          ),
        ),
        // TextField(),
        createToolWidget(),
        Expanded(child: Container(
          margin: const EdgeInsets.all(10),
          child: TextField(
            controller: _resultTextController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 10.0),
                )),
            maxLines: double.maxFinite.toInt(),
          ),
        )),
      ],
    );
  }

  Widget createToolWidget() {
    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: ElevatedButton(onPressed: (){
            handlerEncode();
          }, child: const Text("URL Encode")),
        ),
        ElevatedButton(onPressed: (){
          handlerDecode();
        }, child: const Text("URL Decode")),
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: ElevatedButton(onPressed: (){
            Clipboard.setData(ClipboardData(text: _resultTextController.text));
            MMToaster.showToast(context, "已复制到剪切板");
            // Fluttertoast.showToast(msg: "已复制到剪切板");
          }, child: const Text("复制结果")),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: ElevatedButton(onPressed: (){
             _inputTextController.text = "";
          }, child: const Text("清空输入")),
        ),

      ],
    );
  }

  void handlerEncode() {
    var text = _inputTextController.text;
    var resultText = Uri.encodeComponent(text);
    _resultTextController.text = resultText;
  }

  void handlerDecode() {
    var text = _inputTextController.text;
    var resultText = Uri.decodeComponent(text);
    _resultTextController.text = resultText;
  }
}
