import 'dart:convert';
import 'package:http/http.dart' as http;


//this is a third-party email verification services

//after create an account we get these
String proofyKey = '';
String proofyUserID = '';

class ProofyApi {
  static const String _baseUrl = 'https://api.proofy.io';
  //static const String _userId = '38153';
  //static const String _apiKey = 'XRZWlSLqR2y5oGGpyJcA3UqgQ';
  static String _userId = proofyUserID;
  static String _apiKey = proofyKey;

  Future<bool> verifyEmail(String email) async {
    final url = Uri.parse('$_baseUrl/verifyaddr?aid=$_userId&key=$_apiKey&email=$email');
    final response = await http.get(url);
    final json = jsonDecode(response.body);
    final checkId = json['cid'] as int?;

    if (checkId == null) {
      //print('## checkId==null: $checkId');
      return false;
    }

    final result = await _getCheckResult(checkId);
    bool emailDeliverable = result['result'].isNotEmpty && result['result'][0]['status'] == 1;
    print('## emailDeliverable=$emailDeliverable');
    return emailDeliverable;
    //return result;
  }

  Future<Map<String, dynamic>> _getCheckResult(int checkId) async {
    final url = Uri.parse('$_baseUrl/getresult?aid=$_userId&key=$_apiKey&cid=$checkId');
    final response = await http.get(url);
    //print('## jsonDecode(response.body): ${jsonDecode(response.body)}');

    return jsonDecode(response.body);
  }
}
