Google Url Shortener in Dart
====

A small library and application that shortens and expands urls using dart and google shortener apis.

[![](https://drone.io/adam/goog_url_shortener/status.png)](https://drone.io/adam/goog_url_shortener/latest)


Usage
----

### Library

Installing from [pub.dartlang.org](http://pub.dartlang.org) apply the following to pubspec.yaml 

```
dependencies:
  goog_url_shortener: any
```

Installing from [this](https://github.com/financeCoding/goog_url_shortener) git repo apply the following to pubspec.yaml

```
dependencies:
  goog_url_shortener: 
  	git: git://github.com/financeCoding/goog_url_shortener.git
```

Importing the library

```
import 'package:goog_url_shortener/goog_url_shortener.dart';
```

Example of calling the shortener

```
  initializeSSL();
  UrlShortener urlShortener = new UrlShortener(url: url,
                                               command: type,
                                               key: key);
  var furture = urlShortener.execute(); 
  furture.then((Map data) {
    print('Long Url = ${data["longUrl"]}');
    print('Short Url = ${data["id"]}')
  });                                         
```

Using this code as library a pkcert database needs to be set for the `SecureSocket` to function properly. The following function could be implemented that passes the directory location of the pkcert's

```
/**
 * Setup the certificate database for the client. 
 */
void initializeSSL() {
  var testPkcertDatabase =
      new Path.fromNative(new Options().script).directoryPath.append('pkcert/');
  SecureSocket.setCertificateDatabase(testPkcertDatabase.toNativePath());
}
```

### Tool

The `goog_url_shortener.dart` in `bin/` could be used as a standalone commandline tool for shortening or expanding urls. 

###### Shorten a url

```
$ ./bin/goog_url_shortener.dart -u http://www.dartlang.org -t shorten
Long Url = http://www.dartlang.org/
Short Url = http://goo.gl/8l3PM
```

###### Expand url

```
$ ./bin/goog_url_shortener.dart -u http://goo.gl/8l3PM -t expand
Long Url = http://www.dartlang.org/
Short Url = http://goo.gl/8l3PM
```

###### Help

```
$ ./bin/goog_url_shortener.dart -h
-c, --curl               absolute path for curl
                         (defaults to "curl")

-k, --key                google api key
-u, --url                url
                         (defaults to "http://www.google.com")

-t, --type               type of action to execute

          [analytics]    analytics for the url
          [expand]       expand the url
          [shorten]      shorten the url

-h, --help               help

```

TODO
----
Add an example of creating a cert database.