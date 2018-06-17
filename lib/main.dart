import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:my_flutter_app_firebase/ChatMessage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Chat Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Chat Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TextEditingController _chatTextController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  bool _hasText = false;

  void _handleChatSubmit(String text) {
    print('submitting something?');
    Firestore.instance.collection('chats').add({
      'name': 'test',
      'message': text,
      'timestamp': new DateTime.now().millisecondsSinceEpoch
    }).then((documentReference) => _chatTextController.clear());
  }

  Widget buildChatList() {
    return new Expanded(
        child: new StreamBuilder(
            stream: Firestore.instance
                .collection('chats')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Loading...');
              return new ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data.documents.length,
                  padding: const EdgeInsets.only(top: 10.0),
                  itemBuilder: (context, index) {
                    SchedulerBinding.instance.addPostFrameCallback((duration){
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                    DocumentSnapshot ds = snapshot.data.documents[index];
                    print("documentChange received? ${ds['message']}");
                    return buildChatBubble(ds['name'], ds['message']);
                  });
            }));
  }

  Widget buildChatBar() {
    return new Container(
        padding: new EdgeInsets.all(15.0),
        color: Colors.white,
        child: new Row(
          children: <Widget>[
            new Expanded(
                child: new TextField(
              controller: _chatTextController,
              decoration:
                  new InputDecoration.collapsed(hintText: "Send a message"),
              onChanged: (text) {
                setState(() {
                  _hasText = text.length > 0;
                });
              },
            )),
            new IconButton(
              icon: new Icon(Icons.send),
              onPressed: _hasText
                  ? () {
                      _handleChatSubmit(_chatTextController.text);
                    }
                  : null,
            )
          ],
        ));
  }

  Widget buildChatBubble(String name, String message) {
    const whiteText = const TextStyle(color: Colors.white, fontSize: 15.0);

    return new Container(
      margin: new EdgeInsets.all(5.0),
      decoration: new BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
      padding: new EdgeInsets.all(10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            "${name}: ",
            style: whiteText,
          ),
          new Text(message, style: whiteText)
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[buildChatList(), buildChatBar()],
        ),
      ),
    );
  }
}
