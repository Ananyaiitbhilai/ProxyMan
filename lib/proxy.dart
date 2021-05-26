import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:proxyman/shell.dart';

class Proxy {
  late String name;
  late int port;
  late String ip;

  Proxy(this.name, this.ip, this.port);

  bool validateIP() {
    RegExp ipRegex = RegExp(
        r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$");
    if (ipRegex.hasMatch(this.ip)) return true;
    return false;
  }

  bool validatePort() {
    if (port >= 1024 && port <= 49151) return true;
    return false;
  }

  bool valiadate() {
    return (validateIP() && validatePort());
  }
}

class ProxyMan {
  //used for reading from parent class
  bool loaded = false;
  //the proxy stuff
  List<Proxy> proxies = [];
  int activeIndex = 0;
  bool proxyActive = false;
  int proxyIndex = -1;
  String globalProxyValue = '';
  //instances of required external classes
  late SharedPreferences prefs;
  late Shell superuser;
  late Timer updateTimer;

  // INTERNAL FUNCTIONS : Try not to call them directly from other classes

  ProxyMan(bool needSu) {
    initialize(needSu);
  }

  Future<void> initialize(bool needSu) async {
    prefs = await SharedPreferences.getInstance();
    superuser = Shell(reqSU: needSu);
    while (!superuser.loaded) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    load();
    setProxyState();
    updateTimer = Timer.periodic(Duration(milliseconds: 2000), (timer) {
      setProxyState();
    });
    loaded = true;
  }

  void load() async {
    int? temp = prefs.getInt("length");
    int len = temp ?? 0;
    activeIndex = prefs.getInt("active") ?? 0;
    proxies.clear();
    for (int i = 0; i < len; i++) {
      List<String>? temp2 = prefs.getStringList("Proxy $i");
      if (temp2 != null) {
        proxies.add(Proxy(temp2[0], temp2[1], int.parse(temp2[2])));
      }
    }
  }

  void save() async {
    prefs.setInt("length", proxies.length);
    prefs.setInt("active", activeIndex);
    for (int i = 0; i < proxies.length; i++)
      prefs.setStringList("Proxy $i",
          [proxies[i].name, proxies[i].ip, proxies[i].port.toString()]);
  }

  void parseGlobalProxy(value) {
    value = value.split("\n")[0];
    value = value.toString().replaceAll(new RegExp(r"\s+"), "");
    globalProxyValue = value.toString();
    if (value == ":0") {
      proxyActive = false;
    } else {
      RegExp ip = RegExp(
          r"(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$");
      if (ip.hasMatch(value.split(":")[0]) &&
          int.parse(value.split(":")[1]) <= 49151 &&
          int.parse(value.split(":")[1]) >= 1024)
        proxyActive = true;
      else
        proxyActive = false;
    }
  }

  void dispose() {
    superuser.dispose();
  }

  //EXTERNAL FUNCTIONS

  bool add(String name, String ip, int port) {
    Proxy temp = Proxy(name, ip, port);
    if (temp.valiadate()) {
      proxies.add(Proxy(name, ip, port));
      save();
      return true;
    }
    return false;
  }

  bool addProxy(Proxy proxy) {
    if (proxy.valiadate()) {
      proxies.add(proxy);
      save();
      return true;
    }
    return false;
  }

  bool rem(int index) {
    proxies.removeAt(index);
    save();
    return true;
  }

  void setProxyState() {
    superuser.exec("settings get global http_proxy", parseGlobalProxy);
    if (proxyActive == false) {
      proxyIndex = -1;
      return;
    }
    int retval = -2;
    proxies.forEach((element) {
      List<String> temp = globalProxyValue.split(':');
      bool a1 = temp[0] == element.ip;
      bool a2 = temp[1].toString() == element.port.toString();
      if (a1 && a2) retval = proxies.indexOf(element);
    });
    proxyIndex = retval;
  }

  Proxy? getSelectedProxy() {
    if (proxies.length == 0) return null;
    return proxies[activeIndex];
  }

  void remGlobalProxy() {
    superuser.exec("settings put global http_proxy :0", (p0) => null);
    proxyActive = false;
    proxyIndex = -1;
  }

  void setGlobalProxy(Proxy proxy) {
    superuser.exec("settings put global http_proxy ${proxy.ip}:${proxy.port}",
        (p0) => null);
    proxyActive = true;
    proxyIndex = proxies.indexOf(proxy);
  }
}
