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

classdef CompositeLogger < logging.Logger
    properties
        loggers
    end

    methods
        function obj = CompositeLogger(varargin)
            obj@logging.Logger(varargin{:});
            obj.loggers = {};
        end

        function addLogger(obj, logger)
            obj.loggers{length(obj.loggers) + 1} = logger;
        end

        function setLogLevel(obj, level)
            cellfun(@(x) x.setLogLevel(level), obj.loggers);
        end

        function setConsoleLogLevel(obj, level)
            obj.setLoggerOfTypeToLevel('logging.ConsoleLogger', level);
        end

        function setFileLogLevel(obj, level)
            obj.setLoggerOfTypeToLevel('logging.FileLogger', level);
        end

        function setSyslogLogLevel(obj, level)
            obj.setLoggerOfTypeToLevel('logging.SyslogLogger', level);
        end
    end

    methods (Access = protected)
        function logIfAtLevel(obj, level, varargin)
            cellfun(@(x) x.logIfAtLevel(level, varargin{:}), obj.loggers);
        end

        function setLoggerOfTypeToLevel(obj, type, level)
            loggerIdx = cellfun(@(x) isa(x, type), obj.loggers);
            cellfun(@(x) x.setLogLevel(level), {obj.loggers{loggerIdx}});
        end

        function logMessage(~, ~)
            'noop';
        end
    end
end