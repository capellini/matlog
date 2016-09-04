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

        function varargout = logCommand(obj, commandString, varargin)
            messagePrefix = obj.formatLevelPrefix('COMMAND');

            for j = 1:length(obj.loggers)
                obj.loggers{j}.formatAndLogMessage(messagePrefix, repmat('=', 1, 80));
                obj.loggers{j}.formatAndLogMessage( ...
                    messagePrefix, ...
                    sprintf('Output of command %s follows', commandString) ...
                );
            end

            % varargin contains scope variables or commands to run before running
            % command with output to capture
            for i = 1:nargin - 2
                if ischar(varargin{i})
                    T = evalc(varargin{i});
                    if length(T) > 0
                        T = obj.stripHtmlTags(T);
                        for j = 1:length(obj.loggers)
                            obj.loggers{j}.formatAndLogMessage(messagePrefix, T);
                        end
                    end
                else
                    varname = inputname(i + 2);
                    eval([varname ' = varargin{i};']);
                end
            end

            [T, varargout{1:nargout}] = evalc(commandString);
            if length(T) > 0
              T = obj.stripHtmlTags(T);
                for j = 1:length(obj.loggers)
                    obj.loggers{j}.formatAndLogMessage(messagePrefix, T);
                end
            end

            for j = 1:length(obj.loggers)
                obj.loggers{j}.formatAndLogMessage( ...
                    messagePrefix, ...
                    sprintf('Output of command %s complete', commandString) ...
                );
                obj.loggers{j}.formatAndLogMessage(messagePrefix, repmat('=', 1, 80));
            end
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

        function T = stripHtmlTags(obj, T)
          pat = '<a href[^>]*>';
          T = regexprep(T, pat, '');
          T = regexprep(T, '</a>', '');
        end
    end
end