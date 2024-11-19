import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ume/monitor/utils/inner_utils.dart';

class LogRecorderDetailPage extends StatelessWidget {
  final File file;

  const LogRecorderDetailPage(this.file, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${file.name}")),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      child: SelectableText(file.readAsStringSync()),
    );
  }
}
