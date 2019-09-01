import 'package:autocred_app/utils/auth_utils.dart';
import 'package:autocred_app/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autocred Api Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Prueba Autocred-Api'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _LoginData {
  String dni = '';
  String password = '';
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  var _authToken;
  _LoginData _data = new _LoginData();
  bool _login = false;

  @override
  void initState() {
    super.initState();
    _fetchSessionAndNavigate();
  }

  _fetchSessionAndNavigate() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);
    if (authToken != null) {
      setState(() {
        _authToken = authToken;
        _login = true;
      });
    }
  }

  Future submit() async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

//      print('Mostrando los datos.');
//      print('Dni: ${_data.dni}');
//      print('Password: ${_data.password}');

      var responseJson =
          await NetworkUtils.authenticateUser(_data.dni, _data.password);

      if (responseJson == null) {
        NetworkUtils.showSnackBar(_scaffoldKey, 'Algo anda mal!');
      } else if (responseJson == 'Error de Red') {
        NetworkUtils.showSnackBar(
            _scaffoldKey, 'Ocurrio un error en la solicitud');
      } else if (responseJson['message'] == 'Server Error') {
        NetworkUtils.showSnackBar(_scaffoldKey, 'Ups!, ha ocurrido un error en el servidor');
      }
      if (responseJson['success'] == false) {
        var string = responseJson['message'];
        if (responseJson.containsKey('errors')) {
          var errors = responseJson['errors'];
          if (errors.containsKey("dni")) {
            string = string + ' ' + errors['dni'][0];
          }
          if (errors.containsKey("password")) {
            string = string + ' ' + errors['password'][0];
          }
        }
        NetworkUtils.showSnackBar(_scaffoldKey, string);
        setState(() {
          _login = false;
        });
      } else {
        AuthUtils.insertDetails(_sharedPreferences, responseJson);
        setState(() {
          _authToken = responseJson['access_token'];
          _login = true;
        });
      }
    }
  }

  _logout() {
    NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
    setState(() {
      _login = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: (_login) ? _resultScreen() : _loginScreen(),
    );
  }

  Widget _resultScreen() {
    return Container(
      padding: new EdgeInsets.all(20.0),
      child: ListView(
        children: <Widget>[
          Text('Access Token:' + _authToken),
          MaterialButton(
              color: Theme.of(context).primaryColor,
              child: new Text(
                'Logout',
                style: new TextStyle(color: Colors.white),
              ),
              onPressed: _logout)
        ],
      ),
    );
  }

  Widget _loginScreen() {
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
        padding: new EdgeInsets.all(20.0),
        child: new Form(
          key: this._formKey,
          child: new ListView(
            children: <Widget>[
              new TextFormField(
                  decoration: new InputDecoration(
                      hintText: '12345678-9', labelText: 'Rut o Pasaporte'),
                  onSaved: (String value) {
                    this._data.dni = value;
                  }),
              new TextFormField(
                  obscureText: true,
                  decoration: new InputDecoration(
                      hintText: '***********', labelText: 'Contraseña'),
                  onSaved: (String value) {
                    this._data.password = value;
                  }),
              new Container(
                width: screenSize.width,
                child: new RaisedButton(
                  child: new Text(
                    'Ingresar',
                    style: new TextStyle(color: Colors.white),
                  ),
                  onPressed: this.submit,
                  color: Colors.blue,
                ),
                margin: new EdgeInsets.only(top: 20.0),
              )
            ],
          ),
        ));
  }
}
