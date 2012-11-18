#!/usr/bin/env dart
import 'dart:io';
import 'dart:json';
import 'package:args/args.dart';
import '../../http_example/lib/http.dart';

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

class UrlShortener {
  static const String SHORTEN = "shorten";
  static const String EXPAND = "expand";
  static const String ANALYTICS = "analytics";
  final String googUrl = 'https://www.googleapis.com/urlshortener/v1/url';
  
  final String url;
  final String command;
  final String key;
  final String curlPath;
  
  UrlShortener({this.url: "http://www.google.com", this.command: "shorten", this.key: null, this.curlPath: "curl"});
  
  execute() {
    switch(command) {
      case SHORTEN:
        return shorten();
      case EXPAND:
        return expand();
      case ANALYTICS:
        return analytics();
    }
  }
  
  Future executeCurl(List<String> processArgs) {
    Completer c = new Completer();
    ProcessOptions processOptions = new ProcessOptions();
    Directory directory = new Directory.current();
    processOptions.workingDirectory = directory.path;
    processOptions.environment = new Map();
    //print("$curlPath $processArgs");
    Process.run(curlPath, processArgs, processOptions)
    ..handleException((error) {
      print("Error: $error");
      c.completeException(error);
    })
    ..then((ProcessResult processResult) {
      c.complete(processResult.stdout);
    });
    
    return c.future;
  }
  
  Future shorten() {
    var args = [googUrl, "-H", 'Content-Type: application/json',
                 "-d", JSON.stringify({"longUrl": url})];
    return executeCurl(args);
  }
  
  Future expand() {
    var args = ["$googUrl?shortUrl=$url"];
    return executeCurl(args);
  }
  
  Future analytics() {
    var args = ["$googUrl?shortUrl=$url&projection=FULL"];
    return executeCurl(args);
  }
}

void main() {
  var argParser = new ArgParser();
  argParser.addOption('curl', abbr: 'c',
      help: 'absolute path for curl', defaultsTo: 'curl');
  
  argParser.addOption('key', abbr: 'k',
      help: 'google api key', 
      defaultsTo: null);
  
  argParser.addOption('url', abbr: 'u',
      help: 'url',
      defaultsTo: "http://www.google.com");
  
  /* these are exclusive */
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
  var curl = args['curl'];
  var key = args['key'];
  var url = args['url'];
  var type = args['type'];
  
  UrlShortener urlShortener = new UrlShortener(url: url,
      command: type,
      key: key,
      curlPath: curl);
  Future f = urlShortener.execute();
  f.handleException((error) {
    print("error: $error");
  });
  f.then((String data) {
    print(data);
  }); 
}