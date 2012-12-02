library analytics_tests;

import 'package:unittest/unittest.dart';
import 'package:goog_url_shortener/goog_url_shortener_console.dart';

class AnalyticsTests {
  void run() {
    group("analytics", () {
      test("success", () {
        var url = "http://goo.gl/fbsS";
        var urlShortener = new UrlShortener(url: url, 
            command: UrlShortener.ANALYTICS);
        
        var future = urlShortener.execute();
        
        future.handleException((error){
              expect(false, 'Should not of thrown the following exception $error');
        });
        
        expect(future, completion((Map data) {
          expect(data, containsPair("longUrl", startsWith("http://www.google.com/")));
          expect(data, containsPair("id", startsWith("http://goo.gl/")));
          expect(data, containsPair("kind", equals("urlshortener#url"))); 
          expect(data, containsPair("status", equals("OK")));
          expect(data.keys, contains("created"));
          expect(data.keys, contains("analytics"));
          expect(data["analytics"], contains("allTime"));
          expect(data["analytics"]["allTime"], contains("shortUrlClicks"));
          expect(data["analytics"]["allTime"], contains("longUrlClicks"));
          
          expect(data["analytics"]["allTime"], contains("referrers"));
          expect(data["analytics"]["allTime"], contains("countries"));
          expect(data["analytics"]["allTime"], contains("browsers"));
          expect(data["analytics"]["allTime"], contains("platforms"));
          
          expect(data["analytics"], contains("month"));
          expect(data["analytics"], contains("week"));
          expect(data["analytics"], contains("day"));
          expect(data["analytics"], contains("twoHours"));
          return true;
        }));
      });
      
      test("error", () {
        var url = "http://www.google.com";
        var urlShortener = new UrlShortener(url: url, 
            command: UrlShortener.ANALYTICS);
        
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
