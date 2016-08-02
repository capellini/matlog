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

classdef ConfigureLoggingUnitTests < matlab.unittest.TestCase
    methods (Test)
        function TestNullCase(testCase)
            testCase.initAndVerifyCompositeLogger(struct('console', 'off'), 0);
        end

        function TestDefault(testCase)
            logger = testCase.initAndVerifyCompositeLogger({}, 1);
            testCase.verifyClass(logger.loggers{1}, ?logging.ConsoleLogger);
        end

        function TestConsoleOnlyLogLevel(testCase)
            for l = 1:length(TestHelper.LOG_LEVELS)
                logLevel = logging.LogLevel.(TestHelper.LOG_LEVELS{l});
                logger = testCase.initAndVerifyCompositeLogger(struct('logLevel', logLevel), 1);
                testCase.verifyClass(logger.loggers{1}, ?logging.ConsoleLogger);
                testCase.verifyEqual(logger.loggers{1}.logLevel, logLevel);
            end
        end

        function TestSingleFileLogger(testCase)
            loggerOpts = struct('console', 'off', 'file', 'log.out');
            logger = testCase.initAndVerifyCompositeLogger(loggerOpts, 1);
            testCase.verifyFileLogger(logger.loggers{1}, 'log.out');
        end

        function TestMultipleFileLogger(testCase)
            loggerOpts = struct( ...
                'console', 'off', 'files', {{'log1.out', 'log2.out', 'log3.out'}} ...
            );
            logger = testCase.initAndVerifyCompositeLogger(loggerOpts, 3);
            for i = 1:3
                testCase.verifyFileLogger(logger.loggers{i}, ['log' num2str(i) '.out']);
            end
        end

        function TestSyslogLogger(testCase)
            loggerOpts = struct('console', 'off', 'syslog', 'on');
            logger = testCase.initAndVerifyCompositeLogger(loggerOpts, 1);
            testCase.verifySyslogLogger(logger.loggers{1}, 'local0');
        end

        function TestSyslogLoggerChangingFacility(testCase)
            loggerOpts = struct('console', 'off', 'syslog', 'on', 'facility', 'local3');
            logger = testCase.initAndVerifyCompositeLogger(loggerOpts, 1);
            testCase.verifySyslogLogger(logger.loggers{1}, 'local3');
        end

        function TestCompositeLoggerConsoleAndFile(testCase)
            loggerOpts = struct( ...
                'logLevel', 'TRACE', 'file', 'log.out', 'fileLogLevel', 'DEBUG' ...
            );
            logger = testCase.initAndVerifyCompositeLogger(loggerOpts, 2);
            testCase.verifyClass(logger.loggers{1}, ?logging.ConsoleLogger);
            testCase.verifyEqual(logger.loggers{1}.logLevel, logging.LogLevel.TRACE);
            testCase.verifyFileLogger(logger.loggers{2}, 'log.out');
            testCase.verifyEqual(logger.loggers{2}.logLevel, logging.LogLevel.DEBUG);
        end

        function TestCompositeLoggerConsoleAndSyslog(testCase)
            loggerOpts = struct( ...
                'logLevel', 'TRACE', 'syslog', 'on', 'syslogLogLevel', 'DEBUG' ...
            );
            logger = testCase.initAndVerifyCompositeLogger(loggerOpts, 2);
            testCase.verifyClass(logger.loggers{1}, ?logging.ConsoleLogger);
            testCase.verifyEqual(logger.loggers{1}.logLevel, logging.LogLevel.TRACE);
            testCase.verifySyslogLogger(logger.loggers{2}, 'local0');
            testCase.verifyEqual(logger.loggers{2}.logLevel, logging.LogLevel.DEBUG);
        end

        function TestCompositeLoggerFileAndSyslog(testCase)
            loggerOpts = struct( ...
                'logLevel', 'TRACE', 'console', 'off', ...
                'file', 'log.out', 'syslog', 'on', 'syslogLogLevel', 'DEBUG' ...
            );
            logger = testCase.initAndVerifyCompositeLogger(loggerOpts, 2);
            testCase.verifyFileLogger(logger.loggers{1}, 'log.out');
            testCase.verifyEqual(logger.loggers{1}.logLevel, logging.LogLevel.TRACE);
            testCase.verifySyslogLogger(logger.loggers{2}, 'local0');
            testCase.verifyEqual(logger.loggers{2}.logLevel, logging.LogLevel.DEBUG);
        end
    end

    methods
        function logger = initAndVerifyCompositeLogger(testCase, options, numLoggers)
            logger = logging.configureLogging(options);
            testCase.verifyClass(logger, ?logging.CompositeLogger);
            testCase.verifyLength(logger.loggers, numLoggers);
        end

        function verifyFileLogger(testCase, logger, logFile)
            testCase.verifyClass(logger, ?logging.FileLogger);
            testCase.verifyEqual(logger.logFile, logFile);
        end

        function verifySyslogLogger(testCase, logger, facility)
            testCase.verifyClass(logger, ?logging.SyslogLogger);
            testCase.verifyEqual(logger.facility, facility);
        end
    end
end
