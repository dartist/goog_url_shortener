library test_runner;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:goog_url_shortener/goog_url_shortener.dart';

import 'analytics_tests.dart';
import 'expand_tests.dart';
import 'shorten_tests.dart';

/**
 * Setup the certificate database for the client. 
 */
void initializeSSL() {
  var testPkcertDatabase =
      new Path.fromNative(new Options().script).directoryPath.append('pkcert/');
  SecureSocket.setCertificateDatabase(testPkcertDatabase.toNativePath());
}

void main() {
  initializeSSL();
  new AnalyticsTests().run();
  new ExpandTests().run();
  new ShortenTests().run();
}