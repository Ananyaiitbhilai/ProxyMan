import 'package:flutter/material.dart';
import 'package:proxyman/proxy.dart';

Widget settingsDialog() {
  return SimpleDialog(
    title: Text("Settings"),
    children: [Container()],
    backgroundColor: Color(0xFF132C33),
  );
}

class ProxyCard extends StatefulWidget {
  final int index;
  ProxyCard(this.index);

  @override
  _ProxyCardState createState() => _ProxyCardState();
}

class _ProxyCardState extends State<ProxyCard> {
  late ProxyMan manager;
  late Proxy proxy;

  @override
  Widget build(BuildContext context) {
    manager = SettingsPage.of(context)!.manager;
    proxy = manager.proxies[widget.index];
    return ListTile(
      leading: Radio(
          value: widget.index,
          groupValue: manager.activeIndex,
          onChanged: (int? value) {
            manager.activeIndex = value!;
            manager.save();
            SettingsPage.of(context).rebuild();
          }),
      title: Text(proxy.name),
      subtitle: Text("${proxy.ip}:${proxy.port}"),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          manager.rem(widget.index);
          SettingsPage.of(context).rebuild();
        },
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  static of(BuildContext context) =>
      context.findAncestorStateOfType<_SettingsPageState>();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ProxyMan manager;
  late Proxy tempProxy;

  Widget error = SizedBox(
    height: 0,
    width: 0,
  );

  void awaitLoad() async {
    while (!manager.loaded) await Future.delayed(Duration(milliseconds: 100));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    manager = ProxyMan(false);
    awaitLoad();
    tempProxy = Proxy('', '', 0);
  }

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  void setError(String errorString) async {
    error = Text(errorString, style: TextStyle(color: Colors.red));
    rebuild();
    await Future.delayed(Duration(seconds: 2));
    error = SizedBox(
      height: 0,
      width: 0,
    );
    rebuild();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            Card(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.near_me,
                        color: Colors.blue,
                      ),
                      filled: true,
                      border: InputBorder.none,
                      labelText: "Proxy Name",
                      labelStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.transparent,
                    ),
                    autofocus: false,
                    onChanged: (value) {
                      tempProxy.name = value;
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.web,
                              color: Colors.blue,
                            ),
                            filled: true,
                            border: InputBorder.none,
                            labelText: "IP Address",
                            labelStyle: TextStyle(color: Colors.white),
                            fillColor: Colors.transparent,
                          ),
                          autofocus: false,
                          onChanged: (value) {
                            tempProxy.ip = value;
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        ":",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            border: InputBorder.none,
                            labelText: "Port",
                            labelStyle: TextStyle(color: Colors.white),
                            fillColor: Colors.transparent,
                          ),
                          autofocus: false,
                          onChanged: (value) {
                            if (value.length > 0)
                              tempProxy.port = int.parse(value);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (tempProxy.valiadate() && tempProxy.name.length > 0)
                          manager.addProxy(tempProxy);
                        else {
                          (tempProxy.name.length <= 0)
                              ? setError("Enter a name")
                              : tempProxy.validateIP()
                                  ? setError("Port Range : [1024-49151]")
                                  : setError("IP Invalid");
                        }
                        setState(() {});
                      },
                      child: Icon(Icons.add)),
                  error
                ],
              ),
            ),
            Container(
              height: 400,
              child: ListView.builder(
                itemCount: manager.proxies.length,
                itemBuilder: (context, index) => ProxyCard(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
