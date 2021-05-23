import 'dart:async';
import 'dart:io';
import 'dart:convert';

class Shell {
  bool loaded = false;
  bool reqSU;
  late Process shellProcess;
  late Stream shellOutput;
  late StreamSubscription activeSub;

  Shell({this.reqSU: false}) {
    init();
  }

  Future<void> init() async {
    (reqSU)
        ? shellProcess = await Process.start("su", [])
        : shellProcess = await Process.start("sh", []);
    shellOutput =
        shellProcess.stdout.asBroadcastStream().transform(utf8.decoder);
    loaded = true;
  }

  void exec(String command, Function(dynamic) callback) {
    shellProcess.stdin.writeln(command);
    activeSub = shellOutput.listen((value) {
      callback(value);
      activeSub.cancel();
    });
  }

  Future<void> dispose() async {
    shellProcess.kill();
  }
}
