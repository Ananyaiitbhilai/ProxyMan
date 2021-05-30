import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proxyman/settings.dart';
import 'package:proxyman/shell.dart';
import 'package:proxyman/switch.dart';
import 'package:proxyman/proxy.dart';
import 'package:animations/animations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxy Manager',
      theme: ThemeData.dark(),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();

  static _HomeState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeState>();
}

class _HomeState extends State<Home> {
  static const adminPlatform =
      const MethodChannel("com.example.proxyman/admin");
  late ProxyMan proxyMan;
  late Widget desc;
  late Timer updateTimer;

  void rebuild() {
    setState(() {});
  }

  bool switchCallback(bool value) {
    int state = proxyMan.proxyIndex;
    if (state == -1) {
      Proxy? active = proxyMan.getSelectedProxy();
      if (active != null) {
        proxyMan.setGlobalProxy(active);
        return true;
      }
      return false;
    }
    proxyMan.remGlobalProxy();
    return proxyMan.proxyActive;
  }

  Widget setDesc() {
    if (proxyMan.proxyIndex == -2)
      return Text("Unknown External Proxy : ${proxyMan.globalProxyValue}");
    if (proxyMan.getSelectedProxy() == null)
      return Text("Create Proxy Profile in Settings First.");
    if (proxyMan.proxyIndex == -1) return Text("No Proxy Active");
    Proxy active = proxyMan.proxies[proxyMan.activeIndex];
    return Text("${active.name} Active : ${active.ip}:${active.port}");
  }

  Future<void> awaitLoad() async {
    while (!proxyMan.loaded) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    setState(() {});
  }

  void initAdmin() async {
    try {
      bool result = await adminPlatform.invokeMethod("getRights");
      print("MehodChannel returned : $result");
    } on PlatformException catch (error) {
      print("Admin init failed with error: ${error.message}");
    }
  }

  @override
  void initState() {
    initAdmin();
    super.initState();
    proxyMan = ProxyMan(true);
    updateTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      desc = setDesc();
      setState(() {});
    });
    awaitLoad();
  }

  @override
  void dispose() {
    proxyMan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    desc = setDesc();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Color(0xFF000000),
      body: Container(
        child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                PowerSwitch(
                  switchCallback,
                  size: 200,
                  initialValue: proxyMan.proxyActive,
                ),
                desc,
                Align(
                    alignment: Alignment.bottomCenter,
                    child: OpenContainer(
                      openColor: Colors.black,
                      closedColor: Colors.black,
                      transitionDuration: Duration(milliseconds: 500),
                      closedBuilder: (BuildContext c, VoidCallback action) {
                        return Icon(
                          Icons.settings,
                          size: 40,
                        );
                      },
                      openBuilder: (BuildContext c, VoidCallback action) =>
                          SettingsPage(),
                      tappable: true,
                    )),
              ],
            )),
      ),
    );
  }
}
