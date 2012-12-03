#!/usr/bin/env dart

import 'dart:io';
import 'dart:uri';
import 'dart:json';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:goog_url_shortener/goog_url_shortener.dart';

Logger logger; 

void main() {
  logger = new Logger("main");
  Logger.root.on.record.add((LogRecord r)=>print(r.message.toString()));
  
  var argParser = new ArgParser();
  
  argParser.addFlag('verbose', abbr: 'v', help: "verbose enabled", defaultsTo: false, callback: (enabled) {
    if (enabled) {
      Logger.root.level = Level.FINEST; 
    } else {
      Logger.root.level = Level.SEVERE; 
    }
  });
  
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
  var key = args['key'];
  var url = args['url'];
  var type = args['type'];
  logger.finest("new UrlShortener(key: $key, url: $url, type: $type);");
  SecureSocket.initialize();
  UrlShortener urlShortener = new UrlShortener(url: url,
                                               command: type,
                                               key: key);
  Future f = urlShortener.execute();
  f.handleException((error) {
    logger.severe("urlShortener $error");
  });
  f.then((Map data) {
    if (!data.containsKey("error")) {
      print('Long Url = ${data["longUrl"]}');
      print('Short Url = ${data["id"]}');
      if (type == UrlShortener.ANALYTICS) {
        // TODO(adam): print out the stats
      }
    } else {
      print("error = ${data['error']}");
    }
  }); 
}