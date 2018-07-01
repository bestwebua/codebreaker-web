# CodebreakerWeb

Rack version of Codebreaker2018 [![Gem Version](https://badge.fury.io/rb/codebreaker2018.svg)](https://badge.fury.io/rb/codebreaker2018)

## About

Codebreaker is a logic game in which the code-breaker tries to break a secret code created by a code-maker. The code-maker, which will be played by the application we’re going to write, creates a secret code of four numbers between 1 and 6.

## Technology summary

* Ruby 2.5.0
* Rack 2.0.5
* Twitter Bootstrap 4.1.1
* HTML5/CSS/JS

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
10. Reloading scores before using.
11. Implement ActionInspector middleware, restricted access for necessary application parts.
12. Implement ErrorLogger, recording all hack attempts into log-file.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bestwebua/homework-05-codebreaker-web. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
