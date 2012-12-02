library shorten_tests;

import 'dart:io';
import 'dart:uri';
import 'dart:json';
import 'package:unittest/unittest.dart';
import 'package:goog_url_shortener/goog_url_shortener_console.dart';



class ShortenTests {
  void run() {
    
    group("shortener", () {
      test("successful", () {
        var url = "http://news.dartlang.org";
        var urlShortener = new UrlShortener(url: url, 
            command: UrlShortener.SHORTEN);
        
        var future = urlShortener.execute();
             
        future.handleException((error){
              expect(false, 'Should not of thrown the following exception $error');
        });
        
        expect(future, completion((Map data) {
          expect(data, containsPair("longUrl", startsWith(url)));
          expect(data, containsPair("id", startsWith("http://goo.gl/")));
          expect(data, containsPair("kind", equals("urlshortener#url"))); 
          return true;
        }));
      });
      
      test("error", () {
        var url = "hxttp://okjasfov090932r90f.org";
        var urlShortener = new UrlShortener(url: url, 
            command: UrlShortener.SHORTEN);
        
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

void main() {
  new ShortenTests().run();
}
