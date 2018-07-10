# CodebreakerWeb
[code_climate]: https://codeclimate.com/github/bestwebua/homework-05-codebreaker-web
[![Test Coverage](https://api.codeclimate.com/v1/badges/5b446f43b805420285006f76/test_coverage)][code_climate]

Rack version of Codebreaker2018 [![Gem Version](https://badge.fury.io/rb/codebreaker2018.svg)](https://badge.fury.io/rb/codebreaker2018). Try to guess 4-digit number, that consists of numbers in a range between 1 to 6.

## Features

1. Ability to change the language from anywhere in the application. English and Russian localizations.
2. Self template methods.
3. No monkey-patching codebreaker2018 gem class/methods.
4. This app uses codebreaker2018 gem modules, no double implementation.
5. Players have unique tokens and ip-addresses.
6. Smart top-players sort.
7. Player motivation messages, js implementation.
8. Guessed numbers marker, js implementation.
9. Safe methods in Web class.
10. No DB usage. Application saves all data into YAML. Reloading scores before using.
11. Implement ActionInspector middleware, restricted access for necessary application parts.
12. Implement ErrorLogger, recording all hack attempts into log-file.
13. Responsive design.
14. RSpec tests, 100% coverage.

## Demo

http://codebreaker.bestweb.com.ua:9292

![CodebreakerWeb screenshot](https://raw.githubusercontent.com/bestwebua/homework-05-codebreaker-web/feature/base_version/public/images/screenshot.png)

## Technology summary

* Ruby 2.5.0
* Rack 2.0.5
* codebreaker2018 0.3.5
* Twitter Bootstrap 4.1.1
* HTML5/CSS/JS
* Environment: CentOS 6.8/Puma 3.11
* Testing: RSpec 3.7, simplecov 0.16

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bestwebua/homework-05-codebreaker-web. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
