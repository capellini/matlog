# matlog -- MATLAB Logging Package

Versatile logging utility for MATLAB.  Log to the console, one or more files, the system logger (syslog, rsyslog, syslogng, etc), or some combination of all three.  This logger attempts to add several options while also abstracting the complexity of a log manager.  [Simpler loggers](https://www.mathworks.com/matlabcentral/fileexchange/37701-log4m-a-powerful-and-simple-logger-for-matlab) exist, as do [more complex ones](https://www.mathworks.com/matlabcentral/fileexchange/42078-matlab-logging-facility).  This pacakge attempts to strike a balance between simplicity and versatility.

## Getting Started

Clone this repository into your path or use [MATLAB's addpath](http://www.mathworks.com/help/matlab/ref/addpath.html) to add this repository to your path.  When using matlog, you can either prefix all functions and classes with `logging.` or put an:

  ```
  import logging.*;
  ```
statement in your main script or the MATLAB prompt.  In the examples below the `import` statement has been omitted for brevity, but it is still required if you intend to leave off `logging.` from the front of the function and class names.

## Creating an instance of a Logger

NOTE: In the following examples, I use a `struct` to pass in arguments to the `configureLogging` factory.  However, you may also pass in "classic MATLAB-style" arguments (i.e. `logging.configureLogging('console', 'off', 'file', 'log.out')`) instead, if that is the style that you prefer.

### Console Logger

* To get started with matlog and start logging to the console, create a logger using the `configureLogging` factory method with no arguments.  This will create a console logger that that logs only INFO messages and above to the console:

  ```
  logger = configureLogging();
  logger.debug('This won''t be logged to the screen.');
  logger.info('But this will, since the default log level is INFO.');
  logger.emergency('Emergency messages are always logged.');
  ```

### File Logger

* Create a logger that logs all messages to the console and a logfile:

  ```
  logOptions = struct('logLevel', LogLevel.ALL, 'file', 'log.out');
  logger = configureLogging(logOptions);
  logger.info('Logging to both the console and log.out logfile.');
  ```

* Log to the console and several files:

  ```
  logOptions = struct('files', {{'log1.out', 'log2.out'}});
  logger = configureLogging(logOptions);
  logger.error('Let''s get to logging!');
  ```

### Syslog (and variants) Logger

For those systems that support the `logger` command line utility, the Syslog Logger allows you to send messages to the system log.  **This logger should be used with care.** It simply performs a `system` call to `logger` to log messages.  Therefore, if combined with user input, dangerous things can happen.  Some trivial escaping is attempted, but use this logger **only with input that you know is safe.**

* Log to the console and the system logging utility (using the default `local0` facility):

  ```
  logOptions = struct('syslog', 'on');
  logger = configureLogging(logOptions);
  logger.info('Let''s get to logging!');
  ```

* Log to the console and the system logging utility (using the `local7` facility):

  ```
  logOptions = struct('syslog', 'on', 'facility', 'local7');
  logger = configureLogging(logOptions);
  logger.info('Logging to local7.info!');
  ```

### Other logging variants

#### Turn off console logging

* It's possible to turn off console logging by passing in a `console` property with your options struct with a value of `false` or `'off'`.  For example, to log to syslog only:

  ```
  logOptions = struct('console', 'off', 'syslog', 'on');
  logger = configureLogging(logOptions);
  logger.error('You can''t see me, but I''m logging to syslog!');
  ```

#### LOG ALL THE THINGS!

* Log all to the console, WARNING and above to logfile log.out and CRITICAL and above to the system logging utility:

  ```
  logOptions = struct( ...
      'logLevel', LogLevel.TRACE, ...
      'file', 'log.out', 'fileLogLevel', LogLevel.WARNING, ...
      'syslog', 'on', 'syslogLogLevel', LogLevel.CRITICAL, ...
  );
  logger = configureLogging(logOptions);
  logger.error('Let''s get to logging!');
  ```

## More customized situations

Sometimes you want a highly customized logging experience, with many logs logging to different places at various log levels.  In that case, you can create a basic logger, as above, and then use the addLogger method to add more loggers.  For example:

Start with a basic console logger:

  ```
  logger = configureLogging();
  ```

Then decide to add two File Loggers that log at level TRACE and above:

  ```
  traceLogs = configureLogging(struct( ...
      'console', 'off', ...
      'files', {{'log1.out', 'log2.out'}}, 'fileLogLevel', LogLevel.DEBUG ...
  ));
  logger.addLogger(traceLogs);
  ```

Then also decide that to add a Syslog logger at facility 'local1' at level ALERT and above:

  ```
  syslog = configureLogging(struct( ...
      'console', 'off', ...
      'syslog', 'on', 'facility', 'local1', 'syslogLogLevel', LogLevel.ALERT ...
  ));
  logger.addLogger(syslog);
  ```

And one more file log to log messages WARNING and above:

  ```
  warningLogs = configureLogging(struct( ...
      'console', 'off', ...
      'file', 'log3.out', 'fileLogLevel', LogLevel.WARNING ...
  ));
  logger.addLogger(warningLogs);
  ```

Now, you can use loggers one at a time, or in aggregate:

  ```
  traceLogs.debug('Just to my two trace logfiles');
  syslog.alert('Time to wake up syslog with a message');
  warningLogs.error('Logging to my warning file');
  logger.emergency('Log everywhere');
  ```

## Logging

Once an instance of a Logger has been created, logging is performed at the respective level using the `trace`, `debug`, `info`, `notice`, `warning`, `error`, `critical`, `alert`, and `emergency` methods:

  ```
  logger.trace('Logging at the trace level.');
  logger.debug('Logging at the debug level.');
  logger.info('Logging at the info level.');
  logger.notice('Logging at the notice level.');
  logger.warning('Logging at the warning level.');
  logger.error('Logging at the error level.');
  logger.critical('Logging at the critical level.');
  logger.alert('Logging at the alert level.');
  logger.emergency('Logging at the emergency level.');

  ```

Whether or not a message gets logged depends on the log level set.  The default log level is INFO.  Using this default level, for example, TRACE and DEBUG messages will not be logged, but all other method calls will result in a message being logged.

## Setting the log level

The log level can be set initially when calling `configureLogging`, or later by calling the `setLogLevel` method on the Logger instance.

When using `configureLogging`, you can set a global log level for all logging locations by using the `logLevel` property in your configuration struct.  You may also specify specific logging levels for different types of loggers using the `fileLogLevel` and `syslogLogLevel` properties.

* Create a logger that logs only ERROR messages and above to the console:

  ```
  logOptions = struct('logLevel', LogLevel.ERROR);
  logger = configureLogging(logOptions);
  logger.warning('This won''t be logged to the screen.');
  logger.alert('But this will.');
  ```

* Create a logger that logs only ERROR messages and above to the console, but all messages to `log.out`:

  ```
  logOptions = struct( ...
      'logLevel', LogLevel.ERROR, 'file', 'log.out', ...
      'fileLogLevel', LogLevel.TRACE ...
  );
  logger = configureLogging(logOptions);
  logger.warning('This won''t be logged to the screen.');
  logger.alert('But this will.');
  ```

### Dynamically setting the log level

The `setLogLevel` method can be used to refine log levels dynamically at runtime.  For example, in your main configuration function/method/script, you can set your log level to something more verbose when developing and debugging code. Then, once your code is ready for production, you can increase the log level so logs are not full of trace, debug, and info messages.

  ```
  if strcmp(getenv('PRODUCTION'), 'TRUE')
      logger.setLogLevel(LogLevel.WARNING);
  elseif strcmp(getenv('STAGING'), 'TRUE')
      logger.setLogLevel(LogLevel.INFO);
  elseif strcmp(getenv('DEVELOPMENT'), 'TRUE')
      logger.setLogLevel(LogLevel.TRACE);
  end
  ```

## Running Tests

Logging tests can be run from the command line via a BASH script.  The script assumes that your MATLAB binary is called `matlab`. If it's called something else, ensure the MATLAB variable is set properly in the script.  Run tests on a terminal command line by running:

  ```
  ./run_logging_tests.sh
  ```

Also, you can run the tests inside of MATLAB by running `run_logging_tests`.


## Issues

If you run into issues using this pacakge, please submit an issue on the issue tracker.

## Contributing

Contributions are always welcome via pull request.  Please abide by the `.editorconfig` file by using the [editorconfig plugin](http://editorconfig.org/#download) for your editor of choice.
