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

classdef FileLogger < logging.Logger
%% FILELOGGER - Log messages to a file
%
%  o Create a logger that logs INFO and above to the screen and a file
%    called 'log.out':
%  >> logger = logging.configureLogging(struct('file', 'log.out'));
%
%  o Create a logger that logs INFO and above to a file called
%    'log.out', but does not output messages to the console:
%  >> logger = logging.configureLogging( ...
%         struct('console', 'off', 'file', 'log.out') ...
%     );
%
%  o Create a logger that logs only ERROR and above to the console and logs
%    only DEBUG and above to the file 'log.out':
%  >> logger = logging.configureLogging( ...
%         struct( ...
%             'logLevel', logging.LogLevel.ERROR, ...
%             'file', 'log.out', 'fileLogLevel',  logging.LogLevel.DEBUG ...
%         ) ...
%     );
%
%  o Log some messages:
%  >> logger.trace('This will not be logged anywhere');
%  >> logger.info('This will be logged to log.out only');
%  >> logger.critical('This one will be logged to the screen and log.out');
%
%  o Change the log level:
%  >> logger.setFileLogLevel(logging.LogLevel.TRACE);
%
%  o And log some more messages:
%  >> logger.trace('Now this will be logged to log.out, but not to the screen');
%  >> logger.critical('This will, once again, be logged to both places');
%
%  See also LOGGINGCOMMANDS, CONFIGURELOGGING, CONSOLELOGGER, SYSLOGLOGGER

    properties (SetAccess = protected)
        logFile
    end

    methods
        function obj = FileLogger(logfile, varargin)
            obj@logging.Logger(varargin{:});
            obj.logFile = logfile;
            obj.initializeLogging();
        end
    end

    methods (Access = protected)
        function initializeLogging(obj)
            directory = fileparts(obj.logFile);
            if directory
                obj.createDirectoryIfNotExist(directory);
            end
        end

        function createDirectoryIfNotExist(obj, dir)
            if ~obj.directoryExists(dir)
                obj.createDirectory(dir)
            end
        end

        function dirExists = directoryExists(obj, dir)
            [status, folderInfo] = fileattrib(dir);
            dirExists = (status && folderInfo.directory);
        end

        function createDirectory(~, dir)
            try
                mkdir(dir)
            catch ME
                if strcmp(ME.identifier, 'MATLAB:MKDIR:OSError')
                    throw(MException( ...
                        'logging:CannotCreateDirectory', ...
                        'Log directory does not exist and can''t be created' ...
                    ));
                end
            end
        end

        function fileDescriptor = openLogFile(obj)
            fileDescriptor = fopen(obj.logFile, 'a');
            if (fileDescriptor < 0)
                exception = MException( ...
                    'logging:cannotOpenLogFile', ...
                    sprintf('Cannot open log file %s.', obj.logFile) ...
                );
                throw(exception);
            end
        end

        function closeLogFile(~, fileDescriptor)
            fclose(fileDescriptor);
        end

        function logMessage(obj, message)
            fileDescriptor = obj.openLogFile();
            obj.fprintf(fileDescriptor, message);
            obj.closeLogFile(fileDescriptor);
        end
    end
end