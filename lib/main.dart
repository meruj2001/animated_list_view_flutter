import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation Test',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'List View Animation Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final int dur = 500;
  int counter = 0;
  Random random = new Random();
  Future ft = Future(() {});
  Tween<Offset> _offset_in = Tween(begin: Offset(1, 0), end: Offset.zero);
  Tween<Offset> _offset_out = Tween(begin: Offset(-1, 0), end: Offset(0, 0));

  List<int> list = [];
  List<Widget> animatedView = [];

  void _insertItem(int elem) {
    _listKey.currentState
        .insertItem(list.length, duration: Duration(milliseconds: dur));
    list.insert(list.length, elem + 1);
  }

  void _rempoveItem() {
    int item = list[list.length-1];
    _listKey.currentState.removeItem(
        list.length-1, (_, animation) => _buildRow(context, item, animation, false),
        duration: Duration(milliseconds: dur));
    list.removeAt(list.length-1);
  }

  void onButtonPress(int elem) async {
    final int len = list.length;
    for (int i = 0; i < len; i++) {
      await Future.delayed(Duration(milliseconds: dur~/2));
      setState(() {
        _rempoveItem();
      });
    }
    int range = random.nextInt(4)+3;
    await Future.delayed(Duration(milliseconds: dur~/3));
    for (int i = 0; i < range; i++) {
      await Future.delayed( Duration(milliseconds: dur~/2));
      setState(() {
        _insertItem(elem++);
      });
    }
  }

  Widget _buildRow(
      BuildContext context, int item, Animation animation, bool inOrOut) {
    return SlideTransition(
      position: inOrOut
          ? _offset_in.animate(animation)
          : _offset_out.animate(animation),
      child: Card(
        child: ListTile(
          onTap: () {
            onButtonPress(item);
          },
          contentPadding: EdgeInsets.all(20),
          title: Text(
            "______ $item _______",
            style: TextStyle(
                fontSize: 20,
                backgroundColor: Colors.black,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < 5; i++) {
        ft = ft.then((_) {
          return Future.delayed(Duration(milliseconds: dur~/3), () {
            _insertItem(i);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: AnimatedList(
            key: _listKey,
            initialItemCount: animatedView.length,
            itemBuilder: (context, index, animation) {
              return _buildRow(context, list[index], animation, true);
            }));
  }
}
