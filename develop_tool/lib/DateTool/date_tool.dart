import 'package:develop_tool/Base/mm_base_state.dart';
import 'package:develop_tool/components/mm_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MMDateTool extends StatefulWidget {
  const MMDateTool({super.key});

  @override
  State<MMDateTool> createState() => _MMDateToolState();
}

class _MMDateToolState extends MMBaseState<MMDateTool> {

  final TextEditingController _controller = TextEditingController();

  final TextEditingController _timeController = TextEditingController();

  bool needMillisecond = false;

  @override
  String get barTitle {
    return "date操作";
  }

  @override
  void initState() {
    super.initState();
    _updateTimestamp();
    _convertTimestamp();
    _loadLastSetting();
  }

  Future<void> _loadLastSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      needMillisecond = prefs.getBool("kDateTool_NeedMillisecond") ?? false;
    });
  }

  Future<void> _saveUserSetting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("kDateTool_NeedMillisecond", needMillisecond);
  }

  Widget getTimeStampWidget(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("当前时间戳 (${needMillisecond ? "毫秒" : "秒"}):", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
              ElevatedButton(
                onPressed: _copyInput,
                child: const Text("复制"),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            ElevatedButton(
              onPressed: _updateTimestamp,
              child: const Text("更新时间戳"),
            ),
            const SizedBox(width: 8,),
            ElevatedButton(
              onPressed: _convertTimestamp,
              child: const Text("转换为日期"),
            ),
            const SizedBox(width: 8,),
            ElevatedButton(
              onPressed: () {
                _addMinutes(1);
              },
              child: const Text("加 1 分钟"),
            ),
            const SizedBox(width: 8,),
            ElevatedButton(
              onPressed:  () {
                _addMinutes(10);
              },
              child: const Text("加 10 分钟"),
            )
          ],),
          const SizedBox(height: 16),
          Row(
            children: [
              Text("当前时间戳 (${needMillisecond ? "毫秒" : "秒"}):", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
              Expanded(
                child: TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16,),
          Row(children: [
            const Text("展示毫秒:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
            Switch(
              value: needMillisecond,
              onChanged: (value) {
                setState(() {
                  needMillisecond = value;
                  _updateTimestamp();
                  _convertTimestamp();
                  _saveUserSetting();
                });
              },
              activeColor: Colors.green,  // 选中时的颜色
              inactiveThumbColor: Colors.grey,  // 关闭时的滑块颜色
              inactiveTrackColor: Colors.grey[300], // 关闭时的轨道颜色
            ),
          ],)
        ],
      ),
    );
  }

  @override
  Widget getBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        getTimeStampWidget(context)
      ],
    );
  }
}

extension _MMDateToolStateExtension on _MMDateToolState {

  void _copyInput() {
    Clipboard.setData(ClipboardData(text: _controller.text));
    MMToaster.showToast(context, "已复制到剪切板");
  }

  // 点击按钮时的逻辑
  void _addMinutes(int minute) {
    // 获取当前的时间戳
    int currentTimestamp = int.tryParse(_controller.text) ?? 0;
    // 增加 60 秒（1 分钟）
    int result =  60 * minute;
    if (needMillisecond) {
      result *= 1000;
    }
    currentTimestamp += result;
    // 更新 TextField 的内容
    setState(() {
      _controller.text = currentTimestamp.toString();
    });
  }

  void _updateTimestamp() {
    int timestamp = DateTime.now().millisecondsSinceEpoch ;
    if(needMillisecond == false) {
      timestamp = timestamp ~/ 1000; // 转换为秒
    }
    _controller.text = timestamp.toString();
  }

  /// 将时间戳转换为日期字符串（不使用 `intl`）
  void _convertTimestamp() {
    int? timestamp = int.tryParse(_controller.text);
    if (timestamp != null) {
      if(needMillisecond == false) {
        timestamp = timestamp * 1000;
      }
      DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      String formattedDate = _formatDateTime(date);
      _timeController.text = formattedDate;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("请输入有效的时间戳")),
      );
    }
  }

  /// 自定义格式化日期方法
  String _formatDateTime(DateTime date) {
    return "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} "
        "${_twoDigits(date.hour)}:${_twoDigits(date.minute)}:${_twoDigits(date.second)}";
  }

  /// 保证个位数前补 `0`
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}