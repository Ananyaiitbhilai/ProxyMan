import 'dart:math';
import 'package:flutter/material.dart';
import 'package:proxyman/main.dart';

class BounceCurve extends Curve {
  @override
  double transformInternal(double t) {
    return t;
  }
}

class Bullshit extends CurveTween {
  Bullshit() : super(curve: BounceCurve());

  @override
  double transform(double t) {
    double val = 1.777778 * t +
        13.77778 * pow(t, 2) -
        37.77778 * pow(t, 3) +
        22.22222 * pow(t, 4);
    if (t == 1) val = 0;
    return val;
  }
}

class PowerSwitch extends StatefulWidget {
  final double size;
  final Function switchCallback;
  final bool initialValue;

  PowerSwitch(this.switchCallback, {this.size: 40, this.initialValue: false});

  @override
  _PowerSwitchState createState() => _PowerSwitchState();
}

class _PowerSwitchState extends State<PowerSwitch>
    with TickerProviderStateMixin {
  late bool active;
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    active = widget.initialValue;
    animationController = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);
    animation = CurvedAnimation(
        parent: animationController,
        curve: BounceCurve(),
        reverseCurve: BounceCurve())
      ..addListener(() {
        setState(() {});
      });
    Future.delayed(Duration(seconds: 2)).then((value) {
      active = Home.of(context)!.proxyMan.proxyActive;
    });
    // ..addStatusListener((status) {
    //   if (status == AnimationStatus.completed && active) {
    //     print("[TODO]: do stuff");
    //   }
    //   if (status == AnimationStatus.completed && !active) {
    //     print("[TODO]: do stuff");
    //   }
    // });
    animation = Bullshit().animate(animation);
    animationController.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(blurRadius: 15, spreadRadius: 3),
      ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: widget.size,
            child: InkWell(
              onTap: () {
                bool newActive = widget.switchCallback(active);
                if (newActive != active) {
                  active = newActive;
                  animationController.reset();
                  animationController.forward();
                  setState(() {});
                  Home.of(context)!.rebuild();
                }
              },
              child: CustomPaint(
                painter: PowerSwitchPainter(
                    animationController.value, animation.value, active),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PowerSwitchPainter extends CustomPainter {
  double tickerVal;
  double animationVal;
  bool switchStatus;
  int invFrac = 8;
  final double pi = 3.14159265359;
  late Color inactiveColor;
  late Color activeColor;
  late Paint inactivePaint;
  late Paint activePaint;

  PowerSwitchPainter(this.tickerVal, this.animationVal, this.switchStatus,
      {inactiveColor: Colors.white24, activeColor: Colors.green}) {
    inactivePaint = Paint()
      ..color = inactiveColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
  }

  List<double> getStaticArc() {
    List<double> angles = [];
    angles.add(pi * (2 * invFrac - invFrac / 2 + 1) / invFrac);
    angles.add(pi * ((2 * invFrac) - 2) / invFrac);
    return angles;
  }

  List<double> getActiveArcs() {
    List<double> angleList = [];
    List<double> banned = getStaticArc();
    double a1 = (banned[0] + (2 * pi * tickerVal)) % (2 * pi);
    double maxLen = banned[1];
    double a2 = banned[1] * (min(tickerVal * 2, 1));
    banned[1] = banned[0] - ((2 * pi) / invFrac);

    //start of the arc is inside banned zone
    if (banned[1] <= a1 && banned[0] >= a1) {
      //no mod as a1 is already checked above
      (a2 > banned[0] - a1) ? a2 -= banned[0] - a1 : a2 = 0;
      a1 = banned[0];
      angleList.add(a1);
      angleList.add(a2);
      angleList.add(0);
    } else if (banned[1] <= ((a1 + a2) % (2 * pi)) &&
        banned[0] >= ((a1 + a2) % (2 * pi))) {
      a2 = (banned[1] - a1) % (2 * pi);
      angleList.add(a1);
      angleList.add(a2);
      angleList.add(1);
    } else if (((a1 - banned[0]) % (2 * pi) + a2) < maxLen) {
      angleList.add(a1);
      angleList.add(a2);
      angleList.add(3);
    } else {
      double b1 = banned[0],
          b2 = (((a1 + a2) % (2 * pi)) - banned[0]) % (2 * pi);
      angleList.add(b1);
      angleList.add(b2);
      a2 = (banned[1] - a1) % (2 * pi);
      angleList.add(a1);
      angleList.add(a2);
      angleList.add(2);
    }
    return angleList;
  }

  List<Offset> getLinePoints(Size size) {
    List<Offset> points = [];
    double dia = min(size.height, size.width);
    double y = size.height / 2, x = size.width / 2;
    points.add(Offset(x, y - (dia * (11 / 32)) - (animationVal * 30)));
    points.add(Offset(x, y - (dia * (5 / 32)) - (animationVal * 30)));
    return points;
  }

  Rect getRekt(Size size) {
    //LOL
    double dia = min(size.height, size.width);
    double y = size.height / 2, x = size.width / 2;
    return Rect.fromCenter(
        center: Offset(x, y), width: dia / 2, height: dia / 2);
  }

  //Actual drawing functions
  @override
  void paint(Canvas canvas, Size size) {
    print(switchStatus);
    Rect rekt = getRekt(size);
    List<double> staticAngles = getStaticArc();
    List<Offset> linePoints = getLinePoints(size);

    //draw the base inactive static arc
    canvas.drawArc(
        rekt, staticAngles[0], staticAngles[1], false, inactivePaint);

    //draw the base inactive line
    canvas.drawLine(linePoints[0], linePoints[1], inactivePaint);

    //draw the active components on top
    if (switchStatus) {
      Offset upper =
          linePoints[1] + (linePoints[0] - linePoints[1]) * tickerVal;
      canvas.drawLine(upper, linePoints[1], activePaint);

      List<double> arcList = getActiveArcs();
      // if (arcList.length == 3) {
      //   print("TYPE : ${arcList[2]}, List : $arcList");
      // } else {
      //   print("TYPE : ${arcList[4]}, List : $arcList");
      // }
      canvas.drawArc(rekt, arcList[0], arcList[1], false, activePaint);
      if (arcList.length == 5) {
        canvas.drawArc(rekt, arcList[2], arcList[3], false, activePaint);
      }
    } else {
      Offset upper =
          linePoints[0] + (linePoints[1] - linePoints[0]) * tickerVal;
      if (tickerVal != 1) {
        canvas.drawLine(upper, linePoints[1], activePaint);
        canvas.drawArc(rekt, staticAngles[0], staticAngles[1] * (1 - tickerVal),
            false, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
