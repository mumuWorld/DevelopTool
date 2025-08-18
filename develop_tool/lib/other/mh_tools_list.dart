import 'package:develop_tool/Base/mm_base_state.dart';
import 'package:develop_tool/main_label_cell.dart';
import 'package:develop_tool/other/MengHuan.dart';
import 'package:develop_tool/other/proportion_calculation.dart';
import 'package:flutter/material.dart';

class MHToolsList extends StatefulWidget {
  const MHToolsList({super.key});

  @override
  State<MHToolsList> createState() => _MHToolsListState();
}

class _MHToolsListState extends MMBaseState<MHToolsList> {
  late var dataList = [
    "法伤计算器",
    "比例换算"
  ];

  @override
  String get barTitle {
    return "MH 工具";
  }

  void handleClickCallBack(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const MMMengHuanTool();
      }));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const ProportionCalculation();
      }));
    }
  }

  Widget buildCell(BuildContext context, int index) {
    var item = dataList[index];
    return MMMainLabelCell(
      title: item,
      callback: () {
        handleClickCallBack(index);
      },
    );
  }

  @override
  Widget getBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return buildCell(context, index);
          }, childCount: dataList.length)
        )
      ],
    );
  }
}