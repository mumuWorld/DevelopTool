
import 'package:develop_tool/Base/mm_tool.dart';
import 'package:flutter/material.dart';

class MMMainLabelCell extends StatelessWidget {

  final VoidCallback? callback;

  final String? title;

  const MMMainLabelCell({Key? key, this.title, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(MMTool.getRandomColor()) 
          ),
          onPressed: callback,
        child: Text(
          title ?? "",
        ),
      ),
    );
  }
}
