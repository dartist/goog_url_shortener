Google Url Shortener in Dart
====

Simple application that shortens and expands urls using dart, curl and google shortener apis.

Usage
----
Shorten a url

```
$ ./bin/goog_url_shortener.dart -u http://www.dartlang.org -t shorten
{
 "kind": "urlshortener#url",
 "id": "http://goo.gl/8l3PM",
 "longUrl": "http://www.dartlang.org/"
}
```

Expand url


```
$ ./bin/goog_url_shortener.dart -u http://goo.gl/8l3PM -t expand
{
 "kind": "urlshortener#url",
 "id": "http://goo.gl/8l3PM",
 "longUrl": "http://www.dartlang.org/",
 "status": "OK"
}
```

Help
----
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
---
Add the google api `key` when argument is present. 