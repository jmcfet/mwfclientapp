import 'package:flutter/material.dart';
import 'auth.dart';


class HomePage extends StatelessWidget {
  HomePage({required this.auth, required this.onSignOut});

  final AuthASP auth;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(

     //   debugShowCheckedModeBanner: false,
        home: new Scaffold(

      appBar: AppBar(
        title: Text('Logged In'),
      ),
      body: GetUserInfo(),
    )
    );
  }
  //In future builder, it calls the future function to wait for the result, and as soon as it produces the result it calls the builder function where we build the widget.
  Widget GetUserInfo() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none &&
            projectSnap.hasData == null) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }
        return  new TextButton(
            key: new Key('Alice'),
            child: new Text("show inspector"),
            onPressed: () {}
        );   //we have data
      }, future: null,
  //    future: auth.SetBookedDatesforuser(5,null),
    );
  }



}