import 'package:develop_tool/Base/mm_base_state.dart';
import 'package:flutter/material.dart';



class MMMengHuanTool extends StatefulWidget {
  const MMMengHuanTool({super.key});

  @override
  State<MMMengHuanTool> createState() => _MMMengHuanToolState();
}

class _MMMengHuanToolState extends MMBaseState<MMMengHuanTool> {

  final TextEditingController _shangController = TextEditingController();
  final TextEditingController _moController = TextEditingController();
  final TextEditingController _duanController = TextEditingController();
  final TextEditingController _liliangController = TextEditingController();
  final TextEditingController _tizhiController = TextEditingController();
  final TextEditingController _nailiController = TextEditingController();

  String fashang = "";

  String tenFaShang = "";

  @override
  String get barTitle {
    return "mh";
  }

  Widget getFaxiWidget(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text("伤害:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
              Expanded(
                child: TextField(
                  controller: _shangController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Text("当前段数:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
              Expanded(
                child: TextField(
                  controller: _duanController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ]
          ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text("魔力:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
          Expanded(
            child: TextField(
              controller: _moController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Text("力量:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
          Expanded(
            child: TextField(
              controller: _liliangController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Text("体质:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
          Expanded(
            child: TextField(
              controller: _tizhiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Text("耐力:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
          Expanded(
            child: TextField(
              controller: _nailiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ]),

          const SizedBox(height: 8,),
          ElevatedButton(
            onPressed: calculateFaShang,
            child: const Text("计算法伤"),
          ),
          const SizedBox(height: 8,),
          ElevatedButton(
            onPressed: clear,
            child: const Text("清空"),
          ),
          const SizedBox(height: 8,),
          Row(children: [
            Text("当前法伤", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
            const SizedBox(width: 8,),
            Text(fashang, style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),),
          ],),
          const SizedBox(height: 8,),
          Row(children: [
            Text("10段法伤", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
            const SizedBox(width: 8,),
            Text(tenFaShang, style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),),
          ],),
        ],
      ),
    );
  }

  void calculateFaShang() {
    int shang = int.tryParse(_shangController.text) ?? 0;
    int mo = int.tryParse(_moController.text) ?? 0;
    int duan = int.tryParse(_duanController.text) ?? 0;

    double sh = (shang / 4);
    sh += mo * 0.7;

    int liliang = int.tryParse(_liliangController.text) ?? 0;
    int tizhi = int.tryParse(_tizhiController.text) ?? 0;
    int naili = int.tryParse(_nailiController.text) ?? 0;

    sh += liliang * 0.4;
    sh += tizhi * 0.3;
    sh += naili * 0.2;

    int c = 10 - duan;
    double shiduanSH = sh;
    if (c > 0) {
      shiduanSH = (sh + (c * 2));
    }

    setState(() {
      fashang = sh.toString();
      tenFaShang = shiduanSH.toString();
    });

  }

  void clear() {
    _shangController.text = "";
    _moController.text = "";
    _duanController.text = "";
  }

  @override
  Widget getBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        getFaxiWidget(context)
      ],
    );
  }

}