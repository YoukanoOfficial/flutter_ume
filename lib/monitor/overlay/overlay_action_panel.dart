import 'package:flutter/material.dart';
import 'package:flutter_ume_action/monitor/awesome_monitor.dart';
import 'package:flutter_ume_action/monitor/monitor_action_widget.dart';
import 'package:flutter_ume_action/monitor/page/exception_recorder_page.dart';
import 'package:flutter_ume_action/monitor/utils/navigator_util.dart';

class OverlayActionPanel extends StatefulWidget {
  @override
  _OverlayActionPanelState createState() => _OverlayActionPanelState();
}

class _OverlayActionPanelState extends State<OverlayActionPanel> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: Wrap(
            runSpacing: 4,
            spacing: 4,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              if (Monitor.instance.actions != null)
                ...?Monitor.instance.actions,
              MonitorActionWidget(
                title: 'ExceptionRecorder',
                onTap: () =>
                    NavigatorUtil.pushPage(context, ExceptionRecorderPage()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
