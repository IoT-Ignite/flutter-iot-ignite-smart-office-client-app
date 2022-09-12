import 'package:flutter/material.dart';
import 'package:iotignite_mqtt_client/manager/iot_ignite_rest_manager.dart';
import 'package:iotignite_mqtt_client/exceptions/invalid_email_format_exception.dart';
import 'package:iotignite_mqtt_client/view/device_page.dart';
import 'package:iotignite_mqtt_client/view/things_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import './custom_animation.dart';


void main() {
  runApp(const MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Test',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue[200],
      ),
      home: MyHomePage(),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool _isChecked = false;

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var _tfNameController = TextEditingController();
  var _tfKeyController = TextEditingController();

  var snackBarFailure = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'On Snap!',
      message:
      'Incorrect email or password!',
      contentType: ContentType.failure,
    ),
  );

  var snackBarFailureEmail = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'On Snap!',
      message:
      'Email Format Error!',
      contentType: ContentType.failure,
    ),
  );


  Future<bool?> signInClicked() async {

    var sp = await SharedPreferences.getInstance();

    var email = _tfNameController.text;
    var password = _tfKeyController.text;

    IotIgniteRESTLib? igniteLib;

    try {
      //code that has potential to throw an exception
      igniteLib = IotIgniteRESTLib.getInstance(email, password, true);
    } on InvalidEmailFormatException catch (e) {
      //print("ERROR MSG: ${e.getMessage()} ERROR CODE: ${e.errCode()}");
      ScaffoldMessenger.of(context).showSnackBar(snackBarFailureEmail);
    }

    await SharedPreferences.getInstance();

    bool? authState = await igniteLib?.auth();

    //igniteLib?.getRefreshToken();

    if(authState == true){
      sp.setString("email", email);
      sp.setString("password", password);
      sp.setBool("remember_me", _isChecked);

      return true;
      //Navigator.push(context, MaterialPageRoute(builder: (context) => Welcome()));
    }
    else{
      return false;
      //ScaffoldMessenger.of(context).showSnackBar(snackBarFailure);
    }
  }

  @override
  void initState() {
    _loadUserEmailPassword();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      /*
      appBar: AppBar(
        centerTitle: true,
        title: const Text("LOGIN"),
        titleTextStyle: const TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold ,color: Colors.white),
      ),  */
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.lightGreen,
                  Colors.green,
                  Colors.blue,
                  Colors.lightBlueAccent,
                ],
              )
          ),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("images/temp_green.png", height: 325, width: 450,),
                Text(
                  "WELCOME",
                  style: TextStyle(fontFamily: 'SignikaNegative', fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 50,
                    width: 300,
                    child: TextField(
                      controller: _tfNameController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.white, ),
                        filled: true,
                        fillColor: Colors.white54,
                        prefixIcon: Icon(Icons.person, color: Colors.blue,),
                        border: GradientOutlineInputBorder(
                          gradient: LinearGradient(colors: [Colors.lightGreenAccent, Colors.white]),
                          width: 2,
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 300,
                  child: TextField(
                    controller: _tfKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.white, ),
                      filled: true,
                      fillColor: Colors.white54,
                      prefixIcon: Icon(Icons.key, color: Colors.blue,),
                      border: GradientOutlineInputBorder(
                        gradient: LinearGradient(colors: [Colors.lightGreenAccent, Colors.white]),
                        width: 2,
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: CheckboxListTile(
                      title: Text("Remember me",
                        style: TextStyle( color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'SignikaNegative'),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _isChecked,
                      onChanged: _rememberMeCheckBox
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 40,
                    width: 300,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        onPrimary: Colors.white,
                        shadowColor: Colors.black,
                      ),
                      onPressed: () async {

                        await EasyLoading.show(
                          status: 'loading...',
                          maskType: EasyLoadingMaskType.black,
                        );

                        signInClicked().then((snapshot) => {
                          EasyLoading.dismiss(),
                          print("futurebuilder"),
                          if (snapshot!) {
                            print("snapshot has data true"),
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DevicePage(),),),
                          } else if (snapshot == false) {
                            print("snapshot has data false"),
                            ScaffoldMessenger.of(context).showSnackBar(snackBarFailure),
                          } else {
                            print("snapshot error"),
                            ScaffoldMessenger.of(context).showSnackBar(snackBarFailure),
                            const SizedBox(width: 0),
                          }
                        },
                        );
                      },
                      child: const Text("LOGIN",
                        style: TextStyle(fontFamily: 'SignikaNegative', color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _rememberMeCheckBox(bool? value) {

    _isChecked = value!;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("remember_me", value);
      prefs.setString('email', _tfNameController.text);
      prefs.setString('password', _tfKeyController.text);
    },
    );
    setState(() {
      _isChecked = value;
    });
  }

  void _loadUserEmailPassword() async {

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString("email") ?? "";
      String? password = prefs.getString("password") ?? "";
      bool? rememberMe = prefs.getBool("remember_me") ?? false;

      if (rememberMe) {
        setState(() {
          _isChecked = true;
        });
        _tfNameController.text = email;
        _tfKeyController.text = password;
      }
    } catch (e) {
      print(e);
    }
  }

}

