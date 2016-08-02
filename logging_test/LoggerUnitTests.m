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

classdef LoggerUnitTests < matlab.unittest.TestCase
    properties (Access = protected)
        logger
    end

    methods (TestMethodSetup)
        function createFixture(testCase)
            testCase.logger = logging.NullLogger();
        end
    end

    methods (Test)
        function TestParseOptions_EmptyOptions(testCase)
        %% If you pass no options into parseOptions, it returns an empty struct
            result = logging.Logger.parseOptions();
            testCase.verifyTrue(isstruct(result));
            testCase.verifyEmpty(properties(result));
        end

        function TestParseOptions_OptionsStruct(testCase)
        %% If you pass an options struct into parseOptions, it returns the struct
            opts = struct('logLevel', logging.LogLevel.ERROR);
            result = logging.Logger.parseOptions(opts);
            TestHelper.verifyStructsAreEqual(testCase, result, opts);
        end

        function TestExtractLogLevelFromStruct_NotStruct(testCase)
        %% If you don't pass a struct into testExtractLogLevelFromStruct, it
        %% will just return what you passed in.
            level = 'not a struct';
            result = logging.Logger.extractLogLevelFromStruct(level);
            testCase.verifyEqual(result, level);
        end

        function TestExtractLogLevelFromStruct_StructWithoutLogLevel(testCase)
        %% If you pass in a struct without a logLevel property, it will just
        %% return the struct
            level = struct('notLogLevel', logging.LogLevel.INFO);
            result = logging.Logger.extractLogLevelFromStruct(level);
            TestHelper.verifyStructsAreEqual(testCase, result, level);
        end

        function TestExtractLogLevelFromStruct_StructWithValidLogLevel(testCase)
        %% If you pass in a struct with a logLevel property with a value that
        %% is a valig logging.LogLevel, it will return the appropriate 
        %% logging.LogLevel
            level = struct('logLevel', logging.LogLevel.CRITICAL);
            result = logging.Logger.extractLogLevelFromStruct(level);
            testCase.verifyEqual(result, logging.LogLevel.CRITICAL);
        end

        function TestFormatLevelPrefix_FiveCharacters(testCase)
        %% Test that prefixes have the appropriate amount of spaces added to them
            prefixes = { ...
                {'ALL',       '[ALL]       :: '}, ...
                {'TRACE',     '[TRACE]     :: '}, ...
                {'DEBUG',     '[DEBUG]     :: '}, ...
                {'INFO',      '[INFO]      :: '}, ...
                {'NOTICE',    '[NOTICE]    :: '}, ...
                {'WARNING',   '[WARNING]   :: '}, ...
                {'ERROR',     '[ERROR]     :: '}, ...
                {'CRITICAL',  '[CRITICAL]  :: '}, ...
                {'ALERT',     '[ALERT]     :: '}, ...
                {'EMERGENCY', '[EMERGENCY] :: '}, ...
            };

            for prefixIndex = 1:length(prefixes)
                testData = prefixes{prefixIndex};
                result = logging.Logger.formatLevelPrefix(testData{1});
                testCase.verifyEqual(result, testData{2});
            end
        end

        function TestNullLoggerConstructor(testCase)
        %% For good measure, let's just make sure that the NullLogger
        %% constructor creates the right thing
            testCase.verifyClass(testCase.logger, ?logging.NullLogger);
        end

        function TestDefaultLogLevel(testCase)
        %% Test the default log level of INFO
            testCase.verifyEqual(testCase.logger.logLevel, logging.LogLevel.INFO);
        end

        function TestSettingStringLogLevelInOptions(testCase)
        %% Test that initializing a new Logger with log level options sets
        %% the appropriate log level
            for l = 1:length(TestHelper.LOG_LEVELS)
                logLevel = TestHelper.LOG_LEVELS{l};
                testCase.verifyConstructorLogLevel(logLevel, logging.LogLevel.(logLevel));
            end
        end

        function TestSettingEnumLogLevelInOptions(testCase)
        %% Test that initializing a new Logger with log level options sets
        %% the appropriate log level
            for l = 1:length(TestHelper.LOG_LEVELS)
                levelEnum = logging.LogLevel.(TestHelper.LOG_LEVELS{l});
                testCase.verifyConstructorLogLevel(levelEnum, levelEnum);
            end
        end

        function TestInvalidLogLevelInOptionsThrowsError(testCase)
        %% Passing in an invalid log level into the Logger constructor should
        %% throw an error
            testCase.verifyError( ...
                @() logging.NullLogger(struct('logLevel', -1)), ...
                'logging:InvalidLogLevel' ...
            );
        end

        function TestSetLogLevelMethodString(testCase)
        %% Test setting string log levels using the setLogLevel method
            for l = 1:length(TestHelper.LOG_LEVELS)
                logLevel = TestHelper.LOG_LEVELS{l};
                testCase.verifySetLogLevel(logLevel, logging.LogLevel.(logLevel));
            end
        end

        function TestSetLogLevelMethodEnum(testCase)
        %% Test setting enum log levels using the setLogLevel method
            for l = 1:length(TestHelper.LOG_LEVELS)
                logLevel = logging.LogLevel.(TestHelper.LOG_LEVELS{l});
                testCase.verifySetLogLevel(logLevel, logLevel);
            end
        end

        function TestSetLogLevelMethodInvalidLogLevel(testCase)
        %% Passing in an invalid log level into the Logger constructor should
        %% throw an error
            testCase.verifyError(@() testCase.logger.setLogLevel(-1), 'logging:InvalidLogLevel');
        end

        function TestDefaultIncludeTimestamp(testCase)
        %% Timestamps are turned on by default
            testCase.verifyEqual(testCase.logger.includeTimestamp, true);
        end

        function TestSettingIncludeTimestampInOptions(testCase)
        %% Change includeTimestamp in options
            logger = logging.NullLogger(struct('includeTimestamp', true));
            testCase.verifyEqual(logger.includeTimestamp, true);

            logger = logging.NullLogger(struct('includeTimestamp', false));
            testCase.verifyEqual(logger.includeTimestamp, false);
        end

        function TestDefaultPrintStack(testCase)
        %% Printing the stack is off by default
            testCase.verifyEqual(testCase.logger.printStack, false);
        end

        function TestSettingPrintStackInOptions(testCase)
        %% Change printstack in options
            logger = logging.NullLogger(struct('printStack', true));
            testCase.verifyEqual(logger.printStack, true);

            logger = logging.NullLogger(struct('printStack', false));
            testCase.verifyEqual(logger.printStack, false);
        end

        function TestStackPrinting(testCase)
            function funcOne(logger)
                funcTwo(logger)
            end

            function funcTwo(logger)
                logger.emergency('Log message');
            end

            logger = logging.NullLogger(struct('printStack', true));
            funcOne(logger);
            testCase.verifySubstring( ...
                logger.log{1}, ...
                [ ...
                    'LoggerUnitTests.TestStackPrinting/funcOne > ' ...
                    'LoggerUnitTests.TestStackPrinting/funcTwo' ...
                ] ...
            );
        end

        %% Test various levels of logging
        function TestTraceLogging(testCase)
            testCase.testLoggingAtLevel('trace');
        end

        function TestDebugLogging(testCase)
            testCase.testLoggingAtLevel('debug');
        end

        function TestInfoLogging(testCase)
            testCase.testLoggingAtLevel('info');
        end

        function TestNoticeLogging(testCase)
            testCase.testLoggingAtLevel('notice');
        end

        function TestWarningLogging(testCase)
            testCase.testLoggingAtLevel('warning');
        end

        function TestErrorLogging(testCase)
            testCase.testLoggingAtLevel('error');
        end

        function TestCriticalLogging(testCase)
            testCase.testLoggingAtLevel('critical');
        end

        function TestAlertLogging(testCase)
            testCase.testLoggingAtLevel('alert');
        end

        function TestEmergencyLogging(testCase)
            testCase.verifyMessageIsLogged( ...
                'emergency', 'Emergency messages are always logged' ...
            );
        end
    end

    methods
        function verifyConstructorLogLevel(testCase, logLevelIn, logLevelOut);
        %% Verify setting log level via configuration option in constructor
            loggerOptions = struct('logLevel', logLevelIn);
            logger = logging.NullLogger(loggerOptions);
            testCase.verifyEqual(logger.logLevel, logLevelOut);
        end

        function verifySetLogLevel(testCase, logLevelIn, logLevelOut)
        %% Verify setting log level via setLogLevel method
            logger = testCase.getLoggerWithDifferentLogLevel(logLevelOut);
            logger.setLogLevel(logLevelIn);

            testCase.verifyEqual(logger.logLevel, logLevelOut);
        end

        function logger = getLoggerWithDifferentLogLevel(testCase, logLevel)
        %% Get a logger that does not have the same logging level as [logLevel]
            currentLogLevel = testCase.logger.logLevel;
            if currentLogLevel == logLevel
                logger = logging.NullLogger( ...
                    struct('logLevel', logging.LogLevel(logLevel + 1)) ...
                );
            else
                logger = testCase.logger;
            end
        end

        function testLoggingAtLevel(testCase, logLevel)
        %% Test logging at a certain level [logLevel]
            testCase.testLoggingAtLevelTest(logging.LogLevel.(upper(logLevel)), lower(logLevel));
        end

        function testLoggingAtLevelTest(testCase, logLevelEnum, logFunctionName)
        %% First test that logging at a certain level when the minimum log
        %% level is the level above [logLevelEnum] does not log, and that
        %% logging works when minimum log level is [logLevelEnum]
            testCase.logger.setLogLevel(logging.LogLevel(logLevelEnum + 1));
            testCase.verifyMessageIsNotLogged(logFunctionName, 'This won''t be logged');

            testCase.logger.setLogLevel(logLevelEnum);
            testCase.verifyMessageIsLogged(logFunctionName, 'This will be logged');
        end

        function verifyMessageIsNotLogged(testCase, logFunctionName, message)
            testCase.logger.(logFunctionName)(message);
            testCase.verifyLength(testCase.logger.log, 0);
        end

        function verifyMessageIsLogged(testCase, logFunctionName, message)
            testCase.logger.(logFunctionName)(message);
            testCase.verifyLength(testCase.logger.log, 1);
            testCase.verifySubstring(testCase.logger.log{1}, message);
        end
    end
end