import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {

	static final String endPoint = '/auth/login';

	static final String accessTokenKey = 'access_token';

	static String getToken(SharedPreferences prefs) {
		return prefs.getString(accessTokenKey);
	}

	static insertDetails(SharedPreferences prefs, var response) {
		prefs.setString(accessTokenKey, response['access_token']);
	}
	
}