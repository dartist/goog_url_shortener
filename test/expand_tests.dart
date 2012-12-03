library expand_tests;

import 'dart:io';
import 'dart:uri';
import 'dart:json';
import 'package:unittest/unittest.dart';
import 'package:goog_url_shortener/goog_url_shortener.dart';

class ExpandTests {
  void run() {
    group("expand", () {
      test("success", () {
        var url = "http://goo.gl/fbsS";
        var urlShortener = new UrlShortener(url: url, 
            command: UrlShortener.EXPAND);
        
        var future = urlShortener.execute();
        
        future.handleException((error){
              expect(false, 'Should not of thrown the following exception $error');
        });
        
        expect(future, completion((Map data) {
          expect(data, containsPair("longUrl", startsWith("http://www.google.com/")));
          expect(data, containsPair("id", startsWith("http://goo.gl/")));
          expect(data, containsPair("kind", equals("urlshortener#url"))); 
          expect(data, containsPair("status", equals("OK"))); 
          return true;
        }));
      });
      
      test("error", () {
        var url = "http://www.google.com";
        var urlShortener = new UrlShortener(url: url, 
            command: UrlShortener.EXPAND);
        
        var future = urlShortener.execute();
        
        future.handleException((error){
              expect(false, 'Should not of thrown the following exception $error');
        });
        
        expect(future, completion((Map data) {
          expect(data.keys, contains(equals("error"))); 
          expect(data["error"], containsPair("code", equals(400)));
          expect(data["error"], containsPair("message", equals("Invalid Value")));
          return true;
        }));
        
      });
    });
  }
}
