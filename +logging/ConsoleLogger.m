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

classdef ConsoleLogger < logging.Logger
%% CONSOLELOGGER - Log messages to the screen
%
%  o Create a console logger that logs INFO and above:
%  >> logger = logging.configureLogging();
%
%  o Create a console logger that logs only ERROR and above:
%  >> logger = logging.configureLogging( ...
%         struct('logLevel', logging.LogLevel.ERROR ...
%     );
%
%  o Log some messages:
%  >> logger.trace('Log level is ERROR, so this won't be logged');
%  >> logger.critical('This one will be logged, though');
%
%  o Change the log level:
%  >> logger.setLogLevel(logging.LogLevel.TRACE);
%
%  o And log some more messages:
%  >> logger.trace('Now this will be logged');
%  >> logger.critical('And this one will still be logged, too');
%
%  See also LOGGINGCOMMANDS, CONFIGURELOGGING, FILELOGGER, SYSLOGLOGGER

    properties (Constant)
        CONSOLE = 1;
    end

    methods
        function obj = ConsoleLogger(varargin)
            obj@logging.Logger(varargin{:});
        end
    end

    methods (Access = protected)
        function logMessage(obj, message)
            obj.fprintf(obj.CONSOLE, message);
        end
    end
end