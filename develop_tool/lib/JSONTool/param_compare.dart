import 'package:develop_tool/Base/mm_base_state.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';



class MMParamCompareTool extends StatefulWidget {
  const MMParamCompareTool({super.key});

  @override
  State<MMParamCompareTool> createState() => _MMParamCompareToolState();
}

class _MMParamCompareToolState extends MMBaseState<MMParamCompareTool> {
  double _dividerPosition = 0.3; // 百分比高度位置

  final controllerA = TextEditingController();
  final controllerB = TextEditingController();

  @override
  String get barTitle {
    return "参数比较";
  }

  bool _compareValue = false;

  Map<String, Map<String, dynamic>> _differences = {};

  void _compare() {
    final a = controllerA.text.trim();
    final b = controllerB.text.trim();

    final aParams = _parseParams(a);
    final bParams = _parseParams(b);

    final result = _compareValue
        ? compareParams(aParams, bParams)
        : compareParamKeys(aParams, bParams);

    setState(() {
      _differences = result;
    });
  }

  Map<String, Map<String, dynamic>> compareParams(
      Map<String, dynamic> paramsA,
      Map<String, dynamic> paramsB, {
        bool isJson = false,
      }) {

    final differences = <String, Map<String, dynamic>>{};

    final allKeys = {...paramsA.keys, ...paramsB.keys};

    for (var key in allKeys) {
      final a = paramsA[key];
      final b = paramsB[key];

      if (!paramsA.containsKey(key)) {
        differences[key] = {'status': 'added', 'value': b};
      } else if (!paramsB.containsKey(key)) {
        differences[key] = {'status': 'removed', 'value': a};
      } else if (a != b) {
        differences[key] = {'status': 'changed', 'from': a, 'to': b};
      }
    }

    return differences;
  }

  /*

   */
  Map<String, Map<String, dynamic>> compareParamKeys(
      Map<String, dynamic> a,
      Map<String, dynamic> b,
      ) {
    final diffs = <String, Map<String, dynamic>>{};
    final allKeys = {...a.keys, ...b.keys}.toList()..sort();

    for (var key in allKeys) {
      final valA = a[key]?.toString().trim() ?? '';
      final valB = b[key]?.toString().trim() ?? '';

      final hasA = valA.isNotEmpty;
      final hasB = valB.isNotEmpty;

      if (hasA && !hasB) {
        diffs[key] = {
          'status': 'onlyInA',
          'valueA': valA,
        };
      } else if (!hasA && hasB) {
        diffs[key] = {
          'status': 'onlyInB',
          'valueB': valB,
        };
      } else if ((hasA && !hasB) || (!hasA && hasB)) {
        // 理论上上面两个条件已经 cover 了
      } else if (hasA && hasB) {
        diffs[key] = {
          'status': 'both',
          'valueA': valA,
          'valueB': valB,
        };
      } else if (!hasA && !hasB) {
        // 两边都是空，忽略
      } else {
        // 两边都有 key，有一个是空，一个非空
        diffs[key] = {
          'status': 'partialEmpty',
          'valueA': valA,
          'valueB': valB,
        };
      }
    }

    return diffs;
  }

  Map<String, dynamic> _parseParams(String raw, {bool isJson = false}) {
    String parseStr = "";
    if (raw.startsWith('{')) {
      try {
        return json.decode(raw) as Map<String, dynamic>;
      } catch (_) {}
    } else if (raw.startsWith("http")) { // 如果是以 http 开头就不用拼接了
      parseStr = raw;
    } else {
      parseStr = "http://dummy.com?$raw";
    }
    final uri = Uri.parse(parseStr);
    return uri.queryParameters;
  }

  bool onlyCompareKey = false;

  @override
  Widget getBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final topHeight = _dividerPosition * height;
        final bottomHeight = height - topHeight - 10 - 20; // 拖动条高度为10

        return Column(
          children: [
            Container(
              height: topHeight,
              color: Colors.blue[100],
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: controllerA,
                        expands: true,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "请求参数 A",
                        ),
                        onChanged: (_) => _compare(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: controllerB,
                        expands: true,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "请求参数 B",
                        ),
                        onChanged: (_) => _compare(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                setState(() {
                  _dividerPosition += details.delta.dy / height;
                  _dividerPosition = _dividerPosition.clamp(0.1, 0.9);
                });
              },
              child: Container(
                height: 10,
                color: Colors.grey,
                child: Center(child: Icon(Icons.drag_handle)),
              ),
            ),
            // 中间切换：是否只对比 key
            buildToolBtn(),
            Expanded(
              child: Container(
                height: bottomHeight,
                width: double.infinity,
                color: Colors.green[100],
                child: buildBottomList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildToolBtn() {
    return Container(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('只对比 Key'),
          Switch(
            value: onlyCompareKey,
            onChanged: (val) {
              setState(() {
                onlyCompareKey = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildBottomList() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderWithResizableDividers(),
          Expanded(
            child: ListView(
              children: _buildComparisonRows(_differences),
            ),
          ),
        ],
      );
  }

  double _leftRatio = 0.4;
  double _rightRatio = 0.4;

  Widget _buildHeaderWithResizableDividers() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final keyAWidth = totalWidth * _leftRatio;
        final valueAWidth = totalWidth * (1 - _leftRatio);
        final keyBWidth = totalWidth * _rightRatio;
        final valueBWidth = totalWidth * (1 - _rightRatio);
        return Row(
          children: [
            // 左半部分
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Flexible(
                    flex: (_leftRatio * 1000).toInt(),
                    child: _buildHeaderCell('keyA', keyAWidth),
                  ),
                  _buildDivider(onDrag: (dx) {
                    setState(() {
                      _leftRatio = (_leftRatio * totalWidth + dx) / totalWidth;
                      _leftRatio = _leftRatio.clamp(0.1, 0.9);
                    });
                  }),
                  Flexible(
                    flex: ((1 - _leftRatio) * 1000).toInt(),
                    child: _buildHeaderCell('valueA', valueAWidth),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Flexible(
                    flex: (_rightRatio * 1000).toInt(),
                    child: _buildHeaderCell('keyB', keyBWidth),
                  ),
                  _buildDivider(onDrag: (dx) {
                    setState(() {
                      _rightRatio = (_rightRatio * totalWidth + dx) / totalWidth;
                      _rightRatio = _rightRatio.clamp(0.1, 0.9);
                    });
                  }),
                  Flexible(
                    flex: ((1 - _rightRatio) * 1000).toInt(),
                    child: _buildHeaderCell('valueB', valueBWidth),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResizableCell({required String text, required double width}) {
    return SizedBox(
      width: width,
      child: SelectableText(text, style: TextStyle(fontSize: 13)),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.grey.shade300,
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResizableRow({
    required String keyA,
    required String valueA,
    required String keyB,
    required String valueB,
    Color? colorA,
    Color? colorB,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth / 2 - 8;

        final keyAWidth = totalWidth * _leftRatio;
        final valueAWidth = totalWidth * (1 - _leftRatio);
        final keyBWidth = totalWidth * _rightRatio;
        final valueBWidth = totalWidth * (1 - _rightRatio);

        return Row(
          children: [
            Expanded(child: Row(
              children: <Widget>[
                _buildCopyableCell(keyA, width: keyAWidth, color: colorA),
                SizedBox(width: 8),
                _buildCopyableCell(valueA, width: valueAWidth, color: colorA),],
            ),),
            Expanded(
              child: Row(
                children: [
                  _buildCopyableCell(keyB, width: keyBWidth, color: colorB),
                  SizedBox(width: 8),
                  _buildCopyableCell(valueB, width: valueBWidth, color: colorB),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildDivider({required void Function(double dx) onDrag}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
      child: Container(
        width: 8,
        height:20,
        color: Colors.grey.withOpacity(0.3),
        child: Center(
          child: Container(width: 2, color: Colors.grey),
        ),
      ),
    );
  }

  List<Widget> _buildComparisonRows(Map<String, Map<String, dynamic>> diffs) {
    final rows = <Widget>[];

    final onlyA = diffs.entries.where((e) => e.value['status'] == 'onlyInA').toList();
    final onlyB = diffs.entries.where((e) => e.value['status'] == 'onlyInB').toList();
    final partialEmpty = diffs.entries.where((e) => e.value['status'] == 'partialEmpty').toList();
    final both = diffs.entries.where((e) => e.value['status'] == 'both').toList();

    onlyA.sort((a, b) => a.key.compareTo(b.key));
    onlyB.sort((a, b) => a.key.compareTo(b.key));
    partialEmpty.sort((a, b) => a.key.compareTo(b.key));
    both.sort((a, b) => a.key.compareTo(b.key));

    for (var e in onlyA) {
      rows.add(_buildResizableRow(
        keyA: e.key,
        valueA: e.value['valueA'],
        keyB: '',
        valueB: '',
        colorA: Colors.red,
      ));
    }

    for (var e in onlyB) {
      rows.add(_buildResizableRow(
        keyA: '',
        valueA: '',
        keyB: e.key,
        valueB: e.value['valueB'],
        colorB: Colors.red,
      ));
    }

    for (var e in partialEmpty) {
      rows.add(_buildResizableRow(
        keyA: e.key,
        valueA: e.value['valueA'] ?? '',
        keyB: e.key,
        valueB: e.value['valueB'] ?? '',
        colorA: Colors.red,
        colorB: Colors.red,
      ));
    }

    for (var e in both) {
      rows.add(_buildResizableRow(
        keyA: e.key,
        valueA: e.value['valueA'],
        keyB: e.key,
        valueB: e.value['valueB'],
      ));
    }

    return rows;
  }

  Widget _buildCopyableCell(String text, {required double width, Color? color}) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已复制: $text')),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SelectableText(
            text,
            style: TextStyle(color: color ?? Colors.black, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
