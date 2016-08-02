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

classdef Logger < handle
    properties (Constant)
        ALL = logging.LogLevel.ALL;
        TRACE = logging.LogLevel.TRACE;
        DEBUG = logging.LogLevel.DEBUG;
        INFO = logging.LogLevel.INFO;
        NOTICE = logging.LogLevel.NOTICE;
        WARNING = logging.LogLevel.WARNING;
        ERROR = logging.LogLevel.ERROR;
        CRITICAL = logging.LogLevel.CRITICAL;
        ALERT = logging.LogLevel.ALERT;
        EMERGENCY = logging.LogLevel.EMERGENCY;

        DEFAULT_LOG_LEVEL = logging.LogLevel.INFO;
    end

    properties (SetAccess = protected)
        fprintf
        includeTimestamp = true;
        logLevel = logging.Logger.DEFAULT_LOG_LEVEL;
        options
        printStack = false;
    end

    methods (Static)
        function options = parseOptions(varargin)
            if nargin >= 1
                options = varargin{1};
            else
                options = struct();
            end
        end

        function level = extractLogLevelFromStruct(level)
            if isstruct(level) && isfield(level, 'logLevel')
                level = level.logLevel;
            end
        end

        function message = formatLevelPrefix(level)
        %% formatLevelPrefix - ensures that log message prefix is of uniform size
        %   Ensures that the text prepended to the log message is of uniform
        %   size to aid in readability of the log messages.  For example,
        %   without formatting, an INFO line will be one space less than a
        %   FATAL line, resulting in a harder to read log file.  This
        %   function ensures uniform spacing.
            numSpaces = length('EMERGENCY') - length(level) + 1;
            message = sprintf('[%s]%s:: ', level, repmat(' ', 1, numSpaces));
        end
    end

    methods (Abstract, Access = protected)
        logMessage(obj, message)
    end

    methods
        function obj = Logger(varargin)
            obj.options = obj.parseOptions(varargin{:});
            obj.setInitialLogLevel();
            obj.setTimestampOption();
            obj.setPrintStackOption();
            obj.setPrintFunction();
        end

        function trace(obj, varargin)
            obj.logIfAtLevel('TRACE', varargin{:});
        end

        function debug(obj, varargin)
            obj.logIfAtLevel('DEBUG', varargin{:});
        end

        function info(obj, varargin)
            obj.logIfAtLevel('INFO', varargin{:});
        end

        function notice(obj, varargin)
            obj.logIfAtLevel('NOTICE', varargin{:});
        end

        function warning(obj, varargin)
            obj.logIfAtLevel('WARNING', varargin{:});
        end

        function error(obj, varargin)
            obj.logIfAtLevel('ERROR', varargin{:});
        end

        function critical(obj, varargin)
            obj.logIfAtLevel('CRITICAL', varargin{:});
        end

        function alert(obj, varargin)
            obj.logIfAtLevel('ALERT', varargin{:});
        end

        function emergency(obj, varargin)
            obj.logIfAtLevel('EMERGENCY', varargin{:});
        end

        function setLogLevel(obj, level)
            try
                obj.internalSetLogLevel(level);
            catch ME
                switch ME.identifier
                    case 'MATLAB:subscripting:classHasNoPropertyOrMethod'
                      logging.LogLevel.throwInvalidLevel();
                  otherwise
                    rethrow(ME)
                end
            end
        end

        function handleMatlabError(obj, ME, varargin)
            msgString = getReport(ME, 'extended', 'hyperlinks', 'off');
            formatString = [varargin{1} '\n%s\n'];

            obj.error(formatString, varargin{2:end}, msgString);
        end
    end

    methods (Access = protected)
        function setInitialLogLevel(obj)
            if isfield(obj.options, 'logLevel')
                obj.internalSetLogLevel(obj.options.logLevel);
            end
        end

        function setTimestampOption(obj)
            if isfield(obj.options, 'includeTimestamp')
                obj.includeTimestamp = obj.options.includeTimestamp;
            end
        end

        function setPrintStackOption(obj)
            if isfield(obj.options, 'printStack')
                obj.printStack = obj.options.printStack;
            end
        end

        function setPrintFunction(obj)
        %% This is only used for testing
            if isfield(obj.options, 'fprintf') && isa(obj.options.fprintf, 'function_handle')
                obj.fprintf = obj.options.fprintf;
            else
                obj.fprintf = @fprintf;
            end
        end

        function logIfAtLevel(obj, level, varargin)
            if obj.logLevel <= logging.LogLevel.(level)
                messagePrefix = obj.formatLevelPrefix(level);
                obj.formatAndLogMessage(messagePrefix, varargin{:});
            end
        end

        function formatAndLogMessage(obj, logLevel, varargin)
            formatString = [obj.getTimestampString() logLevel obj.getStack() varargin{1} '\n'];
            message = sprintf(formatString, varargin{2:end});
            obj.logMessage(message);
        end

        function dateString = getTimestampString(obj)
            if obj.includeTimestamp
                dateString = [datestr(now(),'yyyy-mm-dd HH:MM:SS.FFF') ' :: '];
            else
                dateString = '';
            end
        end

        function stackInfo = getStack(obj)
            stackInfo = '';

            if obj.printStack()
                stackInfo = [obj.getCallStack() stackInfo];
            end
        end

        function callStack = getCallStack(obj)
            stackNames = cellstr(arrayfun(@(x) x.name, dbstack(), 'UniformOutput', false))';
            lastSelfReference = 1 + max( ...
                find(strncmp('Logger.', stackNames, 7)) ...
            );

            if length(stackNames) + 1 == lastSelfReference
                callStack = '';
            else
                callStack = [ ...
                  strjoin(obj.flipStackNames({stackNames{lastSelfReference:end}}), ' > ') ' :: ' ...
                ];
            end
        end

        function flippedNames = flipStackNames(obj, stackNames)
          try
            flippedNames = flip(stackNames);
          catch ME
            switch ME.identifier
              case 'MATLAB:UndefinedFunction'
                % Ref: https://github.com/capellini/matlog/issues/1
                flippedNames = obj.flipCellArray(stackNames);
              otherwise
                rethrow(ME);
            end
          end
        end

        function flippedNames = flipCellArray(obj, stackNames)
        %% Custom flip() for use with cell arrays for compatability with
        %% versions of MATLAB pre-2013b
          flippedNames = {};
          for i = 1:length(stackNames)
            flippedNames = {stackNames{i} flippedNames{:}};
          end
        end

        function internalSetLogLevel(obj, level)
            level = obj.extractLogLevelFromStruct(level);

            if ischar(level)
                obj.logLevel = logging.LogLevel.(upper(level));
            elseif isa(level, 'logging.LogLevel')
                obj.logLevel = level;
            else
                throw(MException('logging:InvalidLogLevel', ''));
            end
        end
    end
end