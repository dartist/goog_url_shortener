#!/usr/bin/env dart
import 'dart:io';
import 'dart:uri';
import 'dart:utf';
import 'dart:json';
import 'package:args/args.dart';
import 'package:logging/logging.dart';

/*
Shorten
adam@dartu:~$ curl https://www.googleapis.com/urlshortener/v1/url   -H 'Content-Type: application/json'   -d '{"longUrl": "http://dartoverflow.com:8080/web/engine.html?q=50a8206cb3a13d32d1000014"}'
{
 "kind": "urlshortener#url",
 "id": "http://goo.gl/hK9BC",
 "longUrl": "http://dartoverflow.com:8080/web/engine.html?q=50a8206cb3a13d32d1000014"
}

Expand
adam@dartu:~$ curl 'https://www.googleapis.com/urlshortener/v1/url?shortUrl=http://goo.gl/hK9BC'
{
 "kind": "urlshortener#url",
 "id": "http://goo.gl/hK9BC",
 "longUrl": "http://dartoverflow.com:8080/web/engine.html?q=50a8206cb3a13d32d1000014",
 "status": "OK"
}

Analytics
curl 'https://www.googleapis.com/urlshortener/v1/url?shortUrl=http://goo.gl/fbsS&projection=FULL'
*/

// Logger.root.level = Level.ALL; 
Logger logger; // = new Logger("main");

/**
 * Setup the certificate database for the client. 
 */
void initializeSSL() {
  var testPkcertDatabase =
      new Path.fromNative(new Options().script).directoryPath.append('pkcert/');
  SecureSocket.setCertificateDatabase(testPkcertDatabase.toNativePath());
}

class UrlShortener {
  static const String SHORTEN = "shorten";
  static const String EXPAND = "expand";
  static const String ANALYTICS = "analytics";
  final String googUrl = 'https://www.googleapis.com/urlshortener/v1/url';
  
  final String url;
  final String command;
  final String key;
//  final String curlPath;
  
  UrlShortener({this.url: "http://www.google.com", this.command: "shorten", this.key: '' /*, this.curlPath: "curl" */}) {
    initializeSSL();
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
  
//  Future<String> executeCurl(List<String> processArgs) {
//    Completer c = new Completer();
//    ProcessOptions processOptions = new ProcessOptions();
//    Directory directory = new Directory.current();
//    processOptions.workingDirectory = directory.path;
//    processOptions.environment = new Map();
//    print("$curlPath $processArgs");
//    Process.run(curlPath, processArgs, processOptions)
//    ..handleException((error) {
//      print("Error: $error");
//      c.completeException(error);
//    })
//    ..then((ProcessResult processResult) {
//      c.complete(processResult.stdout);
//    });
//    
//    return c.future;
//  }
  
  Future<Map> shorten() {
    var keyParam = key.isEmpty ? "" : "?&key=$key";
//    var args = ["$googUrl$keyParam", "-H", 'Content-Type: application/json',
//                 "-d", JSON.stringify({"longUrl": url})];
    //return executeCurl(args);
    return shortenWithHttpsClient(
        new Uri.fromString("$googUrl$keyParam"), 
        new Uri.fromString("$url"));
  }
  
  Future<Map> expand() {
    var keyParam = key.isEmpty ? "" : "&key=$key";
//    var args = ["$googUrl?shortUrl=$url$keyParam"];
    //return executeCurl(args);
    return expandWithHttpsClient(new Uri.fromString("$googUrl?shortUrl=$url$keyParam"));
  }
  
  Future<Map> analytics() {
    var keyParam = key.isEmpty ? "" : "&key=$key";
    //var args = ["$googUrl?shortUrl=$url&projection=FULL$keyParam"];
    //return executeCurl(args);
    return expandWithHttpsClient(new Uri.fromString("$googUrl?shortUrl=$url&projection=FULL$keyParam"));
  }
}

void main() {

  Logger.root.level = Level.ALL; 
  logger = new Logger("main");
  Logger.root.on.record.add((LogRecord r)=>print(r.message.toString()));
  
  var argParser = new ArgParser();
//  argParser.addOption('curl', abbr: 'c',
//      help: 'absolute path for curl', defaultsTo: 'curl');
  
  argParser.addOption('key', abbr: 'k',
      help: 'google api key', 
      defaultsTo: '');
  
  argParser.addOption('url', abbr: 'u',
      help: 'url',
      defaultsTo: "http://www.google.com");
  
  argParser.addOption('type', abbr: 't',
      allowed: [UrlShortener.SHORTEN, UrlShortener.EXPAND, UrlShortener.ANALYTICS],
      help: "type of action to execute",
      allowedHelp: {"${UrlShortener.SHORTEN}": "shorten the url",
                    "${UrlShortener.EXPAND}": "expand the url",
                    "${UrlShortener.ANALYTICS}": "analytics for the url"},
      defaultsTo: 'shorten');
  
  argParser.addFlag('help', abbr: 'h', help: "help", negatable: false,  callback: (enabled) { 
    if(enabled) {
      print(argParser.getUsage());
      exit(0);
    }
  });
  
  var args = argParser.parse(new Options().arguments);
//  var curl = args['curl'];
  var key = args['key'];
  var url = args['url'];
  var type = args['type'];
  logger.finest("key = $key, url = $url, type = $type");
  UrlShortener urlShortener = new UrlShortener(url: url,
                                               command: type,
                                               key: key);
//                                               curlPath: curl);
  Future f = urlShortener.execute();
  f.handleException((error) {
    print("error: $error");
  });
  f.then((String data) {
    print(data);
  }); 
}