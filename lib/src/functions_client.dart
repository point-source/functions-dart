import 'dart:convert';

import 'package:functions_client/src/constants.dart';
import 'package:functions_client/src/types.dart';
import 'package:http/http.dart' as http;

import 'isolates.dart';

class FunctionsClient {
  final String _url;
  final Map<String, String> _headers;
  final http.Client? _httpClient;

  FunctionsClient(
    String url,
    Map<String, String> headers, {
    http.Client? httpClient,
  })  : _url = url,
        _headers = {...Constants.defaultHeaders, ...headers},
        _httpClient = httpClient;

  /// Updates the authorization header
  ///
  /// [token] - the new jwt token sent in the authorisation header
  void setAuth(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  /// Invokes a function
  ///
  /// [functionName] - the name of the function to invoke
  ///
  /// [headers]: object representing the headers to send with the request
  ///
  /// [body]: the body of the request
  ///
  /// [responseType]: how the response should be parsed. The default is `json`
  Future<FunctionResponse> invoke(
    String functionName, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    ResponseType responseType = ResponseType.json,
  }) async {
    final bodyStr = await compute(json.encode, body);

    final response = await (_httpClient?.post ?? http.post)(
      Uri.parse('$_url/$functionName'),
      headers: <String, String>{..._headers, if (headers != null) ...headers},
      body: bodyStr,
    );

    final dynamic data;
    if (responseType == ResponseType.json) {
      data = await compute(json.decode, response.body);
    } else if (responseType == ResponseType.blob) {
      data = response.bodyBytes;
    } else if (responseType == ResponseType.arraybuffer) {
      data = response.bodyBytes;
    } else if (responseType == ResponseType.text) {
      data = response.body;
    } else {
      data = response.body;
    }
    return FunctionResponse(data: data, status: response.statusCode);
  }
}
