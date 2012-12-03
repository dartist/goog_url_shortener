library test_runner;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:goog_url_shortener/goog_url_shortener.dart';

import 'analytics_tests.dart';
import 'expand_tests.dart';
import 'shorten_tests.dart';

void main() {
  SecureSocket.initialize();
  new AnalyticsTests().run();
  new ExpandTests().run();
  new ShortenTests().run();
}