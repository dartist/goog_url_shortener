part of goog_url_shortener_console;

/**
 * 
 */
class UrlShortener {
  static const String SHORTEN = "shorten";
  static const String EXPAND = "expand";
  static const String ANALYTICS = "analytics";
  final String googUrl = 'https://www.googleapis.com/urlshortener/v1/url';  
  final String url;
  final String command;
  final String key;
  String keyParam;
  
  Logger logger; 
  
  UrlShortener({this.url: "http://www.google.com", this.command: "shorten", this.key: ''}) {
    logger = new Logger("UrlShortener");
    keyParam = this.key.isEmpty ? "" : "?&key=$key";
  }
  
  Future<Map> execute() {
    switch(command) {
      case SHORTEN:
        return shorten();
      case EXPAND:
        return expand();
      case ANALYTICS:
        return analytics();
    }
    
    throw new Error();
  }
  
  // uri is the shortener api url
  // longUrl is the url to shorten 
  Future<Map> shortenWithHttpsClient(Uri uri, Uri longUrl) {
    logger.finest("shortenWithHttpsClient(${uri.toString()}, ${longUrl.toString()})");
    Completer completer = new Completer();
    
    HttpClient client = new HttpClient();
    HttpClientConnection connection = client.postUrl(uri);
    
    connection
    ..onError = (error) { 
      logger.finest("error = $error");
      completer.completeException(error); 
    }
    
    ..onRequest = (HttpClientRequest request) {
      request.headers.add(HttpHeaders.CONTENT_TYPE, "application/json");
      var requestString = '{"longUrl": "${longUrl.toString()}"}';
      logger.finest("requestString = ${requestString}");
      request.outputStream
      ..write(encodeUtf8(requestString)) 
      ..close();
    }
    
    ..onResponse = (HttpClientResponse response) {
      StringBuffer responseBuffer = new StringBuffer();

      Expect.isTrue(response.statusCode < 500);
      
      if (uri.path.length == 0) {
        Expect.isTrue(response.statusCode != 404);
      }
    
      response
      ..inputStream.onData = () {
        List<int> data = response.inputStream.read();
        responseBuffer.add(decodeUtf8(data));
      }
      
      ..inputStream.onClosed = () { 
        try {
          var jsonDoc = JSON.parse(responseBuffer.toString());
          completer.complete(jsonDoc);   
        } catch (error) {
          logger.finest("error = $error");
          completer.completeException(error);
        }
        client.shutdown();      
      };      
    };
    
    return completer.future;
  }
  
// Return Map of json parsed output. 
  Future<Map> expandWithHttpsClient(Uri uri) {
    Completer completer = new Completer();
    
    HttpClient client = new HttpClient();
    HttpClientConnection connection = client.getUrl(uri);
    
    connection.onError = (error) { 
      completer.completeException(error);
    };
    
    connection.onResponse = (HttpClientResponse response) { 
      StringBuffer responseBuffer = new StringBuffer();
      Expect.isTrue(response.statusCode < 500);
      
      if (uri.path.length == 0) {
        Expect.isTrue(response.statusCode != 404);
      }
    
      response.inputStream.onData = () {
        List<int> data = response.inputStream.read();
        responseBuffer.add(decodeUtf8(data));
      };
      
      response.inputStream.onClosed = () { 
        try {
          var jsonDoc = JSON.parse(responseBuffer.toString());
          completer.complete(jsonDoc);   
        } catch (error) {
          completer.completeException(error);
        }
        
        client.shutdown();      
      };
    };
   
    return completer.future;
  }
    
  Future<Map> shorten() {
    return shortenWithHttpsClient(
        new Uri.fromString("$googUrl$keyParam"), 
        new Uri.fromString("$url"));
  }
  
  Future<Map> expand() {
    return expandWithHttpsClient(new Uri.fromString("$googUrl?shortUrl=$url$keyParam"));
  }
  
  Future<Map> analytics() {
    return expandWithHttpsClient(new Uri.fromString("$googUrl?shortUrl=$url&projection=FULL$keyParam"));
  }
}
