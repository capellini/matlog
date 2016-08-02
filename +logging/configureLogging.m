% Copyright 2016 Rob Capellini
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

function logger = configureLogging(varargin)
%% CONFIGURELOGGING - Configure logging for a script / session
%
%   Syntax:
%
%     Logger = logging.configureLogging()
%     Logger = logging.configureLogging(OptionsStruct)
%
%   Description:
%
%     Configure logging for a session or script.  Options are specified by
%     passing in a struct with the desired options (covered below).  For
%     example, to add logging to a log file that is named 'log.out', pass in
%     OptionsStruct = struct('file', 'log.out').  Logging to the console, a
%     file, and syslog/rsyslog/systemd (via the command-line 'logger'
%     utility) are supported.
%
%   Input arguments:
%     The following input arguments are specified by using properties in a
%     structure that is passed into the configureLogging function.
%
%     'logLevel' - Specify the log level for logging.  Only messages whose
%        levels are at least as high as the specified log level will be
%        logged.  For example, if your log level is set to WARNING, then
%        TRACE, DEBUG, INFO, and NOTICE log requests will be ignored,
%        while WARNING, ERROR, CRITICAL, ALERT, and EMERGENCY log
%        messages will be logged.
%     'console' - Console logging is the default configuration.  If you only
%        want to log to the console, you don't have to pass in anything.  If
%        you would like to turn off console logging, you can specify this
%        using the 'console' parameter.  Set this parameter to false or 'off'
%        to do so.
%     'file' - A string specifing the name of a single log file in which to
%        log messages.
%     'files' - A cell array specifying one or more log file names in which
%        to log messages.
%     'fileLogLevel' - Used to override the default 'logLevel' when logging
%        to files.
%     'syslog' - Specified if logging to syslog/rsyslog/systemd/etc is
%        desired.  Either set 'syslog' to true or 'on' to log to system
%        logger.
%     'fileLogLevel' - Used to override the default 'logLevel' when logging
%        to system logs.
%
%  Output Arguments:
%
%    Logger - A composite logger, which will log to all specified locations.
%    Log entries are made when calling the Logger method of the appropriate
%    log level, provided that the log level requested exceeds the minimum log
%    level (e.g. Logger.warning('I''m a warning message. YOU HAVE BEEN WARNED!').
%
%  Notes:
%
%    o The default log level is INFO.
%
%    o If you request a file to be placed in a directory that does not yet
%      exist, the Logger will attempt to create the directory upon
%      initialization.  If it is unsuccessful in creating the directory,
%      creation of the Logger will fail.
%
%  Example Usage:
%
%    % create a logger that logs only INFO messages and above to the console
%    logger = configureLogging();
%
%    % create a logger that logs only ERROR messages and above to the console
%    logOptions = struct('logLevel', logging.LogLevel.ERROR);
%    logger = configureLogging(logOptions);
%
%    % create a logger that logs all messages to the console and a logfile
%    logOptions = struct('logLevel', logging.LogLevel.ALL, 'file', 'log.out');
%    logger = configureLogging(logOptions);
%
%    % log all to the console, WARNING and above to logfile log.out and
%    % CRITICAL and above to the system logging utility
%    logOptions = struct( ...
%        'logLevel', logging.LogLevel.ALL, ...
%        'file', 'log.out', 'fileLogLevel', logging.LogLevel.WARNING, ...
%        'syslog', 'on', 'syslogLogLevel', logging.LogLevel.CRITICAL, ...
%    );
%    logger = configureLogging(logOptions);
%
%  See also LOGGINGCOMMANDS, CONSOLELOGGER, FILELOGGER, SYSLOGLOGGER

    logger = logging.CompositeLogger();
    options = getOptions(varargin{:});

    %% Console logging
    % must explicitly turn off console logging specify struct('console',
    % false) or struct('console', 'off')
    if ~consoleLoggingExplicitlyTurnedOff(options)
        logger.addLogger(logging.ConsoleLogger(options));
    end

    %% File logging
    % must explicitly turn on file logging
    if singleLogFileSpecified(options)
        logger = turnOnFileLogging(options, logger, options.file);
    end

    if multipleLogFilesSpecified(options)
        for fileIdx = 1:length(options.files)
            logger = turnOnFileLogging(options, logger, options.files{fileIdx});
        end
    end

    %% Syslog logging
    % Only works on *nix ssytems with the logging command line utility
    % must explicitly turn on syslong logging
    % pass the facility in with the options structure, as normal
    if syslogLoggingSpecified(options)
        logger = turnOnSyslogLogging(options, logger);
    end
end

function options = getOptions(varargin)
    if nargin > 0
        options = varargin{1};
    else
        options = struct();
    end
end

function turnedOff = consoleLoggingExplicitlyTurnedOff(options)
    % note that MATLAB docs say that isboolean exists in R2013a, but not in
    % my version
    turnedOff = ...
        isfield(options, 'console') && ( ...
            isscalar(options.console) && options.console == false || ...
            ischar(options.console) && strcmp(options.console, 'off') ...
        );
end

function specified = singleLogFileSpecified(options)
% Use 'file' property in options struct to specify a single file
    specified = isfield(options, 'file');
end

function specified = multipleLogFilesSpecified(options)
% Specified using something like struct('files', {{'filename1.out', filename2.out'}})
    specified = isfield(options, 'files');
end

function logger = turnOnFileLogging(options, logger, filename)
    if isfield(options, 'fileLogLevel')
        options.logLevel = options.fileLogLevel;
    end
    logger.addLogger(logging.FileLogger(filename, options));
end

function specified = syslogLoggingSpecified(options)
    specified = ...
        isfield(options, 'syslog') && ( ...
            isscalar(options.syslog) && options.syslog == true || ...
            ischar(options.syslog) && strcmp(options.syslog, 'on') ...
        );
end

function logger = turnOnSyslogLogging(options, logger)
    if isfield(options, 'syslogLogLevel')
        options.logLevel = options.syslogLogLevel;
    end
    logger.addLogger(logging.SyslogLogger(options));
end