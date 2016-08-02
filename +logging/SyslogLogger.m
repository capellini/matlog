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

classdef SyslogLogger < logging.Logger
%% SYSLOGLOGGER - Log messages to the system logs
%
%   Logs messages to syslog.  Note that this only works on *nix systems with
%   the 'logger' command line utility enabled.  BE EXTREMELY CAREFUL with
%   using this.  It utilizes a 'system' MATLAB call.  User input athat is not
%   validated could do bad things (think logger.fatal("\"; rm -rf /; #")).
%   Only a cursory attempt is made to scrub the input...use this at your own
%   risk.
%
%  o Create a logger that logs INFO and above to the screen and to the system
%    logs at facility 'local0':
%  >> logger = logging.configureLogging(struct('syslog', 'on'));
%
%  o Create a logger that logs INFO and above to facility local0 on system
%    logs, but does not output messages to the console:
%  >> logger = logging.configureLogging( ...
%         struct('console', 'off', 'syslog', 'on') ...
%     );
%
%  o Create a logger that logs ERROR and above to facility local7 on system
%    logs, but does not output messages to the console:
%  >> logger = logging.configureLogging( ...
%         struct( ...
%             'console', 'off', 'syslog', 'on', ...
%             'sysLogLogLevel', logging.LogLevel.ERROR, 'facillity', 'local7' ...
%         ) ...
%     );
%
%  o Create a logger that logs only ERROR and above to the console and logs
%    only DEBUG and above to the 'local4' facility of system logs:
%  >> logger = logging.configureLogging( ...
%         struct( ...
%             'logLevel', logging.LogLevel.ERROR, ...
%             'syslog', 'on', 'syslogLogLevel',  logging.LogLevel.DEBUG ...
%             'facility', 'local4' ...
%         ) ...
%     );
%
%  o Log some messages:
%  >> logger.trace('This will not be logged anywhere');
%  >> logger.info('This will be logged to the system logger');
%  >> logger.critical('This''ll be logged to screen and system logger');
%
%  o Change the log level:
%  >> logger.setSyslogLogLevel(logging.LogLevel.TRACE);
%
%  o And log some more messages:
%  >> logger.trace('This will be logged to system logs, but not to the screen');
%  >> logger.critical('This will, once again, be logged to both places');
%
%  See also LOGGINGCOMMANDS, CONFIGURELOGGING, CONSOLELOGGER, FILELOGGER

    properties (Constant)
        DEFAULT_FACILITY = 'local0';
    end

    properties (SetAccess = protected)
        facility
    end

    methods
        function obj = SyslogLogger(varargin)
            options = logging.Logger.parseOptions(varargin{:});
            if ~isfield(options, 'fprintf')
                options.fprintf = @system;
            end
            obj@logging.Logger(options);
            obj.facility = obj.extractFacilityFromOptions();

            % usually syslog has a timestamp already, so turn it off by default
            obj.includeTimestamp = false;
            obj.setTimestampOption();
        end
    end

    methods (Static)
        function facility = getFacilityFromLogLevel(level)
            if ~isa(level, 'logging.LogLevel')
                logging.LogLevel.throwInvalidLevel();
            end

            switch level
              case {logging.LogLevel.TRACE, logging.LogLevel.DEBUG}
                facility = 'debug';
              case logging.LogLevel.INFO
                facility = 'info';
              case logging.LogLevel.NOTICE
                facility = 'notice';
              case logging.LogLevel.WARNING
                facility = 'warning';
              case logging.LogLevel.ERROR
                facility = 'err';
              case logging.LogLevel.CRITICAL
                facility = 'crit';
              case logging.LogLevel.ALERT
                facility = 'alert';
              case logging.LogLevel.EMERGENCY
                facility = 'emerg';
              otherwise
                logging.LogLevel.throwInvalidLevel();
            end
        end
    end

    methods (Access = protected)
        function facility = extractFacilityFromOptions(obj)
            if isfield(obj.options, 'facility')
                facility = obj.options.facility;
            else
                facility = obj.DEFAULT_FACILITY;
            end
        end

        function logMessage(obj, message)
            message = ['[MATLAB LOG] :: ' obj.escapeMessage(message)];
            level = obj.getFacilityFromLogLevel(obj.logLevel);
            priority = [obj.facility '.' level];
            system(['logger -p ' priority ' "' message '"']);
        end

        function message = escapeMessage(obj, message)
            message = regexprep(message, '"', '\\"');
        end
    end
end