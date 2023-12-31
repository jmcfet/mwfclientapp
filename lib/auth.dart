import 'dart:async';

import 'dart:convert';
import 'dart:io';

import 'Models/BookDates.dart';
import 'Models/UserInfo.dart';
import 'Models/logininfo.dart';

import 'Models/AllBookedDatesResp.dart';
import 'Models/PlayersinfoandBookedDate.dart';
import 'Models/UsersResponse.dart';
import 'globals.dart';
import 'Models/user.dart';
import 'Models/UserResponse.dart';
import 'package:http/http.dart' as http;

import "Models/MatchDTO.dart";
import "Models/MatchsResponse.dart";
import "Models/BookedDatesResponse.dart";
/*
to run this locally using IISExpress just create a new web site in the IIS config file under <sites>
C:\Users\jmcfe\OneDrive\Documents\IISExpress\config
it should look like
<site name="myclud" id="11">
                <application path="/" applicationPool="Clr4IntegratedAppPool">
                    <virtualDirectory path="/" physicalPath="C:\Users\jmcfe\AndroidStudioProjects\login\build\web" />
                </application>
                <bindings>

                    <binding protocol="https" bindingInformation="*:44360:localhost" />
                </bindings>
            </site>

            then navigate to cd \Program Files (x86)\IIS Express
            and enter IISEXpress /siteid:11

            then from login do:
            flutter build web
            and nav to https://localhost:44360
            then to move to production winhost use Fillezilla and point it to ftp.w28.wh-2.com

 */
abstract class BaseAuth {


  Future<UserResponse> signIn(String email, String password);
  Future<UserResponse> register(User user);
  ShowInspector();


}
/*
class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> createUser(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

}
*/

class AuthASP  {
  AuthASP();
/*
  String server = 'localhost';
  int port = 52175;
  String scheme = 'http';
*/

   String scheme = 'https';
 String server = 'landingstennis.com';
  int port = 443;


  String api = '';


  Future<UserResponse> signIn(String userid, String password) async {
    String targethost = '10.0.2.2';

    UserResponse resp = new UserResponse();
    var queryParameters = {
      'username': userid,
      'password': password,

    };

    //we are using asp.net Identity for login/registration. the first time we
    //login we must obtain an OAuth token which we obtain by calling the Token endpoint
    //and pass in the email and password that the user registered with.
    try {

        var gettokenuri = new Uri(scheme: scheme,
            host: server,
            port: port,
      //      host: targethost,
            path: '/Token');
  //      if (server == 'localhost')
  //        gettokenuri.port = port;
        //the user name and password along with the grant type are passed the body as text.
        //and the contentype must be x-www-form-urlencoded
        var loginInfo = 'UserName=' + userid + '&Password=' + password +
            '&grant_type=password';

        final response = await http
            .post(
              gettokenuri,
              headers: {"Content-Type": "application/x-www-form-urlencoded"},
              body: loginInfo
        );

        if (response.statusCode == 200) {
          resp.error = '200';
          final json = jsonDecode(response.body);
          Globals.token = json['access_token'] as String;
        }
        else {
          //this call will fail if the security stamp for user is null
          resp.error = response.statusCode.toString() + ' ' + response.body;
          return resp;
        }

    }


    catch (e){
      resp.error = 'login failed';
    }
    return   resp ;

  }

  Future<UserResponse> login(String userid, String password) async {


    UserResponse resp = new UserResponse();

    loginInfo log = new loginInfo();
    log.Username = userid;
    log.Password = password;
    String js;
    js = jsonEncode(log);
    //we are using asp.net Identity for login/registration. the first time we
    //login we must obtain an OAuth token which we obtain by calling the Token endpoint
    //and pass in the email and password that the user registered with.
    try {

      var gettokenuri = new Uri(scheme: scheme,
          host: server,
          port: port,
          //      host: targethost,
          path: 'api/Account/Login');
      //      if (server == 'localhost')
      //        gettokenuri.port = port;
      //the user name and password along with the grant type are passed the body as text.
      //and the contentype must be x-www-form-urlencoded
      var loginInfo = 'UserName=' + userid + '&Password=' + password ;

      var response = await http
          .post(
          gettokenuri,
          headers: {"Content-Type": "application/json"},
          body: js
      );

      if (response.statusCode == 200) {
        resp.error = '200';
        final json = jsonDecode(response.body);
        Globals.token = json['token'] as String;
        /*
        String authorization =  'Bearer ' + Globals.token;

          var url = new Uri(scheme: scheme,
              host: server,
              port: port,
              path: 'weatherforecast',

          );


          response = await http.get(url,
              headers: {HttpHeaders.authorizationHeader: authorization});

         */
      }
      else {
        //this call will fail if the security stamp for user is null
        resp.error = response.statusCode.toString() + ' ' + response.body;
        return resp;
      }

    }


    catch (e){
      resp.error = 'login failed';
    }
    return   resp ;

  }


  //this call is has anonymous access so no need for access token. we serialize the user
  //object and send in the HTTP body
  Future<UserResponse> register(User user) async {
    String targethost = '10.0.2.2';
    UserResponse resp = new UserResponse();
    String js;
    js = jsonEncode(user);

    //from the emulator 10.0.2.2 is mapped to 127.0.0.1  in windows
    var uri = new Uri(scheme: scheme,
        host: server,
        port: port,
        //      host: targethost,
        path: "api/Account/Register");

    try {
      // final request = await client.p;
      final response = await http
          .post(uri,
          headers: {"Content-Type": "application/json"},
          body: js)
          .then((response) {
        resp.error = '200';
        if ( response.statusCode != 200) {

          resp.error = response.statusCode.toString() + ' ' + response.body;
        }
      });

    }  catch (e) {
      resp.error = 'register failed';
    }

    return resp;

  }
  Future<UserResponse> SetBookedDatesforuser(String? email,DateTime? date,List<int> States) async {
    UserResponse resp = new UserResponse();
   UserInfo info = UserInfo();

 //  info.month = month.toString();
   info.values = States;
 //   info.EMail = email;
   String js = jsonEncode(info);
    var queryParameters1 = {
      'month': date?.month.toString(),
      'year':date?.year.toString(),
      'EMail': email,

    };
    var uri = new Uri(scheme: scheme,
      host: server,
      port: port,
      path: '/api/Account/StatusOfDaysinMonth',
      queryParameters: queryParameters1
    );
    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    String authorization = 'Bearer ' + Globals.token;
   try {
        final response = await http.post(
          uri,
          headers: {HttpHeaders.contentTypeHeader: "application/json",HttpHeaders.authorizationHeader: authorization},
            body: js
        );

       resp.error = '200';
       if ( response.statusCode != 200) {

         resp.error = response.statusCode.toString() + ' ' + response.body;
       }


    }  catch (e) {
        resp.error = 'SetBookedDatesforuser failed';
    }

    return resp;
  }

  //this call is needed because we have no control over the token endpoint
  Future<UserResponse>  getUser(String Name) async {
    UserResponse resp = new UserResponse();
    List<MatchDTO> matchinfo = [];
    var response;
    String list;
    var queryParameters1 = {
      'userid': Name,

    };
    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    String authorization =  'Bearer ' + Globals.token;
    Map<String,dynamic> usermap;
    try {
      var url = new Uri(scheme: scheme,
          host: server,
          port: port,
          path: '/api/Account/GetUserbyUserID',
          queryParameters:queryParameters1
      );


      response = await http.get(url,
          headers: {HttpHeaders.authorizationHeader: authorization}

      );
      resp.error = response.statusCode.toString();
      usermap = json.decode(response.body);
      resp.user = User.fromJson(usermap);
    } catch (error, stacktrace) {
        print("Exception occured: $error stackTrace: $stacktrace");
        resp.error = error.toString();

    }
    finally {
      return resp;
    }


  }
  Future<UsersResponse>  getUsers() async {
    UsersResponse resp = new UsersResponse();
    var response;
    Iterable list;
    var url = new Uri(scheme: scheme,
      host: server,
      port: port,

      path: '/api/Account/getUsers',
    );
    try {
      response = await http.get(url);
      list = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      resp.error = error.toString();
      return resp;
    }
    resp.users = list.map((model) => User.fromJson(model)).toList();
    return resp;
  }
  Future<MatchsResponse>  getAllMatchs(String month,String year) async {
    MatchsResponse resp = new MatchsResponse();
    var response;
    Iterable list;

    var queryParameters1 = {
      'month': month,
      'year':year
    };


    var url = new Uri(scheme: scheme,
      host: server,
      port: port,

      path: '/api/Account/GetAllMatchs',
      queryParameters:queryParameters1

    );
    try {
      response = await http.get(url);
      list = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      resp.error = error.toString();
      return resp;
    }
    resp.matches  = list.map((model) => MatchDTO.fromJSON(model)).toList();

    return resp;
  }
  Future<MatchsResponse>  getMatchsForMonth(DateTime? date,String? Name) async {
    MatchsResponse resp = new MatchsResponse();
    List<MatchDTO> matchinfo = [];
    var response;
    Iterable list;
    var queryParameters1 = {
      'email': Name,
      'year':date?.year.toString(),
      'month': date?.month.toString(),

    };
    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    String authorization = 'Bearer ' + Globals.token;
    try {
    var url = new Uri(scheme: scheme,
        host: server,
        port: port,
        path: '/api/Account/GetMatchesforMonth',
        queryParameters:queryParameters1
    );


      response = await http.get(url,
          headers: {HttpHeaders.authorizationHeader: authorization}

      );
      list = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      resp.matches = null;
      return resp;

    }
    resp.matches = list.map((model) => MatchDTO.fromJSON(model)).toList();
    return  resp;
    //   return resp;

  }
  Future<BookedDatesResponse>  GetMonthStatusforUser(DateTime? date,String? email) async {
    BookedDatesResponse resp = new BookedDatesResponse();
    var response;
    Map<String,dynamic> Datesmap = new Map<String,dynamic>();
    var queryParameters1 = {
      'month': date?.month.toString(),
      'year':  date?.year.toString(),
      'email': email

    };
    var url = new Uri(scheme: scheme,
        host: server,
        port: port,

        path: '/api/Account/GetMonthStatusforUser',
        queryParameters:queryParameters1
    );
    try {
      response = await http.get(url);
      resp.errormessage = '';
      //check for null return this will cause decode to barf
      if (response.body == 'null') {

        resp.status = null;
        return resp;
      }

      if (response.statusCode == 200) {
        Datesmap = json.decode(response.body);
        resp.status = BookDates.fromJSON(Datesmap);
      }
      else {   ///server threw so response body has exception
        resp.errormessage =  response.body;
        resp.status = null;
      }


    } catch (error, stacktrace) {
      resp.status = null;
      resp.errormessage = error.toString();

    }



    return resp;


  }
  Future<bool>  isDBFrozen() async {

    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    String authorization = 'Bearer ' + Globals.token;
    var response;
    try {
      var url = new Uri(scheme: scheme,
          host: server,
          port: port,
          path: '/api/Account/isfreezedatabase',

      );


       response = await http.get(url,
          headers: {HttpHeaders.authorizationHeader: authorization}

      );

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
//      resp.error = error;
      return false;
    }
    if (response.statusCode == 200)
            return false;
    return true;

  }
  Future<bool>  resetPassword(String email,String password) async {
    var queryParameters1 = {
      'email': email,
      'password':password
    };
    var uri = new Uri(scheme: scheme,
        host: server,
        port: port,
        queryParameters:queryParameters1,
        path: "/api/Account/forgotpassword");

    try {
    // final request = await client.p;
        var response = await http.get(uri);

        if ( response.statusCode != 200) {
        return false;
        }
    }
     catch (e) {
 //     resp.error = e.message;
    }


    return true;

  }
//get all the bookings for the month in the year for all user
  Future<AllBookedDatesResponse>  getMonthStatus(String month,String year) async {
    AllBookedDatesResponse resp = new AllBookedDatesResponse();
    var response;
    Iterable list;
    var queryParameters1 = {
      'month': month,
      'year':year
    };
    var url = new Uri(scheme: scheme,
        host: server,
        port:port,

        path: '/api/Account/GetMonthStatus',
        queryParameters:queryParameters1
    );
    try {
      response = await http.get(url);
      list = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      resp.error = error.toString();
      return resp;
    }
    resp.datesandstatus = list.map((model) => PlayersinfoandBookedDates.fromJson(model)).toList();
    return resp;
  }


}

