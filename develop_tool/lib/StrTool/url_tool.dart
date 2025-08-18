import 'package:develop_tool/Base/mm_base_state.dart';
import 'package:develop_tool/components/mm_toast.dart';
import 'package:develop_tool/components/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:typed_data';
// 条件导入，只在非Web平台导入dart:io
import 'dart:io' if (dart.library.html) 'dart:html' as io;

class MMStrToolPage extends StatefulWidget {
  const MMStrToolPage({super.key});

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
  
  bool _isDragging = false;
  dynamic _selectedImageFile; // 在Web上不是File类型
  final ImagePicker _picker = ImagePicker();
  
  // 平台检测
  bool get isDesktop => !kIsWeb && _isDesktopPlatform();
  bool get isMobile => !kIsWeb && _isMobilePlatform();
  
  bool _isDesktopPlatform() {
    if (kIsWeb) return false;
    try {
      // 在Web平台，io.Platform不存在这些属性，所以需要用dynamic
      final platform = io.Platform as dynamic;
      return platform.isWindows || platform.isLinux || platform.isMacOS;
    } catch (e) {
      return false;
    }
  }
  
  bool _isMobilePlatform() {
    if (kIsWeb) return false;
    try {
      // 在Web平台，io.Platform不存在这些属性，所以需要用dynamic
      final platform = io.Platform as dynamic;
      return platform.isAndroid || platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  String _getFileName(dynamic file) {
    if (kIsWeb) {
      // Web平台，file可能是XFile或其他类型
      if (file is XFile) {
        return file.name;
      }
      return "选择的文件";
    } else {
      // 桌面/移动平台
      try {
        final pathSeparator = _getPlatformPathSeparator();
        return file.path.split(pathSeparator).last;
      } catch (e) {
        return "选择的文件";
      }
    }
  }

  String _getPlatformPathSeparator() {
    if (kIsWeb) return "/";
    try {
      final platform = io.Platform as dynamic;
      return platform.pathSeparator;
    } catch (e) {
      return "/";
    }
  }

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
        createQrImageDropArea(),
        Expanded(child: Stack(
          children: [
            Visibility(
              visible: _resultType == ResultType.qrCode,
              child: Container(
                margin: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: QrImageView(
                  data: _inputTextController.text.isEmpty ? "请输入内容" : _inputTextController.text,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),
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
                margin: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    createStrToolWidget(),
                    Text(_textLengthStr)
                  ],
                ),
              ),
            )
          ],
        )),
      ],
    );
  }

  final ScrollController _toolScrollController = ScrollController();

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
    return SizedBox(
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
        debugPrint('Unknown');
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

  final ScrollController _strScrollController = ScrollController();
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

  // 创建二维码图片区域 - 跨平台适配
  Widget createQrImageDropArea() {
    return Container(
      margin: const EdgeInsets.all(10),
      height: isDesktop ? 120 : 150,
      child: isDesktop ? _buildDesktopDropArea() : _buildMobilePickerArea(),
    );
  }

  // 桌面端拖拽区域
  Widget _buildDesktopDropArea() {
    return DropTarget(
      onDragDone: (detail) {
        if (detail.files.isNotEmpty) {
          final file = detail.files.first;
          _processQrImage(file);
        }
      },
      onDragEntered: (detail) {
        setState(() {
          _isDragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _isDragging = false;
        });
      },
      child: GestureDetector(
        onTap: _pickImageFile,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDragging ? Colors.blue : Colors.grey,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(10),
            color: _isDragging ? Colors.blue.shade50 : Colors.grey.shade50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 40,
                color: _isDragging ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedImageFile != null 
                    ? "已选择: ${_getFileName(_selectedImageFile!)}"
                    : "拖拽二维码图片到此处或点击选择文件",
                style: TextStyle(
                  color: _isDragging ? Colors.blue : Colors.grey.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (_selectedImageFile != null) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _processQrImage(_selectedImageFile!),
                  child: const Text("识别二维码"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 移动端选择区域
  Widget _buildMobilePickerArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 40,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedImageFile != null 
                ? "已选择: ${_getFileName(_selectedImageFile!)}"
                : "选择二维码图片进行识别",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImageFromCamera(),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text("拍照"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImageFromGallery(),
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text("相册"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          if (_selectedImageFile != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _processQrImage(_selectedImageFile!),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 36),
              ),
              child: const Text("识别二维码"),
            ),
          ],
        ],
      ),
    );
  }

  // 桌面端选择图片文件
  Future<void> _pickImageFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif'],
      );

      if (result != null) {
        setState(() {
          _selectedImageFile = result.files.single;
        });
      }
    } catch (e) {
      if (mounted) {
        MMToaster.showToast(context, "选择文件失败: ${e.toString()}");
      }
    }
  }

  // 移动端从相机拍照
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });
        if (mounted) {
          MMToaster.showToast(context, "照片拍摄成功");
        }
      }
    } catch (e) {
      if (mounted) {
        MMToaster.showToast(context, "拍照失败: ${e.toString()}");
      }
    }
  }

  // 移动端从相册选择
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });
        if (mounted) {
          MMToaster.showToast(context, "图片选择成功");
        }
      }
    } catch (e) {
      if (mounted) {
        MMToaster.showToast(context, "选择图片失败: ${e.toString()}");
      }
    }
  }

  // 处理二维码图片 - 跨平台优化
  Future<void> _processQrImage(dynamic imageFile) async {
    try {
      // 显示处理中提示
      if (mounted) {
        MMToaster.showToast(context, "正在识别二维码...");
      }
      
      // 读取图片文件的字节数据
      Uint8List bytes;
      
      if (kIsWeb) {
        // Web平台处理
        if (imageFile is XFile) {
          bytes = await imageFile.readAsBytes();
        } else {
          bytes = await imageFile.readAsBytes();
        }
      } else {
        // 桌面/移动平台处理
        if (imageFile is XFile) {
          bytes = await imageFile.readAsBytes();
        } else {
          // PlatformFile或其他类型
          if (imageFile.bytes != null) {
            bytes = Uint8List.fromList(imageFile.bytes!);
          } else if (imageFile.path != null) {
            // 创建File对象读取
            final file = (io.File as dynamic)(imageFile.path!);
            
            // 检查文件是否存在
            if (!await file.exists()) {
              if (mounted) {
                MMToaster.showToast(context, "文件不存在");
              }
              return;
            }

            // 检查文件大小（限制为10MB）
            final fileSize = await file.length();
            if (fileSize > 10 * 1024 * 1024) {
              if (mounted) {
                MMToaster.showToast(context, "文件过大，请选择小于10MB的图片");
              }
              return;
            }
            
            final fileBytes = await file.readAsBytes();
            bytes = Uint8List.fromList(fileBytes);
          } else {
            throw Exception("无法读取文件数据");
          }
        }
      }
      
      // 使用image包解码图片
      final image = img.decodeImage(bytes);
      if (image == null) {
        if (mounted) {
          MMToaster.showToast(context, "无法解析图片文件，请确保是有效的图片格式");
        }
        return;
      }

      // 解码二维码
      await _decodeQrFromImage(image);
      
    } catch (e) {
      if (mounted) {
        String errorMessage = "识别失败";
        if (e.toString().contains("Permission")) {
          errorMessage = "没有文件访问权限";
        } else if (e.toString().contains("FileSystemException")) {
          errorMessage = "文件访问错误";
        } else {
          errorMessage = "识别失败: ${e.toString()}";
        }
        MMToaster.showToast(context, errorMessage);
      }
    }
  }

  // 从图片中解码二维码 - 性能优化版本
  Future<void> _decodeQrFromImage(img.Image image) async {
    try {
      // 对于大图片进行缩放以提高性能
      img.Image processedImage = image;
      if (image.width > 1024 || image.height > 1024) {
        final scale = 1024 / (image.width > image.height ? image.width : image.height);
        final newWidth = (image.width * scale).round();
        final newHeight = (image.height * scale).round();
        processedImage = img.copyResize(image, width: newWidth, height: newHeight);
      }

      // 转换为灰度图像
      final grayImage = img.grayscale(processedImage);
      final width = grayImage.width;
      final height = grayImage.height;
      
      // 创建像素数组 - 优化内存分配
      final pixels = Int32List(width * height);
      int index = 0;
      
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = grayImage.getPixel(x, y);
          // 获取灰度值 - 使用正确的方法
          final r = pixel.r;
          pixels[index++] = r.toInt();
        }
      }

      // 创建LuminanceSource和BinaryBitmap
      final source = RGBLuminanceSource(width, height, pixels);
      final bitmap = BinaryBitmap(HybridBinarizer(source));
      
      // 创建二维码读取器并解码
      final reader = QRCodeReader();
      final result = reader.decode(bitmap);
      
      if (mounted) {
        setState(() {
          _inputTextController.text = result.text;
          _resultType = ResultType.normal;
          // 清空选中的文件以便下次选择
          _selectedImageFile = null;
        });
        
        MMToaster.showToast(context, "二维码识别成功！");
      }
      
    } catch (e) {
      if (mounted) {
        String errorMessage = "二维码解码失败";
        if (e.toString().contains("NotFoundException")) {
          errorMessage = "图片中未找到二维码，请确保二维码清晰完整";
        } else if (e.toString().contains("ChecksumException")) {
          errorMessage = "二维码损坏或模糊，请使用更清晰的图片";
        } else if (e.toString().contains("FormatException")) {
          errorMessage = "不支持的二维码格式";
        } else {
          errorMessage = "解码失败: ${e.toString()}";
        }
        MMToaster.showToast(context, errorMessage);
      }
    }
  }
}
