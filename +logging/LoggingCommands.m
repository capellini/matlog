%% Cheat sheet of logging commands
%
%  Logger creation:
%    The easiest way to configure your logging is to use the
%    logging.configureLogging command.  This will automatically configure all
%    of you logging needs, and will allow you to conveniently log to several
%    locations (e.g. the screen and a file) with one log command.  The
%    following are some examples of using the configureLogging command.
%
%    o create a logger that logs only INFO messages and above to the console:
%    >> logger = configureLogging();
%
%    o create a logger that logs only ERROR messages and above to the console:
%    >> logOptions = struct('logLevel', logging.LogLevel.ERROR);
%    >> logger = configureLogging(logOptions);
%
%    o create a logger that logs all messages to the console and a logfile:
%    >> logOptions = struct('logLevel', logging.LogLevel.ALL, 'file', 'log.out');
%    >> logger = configureLogging(logOptions);
%
%    o log all to the console, WARNING and above to logfile log.out and
%      CRITICAL and above to the system logging utility:
%    >> logOptions = struct( ...
%           'logLevel', logging.LogLevel.ALL, ...
%           'file', 'log.out', 'fileLogLevel', logging.LogLevel.WARNING, ...
%           'syslog', 'on', 'syslogLogLevel', logging.LogLevel.CRITICAL, ...
%       );
%    >> logger = configureLogging(logOptions);
%
%    Logging then becomes a matter of placing logging entries where you want
%    them throughout the code.  It is usually a good idea to be more
%    judicious about where to put logging lines in your code the higher the
%    log level.  For example:
%
%    >> logger.trace('I need this information to debug at a very fine level.')
%    >> logger.trace('More often than not, my log level will be above TRACE.')
%    >> logger.trace( ..
%           ['So I won't see these lines and they won't have a ' ...
%            'substantive performance impact.'] ...
%       );
%    >> logger.trace( ..
%           ['But if I ever need to really inspect the fine details of what''s ' ...
%            'going on in my code, I can lower the log level to trace and ' ...
%             see these messages.'] ...
%       );
%
%    >> logger.critical( ...
%           ['Save these messages for the few occasions when something goes ' ...
%            'really bad. Otherwise, on a day to day basis, your logs will ' ...
%            'be really cluttered.'] ...
%       );
%
%   Now, in your main configuration function/method/script, you can set your
%   log level to something more verbose when developing and debugging code.
%   Then, once your code is ready for production, you can increase the log
%   level so logs are not full of trace, debug, and info messages.
%
%   >> if strcmp(getenv('PRODUCTION'), 'TRUE')
%          logger.setLogLevel(logging.LogLevel.WARNING);
%      elseif strcmp(getenv('STAGING'), 'TRUE')
%          logger.setLogLevel(logging.LogLevel.INFO);
%      elseif strcmp(getenv('DEVELOPMENT'), 'TRUE')
%          logger.setLogLevel(logging.LogLevel.TRACE);
%      end
