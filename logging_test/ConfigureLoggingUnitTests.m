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
    properties
        TESTLOG = 'testlog.out';
    end

    methods (TestMethodTeardown)
        function removeTestFile(testCase)
            if exist(testCase.TESTLOG, 'file')
                delete(testCase.TESTLOG);
            end
        end
    end

    methods (Test)
        function TestNullCase(testCase)
            testCase.initAndVerifyCompositeLogger(struct('console', 'off'), 0);
        end

        function TestDefault(testCase)
            logger = testCase.initAndVerifyCompositeLogger(false, 1);
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

        function TestPassOptsInClassicMatlabStyle(testCase)
        %% Test passing in args as key value pairs, rather than as a struct
            logger = logging.configureLogging('console', 'off', 'file', 'log.out');
            testCase.verifyClass(logger, ?logging.CompositeLogger);
            testCase.verifyLength(logger.loggers, 1);
            testCase.verifyFileLogger(logger.loggers{1}, 'log.out');
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

        function TestLogCommandNoOutputWithAssignment(testCase)
            testCase.assumeTrue(~exist(testCase.TESTLOG, 'file'));

            logger = logging.configureLogging('console', 'off', 'file', testCase.TESTLOG);
            sin0 = logger.logCommand('sin(0)');

            TestHelper.verifyNumLinesInLog(testCase, testCase.TESTLOG, 4);
            testCase.verifyEqual(sin0, 0);
        end

        function TestLogCommandNoOutputWithAssignments(testCase)
            testCase.assumeTrue(~exist(testCase.TESTLOG, 'file'));

            logger = logging.configureLogging('console', 'off', 'file', testCase.TESTLOG);
            [a, b, c] = logger.logCommand('deal(1)');

            TestHelper.verifyNumLinesInLog(testCase, testCase.TESTLOG, 4);
            testCase.verifyEqual(a, 1);
            testCase.verifyEqual(b, 1);
            testCase.verifyEqual(c, 1);
        end

        function TestLogCommandWithOutput(testCase)
            testCase.assumeTrue(~exist(testCase.TESTLOG, 'file'));

            logger = logging.configureLogging('console', 'off', 'file', testCase.TESTLOG);
            logger.logCommand('fprintf(''Logging output'')');

            TestHelper.verifyNumLinesInLog(testCase, testCase.TESTLOG, 5);
            TestHelper.verifyLogEntry( ...
                testCase, testCase.TESTLOG, '[COMMAND]   :: Logging output', 'lineNum', 3 ...
            );
        end

        function TestLogCommandPassScopeAsString(testCase)
            testCase.assumeTrue(~exist(testCase.TESTLOG, 'file'));

            logger = logging.configureLogging('console', 'off', 'file', testCase.TESTLOG);
            x = logger.logCommand( ...
                'fmincon(fun,x0,A,b)', ...
                'fun = @(x)100*(x(2)-x(1)^2)^2 + (1-x(1))^2, x0 = [-1,2], A = [1,2], b = 1' ...
            );

            testCase.verifyEqual(x, [-0.9976 0.9951], 'AbsTol', 1e-4);
        end

        function TestLogCommandPassScopeAsVariables(testCase)
            testCase.assumeTrue(~exist(testCase.TESTLOG, 'file'));

            logger = logging.configureLogging('console', 'off', 'file', testCase.TESTLOG);

            fun = @(x)100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
            x0 = [-1,2];
            A = [1,2];
            b = 1;

            x = logger.logCommand('fmincon(fun,x0,A,b)', fun, x0, A, b);

            testCase.verifyEqual(x, [-0.9976 0.9951], 'AbsTol', 1e-4);
        end
    end

    methods
        function logger = initAndVerifyCompositeLogger(testCase, options, numLoggers)
            if isstruct(options)
                options = options;
            else
                options = struct();
            end

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
