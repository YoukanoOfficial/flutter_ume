import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_shrink_widget/json_shrink_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_ume_action/monitor/awesome_monitor.dart';
import 'package:flutter_ume_action/monitor/monitor_message_notifier.dart';
import 'package:flutter_ume_action/monitor/utils/inner_utils.dart';
import 'package:flutter_ume_action/monitor/utils/navigator_util.dart';
import 'package:flutter_ume_action/monitor/widgets/input_panel_field.dart';

import 'log_recorder_page.dart';

class CurlPage extends StatefulWidget {
  final String? tag;

  const CurlPage({Key? key, this.tag}) : super(key: key);

  @override
  _CurlPageState createState() => _CurlPageState();
}

class _CurlPageState extends State<CurlPage> {
  static RegExp _regex = RegExp(r"\[([^\[\]]*)\]");

  static RegExp _regexUrl = RegExp(
      r"(https?|ftp|file):(//|\\/\\/)[-A-Za-z0-9+&@#/\%?\\/=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");

  static Map<String?, Map<String?, Widget?>> _tabWidgetCached = Map();

  TextEditingController _controller = TextEditingController();
  List<String> _filerDatas = [];
  BuildContext? _context;

  @override
  void initState() {
    _controller.addListener(() => _startFilter(updateView: true));
  }

  _startFilter({bool updateView = false}) {
    if (InnerUtils.isEmpty(_controller.text)) {
      if (updateView) {
        setState(() {
          _filerDatas.clear();
        });
      } else {
        _filerDatas.clear();
      }
      return;
    }

    if (_controller.text.length > 3) {
      MonitorMessageNotifier<String>? notifier =
          Monitor.instance.getNotifier(widget.tag);
      if (notifier?.message != null && notifier!.message!.isNotEmpty) {
        _filerDatas.clear();
        for (int i = 0; i < notifier.message!.length; i++) {
          String msg = notifier.message![i];
          if (msg.contains(_controller.text)) {
            _filerDatas.add(msg);
          }
        }
        if (_filerDatas.isNotEmpty && updateView) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    MonitorMessageNotifier<String>? notifier =
        Monitor.instance.getNotifier(widget.tag);
    if (notifier?.message == null || notifier!.message!.isEmpty) {
      _tabWidgetCached[widget.tag]?.clear();
    }
    _context = context;
    return ValueListenableBuilder<List<String>>(
      valueListenable: notifier!.notifier!,
      builder: (_, List<String> datas, child) {
        if (widget.tag == 'Curl' ||
            widget.tag == 'AesDecode' ||
            widget.tag == 'AesDecodes') {
          _startFilter();
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InputPanelField(
                      hintText: 'Enter keywords to search for interfaces',
                      controller: _controller,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      NavigatorUtil.pushPage(context, LogRecorderPage());
                    },
                    icon: Icon(Icons.view_list_sharp, color: Colors.white),
                  ),
                ],
              ),
              Expanded(child: _buildListView(datas)),
            ],
          );
        }
        return _buildListView(datas);
      },
    );
  }

  _buildListView(List<String>? datas) {
    List<String>? results = datas;
    if (!InnerUtils.isEmpty(_controller.text)) {
      results = _filerDatas;
    }
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView.builder(
        itemBuilder: (_, index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () {
              String content = index >= results!.length ? "" : results[index];
              if (InnerUtils.isEmpty(content)) {
                return;
              }
              if (widget.tag == 'Curl' && content.startsWith("curl -X GET")) {
                Iterable<RegExpMatch> matchers = _regexUrl.allMatches(content);
                if (matchers.isNotEmpty) {
                  String? regexText = matchers.elementAt(0).group(0);
                  if (!InnerUtils.isEmpty(regexText)) {
                    InnerUtils.jumpLink(regexText);
                  }
                }
              }
            },
            onLongPress: () {
              String content = index >= results!.length ? "" : results[index];
              if (widget.tag == 'Page') {
                content = content.split('/').last;
              }
              Clipboard.setData(ClipboardData(text: content));
              showToast('复制成功');
            },
            child: _buildCachedWidget(
                index >= results!.length ? "" : results[index]),
          ),
        ),
        itemCount: results?.length ?? 0,
      ),
    );
  }

  _buildText(String text) {
    if (widget.tag == 'Curl' && !InnerUtils.isEmpty(_controller.text)) {
      text = text.replaceAll(_controller.text, '[${_controller.text}]');
      return _formatColorRichText(text, [
        TextStyle(color: Colors.white),
        TextStyle(color: Colors.red),
      ]);
    }

    if (widget.tag == 'AesDecode' || widget.tag == 'AesDecodes') {
      int index = text.indexOf('\n');
      String highLightText = text.substring(0, index);
      text = text.substring(index + 1, text.length);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InnerUtils.isEmpty(_controller.text)
              ? Text(highLightText, style: TextStyle(color: Colors.cyanAccent))
              : _formatColorRichText(
                  highLightText.replaceAll(
                      _controller.text, '[${_controller.text}]'),
                  [
                    TextStyle(color: Colors.cyanAccent),
                    TextStyle(color: Colors.red),
                  ],
                ),
          JsonShrinkWidget(json: text, deepShrink: 1),
        ],
      );
    }
    return Text(text, style: TextStyle(color: Colors.white));
  }

  _buildCachedWidget(String text) {
    if (InnerUtils.isEmpty(text)) return Text('');
    String key = InnerUtils.generateMd5(text + _controller.text);
    Map<String?, Widget?>? cached = _tabWidgetCached[widget.tag];
    if (cached == null) {
      cached = Map();
      _tabWidgetCached[widget.tag] = cached;
    }
    Widget? child = cached[key];
    if (child == null) {
      child = _buildText(text);
      cached[key] = child;
    }
    return child;
  }

  RichText _formatColorRichText(
    String content,
    List<TextStyle> styles, {
    TextAlign textAlign = TextAlign.left,
    TextOverflow overflow = TextOverflow.visible,
  }) {
    List<TextSpan> spans = [];
    Iterable<RegExpMatch> matchers = _regex.allMatches(content);
    int count = 1;
    TextStyle? style;
    for (Match m in matchers) {
      if (count < styles.length) {
        style = styles[count];
      }
      String? regexText = m.group(0);
      int index = content.indexOf(regexText!);
      spans.add(TextSpan(text: content.substring(0, index)));
      content = content.substring(index, content.length);
      spans.add(TextSpan(
          text: regexText.substring(1, regexText.length - 1), style: style));
      content = content.substring(regexText.length, content.length);
      count++;
    }
    spans.add(TextSpan(text: content));
    return RichText(
      textAlign: textAlign,
      overflow: overflow,
      text: TextSpan(
        text: '',
        style: styles[0],
        children: spans,
      ),
    );
  }
}
