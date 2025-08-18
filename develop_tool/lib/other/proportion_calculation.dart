import 'package:develop_tool/Base/mm_base_state.dart';
import 'package:flutter/material.dart';

class ProportionCalculation extends StatefulWidget {
  const ProportionCalculation({super.key});

  @override
  State<ProportionCalculation> createState() => _ProportionCalculationState();
}

class _ProportionCalculationState extends MMBaseState<ProportionCalculation> {
  final TextEditingController _rmbAmountController = TextEditingController(text: "218");
  final TextEditingController _mhbAmountController = TextEditingController(text: "30000000");
  final TextEditingController _queryRmbController = TextEditingController(text: "100");
  final TextEditingController _pointCardRateController = TextEditingController(text: "14500");
  final TextEditingController _targetMhbController = TextEditingController(text: "30000000");
  final TextEditingController _targetRmbController = TextEditingController(text: "218");
  
  final double rmbToPointCard = 10; // 1 RMB = 10 点卡

  String rmbToMhbResult = "";
  String queryRmbToMhbResult = "";
  String queryRmbWithFeeResult = "";
  String requiredRmbForTargetResult = "";
  String pointCardToMhbResult = "";
  String requiredRmbForPointCardResult = "";
  String requiredMhbForTargetRmbResult = "";
  String mhbActualValueResult = "";
  String mhbAfterFeeValueResult = "";
  String sellMhbResult = "";
  String comparisonResult = "";
  String comparisonDetails = "";

  @override
  String get barTitle {
    return "比例换算";
  }

  @override
  void initState() {
    super.initState();
    // 添加实时监听
    _rmbAmountController.addListener(calculateRmbProportions);
    _mhbAmountController.addListener(calculateRmbProportions);
    _queryRmbController.addListener(calculateRmbProportions);
    _pointCardRateController.addListener(calculatePointCardProportions);
    _targetMhbController.addListener(() {
      calculateRmbProportions();
      calculatePointCardProportions();
    });
    _targetRmbController.addListener(calculatePointCardProportions);
    
    // 执行初始计算，显示默认值的结果
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateRmbProportions();
      calculatePointCardProportions();
    });
  }

  @override
  void dispose() {
    _rmbAmountController.removeListener(calculateRmbProportions);
    _mhbAmountController.removeListener(calculateRmbProportions);
    _queryRmbController.removeListener(calculateRmbProportions);
    _pointCardRateController.removeListener(calculatePointCardProportions);
    _targetMhbController.removeListener(() {
      calculateRmbProportions();
      calculatePointCardProportions();
    });
    _targetRmbController.removeListener(calculatePointCardProportions);
    _rmbAmountController.dispose();
    _mhbAmountController.dispose();
    _queryRmbController.dispose();
    _pointCardRateController.dispose();
    _targetMhbController.dispose();
    _targetRmbController.dispose();
    super.dispose();
  }

  void calculateRmbProportions() {
    double rmbAmount = double.tryParse(_rmbAmountController.text) ?? 0;
    double mhbAmount = double.tryParse(_mhbAmountController.text) ?? 0;
    double queryRmb = double.tryParse(_queryRmbController.text) ?? 0;
    double targetMhb = double.tryParse(_targetMhbController.text) ?? 0;
    
    setState(() {
      if (rmbAmount > 0 && mhbAmount > 0) {
        // 计算 1 RMB = 多少 MHB
        double mhbPerRmb = mhbAmount / rmbAmount;
        rmbToMhbResult = "${mhbPerRmb.toStringAsFixed(2)} MHB";
        
        // 计算指定RMB对应的MHB数量
        if (queryRmb > 0) {
          double queryMhbAmount = queryRmb * mhbPerRmb;
          double queryMhbWithFee = queryMhbAmount / 0.95; // 加上5%手续费后需要的MHB
          queryRmbToMhbResult = "${queryMhbAmount.toStringAsFixed(0)} MHB";
          queryRmbWithFeeResult = "${queryMhbWithFee.toStringAsFixed(0)} MHB";
        } else {
          queryRmbToMhbResult = "";
          queryRmbWithFeeResult = "";
        }
        
        if (targetMhb > 0) {
          // 计算达到目标需要多少 RMB
          double requiredRmb = targetMhb / mhbPerRmb;
          requiredRmbForTargetResult = "${requiredRmb.toStringAsFixed(2)} RMB";
        } else {
          requiredRmbForTargetResult = "";
        }
      } else {
        rmbToMhbResult = "";
        queryRmbToMhbResult = "";
        queryRmbWithFeeResult = "";
        requiredRmbForTargetResult = "";
      }
      calculateComparison();
      calculateSellMhb();
    });
  }

  void calculatePointCardProportions() {
    double pointCardRate = double.tryParse(_pointCardRateController.text) ?? 0;
    double targetMhb = double.tryParse(_targetMhbController.text) ?? 0;
    double targetRmb = double.tryParse(_targetRmbController.text) ?? 0;
    double rmbAmount = double.tryParse(_rmbAmountController.text) ?? 0;
    double mhbAmount = double.tryParse(_mhbAmountController.text) ?? 0;
    
    setState(() {
      if (pointCardRate > 0) {
        pointCardToMhbResult = "${pointCardRate.toStringAsFixed(0)} MHB";
        
        // 达到目标MHB需要多少RMB
        if (targetMhb > 0) {
          double requiredPointCards = targetMhb / pointCardRate;
          double requiredRmb = requiredPointCards / rmbToPointCard;
          requiredRmbForPointCardResult = "${requiredRmb.toStringAsFixed(2)} RMB";
        } else {
          requiredRmbForPointCardResult = "";
        }
        
        // 购买到目标RMB所需的MHB数量
        if (targetRmb > 0) {
          double requiredPointCards = targetRmb * rmbToPointCard;
          double requiredMhb = requiredPointCards * pointCardRate;
          requiredMhbForTargetRmbResult = "${requiredMhb.toStringAsFixed(0)} MHB";
          
          // 计算MHB的实际价值和扣除手续费后的价值
          if (rmbAmount > 0 && mhbAmount > 0) {
            double mhbPerRmb = mhbAmount / rmbAmount;
            double actualValue = requiredMhb / mhbPerRmb;
            double afterFeeValue = actualValue * (1 - 0.05); // 扣除5%手续费
            
            mhbActualValueResult = "${actualValue.toStringAsFixed(2)} RMB";
            mhbAfterFeeValueResult = "${afterFeeValue.toStringAsFixed(2)} RMB";
          } else {
            mhbActualValueResult = "";
            mhbAfterFeeValueResult = "";
          }
        } else {
          requiredMhbForTargetRmbResult = "";
          mhbActualValueResult = "";
          mhbAfterFeeValueResult = "";
        }
      } else {
        pointCardToMhbResult = "";
        requiredRmbForPointCardResult = "";
        requiredMhbForTargetRmbResult = "";
        mhbActualValueResult = "";
        mhbAfterFeeValueResult = "";
      }
      calculateSellMhb();
    });
  }


  void calculateSellMhb() {
    double rmbAmount = double.tryParse(_rmbAmountController.text) ?? 0;
    double mhbAmount = double.tryParse(_mhbAmountController.text) ?? 0;
    
    if (rmbAmount > 0 && mhbAmount > 0) {
      // 计算 3000w MHB 对应的当前汇率 RMB
      double currentRmbFor3000w = (30000000 / mhbAmount) * rmbAmount;
      // 出售收益 = 当前汇率 RMB * 0.95
      double sellRevenue = currentRmbFor3000w * 0.95;
      
      sellMhbResult = "${sellRevenue.toStringAsFixed(2)} RMB";
    } else {
      sellMhbResult = "";
    }
  }

  void calculateComparison() {
    // This method was referenced in the UI but not defined - adding empty implementation
    // since we're removing the 60 point card comparison functionality
    setState(() {
      comparisonResult = "";
      comparisonDetails = "";
    });
  }

  void clear() {
    _rmbAmountController.text = "218";
    _mhbAmountController.text = "30000000";
    _queryRmbController.text = "100";
    _pointCardRateController.text = "14500";
    _targetMhbController.text = "30000000";
    _targetRmbController.text = "218";
    setState(() {
      rmbToMhbResult = "";
      queryRmbToMhbResult = "";
      queryRmbWithFeeResult = "";
      requiredRmbForTargetResult = "";
      pointCardToMhbResult = "";
      requiredRmbForPointCardResult = "";
      requiredMhbForTargetRmbResult = "";
      mhbActualValueResult = "";
      mhbAfterFeeValueResult = "";
      sellMhbResult = "";
      comparisonResult = "";
      comparisonDetails = "";
    });
  }

  @override
  Widget getBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RMB 汇率换算部分
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "RMB 汇率换算",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _rmbAmountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "RMB数量",
                                border: OutlineInputBorder(),
                                hintText: "218",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "RMB =",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _mhbAmountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "MHB数量",
                                border: OutlineInputBorder(),
                                hintText: "30000000",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "MHB",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _queryRmbController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "RMB数量",
                                border: OutlineInputBorder(),
                                hintText: "100",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "RMB =",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "基础换算:",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        queryRmbToMhbResult.isEmpty ? "0 MHB" : queryRmbToMhbResult,
                                        style: TextStyle(
                                          color: queryRmbToMhbResult.isEmpty ? Colors.grey : Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (queryRmbWithFeeResult.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "加手续费后:",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          queryRmbWithFeeResult,
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (rmbToMhbResult.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "1 RMB = ",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    rmbToMhbResult,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (sellMhbResult.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Divider(),
                                const SizedBox(height: 8),
                                const Text(
                                  "出售 3000w MHB 收益:",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      "收益: ",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      sellMhbResult,
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      " (市场价95%)",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 点卡比例换算部分
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "点卡比例换算",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            "1 点卡 =",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _pointCardRateController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "输入MHB数量",
                                border: OutlineInputBorder(),
                                hintText: "14500",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "MHB",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            "目标 MHB:",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _targetMhbController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "输入目标MHB数量",
                                border: OutlineInputBorder(),
                                hintText: "30000000",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            "目标 RMB:",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _targetRmbController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "输入目标RMB数量",
                                border: OutlineInputBorder(),
                                hintText: "218",
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (pointCardToMhbResult.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "1 点卡 = ",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    pointCardToMhbResult,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (requiredRmbForPointCardResult.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text(
                                      "达到目标需要: ",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      requiredRmbForPointCardResult,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (requiredMhbForTargetRmbResult.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Divider(),
                                const SizedBox(height: 8),
                                const Text(
                                  "购买到目标RMB所需:",
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      "需要 MHB: ",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      requiredMhbForTargetRmbResult,
                                      style: const TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (mhbActualValueResult.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text(
                                        "实际价值: ",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        mhbActualValueResult,
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (mhbAfterFeeValueResult.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text(
                                        "扣费后价值: ",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        mhbAfterFeeValueResult,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        " (扣除5%手续费)",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 清空按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: clear,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("清空"),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 说明信息
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "计算说明:",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "• RMB汇率: 输入多少RMB能兑换多少MHB（如218 RMB = 3000w MHB）",
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "• 点卡比例: 1点卡能兑换多少MHB (1RMB=10点卡)",
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "• 目标MHB: 可修改目标金额",
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "• 目标RMB: 可修改目标RMB金额，计算所需MHB及其价值",
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "• 支持实时计算，输入即可看到结果",
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "• 计算购买到目标RMB所需MHB数量及实际价值",
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "• 计算出售MHB的RMB收益 (汇率*0.95)",
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "• 显示扣除5%手续费后的真实价值",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}